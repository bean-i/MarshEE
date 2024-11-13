//
//  SessionManager.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/8/24.
//

import MultipeerConnectivity

final class SessionManager: NSObject {
  static let shared = SessionManager()
  
  var peerID: MCPeerID!
  var session: MCSession!
  var advertiser: MCNearbyServiceAdvertiser?
  var browser: MCBrowserViewController?
  var localUserInfo: UserInfo?
  var isHost: Bool = false
  var projectName: String?
  
  private let serviceType = "feedbacksession"
  private let dataProcessingQueue = DispatchQueue(label: "com.example.feedback.dataProcessing")
  
  var feedbackCompletionCount: Int = 0 {
    didSet {
      checkAllFeedbackCompleted()
    }
  }
  var onSessionConnected: (() -> Void)?
  var onPeersChanged: (() -> Void)?
  var onDataReceived: ((Data, MCPeerID) -> Void)?
  var onPushDataReceived: (() -> Void)?
  
  private override init() { super.init() }
  
  func setLocalUserInfo(name: String, role: String) {
    let peerID = MCPeerID(displayName: name)
    localUserInfo = UserInfo(
      uuid: UUID().uuidString,
      peerID: peerID,
      role: role
    )
  }
  
  func setSession(
    isHost: Bool,
    displayName: String,
    projectName: String? = nil,
    delegate: MCBrowserViewControllerDelegate? = nil
  ) {
    self.isHost = isHost
    self.projectName = projectName ?? "DefaultProject"
    
    peerID = MCPeerID(displayName: displayName)
    session = MCSession(
      peer: peerID,
      securityIdentity: nil,
      encryptionPreference: .required
    )
    session.delegate = self
    
    if isHost {
      setAdvertiser()
      if let localUserInfo = localUserInfo {
        PeerInfoManager.shared.connectedUserInfos.append(localUserInfo)
      }
    } else {
      setBrowser(delegate: delegate)
    }
  }
  
  func stopSession() {
    session.disconnect()
    
    if isHost {
      advertiser?.stopAdvertisingPeer()
    } else {
      browser?.dismiss(animated: true, completion: nil)
    }
    print("세션 종료됨")
  }
  
  private func setAdvertiser() {
    advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
    advertiser?.delegate = self
    advertiser?.startAdvertisingPeer()
  }
  
  private func setBrowser(delegate: MCBrowserViewControllerDelegate?) {
    browser = MCBrowserViewController(
      serviceType: serviceType,
      session: session
    )
    browser?.delegate = delegate
  }
  
  func checkAllFeedbackCompleted() {
    print("\(feedbackCompletionCount)")
    if feedbackCompletionCount == PeerInfoManager.shared.connectedUserInfos.count {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        if let pushResultData = try? JSONEncoder().encode(self.localUserInfo) {
          SessionDataSender.shared.sendData(
            pushResultData,
            message: "showResults",
            to: self.session.connectedPeers
          )
        }
        self.onPushDataReceived?()
      }
    }
  }
  
  func reset() {
    stopSession()
    peerID = nil
    session = nil
    advertiser = nil
    browser = nil
    localUserInfo = nil
    isHost = false
    projectName = nil
    feedbackCompletionCount = 0
    onPeersChanged = nil
    onDataReceived = nil
    onPushDataReceived = nil
    print("SessionManager 초기화 완료")
  }
}

// MARK: - MCSessionDelegate
extension SessionManager: MCSessionDelegate {
  func session(
    _ session: MCSession,
    peer peerID: MCPeerID,
    didChange state: MCSessionState
  ) {
    switch state {
    case .connected:
      print("연결됨: \(peerID.displayName)")
      
    case .connecting:
      print("연결 중: \(peerID.displayName)")
      
    case .notConnected:
      print("연결 끊김: \(peerID.displayName)")
      
    @unknown default:
      fatalError("알 수 없는 상태")
    }
    DispatchQueue.main.async { self.onPeersChanged?() }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    dataProcessingQueue.async {
      DispatchQueue.main.async {
        self.onDataReceived?(data, peerID)
      }
      SessionDataReceiver.shared.processReceivedData(data, from: peerID)
      print("\(peerID.displayName)의 \(data)처리")
    }
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCBrowserViewControllerDelegate
extension SessionManager: MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true, completion: nil)
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true, completion: nil)
  }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension SessionManager: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }
}
