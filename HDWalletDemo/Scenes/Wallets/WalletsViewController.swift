//
//  WalletsViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import UIKit

class WalletsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: WalletsViewModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Your wallets"
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        viewModel.routeToImportWallet()
    }
}
