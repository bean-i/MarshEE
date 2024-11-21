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
  let activityIndicatorForHost = UIActivityIndicatorView()
  let activityIndicatorForPeer = UIActivityIndicatorView()
  let waitingLabelForHost = UILabel()
  let waitingLabelForPeer = UILabel()
  
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
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "뒤로",
      style: .plain,
      target: self,
      action: #selector(backButtonTapped)
    )
    
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
    
    activityIndicatorForHost.do {
      $0.style = .large
      $0.startAnimating()
    }
    
    activityIndicatorForPeer.do {
      $0.style = .large
      $0.startAnimating()
    }
    
    waitingLabelForHost.do {
      $0.text = "멤버들이 참가 중입니다"
      $0.font = UIFont.sfPro(.body)
      $0.textColor = UIColor.lightGray
    }
    
    waitingLabelForPeer.do {
      $0.text = "멤버가 모두 참여할 때까지 대기하세요"
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
      activityIndicatorForHost,
      activityIndicatorForPeer,
      waitingLabelForHost,
      waitingLabelForPeer
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
    
    activityIndicatorForHost.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
    
    activityIndicatorForPeer.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
    
    waitingLabelForHost.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(activityIndicatorForHost.snp.bottom).offset(5)
    }
    
    waitingLabelForPeer.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(activityIndicatorForPeer.snp.bottom).offset(5)
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
      print(PeerInfoManager.shared.connectedUserInfos)
      if self!.peersTableView.dataSource?.numberOfSections?(in: self!.peersTableView) != 0 {
        self!.activityIndicatorForHost.isHidden = true
        self!.waitingLabelForHost.isHidden = true
      } else {
        self!.activityIndicatorForHost.isHidden = false
        self!.waitingLabelForHost.isHidden = false
      }
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
    
    activityIndicatorForPeer.isHidden = isHost
    waitingLabelForPeer.isHidden = isHost
    
    activityIndicatorForHost.isHidden = !isHost
    waitingLabelForHost.isHidden = !isHost
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
  
  @objc private func backButtonTapped() {
    SessionManager.shared.reset()
    PeerInfoManager.shared.reset()
    navigationController?.popViewController(animated: true)
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
