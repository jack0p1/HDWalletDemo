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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
}
