//
//  Wallet.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 26/01/2022.
//

import Foundation

struct Wallet: Codable {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
    let isImported: Bool
}
