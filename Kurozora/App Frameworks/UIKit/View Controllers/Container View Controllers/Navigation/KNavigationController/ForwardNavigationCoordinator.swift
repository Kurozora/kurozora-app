//
//  ForwardNavigationCoordinator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Reopens screens the user navigated away from, driven by a swipe towards the leading screen edge.
@MainActor
final class ForwardNavigationCoordinator: NSObject {
	// MARK: - Properties
	/// The fraction of the screen's width the gesture travels before the transition commits.
	private static let commitThreshold: CGFloat = 0.33

	/// The swipe velocity, in screen widths per second, that commits the transition regardless of progress.
	private static let commitVelocity: CGFloat = 0.8

	/// The forward distance the swipe travels before it starts the transition.
	private static let activationDistance: CGFloat = 12.0

	/// How much more horizontal than vertical the swipe must be to start the transition.
	private static let horizontalRatio: CGFloat = 1.5

	/// How close to the trailing edge a swipe must start to override horizontally scrollable content.
	private static let edgeBandWidth: CGFloat = 40.0

	/// The navigation controller whose history is tracked.
	private weak var navigationController: UINavigationController?

	/// The screens available to navigate forward to, nearest first.
	private var history: [UIViewController] = []

	/// The navigation stack as of the last observed transition.
	private var lastKnownStack: [UIViewController] = []

	/// The interaction driving the in-flight forward transition.
	private var interactionController: UIPercentDrivenInteractiveTransition?

	/// The screen the in-flight forward transition is pushing.
	private var screenBeingRestored: UIViewController?

	/// The gesture that drives the forward transition, for touch as well as trackpad and mouse.
	private(set) var panGestureRecognizer: UIPanGestureRecognizer?

	/// The scroll gesture suspended for the duration of the transition, so the swipe stays on one axis.
	private weak var suspendedScrollGestureRecognizer: UIPanGestureRecognizer?

	/// The forward distance the swipe had travelled when it started the transition.
	private var activationTranslation: CGFloat = 0.0

	/// The views whose interaction is suspended for the duration of the transition.
	private var interactionSuspendedViews: [UIView] = []

	/// Whether the swipe in progress started against the trailing edge.
	private var didBeginAtTrailingEdge = false

	/// The screens a plain forward push put back on the stack, keyed by identity.
	private var forwardPushedScreens: Set<ObjectIdentifier> = []

	/// Whether a screen is available to navigate forward to.
	var canNavigateForward: Bool {
		return !self.history.isEmpty
	}

	/// Whether the navigation controller is partway through a transition.
	var isTransitioning: Bool {
		return self.navigationController?.topViewController?.transitionCoordinator != nil
	}

	// MARK: - Initializers
	/// Creates a coordinator tracking the specified navigation controller.
	///
	/// - Parameter navigationController: The navigation controller whose history to track.
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		self.lastKnownStack = navigationController.viewControllers

		super.init()

		NotificationCenter.default.addObserver(self, selector: #selector(self.clearHistory), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.clearHistory), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handlePreferenceChange), name: .KSForwardNavigationDidChange, object: nil)
	}

	// MARK: - Functions
	/// Answers whether the delegate implements the specified selector.
	///
	/// - Parameter aSelector: The selector to test.
	///
	/// - Returns: Whether the delegate responds to the selector.
	override func responds(to aSelector: Selector!) -> Bool {
		switch aSelector {
		case #selector(ForwardNavigationCoordinator.navigationController(_:animationControllerFor:from:to:)),
		     #selector(ForwardNavigationCoordinator.navigationController(_:interactionControllerFor:)):
			return self.screenBeingRestored != nil
		default:
			return super.responds(to: aSelector)
		}
	}

	/// Installs the forward gesture on the specified view.
	///
	/// - Parameter view: The navigation controller's view.
	func attachGestureRecognizer(to view: UIView) {
		guard self.panGestureRecognizer == nil else { return }

		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
		panGestureRecognizer.allowedScrollTypesMask = .all
		panGestureRecognizer.cancelsTouchesInView = false
		panGestureRecognizer.delegate = self
		view.addGestureRecognizer(panGestureRecognizer)

		self.panGestureRecognizer = panGestureRecognizer
	}

