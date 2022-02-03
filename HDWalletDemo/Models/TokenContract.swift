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
    case gibboToken
    
    var address: String {
        switch self {
        case .chainLink:
            return "0x01BE23585060835E02B77ef475b0Cc51aA1e0709"
        case .gibboToken:
            return "0x0d2b991bf5f41b01deae87bb2db95cd1efacf24b"
        }
    }
    
    var network: TokenNetwork {
        switch self {
        case .chainLink:
            return .rinkeby
        case .gibboToken:
            return .ropsten
        }
    }
}
