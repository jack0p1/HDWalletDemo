//
//  UIViewController.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 21/01/2022.
//

import UIKit

extension UIViewController {
    static func instantiate<T: UIViewController>(from storyboardName: String = "Main") -> T {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: className) as? T else {
            fatalError("Could not instantiate a UIViewController with identifier: \(className) in storyboard: \(storyboardName).")
        }
        return viewController
    }
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alertController, animated: true, completion: nil)
    }
}
