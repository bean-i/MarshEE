//
//  FeedbackSelectionComponent.swift
//  feedback-iOS
//
//  Created by 이빈 on 10/16/24.
//

import SnapKit
import Then
import UIKit

final class FeedbackSelectionComponent: UIView {
  
  // MARK: - Components
  let titleLabel = UILabel()
  let buttonCollectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
  let footerLabel = UILabel()
  
  // MARK: - Properties
  private(set) var selectedTraitTitles: [String] = []
  let maxTraitSelectionCount = 2
  private var categoryName: String
  private var traits: [Trait]
  weak var parentViewController: FeedbackDetailViewController?
  
  // MARK: - Initializer
  init(categoryName: String, traits: [Trait]) {
    self.categoryName = categoryName
    self.traits = traits
    super.init(frame: .zero)
    
    setStyle()
    setUI()
    setAutoLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UI Setup
  private func setStyle() {
    
    titleLabel.do {
      $0.text = categoryName
      $0.font = UIFont.sfPro(.header)
      $0.textColor = .gray
    }

    buttonCollectionView.do {
      let layout = LeftAlignedCollectionViewFlowLayout()
      layout.scrollDirection = .vertical
      layout.minimumLineSpacing = 8
      layout.minimumInteritemSpacing = 7
      layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
      $0.collectionViewLayout = layout
      $0.backgroundColor = .clear
    }
    
    footerLabel.do {
      $0.text = "Data Collecting (0/\(maxTraitSelectionCount))"
      $0.font = UIFont.sfPro(.footer)
      $0.textColor = .gray
    }
    
  }
  
  private func setUI() {
    self.addSubviews(
      titleLabel,
      buttonCollectionView,
      footerLabel
    )
    
    buttonCollectionView.delegate = self
    buttonCollectionView.dataSource = self
    buttonCollectionView.register(TraitButtonCell.self, forCellWithReuseIdentifier: TraitButtonCell.reuseIdentifier)
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
      $0.bottom.equalToSuperview()
      $0.leading.equalToSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateCollectionViewHeight()
  }
  
  private func updateCollectionViewHeight() {
    let height = buttonCollectionView.collectionViewLayout.collectionViewContentSize.height
    buttonCollectionView.snp.updateConstraints {
      $0.height.equalTo(height)
    }
  }
  
  private func updateFooterLabel() {
    if selectedTraitTitles.count == maxTraitSelectionCount {
      footerLabel.text = "􀇻 All Data Collected (\(selectedTraitTitles.count)/\(maxTraitSelectionCount))"
    } else {
      footerLabel.text = "Data Collecting (\(selectedTraitTitles.count)/\(maxTraitSelectionCount))"
    }
  }
}

// MARK: - Extension UICollectionView
extension FeedbackSelectionComponent: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return traits.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item < traits.count else {
      return UICollectionViewCell()
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TraitButtonCell.reuseIdentifier, for: indexPath) as! TraitButtonCell
    let trait = traits[indexPath.item]
    let isSelected = selectedTraitTitles.contains(trait.name)
    cell.configure(with: trait.name, isSelected: isSelected)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // 선택한 Trait의 인덱스 정보
    guard let categoryIndex = parentViewController?.skill.categories.firstIndex(where: { $0.name == self.categoryName }) else {
      print("Invalid category index for \(self.categoryName)")
      return
    }
    let traitIndex = indexPath.item
    let trait = traits[traitIndex]
    
    // 삭제
    if let index = selectedTraitTitles.firstIndex(of: trait.name) {
      selectedTraitTitles.remove(at: index)
      parentViewController?.updateSelectedTraitCount(categoryIndex: categoryIndex, traitIndex: traitIndex, increase: false)
    } else {
      // 최대 선택 개수 확인
      guard selectedTraitTitles.count < maxTraitSelectionCount else {
        print("Max selectable traits reached")
        return
      }
      // 추가
      selectedTraitTitles.append(trait.name)
      parentViewController?.updateSelectedTraitCount(categoryIndex: categoryIndex, traitIndex: traitIndex, increase: true)
    }
    
    // UI 업데이트
    collectionView.reloadItems(at: [indexPath])
    updateFooterLabel()
    parentViewController?.updateDoneButtonState()
  }

}

// MARK: - UICollectionView Flow Layout
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

// MARK: - UICollectionViewCell
final class TraitButtonCell: UICollectionViewCell {
  static let reuseIdentifier = "TraitButtonCell"
  
  private let button: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.sfPro(.subheadline)
    button.layer.cornerRadius = 15
    button.clipsToBounds = true
    button.isUserInteractionEnabled = false
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(button)
    button.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with title: String, isSelected: Bool) {
    let trimmedTitle = title.components(separatedBy: " (").first ?? title
    button.setTitle("   " + trimmedTitle + "   ", for: .normal)
    updateButtonAppearance(isSelected: isSelected)
  }
  
  private func updateButtonAppearance(isSelected: Bool) {
    button.backgroundColor = isSelected
      ? UIColor.systemBlue.withAlphaComponent(0.15)
      : UIColor.systemGray3.withAlphaComponent(0.12)
    
    button.setTitleColor(isSelected
      ? UIColor.systemBlue
      : UIColor.systemGray2, for: .normal)
  }
}
