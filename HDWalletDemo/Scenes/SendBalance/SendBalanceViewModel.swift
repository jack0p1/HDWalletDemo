//
//  SendBalanceViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import Foundation
import XCoordinator

class SendBalanceViewModel {
    private let router: UnownedRouter<MainFlow>
    
    let wallet: Wallet
    
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func sendBalance(to destination: String, amount: String, completion: @escaping () -> Void) {
        DataManager.shared.sendEth(from: wallet, to: destination, amount: amount, completion: completion)
    }
    
    func routeBack() {
        router.trigger(.back)
    }
}
