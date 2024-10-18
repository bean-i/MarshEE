//
//  FeedbackSelectionComponent.swift
//  feedback-iOS
//
//  Created by 이빈 on 10/16/24.
//

import UIKit

import SnapKit
import Then

final class FeedbackSelectionComponent: UIView {
  
  let titleLabel = UILabel()
  
  let buttonCollectionView: UICollectionView = {
    let layout = LeftAlignedCollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 7
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  let footerLabel = UILabel()
  
  private(set) var selectedTraitsTitles: [String] = []
  let maxSelectableTraits = 2
  
  private var name: String
  private var traits: [Trait]
  
  weak var parentViewController: FeedbackDetailViewController?
  
  init(name: String, traits: [Trait]) {
    self.name = name
    self.traits = traits
    super.init(frame: .zero)
    
    setStyle()
    setUI()
    setAutoLayout()
    
    buttonCollectionView.delegate = self
    buttonCollectionView.dataSource = self
    buttonCollectionView.register(TraitButtonCell.self, forCellWithReuseIdentifier: "TraitCell")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setStyle() {
    
    titleLabel.do {
      $0.text = "\(name)"
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }

    buttonCollectionView.do {
      $0.backgroundColor = .clear
    }
    
    footerLabel.do {
      $0.text = "Data Collecting (0/2)"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
    }
    
  }
  
  private func setUI() {
    self.addSubviews(titleLabel, buttonCollectionView, footerLabel)
  }
  
  private func setAutoLayout() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    buttonCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(120)
    }
    
    footerLabel.snp.makeConstraints {
      $0.top.equalTo(buttonCollectionView.snp.bottom).offset(12)
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview()  // 푸터 라벨이 컴포넌트의 끝
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateCollectionViewHeight()
  }
  
  private func updateCollectionViewHeight() {
    let height = buttonCollectionView.collectionViewLayout.collectionViewContentSize.height
    buttonCollectionView.snp.updateConstraints {
      $0.height.equalTo(height)  // 자동으로 컬렉션 뷰의 높이를 조정
    }
  }
}


extension FeedbackSelectionComponent: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return traits.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item < traits.count else {
      return UICollectionViewCell()
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TraitCell", for: indexPath) as! TraitButtonCell
    let trait = traits[indexPath.item]
    
    let isSelected = selectedTraitsTitles.contains(trait.name)
    cell.configure(with: trait.name, isSelected: isSelected)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let trait = traits[indexPath.item]
    let traitName = trait.name
    
    // 선택된 개수가 2개를 초과하면 더 이상 선택하지 않도록 설정
    if selectedTraitsTitles.count == maxSelectableTraits && !selectedTraitsTitles.contains(traitName) {
      return
    }
    
    // 선택된 항목을 추가하거나 제거하는 로직
    if let index = selectedTraitsTitles.firstIndex(of: traitName) {
      selectedTraitsTitles.remove(at: index)
    } else {
      selectedTraitsTitles.append(traitName)
    }
    
    // 셀의 선택 상태에 따라 UI를 업데이트
    collectionView.reloadItems(at: [indexPath])
    
    // 푸터 라벨 업데이트
    updateFooterLabel()
    
    parentViewController?.updateDoneButtonState()
  }
  
  
  private func updateFooterLabel() {
    if selectedTraitsTitles.count == maxSelectableTraits {
      footerLabel.text = "􀇻 All Data Collected (\(selectedTraitsTitles.count)/\(maxSelectableTraits))"
    } else {
      footerLabel.text = "Data Collecting (\(selectedTraitsTitles.count)/\(maxSelectableTraits))"
    }
  }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElements(in: rect)
    
    var leftMargin = sectionInset.left
    var maxY: CGFloat = -1.0
    
    attributes?.forEach { layoutAttribute in
      if layoutAttribute.representedElementKind == nil {
        if layoutAttribute.frame.origin.y >= maxY {
          leftMargin = sectionInset.left
        }
        
        layoutAttribute.frame.origin.x = leftMargin
        
        leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
      
        maxY = max(layoutAttribute.frame.maxY, maxY)
      }
    }
    return attributes
  }
}


final class TraitButtonCell: UICollectionViewCell {
  
  private let button: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.sfPro(.subheadline)
    button.backgroundColor = UIColor(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.12)
    button.configuration?.buttonSize = .medium
    button.configuration?.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
    button.setTitleColor(UIColor(red: 60.0 / 255.0, green: 60.0 / 255.0, blue: 67.0 / 255.0, alpha: 0.3), for: .normal)
    button.layer.cornerRadius = 15
    button.clipsToBounds = true
    button.isUserInteractionEnabled = false  // 버튼이 직접 터치 이벤트를 처리하지 않도록 설정
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(button)
    button.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func updateButtonAppearance(isSelected: Bool) {
    if isSelected {
      button.backgroundColor = UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.15)
      button.setTitleColor(UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0), for: .normal)
    } else {
      button.backgroundColor = UIColor(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.12)
      button.setTitleColor(UIColor(red: 60.0 / 255.0, green: 60.0 / 255.0, blue: 67.0 / 255.0, alpha: 0.3), for: .normal)
    }
  }
  
  func configure(with title: String, isSelected: Bool) {
    let trimmedTitle = title.components(separatedBy: " (").first ?? title
    button.setTitle("   " + trimmedTitle + "   ", for: .normal)
    updateButtonAppearance(isSelected: isSelected)
  }
}
