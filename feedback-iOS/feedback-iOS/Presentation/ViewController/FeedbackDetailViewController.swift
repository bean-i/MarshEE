//
//  FeedbackDetailViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/18/24.
//

import UIKit

final class FeedbackDetailViewController: UIViewController {
  
  var selectedUserInfo: UserInfo?
  
  let button = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setButton()
    setAutolayout()
  }
  
  func setButton() {
    button.setTitle("Perform Action", for: .normal)
    button.backgroundColor = .blue
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    view.addSubview(button)
  }
  
  func setAutolayout() {
    button.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(50)
    }
  }
  
  @objc func buttonTapped() {
    if let selectedUserInfo = selectedUserInfo {
      do {
        if let targetPeerID = SessionManager.shared.session.connectedPeers.first(where: { $0.displayName == selectedUserInfo.peerID }) {
          
          let testData = try JSONEncoder().encode(SessionManager.shared.localUserInfo?.peerID)
          
          SessionManager.shared.sendData(testData, message: "sendFeedback", to: [targetPeerID])
        } else {
          print("해당 피어를 찾을 수 없습니다.")
        }
      } catch {
        print("데이터 인코딩 실패: \(error.localizedDescription)")
      }
    }
  }
}
