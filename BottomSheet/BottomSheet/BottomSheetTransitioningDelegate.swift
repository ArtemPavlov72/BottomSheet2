//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

  // MARK: - Public Methods

  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    _presentationController(forPresented: presented, presenting: presenting, source: source)
  }
}

// MARK: - Private Methods

private extension BottomSheetTransitioningDelegate {
  func _presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> BottomSheetPresentationController {
    BottomSheetPresentationController(
      presentedViewController: presented,
      presenting: presenting
    )
  }
}
