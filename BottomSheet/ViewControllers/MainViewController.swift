//
//  MainViewController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 01.11.2023.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var button: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func buttonAction() {
    let viewController = ResizeViewController(initialHeight: 300)
    present(viewController, animated: true, completion: nil)
  }
}

