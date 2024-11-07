import MultipeerConnectivity

struct MessageData: Codable {
  let message: String
  let data: Data
}

struct UserInfo: Codable, Equatable, Hashable {
  let uuid: String
  let peerID: String
  let role: String
  
  init(uuid: String, peerID: MCPeerID, role: String) {
    self.uuid = uuid
    self.peerID = peerID.displayName
    self.role = role
  }
  
  static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
    return lhs.uuid == rhs.uuid && lhs.peerID == rhs.peerID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
    hasher.combine(peerID)
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
  var feedbackCompletionCount: Int = 0
  
  var connectedUserInfos: [UserInfo] = []
  var myFeedbackDatas: [SkillSet] = []
  var resultData: SkillSet = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])
  
  var onPeersChanged: (() -> Void)?
  var onDataReceived: ((Data, MCPeerID) -> Void)?
  var onPushDataReceived: (() -> Void)?
  
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
    session = MCSession(
      peer: peerID,
      securityIdentity: nil,
      encryptionPreference: .required
    )
    session.delegate = self
    
    if isHost {
      setAdvertiser()
      if let localUserInfo = localUserInfo {
        connectedUserInfos.append(localUserInfo)
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
    browser = MCBrowserViewController(serviceType: serviceType, session: session)
    browser?.delegate = delegate
  }
  
  func sendData(_ data: Data, message: String, to: [MCPeerID]) {
    guard !session.connectedPeers.isEmpty else { return }
    
    let messageData = MessageData(message: message, data: data)
    
    do {
      let encodedMessageData = try JSONEncoder().encode(messageData)
      
      try session.send(encodedMessageData, toPeers: to, with: .reliable)
    } catch {
      print("데이터 전송 실패: \(error.localizedDescription)")
    }
  }
  
  func checkAllFeedbackCompleted() {
    if feedbackCompletionCount == connectedUserInfos.count {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        if let pushResultData = try? JSONEncoder().encode(self.localUserInfo) {
          self.sendData(pushResultData, message: "showResults", to: self.session.connectedPeers)
        }
        let resultVC = ResultViewController()
        if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
          navigationController.pushViewController(resultVC, animated: true)
        }
      }
    }
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
      if !SessionManager.shared.isHost {
        if let hostPeerID = SessionManager.shared.session.connectedPeers.first,
           let localUserInfoData = try? JSONEncoder().encode(localUserInfo) {
          sendData(
            localUserInfoData,
            message: "localUserInfo",
            to: [hostPeerID]
          )
          print("Peer가 Host에게 LocalUserInfo 전송")
        }
      }
    case .connecting:
      print("연결 중: \(peerID.displayName)")
    case .notConnected:
      print("연결 끊김: \(peerID.displayName)")
    @unknown default:
      fatalError("알 수 없는 상태")
    }
    
    DispatchQueue.main.async {
      self.onPeersChanged?()
    }
  }
  
  func session(
    _ session: MCSession,
    didReceive data: Data,
    fromPeer departureID: MCPeerID
  ) {
    DispatchQueue.main.async {
      self.onDataReceived?(data, departureID)
    }
    
    if let receivedMessageData = try? JSONDecoder().decode(MessageData.self, from: data) {
      print("수신한 메시지: \(receivedMessageData.message)")
      
      switch receivedMessageData.message {
        
      case "localUserInfo":
        if let receivedUserInfo = try? JSONDecoder().decode(
          UserInfo.self,
          from: receivedMessageData.data
        ) {
          SessionManager.shared.connectedUserInfos.append(receivedUserInfo)
          print("Peer가 Session에 입장, Host가 Peer의 LocalUserInfo를 수신")
        }
        
      case "startFeedback":
        if let receivedUserInfoData = try? JSONDecoder().decode(
          [UserInfo].self,
          from: receivedMessageData.data
        ) {
          self.connectedUserInfos = receivedUserInfoData
          DispatchQueue.main.async {
            self.onPushDataReceived?()
          }
        }
        
      case "sendFeedback":
        if let receivedFeedbackData = try? JSONDecoder().decode(SkillSet.self, from: receivedMessageData.data) {
          self.myFeedbackDatas.append(receivedFeedbackData)
          
          resultData = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])
          
          for feedbackData in myFeedbackDatas {
            for (categoryIndex, category) in feedbackData.categories.enumerated() {
              for (traitIndex, trait) in category.traits.enumerated() {
                resultData.categories[categoryIndex].traits[traitIndex].count += trait.count
              }
            }
          }
        }
        
      case "feedbackCompleted":
        feedbackCompletionCount += 1
        print("피드백 완료 인원 추가")
        if isHost {
          checkAllFeedbackCompleted()
        }
        
      case "showResults":
        DispatchQueue.main.async {
          self.onPushDataReceived?()
        }
        
      default:
        print("알 수 없는 메시지: \(receivedMessageData.message)")
      }
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

