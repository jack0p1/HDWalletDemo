//
//  SendBalanceViewModel.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import XCoordinator
import UIKit
import Combine

enum SupportedToken: String, CaseIterable {
    case eth, link, gibo
    
    var symbol: String {
        self.rawValue.uppercased()
    }
    
    var contract: TokenContract? {
        switch self {
        case .eth:
            return nil
        case .link:
            return TokenContract.chainLink
        case .gibo:
            return TokenContract.gibboToken
        }
    }
}

class SendBalanceViewModel: NSObject {
    private let router: UnownedRouter<MainFlow>
    
    let wallet: Wallet
    var pickerViewChoice = PassthroughSubject<SupportedToken, Never>()
    var pickerSource: [SupportedToken] {
        SupportedToken.allCases
    }
        
    init(router: UnownedRouter<MainFlow>, wallet: Wallet) {
        self.router = router
        self.wallet = wallet
    }
    
    func sendBalance(to destination: String, amount: String, token: SupportedToken, completion: @escaping () -> Void) {
        if token == .eth {
            DataManager.shared.sendEthBalance(from: wallet, to: destination, amount: amount, completion: completion)
        } else {
            guard let tokenContract = token.contract else { return }
            DataManager.shared.sendTokenBalance(from: wallet, to: destination, amount: amount, tokenContract: tokenContract, completion: completion)
        }
        
    }
    
    func routeBack() {
        router.trigger(.back)
    }
}

extension SendBalanceViewModel: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerSource[row].symbol
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerViewChoice.send(pickerSource[row])
    }
}

extension SendBalanceViewModel: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerSource.count
    }
}
