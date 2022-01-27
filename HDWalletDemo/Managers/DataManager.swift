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
    
    let keychain: KeychainSwift = KeychainSwift()
    let walletKey = "wallet"
    let mnemonicsKey = "mnemonics"
    
    private(set) var wallet: Wallet? {
        get {
            guard let data = keychain.getData(walletKey) else { return nil }
            let wallet = try? JSONDecoder().decode(Wallet.self, from: data)
            return wallet
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            keychain.set(data, forKey: walletKey)
        }
    }
    
    private(set) var mnemonics: String? {
        get {
            return keychain.get(mnemonicsKey)
        }
        set {
            guard let mnemonics = newValue else { return }
            keychain.set(mnemonics, forKey: mnemonicsKey)
        }
    }
    
    private init() { }
    
    func createAccount(password: String) {
        guard self.wallet == nil else { return }
        let bitsOfEntropy: Int = 256 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
        let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
        let keystore = try! BIP32Keystore(
            mnemonics: mnemonics,
            password: password,
            mnemonicsPassword: "",
            language: .english)!
        let name = "HD Wallet 1"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
        self.wallet = wallet
        
        initializeWeb3()
    }
    
    private func initializeWeb3() {
        guard let wallet = self.wallet else { return }
        let data = wallet.data
        let keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        let endpoint = Constants.ropstenEndpoint
        let web3 = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
        web3.addKeystoreManager(keystoreManager)
    }
    
    private func saveWallet() {
        
    }
}
