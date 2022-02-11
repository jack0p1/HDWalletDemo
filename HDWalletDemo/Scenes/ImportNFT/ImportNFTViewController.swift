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
        importButton.isEnabled = true
    }
    
    private func setupView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        contractAddressTextField.delegate = self
        tokenIdTextField.delegate = self
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        guard let contractAddress = contractAddressTextField.text,
              let tokenId = tokenIdTextField.text else { return }
        importButton.isEnabled = false
        loadingView.startAnimating()
        
        viewModel.importNFT(contractAddress: contractAddress, tokenID: tokenId) { [weak self] in
            print($0)
            
            self?.loadingView.stopAnimating()
        }
    }
}

extension ImportNFTViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        importButton.isEnabled = !newString.isEmpty
        return true
    }
}
