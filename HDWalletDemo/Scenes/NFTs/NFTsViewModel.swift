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
    private let wallet: Wallet
    
    var nfts: [NFT] {
        get {
            AccountManager.shared.nfts.map {
                NFT(name: $0.name, imageUrl: $0.image, image: nil)
            }
        } set {
            
        }
    }
    
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func routeToImportNFT() {
        router.trigger(.importNft(wallet: wallet))
    }
}

extension NFTsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nfts.isEmpty ? 1 : nfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NFTTableViewCell.self), for: indexPath) as? NFTTableViewCell else {
            return UITableViewCell()
        }
        guard var nft = nfts[safe: indexPath.row] else {
            return cell
        }
        
        cell.title = nft.name
        
        if let image = nft.image {
            cell.image = image
        } else {
            DispatchQueue.global(qos: .utility).async {
                var imageUrl = nft.imageUrl
                var urlComponents = URLComponents(url: imageUrl, resolvingAgainstBaseURL: false)
                urlComponents?.scheme = "https"
                if let url = urlComponents?.url {
                    imageUrl = url
                }
                
                if let data = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        let nftImage = UIImage(data: data)
                        cell.image = nftImage
                        nft.image = nftImage
                        self.nfts[indexPath.row] = nft
                    }
                }
            }
        }
        
        return cell
    }
}
