//
//  MainCoordinator.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 21/01/2022.
//

import Foundation
import XCoordinator

enum MainFlow: Route {
    case start
    case createWallet
    case mnemonicPhrase
    case balance
}

class MainCoordinator: NavigationCoordinator<MainFlow> {
    init() {
        let initialRoute: MainFlow = (DataManager.shared.wallet != nil && DataManager.shared.mnemonics != nil) ? .balance : .start
        super.init(initialRoute: initialRoute)
    }
    
    override func prepareTransition(for route: MainFlow) -> NavigationTransition {
        switch route {
        case .start:
            let viewController: StartViewController = StartViewController.instantiate()
            viewController.viewModel = StartViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .createWallet:
            let viewController: CreateWalletViewController = CreateWalletViewController.instantiate()
            viewController.viewModel = CreateWalletViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .mnemonicPhrase:
            let viewController: MnemonicPhraseViewController = MnemonicPhraseViewController.instantiate()
            viewController.viewModel = MnemonicPhraseViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .balance:
            let viewController: BalanceViewController = BalanceViewController.instantiate()
            viewController.viewModel = BalanceViewModel(router: unownedRouter)
            return .push(viewController)
        }
    }
}
