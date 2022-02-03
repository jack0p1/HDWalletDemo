//
//  SendBalanceViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 28/01/2022.
//

import UIKit
import Combine

class SendBalanceViewController: UIViewController {
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var currencyTextField: UITextField!
    
    var viewModel: SendBalanceViewModel!
    var subscriptions = Set<AnyCancellable>()
    var chosenToken: SupportedToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
        amountTextField.delegate = self
        setupView()
        setupBinding()
    }
    
    private func setupView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        amountTextField.keyboardType = .decimalPad
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 240))
        pickerView.dataSource = viewModel
        pickerView.delegate = viewModel
        currencyTextField.inputView = pickerView
    }
    
    private func setupBinding() {
        viewModel.pickerViewChoice
            .sink { [weak self] in
                self?.currencyTextField.text = $0.symbol
                self?.chosenToken = $0
            }
            .store(in: &subscriptions)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        guard let destination = addressTextField.text,
              let amount = amountTextField.text,
              let token = chosenToken else { return }
        sendButton.isEnabled = false
        loadingView.startAnimating()
        
        viewModel.sendBalance(to: destination, amount: amount, token: token) { [weak self] in
            NotificationCenter.default.post(name: .sentBalance, object: nil)
            
            self?.loadingView.stopAnimating()
            self?.viewModel.routeBack()
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
