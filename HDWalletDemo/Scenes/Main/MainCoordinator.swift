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
        }
    }
}
