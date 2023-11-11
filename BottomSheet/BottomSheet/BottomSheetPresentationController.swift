//
//  BottomSheetPresentationController.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

/// Has bottomSheet scrollView or not?
public protocol ScrollableBottomSheetPresentedController: AnyObject {
    var scrollView: UIScrollView? { get }
}

final class BottomSheetPresentationController: UIPresentationController {

  // MARK: - Public properties
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
      interactionController
  }

  // MARK: - Private properties
  private let dismissalHandler: BottomSheetModalDismissalHandler

  private var state: State = .dismissed

  private var trackedScrollView: UIScrollView?

  private var isInteractiveTransitionCanBeHandled: Bool {
      isDragging
  }

  private var isDragging = false {
      didSet {
          if isDragging {
              assert(interactionController == nil)
          }
      }
  }
  private var overlayTranslation: CGFloat = 0
  private var scrollViewTranslation: CGFloat = 0
  private var lastContentOffsetBeforeDragging: CGPoint = .zero
  private var didStartDragging = false

  private var pullBar: PullBar?

  private var interactionController: UIPercentDrivenInteractiveTransition?
  
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
    applyStyle()
  }

  ///VC fully presented
  public override func presentationTransitionDidEnd(_ completed: Bool) {
    if completed {
      setupGesturesForPresentedView()
      setupScrollTrackingIfNeeded()

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
      pullBar?.frame.origin.y = presentedView.frame.minY - Style.pullBarHeight + pixelSize
    }
  }

  func addSubviews() {
    guard let containerView = containerView else {
      assertionFailure()
      return
    }
    setupShadingView(containerView: containerView)
    setupPullBar(containerView: containerView)
  }

  func setupShadingView(containerView: UIView) {
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
  func handleShadingViewTapGesture() {
    dismissIfPossible()
  }

  func removeSubviews() {
    shadingView?.removeFromSuperview()
    shadingView = nil
    pullBar?.removeFromSuperview()
    pullBar = nil
  }

  func dismissIfPossible() {
    let canBeDismissed = state == .presented

    if canBeDismissed {
      dismissalHandler.performDismissal(animated: true)
    }
  }

  private func setupPullBar(containerView: UIView) {
      let pullBar = PullBar()
      pullBar.frame.size = CGSize(width: containerView.frame.width, height: Style.pullBarHeight)
      containerView.addSubview(pullBar)

      self.pullBar = pullBar
  }

  /// cornerRadius for custom bottomList
  func applyStyle() {
    guard presentedViewController.isViewLoaded else { return }

    presentedViewController.view.clipsToBounds = true
    presentedViewController.view.layer.cornerRadius = Style.cornerRadius
  }
}

// MARK: - Scroll

private extension BottomSheetPresentationController {
  func setupScrollTrackingIfNeeded() {
    trackScrollView(inside: presentedViewController)
  }

  func trackScrollView(inside viewController: UIViewController) {
      guard
          let scrollableViewController = viewController as? ScrollableBottomSheetPresentedController,
          let scrollView = scrollableViewController.scrollView
      else {
          return
      }

      trackedScrollView?.multicastingDelegate.removeDelegate(self)
      scrollView.multicastingDelegate.addDelegate(self)
      self.trackedScrollView = scrollView
  }

  func removeScrollTrackingIfNeeded() {
      trackedScrollView?.multicastingDelegate.removeDelegate(self)
      trackedScrollView = nil
  }
}

// MARK: - UIScrollViewDelegate

