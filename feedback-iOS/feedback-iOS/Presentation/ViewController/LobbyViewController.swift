//
//  LobbyViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import MultipeerConnectivity
import UIKit
import SwiftUI

import Then
import SnapKit

class LobbyViewController: UIViewController {
  
  let peersTableView = UITableView()
  let startFeedbackButton = UIButton()
  let activityIndicator = UIActivityIndicatorView()
  let waitingLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStyle()
    setUI()
    setAutoLayout()
    setTableView()
    setSession()
    updateUI()
  }
  
  func setStyle() {
    view.backgroundColor = .white
    title = "세션 참가자"
    
    startFeedbackButton.do {
      $0.setTitle("피드백 시작", for: .normal)
      $0.backgroundColor = .gray
      $0.setLayer(borderColor: .clear, cornerRadius: 20)
    }
    
    activityIndicator.do {
      $0.style = .large
      $0.startAnimating()
    }
    
    waitingLabel.do {
      $0.text = "Wail Until Every Participants Join"
      $0.font = UIFont.sfPro(.body)
      $0.textColor = UIColor.lightGray
    }
    
    startFeedbackButton.addTarget(self, action: #selector(startFeedbackButtonTapped), for: .touchUpInside)
  }
  
  func setUI() {
    view.addSubviews(peersTableView, startFeedbackButton, activityIndicator, waitingLabel)
  }
  
  func setAutoLayout() {
    peersTableView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(500)
    }
    
    startFeedbackButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
      $0.width.equalTo(250)
      $0.height.equalTo(50)
    }
    
    activityIndicator.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
    }
    
    waitingLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(activityIndicator.snp.bottom).offset(5)
    }
  }
  
  func setTableView() {
    peersTableView.delegate = self
    peersTableView.dataSource = self
    peersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "peerCell")
  }
  
  func setSession() {
    SessionManager.shared.onPeersChanged = { [weak self] in
      self?.peersTableView.reloadData()
    }
    
    SessionManager.shared.onPushDataReceived = { [weak self] in
        let feedbackVC = FeedbackViewController()
        self?.navigationController?.pushViewController(feedbackVC, animated: true)
    }
  }
  
  func updateUI() {
    let isHost = SessionManager.shared.isHost
    
    startFeedbackButton.isHidden = !isHost
    peersTableView.isHidden = !isHost
    
    activityIndicator.isHidden = isHost
    waitingLabel.isHidden = isHost
  }
  
  @objc func startFeedbackButtonTapped() {
    do {
      let allUserInfoData = try JSONEncoder().encode(SessionManager.shared.receivedUserInfos)
      SessionManager.shared.sendData(
        allUserInfoData,
        message: "startFeedback",
        to: SessionManager.shared.session.connectedPeers
      )
    } catch {
      print("\(error.localizedDescription)")
    }
    
    let feedbackVC = FeedbackViewController()
    self.navigationController?.pushViewController(feedbackVC, animated: true)
  }
}

extension LobbyViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SessionManager.shared.session.connectedPeers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
    let peerID = SessionManager.shared.session.connectedPeers[indexPath.row]
    cell.textLabel?.text = peerID.displayName
    return cell
  }
}
