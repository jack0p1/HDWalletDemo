//
//  BalanceViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import Foundation
import XCoordinator
import web3swift
import Combine

class BalanceViewModel {
    private let router: UnownedRouter<MainFlow>
    
    let wallet: Wallet
    var balanceLoaded = PassthroughSubject<Void, Never>()
    var ethBalance = PassthroughSubject<String, Never>()
    var chainLinkBalance = PassthroughSubject<String, Never>()
    var gibboTokenBalance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func getBalance() {
        let group = DispatchGroup()
        group.enter()
        DataManager.shared.getEthBalance(for: wallet.address) { [weak self] in
            self?.ethBalance.send("Ethereum (ETH): " + ($0 ?? "-"))
            group.leave()
        }
        
        group.enter()
        DataManager.shared.getTokenBalance(for: wallet.address, token: TokenContract.chainLink) { [weak self] balance, name, symbol in
            if let balance = balance, let name = name, let symbol = symbol {
                self?.chainLinkBalance.send("\(name) (\(symbol)): \(balance)")
            }
            group.leave()
        }
        
        group.enter()
        DataManager.shared.getTokenBalance(for: wallet.address, token: TokenContract.gibboToken) { [weak self] balance, name, symbol in
            if let balance = balance, let name = name, let symbol = symbol {
                self?.gibboTokenBalance.send("\(name) (\(symbol)): \(balance)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.balanceLoaded.send()
        }
    }
    
    func routeToSendBalance() {
        router.trigger(.sendBalance(wallet: wallet))
    }
}
