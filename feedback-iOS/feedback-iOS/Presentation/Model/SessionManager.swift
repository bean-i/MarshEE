import MultipeerConnectivity

struct MessageData: Codable {
  let message: String
  let data: Data
}

struct UserInfo: Codable {
  let uuid: String
  let peerID: String
  let role: String
  
  init(uuid: String, peerID: MCPeerID, role: String) {
    self.uuid = uuid
    self.peerID = peerID.displayName
    self.role = role
  }
}

final class SessionManager: NSObject {
  
  static let shared = SessionManager()
  
  var peerID: MCPeerID!
  var session: MCSession!
  var advertiser: MCNearbyServiceAdvertiser?
  var browser: MCBrowserViewController?
  var localUserInfo: UserInfo?
  var projectName: String?
  var isHost: Bool = false
  var receivedUserInfos: [UserInfo] = []
  
  var onPeersChanged: (() -> Void)?
  var onDataReceived: ((Data, MCPeerID) -> Void)?
  
  var localUserUUID: String {
    if let uuid = UserDefaults.standard.string(forKey: "localUserUUID") {
      return uuid
    } else {
      let newUUID = UUID().uuidString
      UserDefaults.standard.set(newUUID, forKey: "localUserUUID")
      return newUUID
    }
  }
  
  private let serviceType = "feedbacksession"
  
  private override init() {
    super.init()
  }
  
  func setLocalUserInfo(name: String, role: String) {
    let peerID = MCPeerID(displayName: name)
    localUserInfo = UserInfo(
      uuid: localUserUUID,
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
    session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    session.delegate = self
    
    if isHost {
      setAdvertiser()
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
    browser = MCBrowserViewController(serviceType: serviceType, session: session)
    browser?.delegate = delegate
  }
  
  func sendData(_ data: Data, message: String, to: [MCPeerID]) {
    guard !session.connectedPeers.isEmpty else { return }
    
    let messageData = MessageData(message: message, data: data)
    
    do {
      let encodedMessageData = try JSONEncoder().encode(messageData)
      
      try session.send(encodedMessageData, toPeers: to, with: .reliable)
      print("\(message) 데이터 전송 성공")
    } catch {
      print("데이터 전송 실패: \(error.localizedDescription)")
    }
  }
}

// MARK: - MCSessionDelegate
extension SessionManager: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("연결됨: \(peerID.displayName)")
      // 피어가 연결된 후 LocalUserInfo 전송
      if !self.isHost, let localUserInfo = self.localUserInfo {
        do {
          let localUserInfoData = try JSONEncoder().encode(localUserInfo)
          let jsonString = String(data: localUserInfoData, encoding: .utf8)
          print("LocalUserInfo JSON: \(jsonString ?? "nil")")
          
          // Host에게 LocalUserInfo 전송
          if let hostPeer = session.connectedPeers.first {
            self.sendData(
              localUserInfoData,
              message: "localUserInfo",
              to: [hostPeer]
            )
            print("LocalUserInfo 전송 완료")
          }
        } catch {
          print("LocalUserInfo 인코딩 실패: \(error.localizedDescription)")
        }
      }
      
      DispatchQueue.main.async {
        self.onPeersChanged?()
      }
    case .connecting:
      print("연결 중: \(peerID.displayName)")
    case .notConnected:
      print("연결 끊김: \(peerID.displayName)")
    @unknown default:
      fatalError("알 수 없는 상태")
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer departureID: MCPeerID) {
    DispatchQueue.main.async {
      self.onDataReceived?(data, departureID)
    }
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
  }
  
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
    // 피어의 초대 처리
    invitationHandler(true, session) // 자동 수락 예시
  }
}
