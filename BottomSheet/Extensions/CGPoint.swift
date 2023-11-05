//
//  CGPoint.swift
//  BottomSheet
//
//  Created by Артем Павлов on 05.11.2023.
//

import CoreGraphics

public extension CGPoint {
    // MARK: - Equality

    func isAlmostEqual(to other: CGPoint) -> Bool {
        x.isAlmostEqual(to: other.x) && y.isAlmostEqual(to: other.y)
    }

    func isAlmostEqual(to other: CGPoint, error: CGFloat) -> Bool {
        x.isAlmostEqual(to: other.x, error: error) && y.isAlmostEqual(to: other.y, error: error)
    }
}
