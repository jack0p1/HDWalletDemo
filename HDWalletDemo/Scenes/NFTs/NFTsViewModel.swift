//
//  NFTsViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 09/02/2022.
//

import UIKit
import XCoordinator

class NFTsViewModel: NSObject {
    private let router: UnownedRouter<MainFlow>
    
    var nfts: [NFT] = []
    
    init(router: UnownedRouter<MainFlow>) {
        self.router = router
    }
}

extension NFTsViewModel: UITableViewDelegate {
    
}

extension NFTsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nftTableViewCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = nfts[safe: indexPath.row]?.name
        content.image = 
        cell.contentConfiguration = content
        return cell
    }
    
    
}
