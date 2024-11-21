//
//  FeedbackTableViewCell.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/18/24.
//

import UIKit

final class FeedbackTableViewCell: UITableViewCell {
  
  static let identifier = "FeedbackTableViewCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