extension BottomSheetPresentationController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let previousTranslation = scrollViewTranslation
    scrollViewTranslation = scrollView.panGestureRecognizer.translation(in: scrollView).y

    didStartDragging = shouldDragOverlay(following: scrollView)
    if didStartDragging {
      startInteractiveTransitionIfNeeded()
      overlayTranslation += scrollViewTranslation - previousTranslation

      // Update scrollView contentInset without invoking scrollViewDidScroll(_:)
      scrollView.bounds.origin.y = -scrollView.adjustedContentInset.top

      updateInteractionControllerProgress(verticalTranslation: overlayTranslation)
    } else {
      lastContentOffsetBeforeDragging = scrollView.panGestureRecognizer.translation(in: scrollView)
    }
  }

  private func startInteractiveTransitionIfNeeded() {
    guard interactionController == nil else { return }

    startInteractiveTransition()
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isDragging = true
  }

  private func shouldDragOverlay(following scrollView: UIScrollView) -> Bool {
    guard scrollView.isTracking, isInteractiveTransitionCanBeHandled else {
      return false
    }

    if let percentComplete = interactionController?.percentComplete {
      if percentComplete.isAlmostEqual(to: 0) {
        return scrollView.isContentOriginInBounds && scrollView.scrollsDown
      }

      return true
    } else {
      return scrollView.isContentOriginInBounds && scrollView.scrollsDown
    }
  }

  ///user turn up finger from screen after scroll
  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>
  ) {
    if didStartDragging {
      let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
      let translation = scrollView.panGestureRecognizer.translation(in: scrollView)
      endInteractiveTransition(
        verticalVelocity: velocity.y,
        verticalTranslation: translation.y - lastContentOffsetBeforeDragging.y
      )
    } else {
      endInteractiveTransition(isCancelled: true)
    }

    overlayTranslation = 0
    scrollViewTranslation = 0
    lastContentOffsetBeforeDragging = .zero
    didStartDragging = false
    isDragging = false
  }
}

// MARK: - Custom logic for swipe-clossing bottomList (UISwipeGestureRecognizer)

private extension BottomSheetPresentationController {
  func setupGesturesForPresentedView() {
    setupPanGesture(for: presentedView)
    setupPanGesture(for: pullBar)
  }

  func setupPanGesture(for view: UIView?) {
    guard let view = view else { return }

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    view.addGestureRecognizer(panRecognizer)
  }

  @objc
  func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
    switch panGesture.state {
    case .began:
      processPanGestureBegan(panGesture)
    case .changed:
      processPanGestureChanged(panGesture)
    case .ended:
      processPanGestureEnded(panGesture)
    case .cancelled:
      processPanGestureCancelled(panGesture)
    default:
      break
    }
  }

  /// processPanGestureBegan
  func processPanGestureBegan(_ panGesture: UIPanGestureRecognizer) {
    startInteractiveTransition()
  }

  private func startInteractiveTransition() {
    interactionController = UIPercentDrivenInteractiveTransition()

    presentingViewController.dismiss(animated: true) { [weak self] in
      guard let self = self else { return }

      if self.presentingViewController.presentedViewController !== self.presentedViewController {
        self.dismissalHandler.performDismissal(animated: true)
      }
    }
  }

  ///processPanGestureChanged
  func processPanGestureChanged(_ panGesture: UIPanGestureRecognizer) {
    let translation = panGesture.translation(in: nil)
    updateInteractionControllerProgress(verticalTranslation: translation.y)
  }

  func updateInteractionControllerProgress(verticalTranslation: CGFloat) {
    guard let presentedView = presentedView else { return }

    let progress = verticalTranslation / presentedView.bounds.height
    interactionController?.update(progress)
  }

  ///processPanGestureEnded
  ///we must know: close bottomSheet or just scroll?
  func processPanGestureEnded(_ panGesture: UIPanGestureRecognizer) {
    let velocity = panGesture.velocity(in: presentedView)
    let translation = panGesture.translation(in: presentedView)
    endInteractiveTransition(verticalVelocity: velocity.y, verticalTranslation: translation.y)
  }

  func endInteractiveTransition(verticalVelocity: CGFloat, verticalTranslation: CGFloat) {
    guard let presentedView = presentedView else { return }

    /// logic of bottomSheet's deceleration
    let deceleration = 800.0 * (verticalVelocity > 0 ? -1.0 : 1.0)
    let finalProgress = (verticalTranslation - 0.5 * verticalVelocity * verticalVelocity / CGFloat(deceleration))
    / presentedView.bounds.height
    let isThresholdPassed = finalProgress < 0.5

    endInteractiveTransition(isCancelled: isThresholdPassed)
  }

  func endInteractiveTransition(isCancelled: Bool) {
    if isCancelled {
      interactionController?.cancel()
    } else {
      interactionController?.finish()
    }
    interactionController = nil
  }

  ///processPanGestureCancelled
  func processPanGestureCancelled(_ panGesture: UIPanGestureRecognizer) {
    endInteractiveTransition(isCancelled: true)
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

// MARK: - Appearance

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
