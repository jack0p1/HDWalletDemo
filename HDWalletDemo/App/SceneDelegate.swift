//
//  SceneDelegate.swift
//  HDWalletDemo
//
//  Created by Jacek Kopaczel on 20/01/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let router = MainCoordinator().strongRouter

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if window != nil {
            router.setRoot(for: window!)
        }
    }
}

