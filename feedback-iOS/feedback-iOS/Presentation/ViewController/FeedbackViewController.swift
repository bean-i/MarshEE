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
  
  let feedbackTableView = UITableView()
  let finishFeedbackButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    setStyle()
    setUI()
    setAutolayout()
    setTableView()
  }
  
  func setStyle() {
    title = "Feedback"
    
    finishFeedbackButton.do {
      $0.setTitle("finish", for: .normal)
      $0.backgroundColor = .systemBlue
      $0.setLayer(borderColor: .clear, cornerRadius: 20)
      $0.addTarget(self, action: #selector(finishFeedbackButtonTapped), for: .touchUpInside)
    }
  }
  
  func setUI() {
    view.addSubviews(
      feedbackTableView,
      finishFeedbackButton
    )
  }
  
  func setAutolayout() {
    feedbackTableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    finishFeedbackButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
      $0.width.equalTo(250)
      $0.height.equalTo(50)
    }
  }
  
  func setTableView() {
    feedbackTableView.delegate = self
    feedbackTableView.dataSource = self
    feedbackTableView.register(UITableViewCell.self, forCellReuseIdentifier: FeedbackTableViewCell.identifier)
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
