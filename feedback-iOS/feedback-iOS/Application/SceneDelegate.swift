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
    
    let tabBarController = UITabBarController()
    
    let testVC = UINavigationController(rootViewController: TestViewController())
    testVC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
    
    let resultVC = UINavigationController(rootViewController: TestViewController())
    resultVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
    
    tabBarController.viewControllers = [testVC, resultVC]
    
    tabBarController.tabBar.tintColor = .systemBlue
    
    let normalAttributes = [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
      NSAttributedString.Key.foregroundColor: UIColor.gray
    ]
    
    let selectedAttributes = [
      NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
      NSAttributedString.Key.foregroundColor: UIColor.gray
    ]
    
    UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
    
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    
    self.window = window
  }
}
