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
    
    func initializeWeb3(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            self.web3Instance = web3(provider: Web3HttpProvider(URL(string: Constants.ropstenEndpoint)!)!)
            completion()
        }
    }
    
    // MARK: - Public methods
    func createWallet(password: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
        
        let create = {
            self.createWallet(with: password)
        }
        
        if web3Instance == nil {
            initializeWeb3 {
                create()
            }
        } else {
            create()
        }
        
        completion()
    }
    
    func importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
        
        let retrieveWallet = {
            self.importWallet(password: password, phrase: phrase)
        }
        
        if web3Instance == nil {
            initializeWeb3 {
                retrieveWallet()
            }
        } else {
            retrieveWallet()
        }
        
        completion()
    }
    
    func getBalance(completion: @escaping (String?) -> Void) {
        guard let wallet = AccountManager.shared.wallet,
              let address = EthereumAddress(wallet.address) else { return }
        
        let retrieveBalance = {
            if let balanceResult = try? self.web3Instance?.eth.getBalance(address: address) {
                completion(Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3))
            } else {
                completion(nil)
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
    
    // MARK: - Private methods
    private func createWallet(with password: String) {
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
        web3Instance?.addKeystoreManager(keystoreManager)
    }
    
    private func importWallet(password: String, phrase: String) {
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
        web3Instance?.addKeystoreManager(keystoreManager)
    }
}
