//
//  ImportNFTViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 09/02/2022.
//

import Foundation
import XCoordinator
import web3swift

class ImportNFTViewModel {
    private let router: UnownedRouter<MainFlow>
    private let wallet: Wallet
    
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func importNFT(contractAddress: String, tokenID: String, completion: @escaping (Web3Error?) -> Void) {
        DataManager.shared.importNFT(owner: wallet, contractAddress: contractAddress, tokenID: tokenID, completion: completion)
    }
    
    func routeBack() {
        router.trigger(.back)
    }
}
