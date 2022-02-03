//
//  Notification.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 03/02/2022.
//

import Foundation

extension Notification.Name {
    static let importedWallet = Notification.Name(rawValue: "importedWallet")
    static let sentBalance = Notification.Name(rawValue: "sentBalance")
}
