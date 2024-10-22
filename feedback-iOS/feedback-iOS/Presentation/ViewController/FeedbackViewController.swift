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
    
    finishFeedbackButton.do {
      $0.setTitle("Report", for: .normal)
      $0.backgroundColor = .systemBlue
      $0.setImage(UIImage(systemName: "append.page"), for: .normal)
      $0.tintColor = .white
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
      $0.leading.equalToSuperview().offset(-16)
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
    feedbackTableView.delegate = self
    feedbackTableView.dataSource = self
    feedbackTableView.register(UITableViewCell.self, forCellReuseIdentifier: FeedbackTableViewCell.identifier)
  }
  
  func updateTableViewHeight() {
      let rowHeight = feedbackTableView.rowHeight
      let numberOfRows = feedbackTableView.numberOfRows(inSection: 0)
      let totalHeight = rowHeight * CGFloat(numberOfRows)
      
      feedbackTableView.snp.updateConstraints {
          $0.height.equalTo(totalHeight)
      }
  }
  
  
  @objc func finishFeedbackButtonTapped() {
//    do {
//      let allUserInfoData = try JSONEncoder().encode(SessionManager.shared.receivedUserInfos)
//      SessionManager.shared.sendData(allUserInfoData, message: "startFeedback", to: SessionManager.shared.session.connectedPeers)
//    } catch {
//      print("\(error.localizedDescription)")
//    }
//    
    let resultVC = ResultViewController()
    self.navigationController?.pushViewController(resultVC, animated: true)
  }
}

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SessionManager.shared.receivedUserInfos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackTableViewCell.identifier, for: indexPath)
    let userInfo = SessionManager.shared.receivedUserInfos[indexPath.row]
    cell.textLabel?.text = userInfo.peerID
    
    if userInfo.peerID == SessionManager.shared.peerID.displayName {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
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
