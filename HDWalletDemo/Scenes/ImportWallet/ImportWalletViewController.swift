//
//  ImportWalletViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import UIKit

class ImportWalletViewController: UIViewController {
    @IBOutlet private weak var seedPhraseTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var importButton: UIButton!
    @IBOutlet private weak var createPasswordLabel: UILabel!
    @IBOutlet private weak var enterSeedLabel: UILabel!
    
    var viewModel: ImportWalletViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        seedPhraseTextField.delegate = self
        passwordTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        setupView()
    }
    
    private func setupView() {
        if viewModel.isAddingChildWallet {
            enterSeedLabel.isHidden = true
            seedPhraseTextField.isHidden = true
            createPasswordLabel.text = "Enter a private key"
            passwordTextField.placeholder = "Private key"
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        importButton.isEnabled = false
        loadingView.startAnimating()
        
        if viewModel.isAddingChildWallet {
            guard let privateKey = passwordTextField.text else { return }
            viewModel.importChildWallet(privateKey: privateKey) { [weak self] in
                self?.loadingView.stopAnimating()
                self?.viewModel.routeBack()
            }
        } else {
            guard let password = passwordTextField.text,
                  let seedPhrase = seedPhraseTextField.text else { return }
            viewModel.importWallet(password: password, phrase: seedPhrase) { [weak self] in
                self?.loadingView.stopAnimating()
                self?.viewModel.routeToWallets()
            }
        }
        
    }
}

extension ImportWalletViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        importButton.isEnabled = !newString.isEmpty
        return true
    }
}
