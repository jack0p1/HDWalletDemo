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
    var ethBalance = PassthroughSubject<String, Never>()
    var chainLinkBalance = PassthroughSubject<String, Never>()
    var balanceLoaded = PassthroughSubject<Void, Never>()
    
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
        DataManager.shared.getTokenBalance(for: wallet.address, token: TokenContract.chainLink) { [weak self] in
            self?.chainLinkBalance.send("ChainLink (LINK): " + ($0 ?? "-"))
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
