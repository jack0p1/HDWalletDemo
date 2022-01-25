//
//  MainViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 20/01/2022.
//

import UIKit

class MainViewController: UIViewController {
    var viewModel: MainViewModel!
    
    @IBAction func createWalletButtonTouched(_ sender: UIButton) {
        viewModel.routeToCreateWallet()
    }
    
    @IBAction func importWalletButtonTouched(_ sender: UIButton) {
        
    }
}

