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
    
    var viewModel: ImportWalletViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        seedPhraseTextField.delegate = self
        passwordTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func importPressed(_ sender: UIButton) {
        guard let seedPhrase = seedPhraseTextField.text,
              let password = passwordTextField.text else { return }
        importButton.isEnabled = false
        loadingView.startAnimating()
        viewModel.importWallet(password: password, phrase: seedPhrase) { [weak self] in
            self?.loadingView.stopAnimating()
            self?.viewModel.routeToWallets()
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
