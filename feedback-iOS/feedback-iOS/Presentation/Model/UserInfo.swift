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
  let peerID: MCPeerID
  let role: String
  
  init(uuid: String, peerID: MCPeerID, role: String) {
    self.uuid = uuid
    self.peerID = peerID
    self.role = role
  }
  
  enum CodingKeys: String, CodingKey {
    case uuid
    case peerID
    case role
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(peerID.displayName, forKey: .peerID)
    try container.encode(role, forKey: .role)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uuid = try container.decode(String.self, forKey: .uuid)
    let peerIDString = try container.decode(String.self, forKey: .peerID)
    peerID = MCPeerID(displayName: peerIDString)
    role = try container.decode(String.self, forKey: .role)
  }
}
