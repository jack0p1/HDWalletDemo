//
//  WalletsViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import XCoordinator
import UIKit

class WalletsViewModel: NSObject {
    private let router: UnownedRouter<MainFlow>
    
    var wallets: [Wallet] {
        AccountManager.shared.allWallets
    }
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
    
    func createChildWallet(completion: @escaping () -> Void) {
        DataManager.shared.createChildWallet(completion: completion)
    }
    
    func routeToImportWallet() {
        router.trigger(.importWallet(isAddingChildWallet: true))
    }
}

extension WalletsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let wallet = wallets[safe: indexPath.row] else { return }
        router.trigger(.balance(wallet: wallet))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WalletsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        wallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletsTableViewCell.self), for: indexPath) as? WalletsTableViewCell,
              let wallet = wallets[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.title = wallet.name
        cell.address = wallet.address
        
        return cell
    }
}
