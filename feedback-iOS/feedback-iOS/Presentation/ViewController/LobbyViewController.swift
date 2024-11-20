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
    title = "찌르기 대기"
    
    startFeedbackButton.do {
      $0.setTitle("찌르기", for: .normal)
      $0.setImage(UIImage(systemName: "hand.point.right.fill"), for: .normal)
      $0.tintColor = .white
      $0.backgroundColor = .systemBlue
      $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
      $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
      $0.setLayer(borderColor: .clear, cornerRadius: 12)
      $0.addTarget(self, action: #selector(startFeedbackButtonTapped), for: .touchUpInside)
    }
    
    activityIndicator.do {
      $0.style = .large
      $0.startAnimating()
    }
    
    waitingLabel.do {
      $0.text = "멤버가 모두 참여할 때까지 대기"
      $0.font = UIFont.sfPro(.body)
      $0.textColor = UIColor.lightGray
    }
    
    peersTableView.do {
      $0.layer.cornerRadius = 10
      $0.clipsToBounds = true
    }
    
  }
  
  func setUI() {
    view.addSubviews(
      peersTableView,
      startFeedbackButton,
      activityIndicator,
      waitingLabel
    )
  }
  
  func setAutoLayout() {
    peersTableView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(400)
    }
    
    startFeedbackButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
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
    peersTableView.isScrollEnabled = false
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
      if let connectedUserInfoData = try? JSONEncoder().encode(PeerInfoManager.shared.connectedUserInfos) {
        SessionDataSender.shared.sendData(
          connectedUserInfoData,
          message: "startFeedback",
          to: SessionManager.shared.session.connectedPeers
        )
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
