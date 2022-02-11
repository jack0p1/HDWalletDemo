//
//  DataManager.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 26/01/2022.
//

import web3swift
import KeychainSwift
import BigInt
import UIKit
import Alamofire

enum TokenStandard {
    case erc721, erc1155
    
    var interfaceId: String {
        switch self {
        case .erc721:
            return "0x80ac58cd"
        case .erc1155:
            return "0xd9b67a26"
        }
    }
}

class DataManager {
    static let shared = DataManager()
        
    let keychain = KeychainSwift()
    var web3RopstenInstance: web3?
    var web3RinkebyInstance: web3?
    
    private init() { }
    
    // MARK: - Public methods
    func createWallet(with password: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
        
        let create = {
            self._createWallet(with: password, completion: completion)
        }
        
        if web3RopstenInstance == nil {
            initializeWeb3 {
                create()
            }
        } else {
            create()
        }
    }
    
    func importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
        
        let retrieveWallet = {
            self._importWallet(password: password, phrase: phrase, completion: completion)
        }
        
        if web3RopstenInstance == nil {
            initializeWeb3 {
                retrieveWallet()
            }
        } else {
            retrieveWallet()
        }
    }
    
    func getEthBalance(for address: String, completion: @escaping (String?) -> Void) {
        guard let address = EthereumAddress(address) else { return }
        
        let retrieveBalance = {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let web3RopstenInstance = self?.web3RopstenInstance else { return }
                var balanceBigUInt: BigUInt?
                do {
                    balanceBigUInt = try web3RopstenInstance.eth.getBalance(address: address)
                } catch {
                    if let error = error as? Web3Error {
                        print(error.errorDescription)
                    }
                }

                DispatchQueue.main.async {
                    if balanceBigUInt != nil {
                        completion(Web3.Utils.formatToEthereumUnits(balanceBigUInt!, toUnits: .eth, decimals: 4)!)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        
        if web3RopstenInstance == nil {
            initializeWeb3 {
                retrieveBalance()
            }
        } else {
            retrieveBalance()
        }
    }
    
    func getTokenBalance(for address: String, tokenContract: TokenContract, completion: @escaping (Double?, String?, String?) -> Void) {
        guard let walletAddress = EthereumAddress(address),
              let exploredAddress = EthereumAddress(address),
              let erc20ContractAddress = EthereumAddress(tokenContract.address) else { return }
        
        let web3Instance = tokenContract.network == .ropsten ? self.web3RopstenInstance : self.web3RinkebyInstance
        
        let retrieveBalance = {
            DispatchQueue.global(qos: .utility).async {
                guard let web3Instance = web3Instance else { return }
                let contract = web3Instance.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
                var options = TransactionOptions.defaultOptions
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                let method = "balanceOf"
                let tx = contract.read(
                    method,
                    parameters: [exploredAddress] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)!
                
                var balanceBigUInt: BigUInt?
                do {
                    let tokenBalance = try tx.call()
                    balanceBigUInt = tokenBalance["0"] as? BigUInt
                } catch {
                    if let error = error as? Web3Error {
                        print(error.errorDescription)
                    }
                }
                
                let tokenData = ERC20(web3: web3Instance, provider: web3Instance.provider, address: erc20ContractAddress)
                let decimals = tokenData.decimals
                let name = tokenData.name
                let symbol = tokenData.symbol
                
                DispatchQueue.main.async {
                    if balanceBigUInt != nil {
                        let denominator = pow(10, Double(decimals))
                        let balance = Double(balanceBigUInt!) / denominator
                        completion(balance, name, symbol)
                    } else {
                        completion(nil, nil, nil)
                    }
                }
            }
        }
        
        if web3Instance == nil {
            initializeWeb3 {
                retrieveBalance()
            }
        } else {
            retrieveBalance()
        }
    }
    
    func importWalletAccount(privateKey: String, completion: @escaping () -> Void) {
        guard let password = AccountManager.shared.password else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            let dataKey = Data.fromHex(formattedKey)!
            let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
            let name = "Wallet \(AccountManager.shared.allWallets.count + 1) (imported)"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: false, isImported: true)
            
            AccountManager.shared.allWallets.append(wallet)
            
            let keystoreManager = KeystoreManager([keystore])
            self?.web3RopstenInstance?.addKeystoreManager(keystoreManager)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func createChildWallet(completion: @escaping () -> Void) {
        guard let password = AccountManager.shared.password,
              let wallet = AccountManager.shared.wallet else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let keystore = BIP32Keystore(wallet.data)!
                try keystore.createNewChildAccount(password: password)
                let keyData = try JSONEncoder().encode(keystore.keystoreParams)
                let updatedWallet = Wallet(address: wallet.address, data: keyData, name: wallet.name, isHD: wallet.isHD, isImported: wallet.isImported)
                
                AccountManager.shared.wallet = updatedWallet
                
                let keystoreManager = KeystoreManager([keystore])
                self?.web3RopstenInstance?.addKeystoreManager(keystoreManager)
                
                let newWalletAddress = keystore.paths["m/44\'/60\'/0\'/0/\((keystore.addresses?.count ?? 1) - 1)"]!.address
                let name = "Wallet \(AccountManager.shared.allWallets.count + 1)"
                let newChildWallet = Wallet(address: newWalletAddress, data: keyData, name: name, isHD: false, isImported: false)
                AccountManager.shared.allWallets.append(newChildWallet)
            } catch {
                if let error = error as? Web3Error {
                    print(error.errorDescription)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func sendEthBalance(from wallet: Wallet, to destination: String, amount: String, completion: @escaping () -> Void) {
        guard let password = AccountManager.shared.password else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let keystoreManager: KeystoreManager
            if wallet.isImported {
                let keystore = EthereumKeystoreV3(wallet.data)!
                keystoreManager = KeystoreManager([keystore])
            } else {
                let keystore = BIP32Keystore(wallet.data)!
                keystoreManager = KeystoreManager([keystore])
            }
            self?.web3RopstenInstance?.addKeystoreManager(keystoreManager)
            
            let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
            let toAddress = EthereumAddress(destination)!
            let contract = self?.web3RopstenInstance?.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
            let amount = Web3.Utils.parseToBigUInt(amount, units: .eth)
            var options = TransactionOptions.defaultOptions
            options.value = amount
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let tx = contract?.write(
                "fallback",
                parameters: [AnyObject](),
                extraData: Data(),
                transactionOptions: options)!
            
            do {
                let _ = try tx?.send(password: password)
            } catch {
                if let error = error as? Web3Error {
                    print(error.errorDescription)
                }
                return
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func sendTokenBalance(from wallet: Wallet, to destination: String, amount: String, tokenContract: TokenContract, completion: @escaping () -> Void) {
        guard let walletAddress = EthereumAddress(wallet.address),
              let toAddress = EthereumAddress(destination),
              let erc20ContractAddress = EthereumAddress(tokenContract.address),
              let password = AccountManager.shared.password else { return }
        
        let web3Instance = tokenContract.network == .ropsten ? self.web3RopstenInstance : self.web3RinkebyInstance
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let web3Instance = web3Instance else { return }
            
            let keystoreManager: KeystoreManager
            if wallet.isImported {
                let keystore = EthereumKeystoreV3(wallet.data)!
                keystoreManager = KeystoreManager([keystore])
            } else {
                let keystore = BIP32Keystore(wallet.data)!
                keystoreManager = KeystoreManager([keystore])
            }
            web3Instance.addKeystoreManager(keystoreManager)
            
            let tokenData = ERC20(web3: web3Instance, provider: web3Instance.provider, address: erc20ContractAddress)
            
            let contract = web3Instance.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
            let value = (Double(amount) ?? 0) * pow(10, Double(tokenData.decimals))
            var options = TransactionOptions.defaultOptions
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let method = "transfer"
            let tx = contract.write(
                method,
                parameters: [toAddress, value] as [AnyObject],
                extraData: Data(),
                transactionOptions: options)!
            
            do {
                let _ = try tx.send(password: password)
            } catch {
                if let error = error as? Web3Error {
                    print(error.errorDescription)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func importNFT(owner wallet: Wallet, contractAddress: String, tokenID: String, completion: @escaping () -> Void) {
        guard let web3 = web3RinkebyInstance,
              let contractAddress = EthereumAddress(contractAddress) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let tokenStandard = self.getTokenStandard(for: contractAddress) else { return }
                                    
            let abi = tokenStandard == .erc721 ? Web3.Utils.erc721ABI : ABI.erc1155ABI
            let contract = web3.contract(abi, at: contractAddress)!
            let method = tokenStandard == .erc721 ? "tokenURI" : "uri"
            let tokenId = BigUInt(stringLiteral: tokenID)
            var metadataUrlString: String
            do {
                let transactionOptions = TransactionOptions.defaultOptions
                let result = try contract.read(method, parameters: [tokenId] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call()
                guard let res = result["0"] as? String else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
                metadataUrlString = res
            } catch {
                if let error = error as? Web3Error {
                    print(error.errorDescription)
                }
                completion()
                return
            }
            

            self.getNFTMetadata(from: metadataUrlString, tokenId: tokenID) {
                if let metadata = $0 {
                    if !AccountManager.shared.nfts.contains(metadata) {
                        AccountManager.shared.nfts.append(metadata)
                    }
                }
                completion()
            }
        }
    }
    
    // MARK: - Private methods
    private func getNFTMetadata(from metadataUrlString: String, tokenId: String, completion: @escaping (NFTMetadata?) -> Void) {
        var urlString = metadataUrlString.replacingOccurrences(of: "0x{id}", with: tokenId)
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.scheme = "https"
        if let string = urlComponents?.string {
            urlString = string
        }
        
        AF.request(urlString).responseDecodable(of: NFTMetadata.self) { response in
            completion(response.value)
        }
    }
    
    private func getTokenStandard(for contractAddress: EthereumAddress) -> TokenStandard? {
        guard let web3 = web3RinkebyInstance else { return nil }
        let contract = web3.contract(ABI.erc165ABI, at: contractAddress)!
        let transactionOptions = TransactionOptions.defaultOptions
        
        do {
            let erc721Result = try contract.read("supportsInterface", parameters: [TokenStandard.erc721.interfaceId] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call()
            guard let supportsERC721 = erc721Result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
            
            let erc1155Result = try contract.read("supportsInterface", parameters: [TokenStandard.erc1155.interfaceId] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call()
            guard let supportsERC1155 = erc1155Result["0"] as? Bool else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
            
            if supportsERC721 {
                return TokenStandard.erc721
            } else if supportsERC1155 {
                return TokenStandard.erc1155
            } else {
                return nil
            }
        } catch {
            if let error = error as? Web3Error {
                print(error.errorDescription)
            }
            return nil
        }
    }
    
    private func initializeWeb3(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if self.web3RopstenInstance == nil {
                self.web3RopstenInstance = web3(provider: Web3HttpProvider(URL(string: Constants.ropstenEndpoint)!)!)
            }
            
            if self.web3RinkebyInstance == nil {
                self.web3RinkebyInstance = web3(provider: Web3HttpProvider(URL(string: Constants.rinkebyEndpoint)!)!)
            }

            completion()
        }
    }
    
    private func _createWallet(with password: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let bitsOfEntropy: Int = 256 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
            let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
            let keystore = try! BIP32Keystore(
                mnemonics: mnemonics,
                password: password,
                mnemonicsPassword: "",
                language: .english)!
            let name = "Wallet 1"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: true, isImported: false)
            
            AccountManager.shared.wallet = wallet
            AccountManager.shared.mnemonics = mnemonics
            AccountManager.shared.password = password
            AccountManager.shared.allWallets = [wallet]
            
            let keystoreManager = KeystoreManager([keystore])
            self?.web3RopstenInstance?.addKeystoreManager(keystoreManager)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func _importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let keystore = try! BIP32Keystore(
                mnemonics: phrase,
                password: password,
                mnemonicsPassword: "",
                language: .english)!
            let name = "Wallet 1"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: true, isImported: false)
            
            AccountManager.shared.mnemonics = phrase
            AccountManager.shared.wallet = wallet
            AccountManager.shared.password = password
            AccountManager.shared.allWallets = [wallet]
            
            let keystoreManager = KeystoreManager([keystore])
            self?.web3RopstenInstance?.addKeystoreManager(keystoreManager)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
