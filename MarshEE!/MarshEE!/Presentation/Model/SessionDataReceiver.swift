//
//  SessionDataReceiver.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/8/24.
//

import MultipeerConnectivity

final class SessionDataReceiver {
  static let shared = SessionDataReceiver()
  private init() {}
  
  func processReceivedData(_ data: Data, from peerID: MCPeerID) {
    if let receivedMessageData = try? JSONDecoder().decode(MessageData.self, from: data) {
      print("수신한 메시지: \(receivedMessageData.message)")
      
      switch receivedMessageData.message {
        
      case "startFeedback":
        if let allUserInfoData = try? JSONDecoder().decode(
          [UserInfo].self,
          from: receivedMessageData.data
        ) {
          PeerInfoManager.shared.connectedUserInfos = allUserInfoData
          DispatchQueue.main.async {
            SessionManager.shared.onPushDataReceived?()
          }
        }
        
      case "sendFeedback":
        if let receivedFeedbackData = try? JSONDecoder().decode(SkillSet.self, from: receivedMessageData.data) {
          PeerInfoManager.shared.myFeedbackDatas.append(receivedFeedbackData)

          PeerInfoManager.shared.resultData = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])

          for feedbackData in PeerInfoManager.shared.myFeedbackDatas {
            for (categoryIndex, category) in feedbackData.categories.enumerated() {
              for (traitIndex, trait) in category.traits.enumerated() {
                PeerInfoManager.shared.resultData.categories[categoryIndex].traits[traitIndex].count += trait.count
              }
            }
          }
        }
        
      case "feedbackCompleted":
        SessionManager.shared.feedbackCompletionCount += 1
        print("피드백 완료 인원 추가")
        
      case "showResults":
        DispatchQueue.main.async {
          SessionManager.shared.onPushDataReceived?()
        }
        
      default:
        print("알 수 없는 메시지: \(receivedMessageData.message)")
      }
    }
  }
}
