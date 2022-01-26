//
//  MainViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 21/01/2022.
//

import Foundation
import XCoordinator

class MainViewModel {
    private let router: UnownedRouter<MainFlow>
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func routeToCreateWallet() {
        router.trigger(.createWallet)
    }
}
