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
    private let address: String
    
    let walletName: String
    var balance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>, address: String, walletName: String) {
        self.router = router
        self.address = address
        self.walletName = walletName
    }
    
    func getBalance() {
        DataManager.shared.getBalance(for: address) { [weak self] in
            guard let balance = $0 else { return }
            self?.balance.send("Ethereum (ETH): " + balance)
        }
    }
    
    func routeToSendBalance() {
        router.trigger(.sendBalance)
    }
}
