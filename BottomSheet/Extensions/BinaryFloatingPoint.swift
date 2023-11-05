//
//  BinaryFloatingPoint.swift
//  BottomSheet
//
//  Created by Артем Павлов on 05.11.2023.
//

extension BinaryFloatingPoint {
  func isAlmostEqual(to other: Self) -> Bool {
    abs(self - other) < abs(self + other).ulp
  }
  
  func isAlmostEqual(to other: Self, accuracy: Self) -> Bool {
    abs(self - other) < (abs(self + other) * accuracy).ulp
  }
  
  func isAlmostEqual(to other: Self, error: Self) -> Bool {
    abs(self - other) <= error
  }
}
