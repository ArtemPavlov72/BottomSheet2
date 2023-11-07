//
//  BottomSheetModalDismissalHandler.swift
//  BottomSheet
//
//  Created by Артем Павлов on 05.11.2023.
//

import Foundation

/// protocol for dismissing custom bottom sheet
public protocol BottomSheetModalDismissalHandler {
  func performDismissal(animated: Bool)
}
