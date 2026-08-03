//
//  ForwardNavigationAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

/// Animates a forward navigation push so it reads as the system's back swipe played in reverse.
final class ForwardNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	// MARK: - Properties
	/// The fraction of the container's width the outgoing view travels.
	private let parallaxRatio: CGFloat = 0.3

	/// The colour the dimming view lays over the outgoing view.
	private let dimmingColor = UIColor.black.withAlphaComponent(0.102)

	/// The opacity of the incoming view's shadow.
	private let shadowOpacity: Float = 0.04

	/// The blur radius of the incoming view's shadow.
	private let shadowRadius: CGFloat = 12.0

	/// The offset of the incoming view's shadow.
	private let shadowOffset = CGSize(width: 0.0, height: -3.0)

	/// The animator driving the transition, retained so an interactive transition keeps a single instance.
	private var propertyAnimator: UIViewPropertyAnimator?

	/// The handler called once the transition ends, passing whether it ran to completion.
	var transitionDidEnd: ((Bool) -> Void)?

	/// How long the transition runs when it plays from end to end.
	static let duration: TimeInterval = 0.35

	/// The spring the transition settles with.
	static var completionTimingParameters: UISpringTimingParameters {
		return UISpringTimingParameters(mass: 1.0, stiffness: 510.8, damping: 37.97, initialVelocity: .zero)
	}

	// MARK: - Functions
	/// The radius the display rounds its corners by, or zero when it does not round them.
	///
	/// - Parameter view: A view in the window whose screen to measure.
	///
	/// - Returns: The display's corner radius in points.
	private func displayCornerRadius(for view: UIView) -> CGFloat {
		guard let window = view.window, let screen = window.windowScene?.screen else { return 0.0 }

		if #available(iOS 26.0, macCatalyst 26.0, *) {
			let publicRadius = window.effectiveRadius(corner: .topLeft)

			if publicRadius > 0.0 {
				return publicRadius
			}
		}

		let radiusKey = #obfuscated("_displayCornerRadius")
		guard screen.responds(to: NSSelectorFromString(radiusKey)) else { return 0.0 }

		return screen.value(forKey: radiusKey) as? CGFloat ?? 0.0
	}

	func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
		return Self.duration
	}

	func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
		self.interruptibleAnimator(using: transitionContext).startAnimation()
	}

	func interruptibleAnimator(using transitionContext: any UIViewControllerContextTransitioning) -> any UIViewImplicitlyAnimating {
		if let propertyAnimator = self.propertyAnimator {
			return propertyAnimator
		}

		let propertyAnimator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), timingParameters: Self.completionTimingParameters)
		propertyAnimator.scrubsLinearly = true
		self.propertyAnimator = propertyAnimator

		guard let toView = transitionContext.view(forKey: .to) else {
			propertyAnimator.addAnimations {}
			propertyAnimator.addCompletion { _ in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			}
			return propertyAnimator
		}

		let containerView = transitionContext.containerView
		let fromView = transitionContext.view(forKey: .from)
		let isRightToLeft = containerView.effectiveUserInterfaceLayoutDirection == .rightToLeft
		let travelDistance = isRightToLeft ? -containerView.bounds.width : containerView.bounds.width

		let dimmingView = UIView(frame: containerView.bounds)
		dimmingView.backgroundColor = self.dimmingColor
		dimmingView.alpha = 0.0
		dimmingView.isUserInteractionEnabled = false
		containerView.addSubview(dimmingView)

		toView.frame = containerView.bounds
		toView.transform = CGAffineTransform(translationX: travelDistance, y: 0.0)
		toView.layer.cornerCurve = .continuous
		toView.layer.shadowColor = UIColor.black.cgColor
		toView.layer.shadowOpacity = self.shadowOpacity
		toView.layer.shadowRadius = self.shadowRadius
		toView.layer.shadowOffset = self.shadowOffset
		containerView.addSubview(toView)

		let cornerRadius = self.displayCornerRadius(for: containerView)

		if cornerRadius > 0.0 {
			let previousMaskedCorners = toView.layer.maskedCorners
			let previouslyClipped = toView.layer.masksToBounds

			toView.layer.cornerRadius = cornerRadius
			toView.layer.maskedCorners = isRightToLeft
				? [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
				: [.layerMinXMinYCorner, .layerMinXMaxYCorner]
			toView.layer.masksToBounds = true

			propertyAnimator.addCompletion { _ in
				toView.layer.cornerRadius = 0.0
				toView.layer.maskedCorners = previousMaskedCorners
				toView.layer.masksToBounds = previouslyClipped
			}
		}

		propertyAnimator.addAnimations {
			toView.transform = .identity
			fromView?.transform = CGAffineTransform(translationX: -travelDistance * self.parallaxRatio, y: 0.0)
			dimmingView.alpha = 1.0
		}

		propertyAnimator.addCompletion { _ in
			let didComplete = !transitionContext.transitionWasCancelled

			dimmingView.removeFromSuperview()
			fromView?.transform = .identity
			toView.transform = .identity
			toView.layer.shadowOpacity = 0.0

			if !didComplete {
				toView.removeFromSuperview()
			}

			transitionContext.completeTransition(didComplete)
		}

		return propertyAnimator
	}

	func animationEnded(_ transitionCompleted: Bool) {
		self.propertyAnimator = nil
		self.transitionDidEnd?(transitionCompleted)
	}
}
