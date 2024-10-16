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
      
      if !SessionManager.shared.isHost {
        do {
          if let localUserInfo = SessionManager.shared.localUserInfo {
            let localUserInfoData = try JSONEncoder().encode(localUserInfo)
            let jsonString = String(data: localUserInfoData, encoding: .utf8)
            print("LocalUserInfo JSON: \(jsonString ?? "nil")")
            
            if let hostPeer = SessionManager.shared.session.connectedPeers.first {
              SessionManager.shared.sendData(
                localUserInfoData,
                message: "localUserInfo",
                to: [hostPeer]
              )
              print("LocalUserInfo 전송 완료")
            }
          } else {
            print("LocalUserInfo가 nil입니다.")
          }
        } catch {
          print("LocalUserInfo 인코딩 실패: \(error.localizedDescription)")
        }
      }
    }
    
    SessionManager.shared.onDataReceived = { [weak self] (data, departureID) in
      print("데이터 수신 시도 from: \(departureID.displayName)")
      if let receivedMessageData = try? JSONDecoder().decode(MessageData.self, from: data) {
        print("수신한 메시지: \(receivedMessageData.message)")
        
        switch receivedMessageData.message {
          //        case "hostPeerID":
          //          if let hostPeerIDString = try? JSONDecoder().decode(String.self, from: receivedMessageData.data) {
          //            print("Peer가 받은 Host의 PeerID: \(hostPeerIDString)")
          //
          //            if let hostPeerID = SessionManager.shared.session.connectedPeers.first(where: { $0.displayName == hostPeerIDString }) {
          //              print("Host PeerID: \(hostPeerID)")
          //
          //              if let localUserInfoData = try? JSONEncoder().encode(SessionManager.shared.localUserInfo) {
          //                SessionManager.shared.sendData(
          //                  localUserInfoData,
          //                  message: "localUserInfo",
          //                  to: [hostPeerID]
          //                )
          //                print("LocalUserInfo 전송 성공")
          //              }
          //            }
          //          }
          
        case "localUserInfo":
          if let receivedUserInfo = try? JSONDecoder().decode(
            UserInfo.self,
            from: receivedMessageData.data
          ) {
            SessionManager.shared.receivedUserInfos.append(receivedUserInfo)
            print("Received user info: \(receivedUserInfo.peerID)")
          }
          
        case "start feedback":
          let feedbackVC = FeedbackViewController()
          self?.navigationController?.pushViewController(feedbackVC, animated: true)
          
        default:
          print("알 수 없는 메시지: \(receivedMessageData.message)")
        }
        print("\(receivedMessageData.message) 데이터 수신 성공")
      }
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
    print(SessionManager.shared.receivedUserInfos)
    do {
      let allUserInfoData = try JSONEncoder().encode(SessionManager.shared.receivedUserInfos)
      SessionManager.shared.sendData(allUserInfoData, message: "start feedback", to: SessionManager.shared.session.connectedPeers)
    } catch {
      print("피어 정보 전송 실패: \(error.localizedDescription)")
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
