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
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func sendBalance(to destination: String, amount: String, completion: @escaping () -> Void) {
        
    }
}
