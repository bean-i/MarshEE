//
//  TestViewController.swift
//  feedback-iOS
//
//  Created by 이빈 on 10/16/24.
//

import UIKit

import SnapKit
import Then

class FeedbackDetailViewController: UIViewController {
  
  var skill = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])
  
  var selectedUserInfo: UserInfo?
  
  let scrollView = UIScrollView()
  let contentView = UIView()
  var userImageView = UILabel()
  let userName = UILabel()
  let userRole = UILabel()
  var lastComponent: UIView? = nil
  let doneButton = UIBarButtonItem()
  
  var onFeedbackCompleted: ((String) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  private func setStyle() {
    view.backgroundColor = .white
    
    self.title = "Feedback"
    self.navigationItem.rightBarButtonItem = doneButton
    
    scrollView.do {
      $0.showsVerticalScrollIndicator = true
    }
    
    userImageView.do {
      if let firstCharacter = selectedUserInfo?.peerID.first {
        $0.text = String(firstCharacter)
      }
      $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
      $0.textColor = .white
      $0.backgroundColor = .lightGray
      $0.textAlignment = .center
      $0.roundCorners(cornerRadius: 31)
    }
    
    userName.do {
      $0.text = selectedUserInfo?.peerID
      $0.font = UIFont.sfPro(.title2)
    }
    
    userRole.do {
      $0.text = selectedUserInfo?.role
      $0.font = UIFont.sfPro(.body)
    }
    
    doneButton.do {
      $0.title = "Done"
      $0.style = .done
      $0.target = self
      $0.action = #selector(doneButtonTapped)
      $0.isEnabled = false
    }
    
  }
  
  private func setUI() {
    contentView.addSubviews(
      userImageView,
      userName,
      userRole
    )
    scrollView.addSubviews(contentView)
    view.addSubview(scrollView)
    
    for (index, category) in skill.categories.enumerated() {
      let feedbackComponent = FeedbackSelectionComponent(name: category.name, traits: category.traits)
      feedbackComponent.parentViewController = self
      contentView.addSubview(feedbackComponent)
      
      feedbackComponent.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview().inset(20)
        if index == 0 {
          $0.top.equalTo(userRole.snp.bottom).offset(16)
        } else {
          let previousComponent = contentView.subviews[contentView.subviews.firstIndex(of: feedbackComponent)! - 1]
          $0.top.equalTo(previousComponent.snp.bottom).offset(22)
        }
      }
      lastComponent = feedbackComponent
    }
    lastComponent?.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-20)
    }
  }
  
  private func setAutoLayout() {
    
    scrollView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    userImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(32)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(62)
    }
    
    userName.snp.makeConstraints {
      $0.top.equalTo(userImageView.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
    }
    
    userRole.snp.makeConstraints {
      $0.top.equalTo(userName.snp.bottom).offset(5)
      $0.centerX.equalToSuperview()
    }
  }
  
  func updateTraitSelection(categoryIndex: Int, traitIndex: Int, increase: Bool) {
    if increase {
      skill.categories[categoryIndex].traits[traitIndex].count += 1
    } else {
      skill.categories[categoryIndex].traits[traitIndex].count -= 1
    }
  }
  
  func updateDoneButtonState() {
    for subview in contentView.subviews {
      if let feedbackComponent = subview as? FeedbackSelectionComponent {
        if feedbackComponent.selectedTraitTitles.count != feedbackComponent.maxTraitSelectionCount {
          doneButton.isEnabled = false
          return
        }
      }
    }
    doneButton.isEnabled = true
  }
  
  @objc private func doneButtonTapped() {
    
    if let selectedUserInfo = selectedUserInfo {
      do {
        if let targetPeerID = SessionManager.shared.session.connectedPeers.first(where: { $0.displayName == selectedUserInfo.peerID }) {
          
          let selectedFeedbacksData = try JSONEncoder().encode(skill)
          
          SessionManager.shared.sendData(selectedFeedbacksData, message: "sendFeedback", to: [targetPeerID])
          
          onFeedbackCompleted?(selectedUserInfo.peerID)
        } else {
          print("해당 피어를 찾을 수 없습니다.")
        }
      } catch {
        print("데이터 인코딩 실패: \(error.localizedDescription)")
      }
    }
    dismiss(animated: true, completion: nil)
  }
}
