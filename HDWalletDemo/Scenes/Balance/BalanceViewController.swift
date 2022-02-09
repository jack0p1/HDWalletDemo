//
//  BalanceViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import UIKit
import Combine

class BalanceViewController: UIViewController {
    @IBOutlet private weak var ethBalanceLabel: UILabel!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var linkBalanceLabel: UILabel!
    @IBOutlet private weak var gibboTokenBalanceLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    
    var viewModel: BalanceViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupView()
    }
    
    private func setupView() {
        title = viewModel.wallet.name
        loadingView.startAnimating()
        viewModel.getBalance()
        sendButton.isEnabled = false
        
        NotificationCenter.default.addObserver(forName: .sentBalance, object: nil, queue: nil) { [weak self] _ in
            self?.loadingView.startAnimating()
            self?.viewModel.getBalance()
        }
    }
    
    private func setupBinding() {
        viewModel.ethBalance
            .sink { [weak self] in
                self?.ethBalanceLabel.text = $0
            }
            .store(in: &subscriptions)
        
        viewModel.chainLinkBalance
            .sink { [weak self] in
                self?.linkBalanceLabel.text = $0
            }
            .store(in: &subscriptions)
        
        viewModel.balanceLoaded
            .sink { [weak self] in
                self?.loadingView.stopAnimating()
                self?.sendButton.isEnabled = true
            }
            .store(in: &subscriptions)
        
        viewModel.gibboTokenBalance
            .sink { [weak self] in
                self?.gibboTokenBalanceLabel.text = $0
            }
            .store(in: &subscriptions)
    }
    
    @IBAction func sendBalancePressed(_ sender: UIButton) {
        viewModel.routeToSendBalance()
    }
    
    @IBAction func nftsPressed(_ sender: UIButton) {
        viewModel.routeToNFTs()
    }
}
