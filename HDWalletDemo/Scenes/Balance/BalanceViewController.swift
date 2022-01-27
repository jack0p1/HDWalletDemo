//
//  BalanceViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import UIKit
import Combine

class BalanceViewController: UIViewController {
    @IBOutlet private weak var balanceLabel: UILabel!
    
    var viewModel: BalanceViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        viewModel.getBalance()
    }
    
    private func setupBinding() {
        viewModel.balance
            .sink { [weak self] in
                self?.balanceLabel.text = $0
            }
            .store(in: &subscriptions)
    }
}
