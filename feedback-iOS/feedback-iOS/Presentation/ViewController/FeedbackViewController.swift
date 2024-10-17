//
//  FeedbackViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/11/24.
//

import UIKit

final class FeedbackViewController: UIViewController {
  
  override func viewDidLoad() {
    view.backgroundColor = .systemBlue
    super.viewDidLoad()
    print(SessionManager.shared.receivedUserInfos)
  }
}
