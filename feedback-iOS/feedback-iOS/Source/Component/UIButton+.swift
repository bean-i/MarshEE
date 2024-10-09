//
//  UIButton+.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit

extension UIButton {
  func setTitle(_ title: String, style: UIFont.Pretendard, color: UIColor) {
    setAttributedTitle(.pretendardString(title, style: style), for: .normal)
    setTitleColor(color, for: .normal)
  }
  
  func setLayer(borderWidth: CGFloat = 0, borderColor: UIColor, cornerRadius: CGFloat) {
    layer.borderColor = borderColor.cgColor
    layer.cornerRadius = cornerRadius
    layer.borderWidth = borderWidth
  }
  
  func addUnderline() {
    let attributedString = NSMutableAttributedString(string: self.titleLabel?.text ?? "")
    attributedString.addAttribute(
      .underlineStyle,
      value: NSUnderlineStyle.single.rawValue,
      range: NSRange(location: 0, length: attributedString.length)
    )
    setAttributedTitle(attributedString, for: .normal)
  }
}
