//
//  HeatmapView.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/21/24.
//

import UIKit

final class HeatmapView: UIView {
  
  var heatmapCollectionView: UICollectionView!
  var skillSet: SkillSet
//  var totalParticipants: Int
  var tooltipLabel: UILabel?
  
  init(frame: CGRect, skillSet: SkillSet/*, totalParticipants: Int*/) {
    self.skillSet = skillSet
//    self.totalParticipants = totalParticipants
    super.init(frame: frame)
    setCollectionView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if let layout = heatmapCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let itemSize = bounds.width / 5
      layout.itemSize = CGSize(width: itemSize, height: itemSize)
    }
    heatmapCollectionView.frame = bounds
  }
  
  func setCollectionView() {
    let layout = UICollectionViewFlowLayout()
    
    layout.itemSize = CGSize(width: frame.width / 5, height: frame.width / 5)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    heatmapCollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
    heatmapCollectionView.backgroundColor = .white
    heatmapCollectionView.delegate = self
    heatmapCollectionView.dataSource = self
    heatmapCollectionView.register(HeatmapCell.self, forCellWithReuseIdentifier: "HeatmapCell")
    
    addSubview(heatmapCollectionView)
  }
  
  func showTooltip(for cell: HeatmapCell) {
    removeTooltip()
    
    let tooltipLabel = UILabel()
    
    let categoryNameParts = cell.categoryName.components(separatedBy: " (")
    let traitNameParts = cell.traitName.components(separatedBy: " (")
    
    let categoryName = categoryNameParts.first ?? cell.categoryName
    let traitName = traitNameParts.first ?? cell.traitName
    
    tooltipLabel.text = "\(categoryName)\n\(traitName): \(cell.selectionCount)명"
    tooltipLabel.textColor = .black
    tooltipLabel.backgroundColor = .white
    tooltipLabel.textAlignment = .center
    tooltipLabel.font = UIFont.systemFont(ofSize: 14)
    tooltipLabel.numberOfLines = 0
    tooltipLabel.lineBreakMode = .byWordWrapping
    tooltipLabel.layer.cornerRadius = 5
    tooltipLabel.clipsToBounds = true
    
    let maxWidth: CGFloat = 120
    tooltipLabel.frame.size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
    tooltipLabel.sizeToFit()
    
    var tooltipX = cell.frame.midX - tooltipLabel.frame.width / 2
    var tooltipY = cell.frame.minY - tooltipLabel.frame.height - 10
    
    if tooltipX < 0 {
      tooltipX = 5
    } else if tooltipX + tooltipLabel.frame.width > bounds.width {
      tooltipX = bounds.width - tooltipLabel.frame.width - 5
    }
    
    if tooltipY < 0 {
      tooltipY = cell.frame.maxY + 10
    }
    
    tooltipLabel.frame = CGRect(x: tooltipX, y: tooltipY, width: tooltipLabel.frame.width + 10, height: tooltipLabel.frame.height + 5)
    
    self.addSubview(tooltipLabel)
    self.tooltipLabel = tooltipLabel
  }
  
  func removeTooltip() {
    tooltipLabel?.removeFromSuperview()
    tooltipLabel = nil
  }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HeatmapView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return skillSet.categories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return skillSet.categories[section].traits.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeatmapCell", for: indexPath) as! HeatmapCell
    let trait = skillSet.categories[indexPath.section].traits[indexPath.row]
    cell.configure(categoryName: skillSet.categories[indexPath.section].name, traitName: trait.name, selectionCount: trait.count/*, totalParticipants: totalParticipants*/)
    
    cell.showTooltip = { [weak self] touchedCell in
      self?.showTooltip(for: touchedCell)
    }
    cell.removeTooltip = { [weak self] in
      self?.removeTooltip()
    }
    return cell
  }
}

class HeatmapCell: UICollectionViewCell {
  var categoryName: String = ""
  var traitName: String = ""
  var selectionCount: Int = 0
  
  var showTooltip: ((HeatmapCell) -> Void)?
  var removeTooltip: (() -> Void)?
  
  func configure(categoryName: String, traitName: String, selectionCount: Int/*, totalParticipants: Int*/) {
    self.categoryName = categoryName
    self.traitName = traitName
    self.selectionCount = selectionCount
    
    if selectionCount == 0 {
      backgroundColor = .systemGray5
    } else {
      let totalUsers = PeerInfoManager.shared.connectedUserInfos.count
      
      let intensity: CGFloat
      intensity = CGFloat(selectionCount) / CGFloat(totalUsers - 1)
      
      let color = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: min(intensity, 1.0))
      backgroundColor = color
      print("Intensity: \(intensity)")
    }
    
    layer.borderColor = UIColor.systemGray6.cgColor
    layer.borderWidth = 1.0

  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    showTooltip?(self)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    removeTooltip?()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    removeTooltip?()
  }
}


