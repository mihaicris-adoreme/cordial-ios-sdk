//
//  ExternalDisplaySceneDelegate.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 13.09.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

@available(iOS 16.0, *)
class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var screen: UIScreen?

    weak var linkedScreen: UIScreen?

    func setupDisplayLinkIfNecessary() {
        let currentScreen = self.screen
        
        if currentScreen != self.linkedScreen {
            self.linkedScreen = currentScreen
        }
    }
    
    // MARK: - UIWindowSceneDelegate
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if session.role == .windowExternalDisplayNonInteractive {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = ExternalDisplayViewController()
            self.window = window
            window.makeKeyAndVisible()

            self.setupDisplayLinkIfNecessary()
        }
    }

    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        
        self.setupDisplayLinkIfNecessary()
    }
}

