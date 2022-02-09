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
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
    
    @IBAction func importNFTPressed(_ sender: UIButton) {
        viewModel.routeToImportNFT()
    }
}
