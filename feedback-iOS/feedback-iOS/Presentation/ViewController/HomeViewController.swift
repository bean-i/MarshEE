//
//  HomeViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import MultipeerConnectivity
import UIKit

import SnapKit
import Then

final class HomeViewController: UIViewController {
  
  let makeFeedbackButton = UIButton()
  let enterFeedbackButton = UIButton()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  private func setStyle() {
    
    title = "FeedBack!"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    
    makeFeedbackButton.do {
      $0.setTitle("세션 생성", for: .normal)
      $0.backgroundColor = .gray
      $0.titleLabel?.font = UIFont.sfPro(.title2)
    }
    
    enterFeedbackButton.do {
      $0.setTitle("세션 참여", for: .normal)
      $0.backgroundColor = .gray
      $0.titleLabel?.font = UIFont.sfPro(.headline)
    }
    
    makeFeedbackButton.addTarget(self, action: #selector(makeFeedbackButtonTapped), for: .touchUpInside)
    enterFeedbackButton.addTarget(self, action: #selector(enterFeedbackButtonTapped), for: .touchUpInside)
  }
  
  private func setUI() {
    view.addSubviews(makeFeedbackButton, enterFeedbackButton)
  }
  
  private func setAutoLayout() {
    makeFeedbackButton.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(100)
    }
    
    enterFeedbackButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(makeFeedbackButton.snp.bottom).offset(20)
      $0.width.equalTo(100)
      $0.height.equalTo(50)
    }
  }
  
  @objc func makeFeedbackButtonTapped() {
    
    SessionManager.shared.setSession(isHost: true, displayName: "Rama")
    
    let sessionVC = SessionViewController()
    navigationController?.pushViewController(sessionVC, animated: true)
    
    print("세션 생성 및 광고 시작")
  }
  
  @objc func enterFeedbackButtonTapped() {
    SessionManager.shared.setSession(isHost: false, displayName: "Vicky", delegate: self)
    
    if let browser = SessionManager.shared.browser {
      present(browser, animated: true)
    }
  }
}

// MARK: - MCBrowserViewControllerDelegate
extension HomeViewController: MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true) {
      let sessionVC = SessionViewController()
      self.navigationController?.pushViewController(sessionVC, animated: true)
    }
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true, completion: nil)
  }
}
