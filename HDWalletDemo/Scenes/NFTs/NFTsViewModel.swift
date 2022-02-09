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
        nfts.isEmpty ? 1 : nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nftTableViewCell", for: indexPath)
        
        guard var nft = nfts[safe: indexPath.row] else {
            return cell
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = nft.name
        
        if let image = nft.image {
            content.image = image
        } else {
            DispatchQueue.global(qos: .utility).async {
                if let data = try? Data(contentsOf: nft.imageUrl) {
                    DispatchQueue.main.async {
                        let nftImage = UIImage(data: data)
                        content.image = nftImage
                        nft.image = nftImage
                    }
                }
            }
        }
        
        cell.contentConfiguration = content
        return cell
    }
}
