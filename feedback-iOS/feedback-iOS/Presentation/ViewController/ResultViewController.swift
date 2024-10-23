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
  
  let containerView = UIView()
  let graphTitleLabel = UILabel()
  let mostReceivedSkillLabel = UILabel()
  var hitmapView = HeatmapView(frame: .zero, skillSet: SessionManager.shared.resultData)
  let containerViewFooter = UILabel()
  var isCompleted: Bool = false
  let doneButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStyle()
    setUI()
    setAutoLayout()
    
    if let mostSelected = findMostSelectedTraitAndCategory(in: SessionManager.shared.resultData) {
      mostReceivedSkillLabel.text = "\(mostSelected.trait) \(mostSelected.category) 􁾪"
    } else {
      mostReceivedSkillLabel.text = "데이터가 없습니다."
    }
  }
  
  func setStyle() {
    title = "음미하기"
    view.backgroundColor = .systemGray6
    navigationItem.hidesBackButton = true
    
    containerView.do {
      $0.backgroundColor = .white
      $0.roundCorners(cornerRadius: 10)
    }
    
    graphTitleLabel.do {
      $0.text = "이번 프로젝트에서 가장 두드러진 능력"
      $0.textColor = .black
      $0.font = UIFont.sfPro(.body)
      $0.textAlignment = .left
    }
    
    mostReceivedSkillLabel.do {
      $0.textColor = .systemBlue
      $0.font = UIFont.sfPro(.title2)
      $0.textAlignment = .left
    }
    
    containerViewFooter.do {
      $0.text = "타일을 터치하여 잘 구워진 SOFT SKILL을 탐색"
      $0.font = .sfPro(.footer)
      $0.textColor = .gray
      $0.textAlignment = .left
    }
    
    doneButton.do {
      $0.setTitle("음미 완료", for: .normal)
      $0.setImage(UIImage(systemName: "fork.knife"), for: .normal)
      $0.tintColor = .white
      $0.backgroundColor = .systemBlue
      $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
      $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
      $0.setLayer(borderColor: .clear, cornerRadius: 12)
      $0.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
  }
  
  func setUI() {
    view.addSubviews(
      containerView,
      containerViewFooter,
      doneButton
    )
    
    containerView.addSubviews(
      graphTitleLabel,
      mostReceivedSkillLabel,
      hitmapView
    )
  }
  
  func setAutoLayout() {
    containerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.height.equalTo(452)
    }
    
    graphTitleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(16)
    }
    
    mostReceivedSkillLabel.snp.makeConstraints {
      $0.top.equalTo(graphTitleLabel.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(16)
      $0.height.equalTo(25)
    }
    
    hitmapView.snp.makeConstraints {
      $0.top.equalTo(mostReceivedSkillLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(hitmapView.snp.width)
      $0.bottom.equalToSuperview().offset(-16)
    }
    
    containerViewFooter.snp.makeConstraints {
      $0.top.equalTo(containerView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().offset(32)
    }
    
    doneButton.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
      $0.height.equalTo(50)
    }
  }
  
  @objc func doneButtonTapped() {
    let alertController = UIAlertController(
      title: "홈 화면으로 돌아가시겠습니까?",
      message: nil,
      preferredStyle: .alert
    )
    
    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
      self.navigationController?.popToRootViewController(animated: true)
    }
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  func findMostSelectedTraitAndCategory(in skillSet: SkillSet) -> (category: String, trait: String, count: Int)? {
    var mostSelected: (category: String, trait: String, count: Int)? = nil
    
    for category in skillSet.categories {
      for trait in category.traits {
        if let currentMostSelected = mostSelected {
          if trait.count > currentMostSelected.count {
            mostSelected = (category.name, trait.name, trait.count)
          }
        } else {
          mostSelected = (category.name, trait.name, trait.count)
        }
      }
    }
    return mostSelected
  }
}
