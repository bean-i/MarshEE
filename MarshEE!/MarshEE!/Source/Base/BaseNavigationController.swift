//
//  BaseNavigationController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/10/24.
//

import UIKit

public class BaseNavigationController: UINavigationController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
  }

  private func configureNavigationBar() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
    
    self.navigationBar.prefersLargeTitles = true
    self.navigationBar.standardAppearance = appearance
    self.navigationBar.scrollEdgeAppearance = appearance
  }
}

