//
//  WalletsViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import UIKit

class WalletsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var createButton: UIButton!
    
    var viewModel: WalletsViewModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        let name = String(describing: WalletsTableViewCell.self)
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        setupView()
    }
    
    private func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Your wallets"
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.largeTitleDisplayMode = .always
        
        NotificationCenter.default.addObserver(forName: .importedWallet, object: nil, queue: nil) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        createButton.isEnabled = false
        loadingView.startAnimating()
        viewModel.createChildWallet { [weak self] in
            self?.createButton.isEnabled = true
            self?.loadingView.stopAnimating()
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        viewModel.routeToImportWallet()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        viewModel.resetAndCloseApp()
    }
}
