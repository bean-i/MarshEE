//
//  SessionDataSender.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/8/24.
//

import MultipeerConnectivity

final class SessionDataSender {
  static let shared = SessionDataSender()
  private init() {}
  
  func sendData(_ data: Data, message: String, to: [MCPeerID]) {
    guard !SessionManager.shared.session.connectedPeers.isEmpty else { return }
    let messageData = MessageData(message: message, data: data)
    
    do {
      let encodedMessageData = try JSONEncoder().encode(messageData)
      try SessionManager.shared.session.send(encodedMessageData, toPeers: to, with: .reliable)
      print("데이터 전송 성공: \(message)")
    } catch {
      print("데이터 전송 실패: \(error.localizedDescription)")
    }
  }
}
