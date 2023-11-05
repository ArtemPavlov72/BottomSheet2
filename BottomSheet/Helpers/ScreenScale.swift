//
//  ScreenScale.swift
//  BottomSheet
//
//  Created by Артем Павлов on 03.11.2023.
//

import UIKit

var pixelSize: CGFloat {
  let scale = UIScreen.mainScreenScale
  return 1.0 / scale
}

extension CGFloat {
  var pixelCeiled: CGFloat {
    let scale = UIScreen.mainScreenScale
    return Darwin.ceil(self * scale) / scale
  }
}

extension CGPoint {
  var pixelCeiled: CGPoint {
    CGPoint(x: x.pixelCeiled, y: y.pixelCeiled)
  }
}

extension CGSize {
  var pixelCeiled: CGSize {
    CGSize(width: width.pixelCeiled, height: height.pixelCeiled)
  }
}

extension UIScreen {
  static let mainScreenScale = UIScreen.main.scale
  static let mainScreenPixelSize = CGFloat(1.0) / mainScreenScale
}
