//
//  BottomSheetPresentationController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

final class BottomSheetPresentationController: UIPresentationController {

  // MARK: - Public Methods

  override var frameOfPresentedViewInContainerView: CGRect {
    targetFrameForPresentedView()
  }

  override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
    updatePresentedViewSize()
  }

  override var shouldPresentInFullscreen: Bool {
    false
  }
}

// MARK: - Private Methods

private extension BottomSheetPresentationController {
  func targetFrameForPresentedView() -> CGRect {
    guard let containerView = containerView else {
      return .zero
    }

    let windowInsets = presentedView?.window?.safeAreaInsets ?? .zero

    let preferredHeight = presentedViewController.preferredContentSize.height + windowInsets.bottom
    let maxHeight = containerView.bounds.height - windowInsets.top
    let height = min(preferredHeight, maxHeight)

    return .init(
      x: 0,
      y: (containerView.bounds.height - height).pixelCeiled,
      width: containerView.bounds.width,
      height: height.pixelCeiled
    )
  }

  func updatePresentedViewSize() {
    guard let presentedView = presentedView else {
      return
    }

    let oldFrame = presentedView.frame
    let targetFrame = targetFrameForPresentedView()
    if !oldFrame.isAlmostEqual(to: targetFrame) {
      presentedView.frame = targetFrame
    }
  }
}
