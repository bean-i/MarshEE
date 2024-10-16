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

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    SessionManager.shared.stopSession()
  }

  func setStyle() {
    view.backgroundColor = .white

    title = "세션 참가자"

    startFeedbackButton.do {
      $0.setTitle("피드백 시작", for: .normal)
      $0.backgroundColor = .gray
      $0.setLayer(borderColor: .clear, cornerRadius: 20)
    }

    waitingLabel.do {
      $0.text = "참가 대기 중"
    }

    startFeedbackButton.addTarget(self, action: #selector(startFeedbackButtonTapped), for: .touchUpInside)
  }

  func setUI() {
    view.addSubviews(peersTableView, startFeedbackButton, waitingLabel)
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

    waitingLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
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

    SessionManager.shared.onDataReceived = { [weak self] (data, peerID) in
      guard let message = String(data: data, encoding: .utf8), message == "Start Feedback" else { return }
      let feedbackVC = FeedbackViewController()
      self?.navigationController?.pushViewController(feedbackVC, animated: true)
    }
  }

  func updateUI() {
    let isHost = SessionManager.shared.isHost
    startFeedbackButton.isHidden = !isHost
    waitingLabel.isHidden = isHost
  }

  @objc func startFeedbackButtonTapped() {
    let message = "Start Feedback".data(using: .utf8)!
    do {
      try SessionManager.shared.session.send(message, toPeers: SessionManager.shared.session.connectedPeers, with: .reliable)
      print("화면 전환 신호 전송됨")
    } catch {
      print("메시지 전송 실패: \(error.localizedDescription)")
    }
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