	/// Reopens the nearest screen in history without an interactive transition.
	func navigateForward() {
		guard
			let navigationController = self.navigationController,
			self.screenBeingRestored == nil,
			let screen = self.history.first
		else { return }

		self.history.removeFirst()
		self.forwardPushedScreens.insert(ObjectIdentifier(screen))

		navigationController.pushViewController(screen, animated: !UserSettings.isReduceMotionEnabled)
	}

	/// Banks screens a programmatic pop removed.
	///
	/// - Parameter screens: The screens the pop removed, deepest last.
	func bankRemovedScreens(_ screens: [UIViewController]) {
		guard let navigationController = self.navigationController else { return }

		self.lastKnownStack = navigationController.viewControllers

		guard UserSettings.forwardNavigationEnabled, !screens.isEmpty else { return }
		self.history.insert(contentsOf: screens, at: 0)
	}

	/// Drops every screen held in history, releasing them.
	@objc func clearHistory() {
		self.history.removeAll()
	}

	/// Releases tracked screens that are neither on the navigation stack nor in history.
	func discardUnreachableScreens() {
		guard
			let navigationController = self.navigationController,
			self.screenBeingRestored == nil,
			navigationController.topViewController?.transitionCoordinator == nil
		else { return }

		let reachable = Set((navigationController.viewControllers + self.history).map(ObjectIdentifier.init))
		self.lastKnownStack.removeAll { !reachable.contains(ObjectIdentifier($0)) }
	}

	/// Starts an interactive transition to the nearest screen in history.
	private func beginRestoringScreen() {
		guard
			let navigationController = self.navigationController,
			self.screenBeingRestored == nil,
			!self.isTransitioning,
			let screen = self.history.first
		else { return }

		self.history.removeFirst()

		let interactionController = UIPercentDrivenInteractiveTransition()
		self.interactionController = interactionController
		self.screenBeingRestored = screen
		self.lastKnownStack = navigationController.viewControllers + [screen]

		self.suspendInteraction(on: navigationController.topViewController?.view)
		self.suspendInteraction(on: screen.viewIfLoaded)

		self.readvertiseDelegate(on: navigationController)
		navigationController.pushViewController(screen, animated: true)

		self.suspendInteraction(on: screen.viewIfLoaded)
	}

	/// Settles the coordinator's state once an interactive forward transition ends.
	///
	/// - Parameter didComplete: Whether the transition ran to completion.
	private func endRestoringScreen(didComplete: Bool) {
		if !didComplete, let screen = self.screenBeingRestored {
			self.history.insert(screen, at: 0)
		}

		self.interactionSuspendedViews.forEach { $0.isUserInteractionEnabled = true }
		self.interactionSuspendedViews.removeAll()

		self.interactionController = nil
		self.screenBeingRestored = nil
		self.activationTranslation = 0.0
		self.lastKnownStack = self.navigationController?.viewControllers ?? []

		if let navigationController = self.navigationController {
			self.readvertiseDelegate(on: navigationController)
		}
	}

	/// Stops the specified view responding to touches until the transition ends.
	///
	/// - Parameter view: The view to quieten.
	private func suspendInteraction(on view: UIView?) {
		guard
			let view = view,
			view.isUserInteractionEnabled,
			!self.interactionSuspendedViews.contains(where: { $0 === view })
		else { return }

		view.isUserInteractionEnabled = false
		self.interactionSuspendedViews.append(view)
	}

	/// Reassigns the delegate so its transition methods are read again.
	///
	/// - Parameter navigationController: The navigation controller to re-advertise on.
	private func readvertiseDelegate(on navigationController: UINavigationController) {
		navigationController.delegate = nil
		navigationController.delegate = self
	}

	/// Returns whether the specified gesture's touch sits against the trailing screen edge.
	///
	/// - Parameter gestureRecognizer: The gesture to locate.
	///
	/// - Returns: Whether the touch is within the edge band.
	private func beginsAtTrailingEdge(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let view = gestureRecognizer.view else { return false }

		let location = gestureRecognizer.location(in: view)
		let distanceFromTrailingEdge = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
			? location.x
			: view.bounds.maxX - location.x

		return distanceFromTrailingEdge <= Self.edgeBandWidth
	}

	/// Returns whether the content under the specified point can scroll horizontally.
	///
	/// - Parameters:
	///    - location: The point to test, in the specified view's coordinate space.
	///    - view: The view to hit test.
	///
	/// - Returns: Whether any view under the point scrolls horizontally.
	private func hasHorizontallyScrollableContent(at location: CGPoint, in view: UIView) -> Bool {
		var candidate = view.hitTest(location, with: nil)

		while let current = candidate {
			if let scrollView = current as? UIScrollView, self.scrollsHorizontally(scrollView) {
				return true
			}

			candidate = current.superview
		}

		return false
	}

