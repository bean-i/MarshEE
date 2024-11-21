//
//  UIFont+.swift
//  feedback-iOS
//
//  Created by Chandrala on 10/9/24.
//

import UIKit

extension UIFont {
  static func sfPro(_ style: SFPro) -> UIFont {
    return UIFont(name: style.weight, size: style.size) ?? .systemFont(ofSize: style.size)
  }
  
  enum SFPro {
    private static let scaleRatio: CGFloat = max(Screen.height(1), Screen.width(1))
    
    case title2
    case headline
    case body, header, footer, subheadline
    
    var weight: String {
      switch self {
      case .title2:
        "SFProText-Bold"
      case .headline:
        "SFProText-Semibold"
      case .body, .header, .footer, .subheadline:
        "SFProText-Regular"
      }
    }
    
    var size: CGFloat {
      return defaultSize * SFPro.scaleRatio
    }
    
    private var defaultSize: CGFloat {
      switch self {
      case .title2: 22
      case .body, .headline: 17
      case .subheadline: 15
      case .header, .footer: 13
      }
    }
    
    var tracking: CGFloat { CGFloat(-2) / 100 * size }
    
    var lineHeight: CGFloat {
      switch self {
      default: 1.6 * size
      }
    }
    
    var baselineOffset: CGFloat { return (lineHeight - size) / 3 }
  }
}

