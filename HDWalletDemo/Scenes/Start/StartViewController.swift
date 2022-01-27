//
//  StartViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 20/01/2022.
//

import UIKit

class StartViewController: UIViewController {
    var viewModel: StartViewModel!
    
    @IBAction func createWalletButtonTouched(_ sender: UIButton) {
        viewModel.routeToCreateWallet()
    }
    
    @IBAction func importWalletButtonTouched(_ sender: UIButton) {
        viewModel.routeToImportWallet()
    }
}

