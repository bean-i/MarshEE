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
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = .clear
    appearance.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black,
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .medium)
    ]
    appearance.buttonAppearance.normal.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.black
    ]

    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance

    navigationBar.tintColor = .black
    navigationItem.backButtonDisplayMode = .minimal
  }
}

