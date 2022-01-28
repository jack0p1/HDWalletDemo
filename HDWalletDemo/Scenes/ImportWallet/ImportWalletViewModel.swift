//
//  ImportWalletViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import Foundation
import XCoordinator

class ImportWalletViewModel {
    private let router: UnownedRouter<MainFlow>
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        DataManager.shared.importWallet(password: password, phrase: phrase, completion: completion)
    }
    
    func routeToWallets() {
        router.trigger(.wallets)
    }
}
