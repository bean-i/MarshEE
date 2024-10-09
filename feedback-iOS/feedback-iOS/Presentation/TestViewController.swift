//
//  TestViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit

import SnapKit
import Then

final class TestViewController: UIViewController {
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
    makeFeedbackButton.do {
      $0.setTitle("세션 생성", for: .normal)
      $0.backgroundColor = .gray
    }
    
    enterFeedbackButton.do {
      $0.setTitle("세션 검색", for: .normal)
      $0.backgroundColor = .gray
    }
    
    
  }
  
  private func setUI() {
    view.addSubviews(makeFeedbackButton, enterFeedbackButton)
  }
  
  private func setAutoLayout() {
    makeFeedbackButton.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(50)
    }
    
    enterFeedbackButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(makeFeedbackButton.snp.bottom).offset(20)
      $0.width.equalTo(100)
      $0.height.equalTo(50)
    }
  }
}
