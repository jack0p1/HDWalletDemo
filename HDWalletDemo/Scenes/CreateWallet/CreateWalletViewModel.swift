//
//  CreateWalletViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 25/01/2022.
//

import Foundation
import XCoordinator

class CreateWalletViewModel {
    private let router: UnownedRouter<MainFlow>
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func createAccount(with password: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .utility).async {
            DataManager.shared.createAccount(password: password) {
                DispatchQueue.main.async {
                    completion()
                    self.routeToMnemonicPhrase()
                }
            }
        }
    }
    
    private func routeToMnemonicPhrase() {
        router.trigger(.mnemonicPhrase)
    }
}
