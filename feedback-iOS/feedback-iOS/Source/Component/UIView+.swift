//
//  UIView+.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit

extension UIView {
  convenience init(backgroundColor: UIColor) {
    self.init(frame: .zero)
    self.backgroundColor = backgroundColor
  }
  
  func addSubviews(_ views: UIView...) {
    views.forEach {
      addSubview($0)
    }
  }
  
  func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
    clipsToBounds = true
    layer.cornerRadius = cornerRadius
    layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
  }
}
