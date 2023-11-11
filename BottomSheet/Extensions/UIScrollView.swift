//
//  UIScrollView.swift
//  BottomSheet
//
//  Created by Артем Павлов on 09.11.2023.
//

import UIKit

extension UIScrollView {
  var scrollsUp: Bool {
    panGestureRecognizer.velocity(in: nil).y < 0
  }
  
  var scrollsDown: Bool {
    !scrollsUp
  }
  
  var isContentOriginInBounds: Bool {
    contentOffset.y <= -adjustedContentInset.top
  }
}
