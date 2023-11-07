//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

protocol BottomSheetPresentationControllerFactory {
  func makeBottomSheetPresentationController(
    presentedViewController: UIViewController,
    presentingViewController: UIViewController?
  ) -> BottomSheetPresentationController
}

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

  private weak var presentationController: BottomSheetPresentationController?

  private let factory: BottomSheetPresentationControllerFactory

  init(factory: BottomSheetPresentationControllerFactory) {
    self.factory = factory
  }

  // MARK: - Public Methods

  ///custom func presentationController, with using "_presentationController" func
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    _presentationController(forPresented: presented, presenting: presenting, source: source)
  }

  // MARK: - UIViewControllerTransitioningDelegate

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    presentationController
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    presentationController
  }
}

// MARK: - Private Methods

/// Calling BottomSheetPresentationController
private extension BottomSheetTransitioningDelegate {
  func _presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> BottomSheetPresentationController {
    if let presentationController = presentationController {
      return presentationController
    }

    let controller = factory.makeBottomSheetPresentationController(
      presentedViewController: presented,
      presentingViewController: presenting
    )

    /// otherwise presentationController will be nil
    presentationController = controller

    return controller
  }
}
