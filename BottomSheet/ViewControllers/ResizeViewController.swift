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

  private let _scrollView = UIScrollView()

  private let scrollContentView = UIView()

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

  private let showNextButton: UIButton = {
      let button = UIButton()
      button.backgroundColor = .systemBlue
      button.setTitle("Show next", for: .normal)
      return button
  }()

  private let showRootButton: UIButton = {
      let button = UIButton()
      button.backgroundColor = .systemPink
      button.setTitle("Show root", for: .normal)
      return button
  }()

  // MARK: - Public Properties

  var isShowNextButtonHidden: Bool {
      navigationController == nil
  }

  var isShowRootButtonHidden: Bool {
      navigationController?.viewControllers.count ?? 0 <= 1
  }

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
    tabBar.isHidden = true
    view.backgroundColor = .systemGray6

    contentSizeLabel.textAlignment = .center

    let buttons = actions.map(UIButton.init(buttonAction:))

    buttonStackView = UIStackView(arrangedSubviews: buttons)
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 8
  }

  func setupConstraints() {
    [_scrollView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }

    [scrollContentView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      _scrollView.addSubview($0)
    }


    [contentSizeLabel, buttonStackView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      scrollContentView.addSubview($0)
    }

    NSLayoutConstraint.activate([
      _scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      _scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      _scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      _scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      scrollContentView.topAnchor.constraint(equalTo: _scrollView.topAnchor),
      scrollContentView.bottomAnchor.constraint(equalTo: _scrollView.bottomAnchor),
      scrollContentView.leadingAnchor.constraint(equalTo: _scrollView.leadingAnchor),
      scrollContentView.trailingAnchor.constraint(equalTo: _scrollView.trailingAnchor),
      scrollContentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
      scrollContentView.heightAnchor.constraint(equalToConstant: currentHeight),

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
    guard newValue >= 200 && newValue < 5000 else {
      return
    }

    contentSizeLabel.text = "preferredContentHeight = \(currentHeight)"
    currentHeight = newValue

    let updates = { [self] in
      self.scrollContentView.heightConstraint?.constant = newValue
      preferredContentSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: newValue
      )
    }

    let canAnimateChanges = viewIfLoaded?.window != nil

    if canAnimateChanges {
      UIView.animate(withDuration: 0.25, animations: updates)
    } else {
      updates()
    }
  }
}

extension ResizeViewController: ScrollableBottomSheetPresentedController {
  var scrollView: UIScrollView? {
    _scrollView
  }
}


