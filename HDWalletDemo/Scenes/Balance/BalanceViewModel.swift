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
    
    var balance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>, address: String) {
        self.router = router
        self.address = address
    }
    
    func getBalance() {
        DataManager.shared.getBalance(for: address) { [weak self] in
            guard let balance = $0 else { return }
            DispatchQueue.main.async {
                self?.balance.send(balance + " ETH")
            }
        }
    }
    
    func routeToSendBalance() {
        router.trigger(.sendBalance)
    }
}
