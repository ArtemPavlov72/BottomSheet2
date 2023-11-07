//
//  MainViewController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 01.11.2023.
//

import UIKit

///root controller
class MainViewController: UIViewController {

  @IBOutlet weak var button: UIButton!

  private var bottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func buttonAction() {
    let viewController = ResizeViewController(initialHeight: 300)
    bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(factory: self)
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = bottomSheetTransitioningDelegate
    present(viewController, animated: true, completion: nil)
  }
}

extension MainViewController: BottomSheetPresentationControllerFactory {
  func makeBottomSheetPresentationController(
    presentedViewController: UIViewController,
    presentingViewController: UIViewController?
  ) -> BottomSheetPresentationController {
    .init(
      presentedViewController: presentedViewController,
      presentingViewController: presentingViewController,
      dismissalHandler: self
    )
  }
}

// MARK: - Dismiss for custom bottom sheet
extension MainViewController: BottomSheetModalDismissalHandler {
  func performDismissal(animated: Bool) {
    presentedViewController?.dismiss(animated: animated, completion: nil)
  }
}
