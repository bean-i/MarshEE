//
//  TestViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import MultipeerConnectivity
import UIKit

import SnapKit
import Then

final class TestViewController: UIViewController {
  
  var peerID: MCPeerID!
  var session: MCSession!
  var advertiser: MCNearbyServiceAdvertiser!
  var browser: MCBrowserViewController!
  
  let makeFeedbackButton = UIButton()
  let enterFeedbackButton = UIButton()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    let serviceType = "feedbacksession"
    
    peerID = MCPeerID(displayName: UIDevice.current.name)
    session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    session.delegate = self
    
    browser = MCBrowserViewController(serviceType: serviceType, session: session)
    browser.delegate = self
    
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  private func setStyle() {
    
    title = "FeedBack!"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    
    makeFeedbackButton.do {
      $0.setTitle("세션 생성", for: .normal)
      $0.backgroundColor = .gray
    }
    
    enterFeedbackButton.do {
      $0.setTitle("세션 참여", for: .normal)
      $0.backgroundColor = .gray
    }
    
    makeFeedbackButton.addTarget(self, action: #selector(makeFeedbackButtonTapped), for: .touchUpInside)
    enterFeedbackButton.addTarget(self, action: #selector(enterFeedbackButtonTapped), for: .touchUpInside)
  }
  
  private func setUI() {
    view.addSubviews(makeFeedbackButton, enterFeedbackButton)
  }
  
  private func setAutoLayout() {
    makeFeedbackButton.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(50)
    }
    
    enterFeedbackButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(makeFeedbackButton.snp.bottom).offset(20)
      $0.width.equalTo(100)
      $0.height.equalTo(50)
    }
  }
  
  @objc func makeFeedbackButtonTapped() {
    let serviceType = "feedbacksession"
    
    advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
    advertiser.delegate = self
    advertiser.startAdvertisingPeer()
    
    let sessionVC = SessionViewController()
    sessionVC.session = self.session
    sessionVC.peers = allPeersIncludingHost()
    navigationController?.pushViewController(sessionVC, animated: true)
    
    print("세션 생성 및 광고 시작")
  }
  
  @objc func enterFeedbackButtonTapped() {
    present(browser, animated: true)
  }
  
  func allPeersIncludingHost() -> [MCPeerID] {
    return [peerID] + session.connectedPeers
  }
}

extension TestViewController: MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    dismiss(animated: true)
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    dismiss(animated: true)
  }
}

extension TestViewController: MCSessionDelegate {
  
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("피어 연결됨: \(peerID.displayName)")
    case .connecting:
      print("피어 연결 중: \(peerID.displayName)")
    case .notConnected:
      print("피어 연결 끊김: \(peerID.displayName)")
    @unknown default:
      fatalError("알 수 없는 상태")
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension TestViewController: MCNearbyServiceAdvertiserDelegate {
  
  // 피어로부터 참여 요청을 받았을 때 호출되는 메서드
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    
    // 피어로부터의 초대를 수락할지 결정
    let alert = UIAlertController(title: "세션 요청", message: "\(peerID.displayName) 가 세션에 참여를 요청했습니다.", preferredStyle: .alert)
    
    // 수락 버튼
    alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { _ in
      // 세션 참여를 수락하고 세션을 연결
      invitationHandler(true, self.session)  // self.session은 사용자의 MCSession 인스턴스
    }))
    
    // 거절 버튼
    alert.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
      // 세션 참여를 거절
      invitationHandler(false, nil)
    }))
    
    // 사용자에게 알림 표시
    present(alert, animated: true, completion: nil)
  }
}
