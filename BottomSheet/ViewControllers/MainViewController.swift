//
//  MainViewController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 01.11.2023.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var button: UIButton!

  private var bottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func buttonAction() {
    let viewController = ResizeViewController(initialHeight: 300)
    bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate()
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = bottomSheetTransitioningDelegate
    present(viewController, animated: true, completion: nil)
  }
}
