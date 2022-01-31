//
//  DataManager.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 26/01/2022.
//

import Foundation
import web3swift
import KeychainSwift

class DataManager {
    static let shared = DataManager()
        
    let keychain = KeychainSwift()
    var web3Instance: web3?
    
    private init() { }
    
    // MARK: - Public methods
    func createWallet(with password: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
        
        let create = {
            self._createWallet(with: password, completion: completion)
        }
        
        if web3Instance == nil {
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
        
        if web3Instance == nil {
            initializeWeb3 {
                retrieveWallet()
            }
        } else {
            retrieveWallet()
        }
    }
    
    func getBalance(for address: String, completion: @escaping (String?) -> Void) {
            let retrieveBalance = {
                self._getBalance(address: address, completion: completion)
            }
            
            if web3Instance == nil {
                initializeWeb3 {
                    retrieveBalance()
                }
            } else {
                retrieveBalance()
            }
    }
    
    func importChildWallet(privateKey: String, completion: @escaping () -> Void) {
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
            self?.web3Instance?.addKeystoreManager(keystoreManager)
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
                let keystore = BIP32Keystore(wallet.data!)!
                try keystore.createNewChildAccount(password: password)
                let keyData = try JSONEncoder().encode(keystore.keystoreParams)
                let updatedWallet = Wallet(address: wallet.address, data: keyData, name: wallet.name, isHD: wallet.isHD, isImported: wallet.isImported)
                
                AccountManager.shared.wallet = updatedWallet
                
                let keystoreManager = KeystoreManager([keystore])
                self?.web3Instance?.addKeystoreManager(keystoreManager)
                
                let newWalletAddress = keystore.paths["m/44\'/60\'/0\'/0/\((keystore.addresses?.count ?? 1) - 1)"]!.address
                let name = "Wallet \(AccountManager.shared.allWallets.count + 1)"
                let newChildWallet = Wallet(address: newWalletAddress, data: nil, name: name, isHD: false, isImported: false)
                AccountManager.shared.allWallets.append(newChildWallet)
            } catch(let error) {
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
            let group = DispatchGroup()
            group.enter()
            self?.web3Instance = web3(provider: Web3HttpProvider(URL(string: Constants.ropstenEndpoint)!)!)
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
            self?.web3Instance?.addKeystoreManager(keystoreManager)
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
            self?.web3Instance?.addKeystoreManager(keystoreManager)
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    private func _getBalance(address: String, completion: @escaping (String?) -> Void) {
        guard let address = EthereumAddress(address) else { return }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let group = DispatchGroup()
            group.enter()
            let balanceResult = try? self?.web3Instance?.eth.getBalance(address: address)
            group.leave()
            
            group.notify(queue: .main) {
                if balanceResult != nil {
                    completion(Web3.Utils.formatToEthereumUnits(balanceResult!, toUnits: .eth, decimals: 3))
                } else {
                    completion(nil)
                }
            }
        }
    }
}
