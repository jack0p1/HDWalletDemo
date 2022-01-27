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
    
    func initializeWeb3(completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            self.web3Instance = web3(provider: Web3HttpProvider(URL(string: Constants.ropstenEndpoint)!)!)
            completion?()
        }
    }
    
    func createAccount(password: String, completion: @escaping () -> Void) {
        guard AccountManager.shared.wallet == nil else { return }
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
        AccountManager.shared.wallet = wallet
        AccountManager.shared.mnemonics = mnemonics
        
        let keystoreManager = KeystoreManager([keystore])
        web3Instance?.addKeystoreManager(keystoreManager)
        
        completion()
    }
    
    func getBalance(for address: String, completion: @escaping (String?) -> Void) {
        guard let address = EthereumAddress(address) else { return }
        
        if let balanceResult = try? web3Instance?.eth.getBalance(address: address) {
            completion(Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3))
        } else {
            completion(nil)
        }
    }
}
