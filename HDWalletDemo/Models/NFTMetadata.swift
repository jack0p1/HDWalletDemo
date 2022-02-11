//
//  NFTMetadata.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 11/02/2022.
//

import Foundation

struct NFTMetadata: Codable, Equatable {
    let name: String
    let image: URL
}
