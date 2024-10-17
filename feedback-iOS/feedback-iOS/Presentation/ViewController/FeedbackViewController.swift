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
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    setStyle()
    setUI()
    setAutolayout()
    setTableView()
  }
  
  func setStyle() {
  }
  
  func setUI() {
    view.addSubview(feedbackTableView)
  }
  
  func setAutolayout() {
    feedbackTableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setTableView() {
    feedbackTableView.delegate = self
    feedbackTableView.dataSource = self
    feedbackTableView.register(UITableViewCell.self, forCellReuseIdentifier: FeedbackTableViewCell.identifier)
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
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedUserInfo = SessionManager.shared.receivedUserInfos[indexPath.row]
    
    let detailVC = FeedbackDetailViewController()
    detailVC.selectedUserInfo = selectedUserInfo
    
    detailVC.modalPresentationStyle = .fullScreen
    present(detailVC, animated: true, completion: nil)
  }
}
