//
//  ResultViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/18/24.
//

import UIKit
import Then
import SnapKit

final class ResultViewController: UIViewController {
  
  let resultLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  func setStyle() {
    resultLabel.do {
      $0.text = ""
      $0.font = UIFont.sfPro(.body)
      $0.textColor = UIColor.systemBlue
      $0.textAlignment = .left
    }
  }
  
  func setUI() {
    view.addSubview(resultLabel)
  }
  
  func setAutoLayout() {
    resultLabel.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
    }
  }
}
