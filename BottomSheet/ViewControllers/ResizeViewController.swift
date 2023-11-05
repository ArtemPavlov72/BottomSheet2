//
//  ResizeViewController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 01.11.2023.
//

import UIKit

final class ResizeViewController: UITabBarController {

  // MARK: - Private Properties

  private let contentSizeLabel = UILabel()

  private var currentHeight: CGFloat

  private var buttonStackView = UIStackView()

  private lazy var actions = [
    ButtonAction(title: "x2", backgroundColor: .systemBlue, handler: { [unowned self] in
      updateContentHeight(newValue: currentHeight * 2)
    }),
    ButtonAction(title: "/2", backgroundColor: .systemBlue, handler: { [unowned self] in
      updateContentHeight(newValue: currentHeight / 2)
    }),
    ButtonAction(title: "+100", backgroundColor: .systemBlue, handler: { [unowned self] in
      updateContentHeight(newValue: currentHeight + 100)
    }),
    ButtonAction(title: "-100", backgroundColor: .systemBlue, handler: { [unowned self] in
      updateContentHeight(newValue: currentHeight - 100)
    }),
  ]

  // MARK: - Init

  init(initialHeight: CGFloat) {
    currentHeight = initialHeight
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life Cycles Methods

  override func viewDidLoad() {
    super.viewDidLoad()

    setupDefaultSettings()
    setupConstraints()
    updateContentHeight(newValue: currentHeight)
  }
}

// MARK: - Private Methods

private extension ResizeViewController {
  func setupDefaultSettings() {
    view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1)

    contentSizeLabel.textAlignment = .center

    let buttons = actions.map(UIButton.init(buttonAction:))

    buttonStackView = UIStackView(arrangedSubviews: buttons)
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 8
  }

  func setupConstraints() {
    [contentSizeLabel, buttonStackView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }

    NSLayoutConstraint.activate([
      contentSizeLabel.topAnchor.constraint(equalTo: view.topAnchor),
      contentSizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentSizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      buttonStackView.topAnchor.constraint(equalTo: contentSizeLabel.bottomAnchor, constant: 8),
      buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      buttonStackView.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  func updateContentHeight(newValue: CGFloat) {
    guard newValue >= 200 && newValue < 5000 else { return }

    currentHeight = newValue
    contentSizeLabel.text = "preferredContentHeight = \(currentHeight)"
    preferredContentSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: newValue
    )
  }
}
