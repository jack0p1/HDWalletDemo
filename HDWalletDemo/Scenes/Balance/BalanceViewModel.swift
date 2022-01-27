//
//  BalanceViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import Foundation
import XCoordinator

class BalanceViewModel {
    let router: UnownedRouter<MainFlow>
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
}
