//
//  MainCoordinator.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 21/01/2022.
//

import Foundation
import XCoordinator

enum MainFlow: Route {
    case main
    case createWallet
    case mnemonicPhrase
}

class MainCoordinator: NavigationCoordinator<MainFlow> {
    init() {
        super.init(initialRoute: .main)
    }
    
    override func prepareTransition(for route: MainFlow) -> NavigationTransition {
        switch route {
        case .main:
            let viewController: MainViewController = MainViewController.instantiate()
            viewController.viewModel = MainViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .createWallet:
            let viewController: CreateWalletViewController = CreateWalletViewController.instantiate()
            viewController.viewModel = CreateWalletViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .mnemonicPhrase:
            let viewController: MnemonicPhraseViewController = MnemonicPhraseViewController.instantiate()
            viewController.viewModel = MnemonicPhraseViewModel(router: unownedRouter)
            return .push(viewController)
        }
    }
}
