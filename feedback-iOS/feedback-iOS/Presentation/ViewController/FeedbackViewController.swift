//
//  FeedbackViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/11/24.
//

import UIKit
import SnapKit
import Then

final class FeedbackViewController: UIViewController {
  
  let feedbackTableViewHeader = UILabel()
  let feedbackTableView = UITableView()
  let finishFeedbackButton = UIButton()
  let meLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    setStyle()
    setUI()
    setAutolayout()
    setTableView()
    updateTableViewHeight()
  }
  
  func setStyle() {
    title = "Feedback"
    navigationItem.hidesBackButton = true
    view.backgroundColor = .systemGray6
    
    feedbackTableViewHeader.do {
      $0.text = "CHOOSE YOUR TEAMMATE"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    feedbackTableView.do {
      $0.layer.cornerRadius = 10
      $0.clipsToBounds = true
    }
    
    finishFeedbackButton.do {
      $0.setTitle("Report", for: .normal)
      $0.backgroundColor = .systemBlue
      $0.setImage(UIImage(systemName: "append.page"), for: .normal)
      $0.tintColor = .white
      $0.setLayer(borderColor: .clear, cornerRadius: 12)
      $0.addTarget(self, action: #selector(finishFeedbackButtonTapped), for: .touchUpInside)
    }
    
    meLabel.do {
      $0.text = "Me"
      $0.textColor = .gray
      $0.font = .sfPro(.body)
    }
  }
  
  func setUI() {
    view.addSubviews(
      feedbackTableViewHeader,
      feedbackTableView,
      finishFeedbackButton
    )
  }
  
  func setAutolayout() {
    
    feedbackTableViewHeader.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      $0.leading.equalToSuperview().offset(32)
    }
    
    feedbackTableView.snp.makeConstraints {
      $0.top.equalTo(feedbackTableViewHeader.snp.bottom).offset(10)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.height.equalTo(100)
    }
    
    finishFeedbackButton.snp.makeConstraints {
      $0.top.equalTo(feedbackTableView.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
      $0.height.equalTo(50)
    }
  }
  
  func setTableView() {
    feedbackTableView.isScrollEnabled = false
    feedbackTableView.delegate = self
    feedbackTableView.dataSource = self
    feedbackTableView.register(UITableViewCell.self, forCellReuseIdentifier: FeedbackTableViewCell.identifier)
  }
  
  func updateTableViewHeight() {
    feedbackTableView.layoutIfNeeded()
    let totalHeight = feedbackTableView.contentSize.height
    feedbackTableView.snp.updateConstraints {
      $0.height.equalTo(totalHeight)
    }
  }
  
  
  @objc func finishFeedbackButtonTapped() {
      if SessionManager.shared.isHost {
          SessionManager.shared.feedbackCompletionCount += 1
          SessionManager.shared.checkAllFeedbackCompleted()
      } else {
          if let feedbackCompletedData = try? JSONEncoder().encode(SessionManager.shared.localUserInfo?.peerID) {
              if let hostPeerID = SessionManager.shared.session.connectedPeers.first {
                  SessionManager.shared.sendData(
                      feedbackCompletedData,
                      message: "feedbackCompleted",
                      to: [hostPeerID]
                  )
              }
          }
      }

      let resultLobbyVC = ResultLobbyViewController()
      self.navigationController?.pushViewController(resultLobbyVC, animated: true)
  }
}

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SessionManager.shared.receivedUserInfos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackTableViewCell.identifier, for: indexPath)
    let userInfo = SessionManager.shared.receivedUserInfos[indexPath.row]
    cell.textLabel?.text = "\(userInfo.peerID)\n\(userInfo.role)"
    
    if userInfo.peerID == SessionManager.shared.peerID.displayName {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      let selectedUserInfo = SessionManager.shared.receivedUserInfos[indexPath.row]
      
      if selectedUserInfo.peerID == SessionManager.shared.localUserInfo?.peerID {
          return nil
      }
      return indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedUserInfo = SessionManager.shared.receivedUserInfos[indexPath.row]
    
    let detailVC = FeedbackDetailViewController()
    let modalDetailVC = UINavigationController(rootViewController: detailVC)
    modalDetailVC.modalPresentationStyle = .pageSheet
    detailVC.selectedUserInfo = selectedUserInfo
    
    present(modalDetailVC, animated: true, completion: nil)
  }
}
