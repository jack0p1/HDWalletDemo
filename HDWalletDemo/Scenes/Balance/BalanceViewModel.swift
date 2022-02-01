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
    var balance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func getBalance() {
        DataManager.shared.getBalance(for: wallet.address) { [weak self] in
            guard let balance = $0 else { return }
            self?.balance.send("Ethereum (ETH): " + balance)
        }
    }
    
    func routeToSendBalance() {
        router.trigger(.sendBalance(wallet: wallet))
    }
}
