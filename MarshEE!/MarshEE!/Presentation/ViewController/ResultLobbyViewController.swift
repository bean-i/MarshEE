//
//  ResultLobbyViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/23/24.
//

import UIKit

import Then
import SnapKit

final class ResultLobbyViewController: UIViewController {
  let activityIndicator = UIActivityIndicatorView()
  let waitingLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStyle()
    setUI()
    setAutoLayout()
    
    SessionManager.shared.onPushDataReceived = { [weak self] in
      let resultVC = ResultViewController()
      self?.navigationController?.pushViewController(resultVC, animated: true)
    }
  }
  
  func setStyle() {
    view.backgroundColor = .white
    title = "굽기"
    navigationItem.hidesBackButton = true
    
    activityIndicator.do {
      $0.style = .large
      $0.startAnimating()
    }
    
    waitingLabel.do {
      $0.text = "당신의 SOFT SKILL이 구워지는 중"
      $0.font = UIFont.sfPro(.body)
      $0.textColor = UIColor.lightGray
    }
  }
  
  func setUI() {
    view.addSubviews(activityIndicator, waitingLabel)
  }
  
  func setAutoLayout() {
    
    activityIndicator.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
    }
    
    waitingLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(activityIndicator.snp.bottom).offset(5)
    }
  }
}
