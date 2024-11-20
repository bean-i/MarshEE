//
//  FeedbackDetailViewController.swift
//  feedback-iOS
//
//  Created by 이빈 on 10/16/24.
//

import UIKit

import SnapKit
import Then

class FeedbackDetailViewController: UIViewController {
  
  // MARK: - Components
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private var userImageView = UILabel()
  private let userName = UILabel()
  private let userRole = UILabel()
  private var lastComponent: UIView? = nil
  private let backButton = UIBarButtonItem()
  private let doneButton = UIBarButtonItem()
  
  // MARK: - Properties
  var skill = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])
  var selectedUserInfo: UserInfo?
  var onFeedbackCompleted: ((String) -> Void)?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  // MARK: - UI Setup
  private func setStyle() {
    view.backgroundColor = .white
    title = "찌르기"
    navigationItem.leftBarButtonItem = backButton
    navigationItem.rightBarButtonItem = doneButton
    
    scrollView.do {
      $0.showsVerticalScrollIndicator = true
    }
    
    userImageView.do {
      if let firstCharacter = selectedUserInfo?.peerID.displayName.first {
        $0.text = String(firstCharacter)
      }
      $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
      $0.textColor = .white
      $0.backgroundColor = .lightGray
      $0.textAlignment = .center
      $0.roundCorners(cornerRadius: 31)
    }
    
    userName.do {
      $0.text = selectedUserInfo?.peerID.displayName
      $0.font = UIFont.sfPro(.title2)
    }
    
    userRole.do {
      $0.text = selectedUserInfo?.role
      $0.font = UIFont.sfPro(.body)
    }
    
    backButton.do {
      $0.image = UIImage(systemName: "chevron.left")
      $0.style = .plain
      $0.target = self
      $0.action = #selector(backButtonTapped)
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
    
    addFeedbackSelectionComponent()
    setupLastComponentConstraints()
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
  
  // MARK: - Create Component
  private func addFeedbackSelectionComponent() {
    for (index, category) in skill.categories.enumerated() {
      let feedbackSelectionComponent = FeedbackSelectionComponent(categoryName: category.name, traits: category.traits)
      feedbackSelectionComponent.parentViewController = self
      contentView.addSubview(feedbackSelectionComponent)
      
      feedbackSelectionComponent.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview().inset(20)
        if index == 0 {
          $0.top.equalTo(userRole.snp.bottom).offset(16)
        } else {
          let previousComponent = contentView.subviews[contentView.subviews.firstIndex(of: feedbackSelectionComponent)! - 1]
          $0.top.equalTo(previousComponent.snp.bottom).offset(22)
        }
      }
      lastComponent = feedbackSelectionComponent
    }
  }
  
  private func setupLastComponentConstraints() {
    lastComponent?.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-20)
    }
  }
  
  // MARK: - Update Methods
  func updateSelectedTraitCount(categoryIndex: Int, traitIndex: Int, increase: Bool) {
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
  
  // MARK: - Actions
  @objc private func backButtonTapped() {
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func doneButtonTapped() {
    if let selectedUserInfo = selectedUserInfo {
      do {
        if let targetPeerID = SessionManager.shared.session.connectedPeers.first(where: { $0 == selectedUserInfo.peerID }) {
          
          let selectedFeedbacksData = try JSONEncoder().encode(skill)
          
          SessionDataSender.shared.sendData(selectedFeedbacksData, message: "sendFeedback", to: [targetPeerID])
          
          onFeedbackCompleted?(selectedUserInfo.peerID.displayName)
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

