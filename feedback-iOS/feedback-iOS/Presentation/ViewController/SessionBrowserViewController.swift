//
//  SessionBrowserViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 11/19/24.
//

import MultipeerConnectivity
import UIKit

import SnapKit

final class SessionBrowserViewController: UIViewController {
  private let sessionTableView = UITableView()
  private var nearbyServiceBrowser: MCNearbyServiceBrowser!
  private var discoveredSessions: [(peerID: MCPeerID, sessionName: String)] = []
  var localUserInfoData: Data?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUI()
    setStyle()
    setAutoLayout()
    setTableView()
    startBrowsing()
    encodeLocalUserInfo()
  }
  
  private func setUI() {
    view.addSubview(sessionTableView)
  }
  
  private func setStyle() {
    view.backgroundColor = .white
    title = "피드백에 참가하기"
  }
  
  private func setAutoLayout() {
    sessionTableView.snp.makeConstraints() {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setTableView() {
    sessionTableView.delegate = self
    sessionTableView.dataSource = self
    sessionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
  }
  
  private func startBrowsing() {
    nearbyServiceBrowser = MCNearbyServiceBrowser(
      peer: SessionManager.shared.peerID,
      serviceType: "feedbacksession"
    )
    nearbyServiceBrowser.delegate = self
    nearbyServiceBrowser.startBrowsingForPeers()
  }
  
  private func stopBrowsing() {
    nearbyServiceBrowser.stopBrowsingForPeers()
  }
  
  private func encodeLocalUserInfo() {
    do {
      localUserInfoData = try JSONEncoder().encode(SessionManager.shared.localUserInfo)
    } catch {
      print("Error: \(error.localizedDescription)")
    }
  }
}

extension SessionBrowserViewController: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    if !discoveredSessions.contains(where: { $0.peerID == peerID }) {
      let sessionName = info?["sessionName"] ?? "Unknown Session"
      discoveredSessions.append((peerID: peerID, sessionName: sessionName))
      sessionTableView.reloadData()
    }
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    if let index = discoveredSessions.firstIndex(where: { $0.peerID == peerID }) {
      discoveredSessions.remove(at: index)
      sessionTableView.reloadData()
    }
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    print("브라우저 시작 실패: \(error.localizedDescription)")
  }
}

extension SessionBrowserViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return discoveredSessions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
    let session = discoveredSessions[indexPath.row]
    cell.textLabel?.text = "\(session.sessionName)"
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedSession = discoveredSessions[indexPath.row]
    let alert = UIAlertController(
      title: "세션 입장 확인",
      message: "\(selectedSession.sessionName) 세션에 입장하시겠습니까?",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
      guard let self = self else { return }
      
      if let context = self.localUserInfoData {
        self.nearbyServiceBrowser.invitePeer(
          selectedSession.peerID,
          to: SessionManager.shared.session,
          withContext: context,
          timeout: 30
        )
      }
      
      self.stopBrowsing()
      self.dismiss(animated: true, completion: nil)
      
      let LobbyVC = LobbyViewController()
      self.navigationController?.pushViewController(LobbyVC, animated: true)
    })
    
    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
}
