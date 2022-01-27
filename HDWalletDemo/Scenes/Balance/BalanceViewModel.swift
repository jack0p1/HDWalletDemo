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
    let router: UnownedRouter<MainFlow>
    
    var balance = PassthroughSubject<String, Never>()
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func getBalance() {
        guard let wallet = AccountManager.shared.wallet else { return }
        
        let retrieveBalance = {
            DataManager.shared.getBalance(for: wallet.address) { [weak self] in
                guard let balance = $0 else { return }
                DispatchQueue.main.async {
                    self?.balance.send(balance + " ETH")
                }
            }
        }
        
        if DataManager.shared.web3Instance == nil {
            DataManager.shared.initializeWeb3 {
                retrieveBalance()
            }
        } else {
            retrieveBalance()
        }
    }
}
