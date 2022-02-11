//
//  NFTsViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 09/02/2022.
//

import UIKit

class NFTsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NFTsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NFTs"
        tableView.dataSource = viewModel
        let name = String(describing: NFTTableViewCell.self)
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        
        NotificationCenter.default.addObserver(forName: .importedNFT, object: nil, queue: nil) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func importNFTPressed(_ sender: UIButton) {
        viewModel.routeToImportNFT()
    }
}
