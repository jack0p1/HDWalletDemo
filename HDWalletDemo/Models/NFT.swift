//
//  NFT.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 09/02/2022.
//

import UIKit

struct NFT {
    let contractAddress: String
    let tokenId: String
    let name: String
    let imageUrl: URL
    
    var image: UIImage?
}
