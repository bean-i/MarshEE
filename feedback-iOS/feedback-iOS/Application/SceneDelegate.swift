//
//  SceneDelegate.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/6/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      
      guard let windowScene = (scene as? UIWindowScene) else { return }
      
      let window = UIWindow(windowScene: windowScene)
      let rootViewController = TestViewController()
      let navigationController = UINavigationController(rootViewController: rootViewController)
      
      window.rootViewController = navigationController
      window.makeKeyAndVisible()
      
      self.window = window
    }
}

