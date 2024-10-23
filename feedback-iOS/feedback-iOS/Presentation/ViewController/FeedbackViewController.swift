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
  
  var completedUserPeerIDs: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStyle()
    setUI()
    setAutolayout()
    setTableView()
    updateTableViewHeight()
  }
  
  func setStyle() {
    title = "찌르기"
    navigationItem.hidesBackButton = true
    view.backgroundColor = .systemGray6
    
    feedbackTableViewHeader.do {
      $0.text = "팀원을 눌러서 SOFT SKILL 찌르기"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    feedbackTableView.do {
      $0.layer.cornerRadius = 10
      $0.clipsToBounds = true
    }
    
    finishFeedbackButton.do {
      $0.setTitle("굽기", for: .normal)
      $0.backgroundColor = .systemBlue
      $0.setImage(UIImage(systemName: "flame.fill"), for: .normal)
      $0.tintColor = .white
      $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
      $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
      $0.setLayer(borderColor: .clear, cornerRadius: 12)
      $0.addTarget(self, action: #selector(finishFeedbackButtonTapped), for: .touchUpInside)
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
      $0.height.equalTo(200)
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
    let totalParticipants = SessionManager.shared.session.connectedPeers.count + 1
    if completedUserPeerIDs.count == totalParticipants - 1 {
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
    else {
      let alert = UIAlertController(title: "피드백 미완료", message: "모든 참가자의 피드백을 완료해주세요.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
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
      let meLabel = UILabel()
      meLabel.text = "Me"
      meLabel.textColor = .gray
      meLabel.font = .sfPro(.body)
      meLabel.sizeToFit()
      meLabel.textAlignment = .left
      meLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
      
      cell.accessoryView = meLabel
    }
    
    else if completedUserPeerIDs.contains(userInfo.peerID) {
      cell.accessoryType = .checkmark
      cell.accessoryView = nil
    } else {
      cell.accessoryType = .disclosureIndicator
      cell.accessoryView = nil
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
    
    detailVC.onFeedbackCompleted = { [weak self] peerID in
      self?.completedUserPeerIDs.append(peerID)
      self?.feedbackTableView.reloadData()
    }
    
    present(modalDetailVC, animated: true, completion: nil)
  }
}
