//
//  CreateWalletViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 25/01/2022.
//

import UIKit
import web3swift

class CreateWalletViewController: UIViewController {
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    var viewModel: CreateWalletViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
    }
    
    @IBAction func createPressed(_ sender: UIButton) {
        loadingView.startAnimating()
        
    }
}

extension CreateWalletViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        createButton.isEnabled = !newString.isEmpty
        return true
    }
}
