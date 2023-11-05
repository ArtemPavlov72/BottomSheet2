//
//  CGRect.swift
//  BottomSheet
//
//  Created by Артем Павлов on 05.11.2023.
//

import CoreGraphics

extension CGRect {
  // MARK: - Properties
  
  var center: CGPoint {
    get {
      CGPoint(x: midX, y: midY)
    }
    set {
      origin = CGPoint(x: newValue.x - width * 0.5, y: newValue.y - height * 0.5)
    }
  }
  
  // MARK: - Equality
  
  func isAlmostEqual(to other: CGRect) -> Bool {
    size.isAlmostEqual(to: other.size) && origin.isAlmostEqual(to: other.origin)
  }
  
  func isAlmostEqual(to other: CGRect, error: CGFloat) -> Bool {
    size.isAlmostEqual(to: other.size, error: error) && origin.isAlmostEqual(to: other.origin, error: error)
  }
}
