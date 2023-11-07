//
//  BottomSheetPresentationController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

final class BottomSheetPresentationController: UIPresentationController {

  private let dismissalHandler: BottomSheetModalDismissalHandler

  private var state: State = .dismissed

  private var pullBar: PullBar?
  
  /// shadow
  private var shadingView: UIView?

  init(
    presentedViewController: UIViewController,
    presentingViewController: UIViewController?,
    dismissalHandler: BottomSheetModalDismissalHandler
  ) {
    self.dismissalHandler = dismissalHandler
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
  }

  // MARK: - LifeStyle Methods

  override func presentationTransitionWillBegin() {
    state = .presenting

    /// adding shadow, when the bottomSheet opened.
    addSubviews()
  }

  public override func presentationTransitionDidEnd(_ completed: Bool) {
    if completed {
      state = .presented
    } else {
      state = .dismissed
    }
  }

  public override func dismissalTransitionWillBegin() {
    state = .dismissing
  }

  public override func dismissalTransitionDidEnd(_ completed: Bool) {
    if completed {

      ///removing shadow, when the bottomSheet closed
      removeSubviews()

      state = .dismissed
    } else {
      state = .presented
    }
  }

  // MARK: - Public Methods

  /// changing frame
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

  private func addSubviews() {
    guard let containerView = containerView else {
      assertionFailure()
      return
    }
    setupShadingView(containerView: containerView)
  }

  private func setupShadingView(containerView: UIView) {
    let shadingView = UIView()
    containerView.addSubview(shadingView)
    shadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    shadingView.frame = containerView.bounds

    let tapGesture = UITapGestureRecognizer()
    shadingView.addGestureRecognizer(tapGesture)

    tapGesture.addTarget(self, action: #selector(handleShadingViewTapGesture))
    self.shadingView = shadingView
  }

  @objc
  private func handleShadingViewTapGesture() {
    dismissIfPossible()
  }

  private func removeSubviews() {
    shadingView?.removeFromSuperview()
    shadingView = nil
  }

  private func dismissIfPossible() {
    let canBeDismissed = state == .presented

    if canBeDismissed {
      dismissalHandler.performDismissal(animated: true)
    }
  }
}

// MARK: - BottomSheetPresentationController lifeStyle

private extension BottomSheetPresentationController {
  enum State {
    case dismissed
    case presenting
    case presented
    case dismissing
  }
}

// MARK: - BottomSheetPresentationController style

private extension BottomSheetPresentationController {
  enum Style {
    static let cornerRadius: CGFloat = 10
    static let pullBarHeight = Style.cornerRadius * 2
  }
}

// MARK: - Animation for shadow

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let sourceViewController = transitionContext.viewController(forKey: .from),
      let destinationViewController = transitionContext.viewController(forKey: .to),
      let sourceView = sourceViewController.view,
      let destinationView = destinationViewController.view
    else {
      return
    }

    let isPresenting = destinationViewController.isBeingPresented
    let presentedView = isPresenting ? destinationView : sourceView
    let containerView = transitionContext.containerView
    if isPresenting {
      containerView.addSubview(destinationView)

      destinationView.frame = containerView.bounds
    }

    sourceView.layoutIfNeeded()
    destinationView.layoutIfNeeded()

    let frameInContainer = frameOfPresentedViewInContainerView
    let offscreenFrame = CGRect(
      origin: CGPoint(
        x: 0,
        y: containerView.bounds.height
      ),
      size: sourceView.frame.size
    )

    presentedView.frame = isPresenting ? offscreenFrame : frameInContainer
    pullBar?.frame.origin.y = presentedView.frame.minY - Style.pullBarHeight + pixelSize
    shadingView?.alpha = isPresenting ? 0 : 1

    let animations = {
      presentedView.frame = isPresenting ? frameInContainer : offscreenFrame
      self.pullBar?.frame.origin.y = presentedView.frame.minY - Style.pullBarHeight + pixelSize
      self.shadingView?.alpha = isPresenting ? 1 : 0
    }

    let completion = { (completed: Bool) in
      transitionContext.completeTransition(completed && !transitionContext.transitionWasCancelled)
    }

    let options: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .curveEaseInOut
    let transitionDurationValue = transitionDuration(using: transitionContext)
    UIView.animate(withDuration: transitionDurationValue, delay: 0, options: options, animations: animations, completion: completion)
  }
}

// MARK: - PullBar

extension BottomSheetPresentationController {
  final class PullBar: UIView {
    enum Style {
      static let size = CGSize(width: 40, height: 4)
    }

    private let centerView: UIView = {
      let view = UIView()
      view.frame.size = Style.size
      view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
      view.layer.cornerRadius = Style.size.height * 0.5
      return view
    }()

    init() {
      super.init(frame: .zero)
      backgroundColor = .clear
      setupSubviews()
    }

    required init?(coder: NSCoder) {
      preconditionFailure("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
      addSubview(centerView)
    }

    override func layoutSubviews() {
      super.layoutSubviews()

      centerView.center = bounds.center
    }
  }
}
