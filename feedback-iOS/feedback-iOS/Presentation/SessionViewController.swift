//
//  SessionViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit
import MultipeerConnectivity
import SnapKit

class SessionViewController: UIViewController {
  
  var session: MCSession!
  var peers: [MCPeerID] = []
  
  let peersTableView = UITableView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    title = "세션 참가자"
    
    session.delegate = self
    peersTableView.delegate = self
    peersTableView.dataSource = self
    peersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "peerCell")
    
    setUI()
    setAutoLayout()
  }
  
  func setUI() {
    view.addSubviews(peersTableView)
  }
  
  func setAutoLayout() {
    peersTableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

extension SessionViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
    let peerID = peers[indexPath.row]
    cell.textLabel?.text = peerID.displayName
    return cell
  }
}

extension SessionViewController: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("연결됨: \(peerID.displayName)")
      peers.append(peerID)
    case .notConnected:
      print("연결 끊김: \(peerID.displayName)")
      if let index = peers.firstIndex(of: peerID) {
        peers.remove(at: index)
      }
    case .connecting:
      print("연결 중: \(peerID.displayName)")
    @unknown default:
      fatalError("알 수 없는 상태")
    }
    
    DispatchQueue.main.async {
      self.peersTableView.reloadData()
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
