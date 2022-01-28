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
    
    var balance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func getBalance() {
        DataManager.shared.getBalance() { [weak self] in
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
