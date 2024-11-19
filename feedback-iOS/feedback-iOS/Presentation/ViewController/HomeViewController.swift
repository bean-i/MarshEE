//
//  HomeViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.

import MultipeerConnectivity
import SnapKit
import Then
import UIKit

final class HomeViewController: UIViewController {
  
  // MARK: - Components
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let tapGesture = UITapGestureRecognizer()
  
  private let mainImageView = UIImageView()
  private let mainTitleLabel = UILabel()
  private let subTitleLabel = UILabel()
  
  private let userInfoHeaderLabel = UILabel()
  private let userInfoContainerView = UIView()
  private let userNameLabel = UILabel()
  private var userNameTextField = UITextField()
  private let lineView = UIView()
  private let userDescriptionLabel = UILabel()
  private var userDescriptionTextField = UITextField()
  private let userInfoFooterLabel = UILabel()
  
  private let buttonHeaderLabel = UILabel()
  private let createButton = UIButton()
  private let joinButton = UIButton()
  private let buttonStackView = UIStackView()
  private let buttonFooterLabel = UILabel()
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureTapGesture()
    configureNotifications()
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - UI Setup
  private func setStyle() {
    // View Background Color 적용
    view.backgroundColor = .systemGray6
    
    // Configure Navigation Bar
    configureNavigationBar()
    
    // Configure Sections
    configureMainSectionStyle()
    configureUserInfoSectionStyle()
    configureButtonSectionStyle()
  }
  
