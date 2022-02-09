//
//  MnemonicPhraseViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import Foundation
import XCoordinator

class MnemonicPhraseViewModel {
    private let router: UnownedRouter<MainFlow>
    
    var mnemonics: String? {
        AccountManager.shared.mnemonics
    }
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func routeToWallets() {
        router.trigger(.wallets)
    }
}
