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
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    var viewModel: BalanceViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingView.startAnimating()
        viewModel.getBalance()
    }
    
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = viewModel.wallet.name
    }
    
    private func setupBinding() {
        viewModel.balance
            .sink { [weak self] in
                self?.balanceLabel.text = $0
                self?.loadingView.stopAnimating()
            }
            .store(in: &subscriptions)
    }
    
    @IBAction func sendBalancePressed(_ sender: UIButton) {
        viewModel.routeToSendBalance()
    }
}
