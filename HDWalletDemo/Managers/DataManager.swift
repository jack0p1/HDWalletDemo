//
//  DataManager.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 26/01/2022.
//

import Foundation
import web3swift
import KeychainSwift
import BigInt

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
                
                let group = DispatchGroup()
                group.enter()
                
                var balanceBigUInt: BigUInt?
                do {
                    balanceBigUInt = try web3RopstenInstance.eth.getBalance(address: address)
                } catch {
                    print(error.localizedDescription)
                }
                
                group.leave()
                
                group.notify(queue: .main) {
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
    
    func getTokenBalance(for address: String, token: TokenContract, completion: @escaping (Double?, String?, String?) -> Void) {
        guard let walletAddress = EthereumAddress(address),
              let exploredAddress = EthereumAddress(address),
              let erc20ContractAddress = EthereumAddress(token.contractAddress) else { return }
        
        let web3Instance = token.network == .ropsten ? self.web3RopstenInstance : self.web3RinkebyInstance
        
        let retrieveBalance = {
            DispatchQueue.global(qos: .utility).async {
                guard let web3Instance = web3Instance else { return }
                
                let group = DispatchGroup()
                group.enter()
                
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
                    print(error.localizedDescription)
                }
                
                let tokenData = ERC20(web3: web3Instance, provider: web3Instance.provider, address: erc20ContractAddress)
                
                group.leave()
                
                group.notify(queue: .main) {
                    if balanceBigUInt != nil {
                        let denominator = pow(10, Double(tokenData.decimals))
                        let balance = Double(balanceBigUInt!) / denominator
                        completion(balance, tokenData.name, tokenData.symbol)
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
            let group = DispatchGroup()
            group.enter()
            
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
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    func createChildWallet(completion: @escaping () -> Void) {
        guard let password = AccountManager.shared.password,
              let wallet = AccountManager.shared.wallet else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            
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
                print(error.localizedDescription)
            }
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    func sendEth(from wallet: Wallet, to destination: String, amount: String, completion: @escaping () -> Void) {
        guard let password = AccountManager.shared.password else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            
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
                print(error.localizedDescription)
            }
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    // MARK: - Private methods
    private func initializeWeb3(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let group = DispatchGroup()
            group.enter()
            
            if self.web3RopstenInstance == nil {
                self.web3RopstenInstance = web3(provider: Web3HttpProvider(URL(string: Constants.ropstenEndpoint)!)!)
            }
            
            if self.web3RinkebyInstance == nil {
                self.web3RinkebyInstance = web3(provider: Web3HttpProvider(URL(string: Constants.rinkebyEndpoint)!)!)
            }
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    private func _createWallet(with password: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            
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
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    private func _importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            
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
            
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