	/// Returns whether the specified scroll view scrolls horizontally.
	///
	/// - Parameter scrollView: The scroll view to measure.
	///
	/// - Returns: Whether the scroll view scrolls horizontally.
	private func scrollsHorizontally(_ scrollView: UIScrollView) -> Bool {
		return scrollView.contentSize.width > scrollView.bounds.width
	}

	/// Releases the history when forward navigation is turned off.
	@objc private func handlePreferenceChange() {
		guard !UserSettings.forwardNavigationEnabled else { return }
		self.clearHistory()
	}

	/// The sign that turns a horizontal translation in the specified view into forward progress.
	///
	/// - Parameter view: The view the translation was measured in.
	///
	/// - Returns: The multiplier to apply to a horizontal translation.
	private func forwardDirection(in view: UIView) -> CGFloat {
		return view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? 1.0 : -1.0
	}

	/// Commits or cancels the in-flight transition, handing the remainder to a spring.
	///
	/// - Parameters:
	///    - progress: How far the swipe travelled, as a fraction of the screen's width.
	///    - velocity: How fast the swipe was travelling forward, as a fraction of the screen's width per second.
	private func commitOrCancelTransition(progress: CGFloat, velocity: CGFloat) {
		guard let interactionController = self.interactionController else { return }

		let shouldCommit = progress > Self.commitThreshold || velocity > Self.commitVelocity
		let remaining = shouldCommit ? max(1.0 - progress, 0.02) : max(progress, 0.02)

		interactionController.timingCurve = ForwardNavigationAnimator.completionTimingParameters
		interactionController.completionSpeed = remaining

		if shouldCommit {
			interactionController.finish()
		} else {
			interactionController.cancel()
		}
	}

	/// Suspends the scroll gesture the swipe is competing with, locking the swipe to one axis.
	///
	/// - Parameter recognizer: The forward gesture, used to locate the content being scrolled.
	private func suspendCompetingScrollGesture(for recognizer: UIPanGestureRecognizer) {
		guard
			let view = recognizer.view,
			let hitView = view.hitTest(recognizer.location(in: view), with: nil)
		else { return }

		var candidate: UIView? = hitView

		while let current = candidate {
			if let scrollView = current as? UIScrollView, scrollView.isScrollEnabled {
				scrollView.panGestureRecognizer.isEnabled = false
				scrollView.panGestureRecognizer.isEnabled = true
				self.suspendedScrollGestureRecognizer = scrollView.panGestureRecognizer
				return
			}

			candidate = current.superview
		}
	}

	/// Whether the swipe points forward.
	///
	/// - Parameters:
	///    - translation: The swipe's translation.
	///    - direction: The sign that turns a horizontal translation into forward progress.
	///
	/// - Returns: Whether the transition should start.
	private func pointsForward(translation: CGPoint, direction: CGFloat) -> Bool {
		return translation.x * direction > 0.0
			&& abs(translation.x) > abs(translation.y) * Self.horizontalRatio
	}

	/// Whether the swipe has travelled far enough, and straight enough, to be a deliberate forward one.
	///
	/// - Parameters:
	///    - translation: The swipe's translation.
	///    - direction: The sign that turns a horizontal translation into forward progress.
	///
	/// - Returns: Whether the transition should start.
	private func qualifiesAsForwardSwipe(translation: CGPoint, direction: CGFloat) -> Bool {
		return translation.x * direction > Self.activationDistance
			&& abs(translation.x) > abs(translation.y) * Self.horizontalRatio
	}

	/// Whether the swipe ended as a flick fast and straight enough to be a deliberate forward one.
	///
	/// - Parameters:
	///    - velocity: The swipe's velocity.
	///    - direction: The sign that turns a horizontal velocity into forward progress.
	///    - width: The width the forward velocity is measured against.
	///
	/// - Returns: Whether the transition should start.
	private func qualifiesAsForwardFlick(velocity: CGPoint, direction: CGFloat, width: CGFloat) -> Bool {
		return velocity.x * direction / width > Self.commitVelocity
			&& abs(velocity.x) > abs(velocity.y) * Self.horizontalRatio
	}

	// MARK: - Actions
	@objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
		guard let view = recognizer.view else { return }

