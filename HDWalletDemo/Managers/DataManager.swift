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
    
    func getBalance(completion: @escaping (String?) -> Void) {
        guard let wallet = AccountManager.shared.wallet,
              let address = EthereumAddress(wallet.address) else { return }
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let retrieveBalance = {
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
            
            if self?.web3Instance == nil {
                self?.initializeWeb3 {
                    retrieveBalance()
                }
            } else {
                retrieveBalance()
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
            let name = "HD Wallet"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
            
            AccountManager.shared.wallet = wallet
            AccountManager.shared.mnemonics = mnemonics
            AccountManager.shared.password = password
            
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
            let name = "HD Wallet"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
            
            AccountManager.shared.mnemonics = phrase
            AccountManager.shared.wallet = wallet
            AccountManager.shared.password = password
            
            let keystoreManager = KeystoreManager([keystore])
            self?.web3Instance?.addKeystoreManager(keystoreManager)
            group.leave()
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
