//
//  AccountManager.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import Foundation
import KeychainSwift

class AccountManager {
    static let shared = AccountManager()
    
    private let walletKey = "wallet"
    private let mnemonicsKey = "mnemonics"
    private let keychain = KeychainSwift()
    
    private init() { }
    
    var wallet: Wallet? {
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
    
    var mnemonics: String? {
        get {
            return keychain.get(mnemonicsKey)
        }
        set {
            guard let mnemonics = newValue else { return }
            keychain.set(mnemonics, forKey: mnemonicsKey)
        }
    }
}