		let direction = self.forwardDirection(in: view)
		let width = max(view.bounds.width, 1.0)
		let translation = recognizer.translation(in: view)
		let forwardTranslation = translation.x * direction
		let velocityVector = recognizer.velocity(in: view)
		let velocity = velocityVector.x * direction / width

		let travelled = forwardTranslation - self.activationTranslation
		let remainingWidth = max(width - self.activationTranslation, 1.0)
		let progress = min(max(travelled / remainingWidth, 0.0), 1.0)

		switch recognizer.state {
		case .began:
			guard
				self.didBeginAtTrailingEdge,
				self.pointsForward(translation: translation, direction: direction)
			else { return }

			self.activationTranslation = 0.0
			self.suspendCompetingScrollGesture(for: recognizer)
			self.beginRestoringScreen()
			self.interactionController?.update(0.0)
		case .changed:
			guard self.interactionController != nil else {
				guard self.qualifiesAsForwardSwipe(translation: translation, direction: direction) else { return }

				self.activationTranslation = forwardTranslation
				self.suspendCompetingScrollGesture(for: recognizer)
				self.beginRestoringScreen()
				self.interactionController?.update(0.0)
				return
			}

			self.interactionController?.update(progress)
		case .ended:
			guard self.interactionController != nil else {
				guard
					self.qualifiesAsForwardSwipe(translation: translation, direction: direction)
						|| self.qualifiesAsForwardFlick(velocity: velocityVector, direction: direction, width: width),
					forwardTranslation > 0.0
				else { return }

				self.activationTranslation = 0.0
				self.suspendCompetingScrollGesture(for: recognizer)
				self.beginRestoringScreen()
				self.interactionController?.update(0.0)
				self.commitOrCancelTransition(progress: 0.0, velocity: max(velocity, Self.commitVelocity * 2.0))
				return
			}

			self.commitOrCancelTransition(progress: progress, velocity: velocity)
		case .cancelled, .failed:
			self.interactionController?.cancel()
		default:
			break
		}
	}
}

// MARK: - UINavigationControllerDelegate
extension ForwardNavigationCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let currentStack = navigationController.viewControllers
		let previousStack = self.lastKnownStack
		self.lastKnownStack = currentStack

		guard self.screenBeingRestored == nil else { return }

		let isUnchanged = currentStack.elementsEqual(previousStack) { $0 === $1 }
		guard !isUnchanged else { return }

		let isPop = currentStack.count < previousStack.count
			&& currentStack.elementsEqual(previousStack.prefix(currentStack.count)) { $0 === $1 }

		if isPop {
			guard UserSettings.forwardNavigationEnabled else { return }
			self.history.insert(contentsOf: previousStack.suffix(from: currentStack.count), at: 0)
			return
		}

		if let topScreen = currentStack.last, self.forwardPushedScreens.remove(ObjectIdentifier(topScreen)) != nil {
			return
		}

		self.clearHistory()
		self.forwardPushedScreens.removeAll()
	}

	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
		guard
			operation == .push,
			self.interactionController != nil,
			toVC === self.screenBeingRestored
		else { return nil }

		let animator = ForwardNavigationAnimator()
		animator.transitionDidEnd = { [weak self] didComplete in
			self?.endRestoringScreen(didComplete: didComplete)
		}

		return animator
	}

	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
		guard animationController is ForwardNavigationAnimator else { return nil }
		return self.interactionController
	}
}

// MARK: - UIGestureRecognizerDelegate
extension ForwardNavigationCoordinator: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard
			UserSettings.forwardNavigationEnabled,
			self.canNavigateForward,
			self.screenBeingRestored == nil,
			let navigationController = self.navigationController,
			navigationController.presentedViewController == nil,
			navigationController.topViewController?.transitionCoordinator == nil
		else { return false }

		guard let view = gestureRecognizer.view else { return true }

		self.didBeginAtTrailingEdge = self.beginsAtTrailingEdge(gestureRecognizer)

		return self.didBeginAtTrailingEdge || !self.hasHorizontallyScrollableContent(at: gestureRecognizer.location(in: view), in: view)
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		guard
			self.beginsAtTrailingEdge(gestureRecognizer),
			let scrollView = otherGestureRecognizer.view as? UIScrollView,
			scrollView.panGestureRecognizer === otherGestureRecognizer
		else { return false }

		return self.scrollsHorizontally(scrollView)
	}
}
