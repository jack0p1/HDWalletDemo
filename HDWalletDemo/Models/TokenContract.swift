//
//  TokenContract.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 01/02/2022.
//

import Foundation

enum TokenNetwork {
    case ropsten, rinkeby
}

enum TokenContract {
    case chainLink
    
    var chainId: Int {
        switch self {
        case .chainLink:
            return 4
        }
    }
    
    var contractAddress: String {
        switch self {
        case .chainLink:
            return "0x01BE23585060835E02B77ef475b0Cc51aA1e0709"
        }
    }
    
    var name: String {
        switch self {
        case .chainLink:
            return "ChainLink Token"
        }
    }
    
    var symbol: String {
        switch self {
        case .chainLink:
            return "LINK"
        }
    }
    
    var decimals: Int {
        switch self {
        case .chainLink:
            return 18
        }
    }
    
    var network: TokenNetwork {
        switch self {
        case .chainLink:
            return .rinkeby
        }
    }
}
