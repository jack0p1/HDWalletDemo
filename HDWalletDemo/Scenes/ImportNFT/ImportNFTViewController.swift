//
//  ImportNFTViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 09/02/2022.
//

import UIKit

class ImportNFTViewController: UIViewController {
    @IBOutlet private weak var contractAddressTextField: UITextField!
    @IBOutlet private weak var tokenIdTextField: UITextField!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var importButton: UIButton!
    
    var viewModel: ImportNFTViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        guard let contractAddress = contractAddressTextField.text,
              let tokenId = tokenIdTextField.text else { return }
        importButton.isEnabled = false
        loadingView.startAnimating()
    }
}
