//
//  UserInfo.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/8/24.
//

import MultipeerConnectivity
import UIKit

struct UserInfo: Codable, Equatable, Hashable {
  let uuid: String
  let peerID: String
  let role: String
  
  init(uuid: String, peerID: MCPeerID, role: String) {
    self.uuid = uuid
    self.peerID = peerID.displayName
    self.role = role
  }
}
