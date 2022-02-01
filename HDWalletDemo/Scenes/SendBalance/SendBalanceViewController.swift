//
//  SendBalanceViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import UIKit

class SendBalanceViewController: UIViewController {
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountLabel: UILabel!
    
    var viewModel: SendBalanceViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
        amountTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        amountTextField.keyboardType = .decimalPad
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        guard let destination = addressTextField.text,
              let amount = amountTextField.text else { return }
        sendButton.isEnabled = false
        loadingView.startAnimating()
        
        viewModel.sendBalance(to: destination, amount: amount) { [weak self] in
            self?.loadingView.stopAnimating()
        }
    }
}

extension SendBalanceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case amountTextField:
            if string == "," {
                textField.text = textField.text! + "."
                return false
            }
            fallthrough
        default:
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            sendButton.isEnabled = !newString.isEmpty
            return true
        }
    }
}
