//
//  PeerInfoManager.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/8/24.
//

import MultipeerConnectivity

final class PeerInfoManager {
  static let shared = PeerInfoManager()
  private init() {}
  
  var connectedUserInfos: [UserInfo] = []
  var myFeedbackDatas: [SkillSet] = []
  var resultData: SkillSet = SkillSet(categories: [communication, selfDevelopment, problemSolving, teamwork, leadership])
  
  func addPeerInfo(_ userInfo: UserInfo) {
    connectedUserInfos.append(userInfo)
    print("Peer 정보 추가됨: \(userInfo)")
  }
  
  func updateFeedback(with feedbackData: SkillSet) {
    myFeedbackDatas.append(feedbackData)
    for (categoryIndex, category) in feedbackData.categories.enumerated() {
      for (traitIndex, trait) in category.traits.enumerated() {
        resultData.categories[categoryIndex].traits[traitIndex].count += trait.count
      }
    }
  }
}
