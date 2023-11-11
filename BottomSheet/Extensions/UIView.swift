//
//  UIView.swift
//  BottomSheet
//
//  Created by Артем Павлов on 10.11.2023.
//

import UIKit

extension UIView {

  var heightConstraint: NSLayoutConstraint? {
    get {
      return constraints.first(where: {
        $0.firstAttribute == .height && $0.relation == .equal
      })
    }
    set { setNeedsLayout() }
  }
}
