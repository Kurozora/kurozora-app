//
//  MediaViewerPresentationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A presentation controller that dims the presenting screen behind the media viewer.
final class MediaViewerPresentationController: UIPresentationController {
	// MARK: - Views
	/// The view that dims the presenting screen.
	let dimmingView: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.alpha = 0.0
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return view
	}()

	// MARK: - View
	override var shouldRemovePresentersView: Bool {
		return false
	}

	override func presentationTransitionWillBegin() {
		super.presentationTransitionWillBegin()

		guard let containerView = self.containerView else { return }
		self.dimmingView.frame = containerView.bounds
		containerView.insertSubview(self.dimmingView, at: 0)

		self.animateDimmingView(to: 1.0)
	}

	override func presentationTransitionDidEnd(_ completed: Bool) {
		super.presentationTransitionDidEnd(completed)

		if !completed {
			self.dimmingView.removeFromSuperview()
		}
	}

	override func dismissalTransitionWillBegin() {
		super.dismissalTransitionWillBegin()

		self.animateDimmingView(to: 0.0)
	}

	override func dismissalTransitionDidEnd(_ completed: Bool) {
		super.dismissalTransitionDidEnd(completed)

		if completed {
			self.dimmingView.removeFromSuperview()
		} else {
			self.dimmingView.alpha = 1.0
		}
	}

	override func containerViewWillLayoutSubviews() {
		super.containerViewWillLayoutSubviews()

		guard let containerView = self.containerView else { return }
		self.dimmingView.frame = containerView.bounds
		self.presentedView?.frame = self.frameOfPresentedViewInContainerView
	}

	// MARK: - Functions
	/// Fades the dimming view alongside the running transition.
	///
	/// - Parameter alpha: The alpha to animate to.
	private func animateDimmingView(to alpha: CGFloat) {
		guard let coordinator = self.presentedViewController.transitionCoordinator else {
			self.dimmingView.alpha = alpha
			return
		}

		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.dimmingView.alpha = alpha
		})
	}
}
