//
//  HomeViewController.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit

import SnapKit
import Then

final class HomeViewController: UIViewController {
  
  let scrollView = UIScrollView()
  let contentView = UIView()
  
  let tapGesture = UITapGestureRecognizer()
  
  let appearance = UINavigationBarAppearance()
  
  let mainImage = UIImageView()
  
  let mainLabel = UILabel()
  let subLabel = UILabel()
  
  let userInfoHeader = UILabel()
  
  let userInfoTable = UIView()
  
  let userNameLabel = UILabel()
  var userNameTextField = UITextField()
  
  let lineView = UIView()
  
  let descriptionLabel = UILabel()
  var descriptionTextField = UITextField()
  
  let userInfoFooter = UILabel()
  
  let buttonHeader = UILabel()
  
  let createButton = UIButton()
  let joinButton = UIButton()
  let buttonStackView = UIStackView()
  
  let buttonFooter = UILabel()
  
  
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNotifications()
    
    setStyle()
    setUI()
    setAutoLayout()
    
  }
  
  private func setStyle() {
    view.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    
    title = "Home"
    
    tapGesture.do {
      $0.addTarget(self, action: #selector(dismissKeyboard))
    }
    
    appearance.do {
      $0.configureWithOpaqueBackground()
      $0.backgroundColor = .white
      $0.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = appearance
    
    mainImage.do {
      $0.image = UIImage(named: "chart")
      $0.contentMode = .scaleAspectFit
    }
    
    mainLabel.do {
      $0.text = "당신의 소프트 스킬,\n피드백으로 성장하다"
      $0.font = UIFont.sfPro(.title2)
      $0.numberOfLines = 0
      $0.textAlignment = .center
    }
    
    subLabel.do {
      $0.text = "의사소통, 자기개발, 문제해결, 팀워크, 리더십 – 다섯\n가지 핵심 역량을 상호 피드백으로 발전시켜 보세요."
      $0.font = UIFont.sfPro(.body)
      $0.numberOfLines = 0
      $0.textAlignment = .center
    }
    
    userInfoHeader.do {
      $0.text = "USER INFORMATION"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    userInfoTable.do {
      $0.backgroundColor = .white
      $0.layer.cornerRadius = 10 //radius
    }
    
    userNameLabel.do {
      $0.text = "User Name"
      $0.font = UIFont.sfPro(.body)
    }
    
    userNameTextField.do {
      $0.placeholder = "Required" // 수정
      $0.clearButtonMode = .always
    }
    
    lineView.do {
      $0.backgroundColor = UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 86.0 / 255.0, alpha: 0.34)
    }
    
    descriptionLabel.do {
      $0.text = "Role"
      $0.font = UIFont.sfPro(.body)
    }
    
    descriptionTextField.do {
      $0.placeholder = "Optional" // 수정
      $0.clearButtonMode = .always
    }
    
    userInfoFooter.do {
      $0.text = "식별 가능한 유저 이름을 작성해 주세요"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
    }
    
    buttonHeader.do {
      $0.text = "START SESSION WITH"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }
    
    createButton.do {
      $0.setTitle("Create", for: .normal)
      $0.titleLabel?.font = UIFont.sfPro(.body)
      $0.setTitleColor(.white, for: .normal)
      $0.setImage(UIImage(systemName: "plus.app"), for: .normal)
      $0.tintColor = UIColor(.white)
      $0.backgroundColor = .systemBlue
      $0.setLayer(borderColor: .clear, cornerRadius: 12) //radius
      $0.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }
    
    joinButton.do {
      $0.setTitle("Join", for: .normal)
      $0.titleLabel?.font = UIFont.sfPro(.body)
      $0.setTitleColor(.systemBlue, for: .normal)
      $0.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
      $0.tintColor = .systemBlue
      $0.backgroundColor = UIColor(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.12)
      $0.setLayer(borderColor: .clear, cornerRadius: 12) //radius
    }
    
    buttonStackView.do {
      $0.axis = .horizontal
      $0.spacing = 19
      $0.alignment = .fill
      $0.distribution = .fillEqually
    }
    
    buttonFooter.do {
      $0.text = "Create를 통해 세션을 생성할 수 있고, Join을 통해 이미 생성\n된 세션에 참가할 수 있죠"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
      $0.numberOfLines = 0
      $0.lineBreakMode = .byCharWrapping
    }
  }
  
  private func setUI() {
  
    [createButton, joinButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }

    contentView.addSubviews(
      mainImage,
      mainLabel,
      subLabel,
      userInfoHeader,
      userInfoTable,
      userNameLabel,
      userNameTextField,
      lineView,
      descriptionLabel,
      descriptionTextField,
      userInfoFooter,
      buttonHeader,
      buttonStackView,
      buttonFooter
    )
    
    scrollView.addSubview(contentView)

    view.addGestureRecognizer(tapGesture)
    view.addSubviews(scrollView)

  }
  
  private func setAutoLayout() {
    
    scrollView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
      $0.height.equalToSuperview()
    }
    
    mainImage.snp.makeConstraints {
      $0.width.height.equalTo(128)
      $0.top.equalTo(contentView.snp.top).offset(50)
      $0.centerX.equalToSuperview()
    }
    
    mainLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(mainImage.snp.bottom).offset(22)
    }
    
    subLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(mainLabel.snp.bottom).offset(22)
    }
    
    userInfoHeader.snp.makeConstraints {
      $0.top.equalTo(subLabel.snp.bottom).offset(32)
      $0.leading.equalToSuperview().inset(32)
    }
    
    userInfoTable.snp.makeConstraints {
      $0.top.equalTo(userInfoHeader.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.width.equalTo(370)
      $0.height.equalTo(88)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(userInfoTable.snp.top).inset(11)
      $0.leading.equalToSuperview().inset(32)
    }
    
    userNameTextField.snp.makeConstraints {
      $0.top.equalTo(userInfoTable.snp.top).inset(11)
      $0.leading.equalToSuperview().inset(144)
      $0.trailing.equalToSuperview().inset(32)
      $0.height.equalTo(22)
    }
    
    lineView.snp.makeConstraints {
      $0.centerY.equalTo(userInfoTable)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalTo(userInfoTable)
      $0.height.equalTo(0.33)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(11)
      $0.leading.equalToSuperview().inset(32)
    }
    
    descriptionTextField.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(11)
      $0.leading.equalToSuperview().inset(144)
      $0.trailing.equalToSuperview().inset(32)
      $0.height.equalTo(22)
    }
    
    userInfoFooter.snp.makeConstraints {
      $0.top.equalTo(userInfoTable.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(32)
    }
    
    buttonHeader.snp.makeConstraints {
      $0.top.equalTo(userInfoFooter.snp.bottom).offset(22)
      $0.leading.equalToSuperview().inset(32)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(buttonHeader.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(60)
    }
    
    buttonFooter.snp.makeConstraints {
      $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(32)
    }
  }
  
  @objc func showAlert() {
    print("Create button pressed")
    let alertController = UIAlertController(
      title: "Create the Room",
      message: "Please enter your project name.",
      preferredStyle: .alert
    )

    alertController.addTextField {
      $0.placeholder = "Your Project Name"
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let createAction = UIAlertAction(title: "Create", style: .default) // 다음 화면 연결
    
    alertController.addAction(cancelAction)
    alertController.addAction(createAction)
    
    present(alertController, animated: true, completion: nil)
  }

  
  private func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let keyboardHeight = keyboardFrame.cgRectValue.height
    
    if userNameTextField.isFirstResponder || descriptionTextField.isFirstResponder {
      if view.frame.origin.y == 0 {
        view.frame.origin.y -= keyboardHeight
      }
    }
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    if view.frame.origin.y != 0 {
      view.frame.origin.y = 0
    }
  }
  
  @objc func dismissKeyboard() {
      view.endEditing(true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
