//
//  MnemonicPhraseViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 27/01/2022.
//

import UIKit

class MnemonicPhraseViewController: UIViewController {
    @IBOutlet weak var mnemonicsLabel: UILabel!
    
    var viewModel: MnemonicPhraseViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        mnemonicsLabel.text = viewModel.mnemonics
    }
    
    @IBAction func copyPressed(_ sender: UIButton) {
        UIPasteboard.general.string = mnemonicsLabel.text
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        viewModel.routeToBalance()
    }
}
