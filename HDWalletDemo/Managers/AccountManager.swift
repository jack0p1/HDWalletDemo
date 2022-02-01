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
    private let passwordKey = "password"
    private let allWalletsKeys = "allWallets"
    private let keychain = KeychainSwift()
    
    private init() { }
    
    var allWallets: [Wallet] {
        get {
            guard let data = keychain.getData(allWalletsKeys),
                  let wallets = try? JSONDecoder().decode([Wallet].self, from: data) else { return [] }
            return wallets
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            if !keychain.set(data, forKey: allWalletsKeys) {
                print("Couldn't save all wallets.")
            }
        }
    }
    
    var wallet: Wallet? {
        get {
            guard let data = keychain.getData(walletKey) else { return nil }
            let wallet = try? JSONDecoder().decode(Wallet.self, from: data)
            return wallet
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            if !keychain.set(data, forKey: walletKey) {
                print("Couldn't save a wallet.")
            }
        }
    }
    
    var mnemonics: String? {
        get {
            return keychain.get(mnemonicsKey)
        }
        set {
            guard let mnemonics = newValue else { return }
            if !keychain.set(mnemonics, forKey: mnemonicsKey) {
                print("Couldn't save mnemonics.")
            }
        }
    }
    
    var password: String? {
        get {
            return keychain.get(passwordKey)
        }
        set {
            guard let password = newValue else { return }
            if !keychain.set(password, forKey: passwordKey) {
                print("Couldn't save a password.")
            }
        }
    }
}