  private func setUI() {
    
    [createButton, joinButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
    
    contentView.addSubviews(
      mainImageView,
      mainTitleLabel,
      subTitleLabel,
      userInfoHeaderLabel,
      userInfoContainerView,
      userNameLabel,
      userNameTextField,
      lineView,
      userDescriptionLabel,
      userDescriptionTextField,
      userInfoFooterLabel,
      buttonHeaderLabel,
      buttonStackView,
      buttonFooterLabel
    )
    
    scrollView.addSubview(contentView)
    view.addSubviews(scrollView)
    
  }
  
  private func setAutoLayout() {
    
    scrollView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    mainImageView.snp.makeConstraints {
      $0.top.equalTo(contentView.snp.top).offset(50)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(128)
    }
    
    mainTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mainImageView.snp.bottom).offset(22)
      $0.centerX.equalToSuperview()
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mainTitleLabel.snp.bottom).offset(22)
      $0.centerX.equalToSuperview()
    }
    
    userInfoHeaderLabel.snp.makeConstraints {
      $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
      $0.leading.equalToSuperview().inset(32)
    }
    
    userInfoContainerView.snp.makeConstraints {
      $0.top.equalTo(userInfoHeaderLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(88)
      $0.width.equalTo(370)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(userInfoContainerView.snp.top).inset(11)
      $0.leading.equalToSuperview().inset(32)
    }
    
    userNameTextField.snp.makeConstraints {
      $0.top.equalTo(userInfoContainerView.snp.top).inset(3)
      $0.bottom.equalTo(lineView.snp.top).inset(-3)
      $0.leading.equalTo(userNameLabel.snp.trailing).offset(22)
      $0.trailing.equalToSuperview().inset(32)
    }
    
    lineView.snp.makeConstraints {
      $0.centerY.equalTo(userInfoContainerView)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalTo(userInfoContainerView)
      $0.height.equalTo(0.33)
    }
    
    userDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(11)
      $0.leading.equalToSuperview().inset(32)
    }
    
    userDescriptionTextField.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.top).inset(3)
      $0.bottom.equalTo(userInfoContainerView.snp.bottom).inset(3)
      $0.leading.equalTo(userDescriptionLabel.snp.trailing).offset(22)
      $0.trailing.equalToSuperview().inset(32)
    }
    
    userInfoFooterLabel.snp.makeConstraints {
      $0.top.equalTo(userInfoContainerView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(32)
    }
    
    buttonHeaderLabel.snp.makeConstraints {
      $0.top.equalTo(userInfoFooterLabel.snp.bottom).offset(22)
      $0.leading.equalToSuperview().inset(32)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(buttonHeaderLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(60)
    }
    
    buttonFooterLabel.snp.makeConstraints {
      $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(32)
    }
  }
  
  private func configureNavigationBar() {
    navigationItem.title = "홈"
  }
  
  private func configureMainSectionStyle() {
    mainImageView.do {
      $0.image = UIImage(named: "chart")
      $0.contentMode = .scaleAspectFit
    }
    
    mainTitleLabel.do {
      $0.text = "당신의 말랑한 SOFT SKILL,\n찌르고 굽고 음미해봐요"
      $0.font = UIFont.sfPro(.title2)
      $0.numberOfLines = 0
      $0.textAlignment = .center
    }
    
    subTitleLabel.do {
      $0.text = "의사소통, 자기개발, 문제해결, 팀워크, 리더십을\n상호 피드백으로 발전시켜 보세요."
      $0.font = UIFont.sfPro(.body)
      $0.numberOfLines = 0
      $0.textAlignment = .center
    }
  }
  
  private func configureUserInfoSectionStyle() {
    userInfoHeaderLabel.do {
      $0.text = "당신의 아이덴티티"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    userInfoContainerView.do {
      $0.backgroundColor = .white
      $0.layer.cornerRadius = 10 //radius
    }
    
    userNameLabel.do {
      $0.text = "이름"
      $0.font = UIFont.sfPro(.body)
      $0.sizeToFit()
    }
    
    userNameTextField.do {
      $0.placeholder = "내 이름을 작성" // 수정
      $0.clearButtonMode = .always
    }
    
    lineView.do {
      $0.backgroundColor = .systemGray.withAlphaComponent(0.54)
    }
    
    userDescriptionLabel.do {
      $0.text = "설명"
      $0.font = UIFont.sfPro(.body)
      $0.sizeToFit()
    }
    
    userDescriptionTextField.do {
      $0.placeholder = "내 역할을 어필해 더 정확한 결과 확인"
      $0.clearButtonMode = .always
    }
    
    userInfoFooterLabel.do {
      $0.text = "식별 가능한 유저 이름과 설명을 작성해 주세요"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
    }
  }
  
  private func configureButtonSectionStyle() {
    buttonHeaderLabel.do {
      $0.text = "다음으로 세션을 시작해요"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    createButton.do {
      var config = UIButton.Configuration.filled()
      config.title = "생성"
      config.image = UIImage(systemName: "plus.app")
      config.imagePadding = 4
      config.cornerStyle = .medium
      
      $0.configuration = config
      $0.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    joinButton.do {
      var config = UIButton.Configuration.gray()
      config.title = "참가"
      config.image = UIImage(systemName: "person.badge.plus")
      config.imagePadding = 4
      config.cornerStyle = .medium
      
      $0.configuration = config
      $0.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }
    
    buttonStackView.do {
      $0.axis = .horizontal
      $0.spacing = 19
      $0.alignment = .fill
      $0.distribution = .fillEqually
    }
    
    buttonFooterLabel.do {
      $0.text = "세션을를 통해 세션을 생성할 수 있고, 이미 생성된 세션에\n참가할 수도 있어요"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
      $0.numberOfLines = 0
      $0.lineBreakMode = .byCharWrapping
    }
  }
  
  // MARK: - Button Actions
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  @objc func createButtonTapped() {
    print("Create button pressed")
      
    // 이름과 역할 작성했는지 체크
    let userName = userNameTextField.text ?? ""
    let userDescription = userDescriptionTextField.text ?? ""
    
    if userName.isEmpty {
      showAlert(title: "이름 입력 필요", message: "이름을 작성해주세요.")
      return
    }
    
    if userDescription.isEmpty {
      showAlert(title: "역할 입력 필요", message: "역할을 작성해주세요.")
      return
    }
    
    // 이름과 역할 작성했다면, 프로젝트 생성 창 띄우기
    let alertController = UIAlertController(
      title: "세션 생성하기",
      message: "식별 가능한 프로젝트 이름을 설정해요",
      preferredStyle: .alert
    )
    
    alertController.addTextField {
      $0.placeholder = "프로젝트 이름"
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
      guard let self = self else { return }
      let projectName = alertController.textFields?.first?.text ?? ""
      
      // 프로젝트 이름 작성 확인
      if projectName.isEmpty {
        self.showAlert(title: "프로젝트 이름 필요", message: "프로젝트 이름을 입력해주세요.")
        return
      }
      
      // 세션 생성
      SessionManager.shared.setLocalUserInfo(
        name: userName,
        role: userDescription
      )
      
      SessionManager.shared.setSession(
        isHost: true,
        displayName: userName,
        projectName: projectName,
        delegate: self
      )
      
      let sessionVC = LobbyViewController()
      self.navigationController?.pushViewController(sessionVC, animated: true)
      
    }
    alertController.addAction(cancelAction)
    alertController.addAction(createAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  @objc private func joinButtonTapped() {
    guard let userName = userNameTextField.text, !userName.isEmpty else {
      showAlert(title: "이름 입력 필요", message: "이름을 작성해주세요.")
      return
    }
    
    guard let userDescription = userDescriptionTextField.text, !userDescription.isEmpty else {
      showAlert(title: "역할 입력 필요", message: "역할을 작성해주세요.")
      return
    }

    SessionManager.shared.setLocalUserInfo(
      name: userName,
      role: userDescription
    )
    SessionManager.shared.setSession(
      isHost: false,
      displayName: userName,
      delegate: self
    )
    
    let SessionBrowserVC = SessionBrowserViewController()
    self.navigationController?.pushViewController(SessionBrowserVC, animated: true)
  }
  
  // MARK: - Keyboard
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let keyboardHeight = keyboardFrame.cgRectValue.height
    
    if userNameTextField.isFirstResponder || userDescriptionTextField.isFirstResponder {
      UIView.animate(withDuration: 0.3) {
        self.view.frame.origin.y = -keyboardHeight
      }
    }
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    UIView.animate(withDuration: 0.3) {
      self.view.frame.origin.y = 0
    }
  }
  
  private func configureTapGesture() {
    tapGesture.addTarget(self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
  }
  
  private func configureNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
}

// MARK: - MCBrowserViewControllerDelegate
extension HomeViewController: MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true) {
      let lobbyVC = LobbyViewController()
      self.navigationController?.pushViewController(lobbyVC, animated: true)
    }
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true, completion: nil)
  }
}
