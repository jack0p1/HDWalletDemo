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
    let isAddingChildWallet: Bool
    
    init(router: UnownedRouter<MainFlow>, isAddingChildWallet: Bool) {
        self.router = router
        self.isAddingChildWallet = isAddingChildWallet
    }
    
    func importWallet(password: String, phrase: String, completion: @escaping () -> Void) {
        DataManager.shared.importWallet(password: password, phrase: phrase, completion: completion)
    }
    
    func importChildWallet(privateKey: String, completion: @escaping () -> Void) {
        DataManager.shared.importWalletAccount(privateKey: privateKey, completion: completion)
    }
    
    func routeToWallets() {
        router.trigger(.wallets)
    }
    
    func routeBack() {
        router.trigger(.back)
    }
}
