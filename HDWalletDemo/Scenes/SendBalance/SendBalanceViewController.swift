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
    
    var viewModel: SendBalanceViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        
    }
}

extension SendBalanceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        sendButton.isEnabled = !newString.isEmpty
        return true
    }
}
