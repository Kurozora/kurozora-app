//
//  TrailerFullscreenTransitionAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Zooms a trailer between its place on the page and the fullscreen player.
final class TrailerFullscreenTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	// MARK: - Properties
	/// A Boolean value indicating whether the fullscreen player is appearing.
	private let isPresenting: Bool

	/// The frame the trailer occupies on the page, in window coordinates.
	private let sourceFrame: CGRect?

	// MARK: - Initializers
	/// Creates an animator for one direction of the fullscreen transition.
	///
	/// - Parameters:
	///    - isPresenting: Whether the fullscreen player is appearing.
	///    - sourceFrame: The frame the trailer occupies on the page, in window coordinates.
	init(isPresenting: Bool, sourceFrame: CGRect?) {
		self.isPresenting = isPresenting
		self.sourceFrame = sourceFrame
		super.init()
	}

	// MARK: - Functions
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let fullscreenKey: UITransitionContextViewControllerKey = self.isPresenting ? .to : .from

		guard let fullscreenViewController = transitionContext.viewController(forKey: fullscreenKey) as? TrailerFullscreenViewController else {
			transitionContext.completeTransition(false)
			return
		}

		if self.isPresenting {
			containerView.addSubview(fullscreenViewController.view)
		}

		fullscreenViewController.view.frame = containerView.bounds
		fullscreenViewController.view.layoutIfNeeded()

		let zoom = self.zoomTransforms(in: containerView)
		let chromeViews = fullscreenViewController.chromeViews

		if self.isPresenting {
			fullscreenViewController.zoomWindowView.transform = zoom.window
			fullscreenViewController.contentView.transform = zoom.content
			fullscreenViewController.backdropView.alpha = 0.0
			chromeViews.forEach { $0.alpha = 0.0 }
		}

		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 4.0, options: [.allowUserInteraction]) {
			fullscreenViewController.zoomWindowView.transform = self.isPresenting ? .identity : zoom.window
			fullscreenViewController.contentView.transform = self.isPresenting ? .identity : zoom.content
			fullscreenViewController.backdropView.alpha = self.isPresenting ? 1.0 : 0.0
			chromeViews.forEach { $0.alpha = self.isPresenting ? 1.0 : 0.0 }
		} completion: { _ in
			fullscreenViewController.zoomWindowView.transform = .identity
			fullscreenViewController.contentView.transform = .identity
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}

	/// Returns the transforms that place the fullscreen player over the trailer's place on the page.
	///
	/// - Parameter containerView: The view the transition runs in.
	///
	/// - Returns: The window and content transforms.
	private func zoomTransforms(in containerView: UIView) -> (window: CGAffineTransform, content: CGAffineTransform) {
		let fallback = CGAffineTransform(scaleX: 0.9, y: 0.9)

		guard let sourceFrame = self.sourceFrame, containerView.bounds.width > 0.0, containerView.bounds.height > 0.0 else {
			return (fallback, .identity)
		}

		let targetFrame = containerView.convert(sourceFrame, from: containerView.window)
		guard targetFrame.width > 0.0, targetFrame.height > 0.0 else {
			return (fallback, .identity)
		}

		let scaleX = targetFrame.width / containerView.bounds.width
		let scaleY = targetFrame.height / containerView.bounds.height
		let translationX = targetFrame.midX - containerView.bounds.midX
		let translationY = targetFrame.midY - containerView.bounds.midY

		let windowTransform = CGAffineTransform(translationX: translationX, y: translationY).scaledBy(x: scaleX, y: scaleY)

		// The picture fills the smaller rect by scaling evenly, cropped by the window it sits in.
		let pictureScale = max(scaleX, scaleY)
		let pictureTransform = CGAffineTransform(translationX: translationX, y: translationY).scaledBy(x: pictureScale, y: pictureScale)

		return (windowTransform, pictureTransform.concatenating(windowTransform.inverted()))
	}
}
