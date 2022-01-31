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
    case importWallet(isAddingChildWallet: Bool)
    case mnemonicPhrase
    case balance(address: String)
    case sendBalance
    case wallets
    case back
}

class MainCoordinator: NavigationCoordinator<MainFlow> {
    init() {
        let initialRoute: MainFlow = (AccountManager.shared.wallet != nil && AccountManager.shared.mnemonics != nil) ? .wallets : .start
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
            
        case .importWallet(let isChild):
            let viewController: ImportWalletViewController = ImportWalletViewController.instantiate()
            viewController.viewModel = ImportWalletViewModel(router: unownedRouter, isAddingChildWallet: isChild)
            return .push(viewController)
            
        case .mnemonicPhrase:
            let viewController: MnemonicPhraseViewController = MnemonicPhraseViewController.instantiate()
            viewController.viewModel = MnemonicPhraseViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .balance(let address):
            let viewController: BalanceViewController = BalanceViewController.instantiate()
            viewController.viewModel = BalanceViewModel(router: unownedRouter, address: address)
            return .present(viewController)
            
        case .sendBalance:
            let viewController: SendBalanceViewController = SendBalanceViewController.instantiate()
            viewController.viewModel = SendBalanceViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .wallets:
            let viewController: WalletsViewController = WalletsViewController.instantiate()
            viewController.viewModel = WalletsViewModel(router: unownedRouter)
            return .push(viewController)
            
        case .back:
            return .pop()
        }
    }
}
