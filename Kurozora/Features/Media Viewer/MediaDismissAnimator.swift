//
//  MediaDismissAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// Shrinks the fullscreen media back into the thumbnail it came from.
final class MediaDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	// MARK: - Properties
	private let closeMethod: MediaViewerCloseMethod
	private weak var transitionDelegate: MediaTransitionDelegate?

	// MARK: - Initializers
	init(closeMethod: MediaViewerCloseMethod, transitionDelegate: MediaTransitionDelegate?) {
		self.closeMethod = closeMethod
		self.transitionDelegate = transitionDelegate
	}

	// MARK: - Functions
	func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.closeMethod.duration
	}

	func animateTransition(using context: UIViewControllerContextTransitioning) {
		guard let albumViewController = context.viewController(forKey: .from) as? MediaAlbumViewController else {
			context.completeTransition(false)
			return
		}

		let containerView = context.containerView
		let duration = self.transitionDuration(using: context)
		let currentIndex = albumViewController.currentIndex
		self.transitionDelegate?.scrollThumbnailIntoView(for: currentIndex, animated: false)

		let mediaView = albumViewController.currentMedia?.mediaView
		let startFrame = mediaView.map { containerView.convert($0.bounds, from: $0) } ?? .zero

		guard
			let mediaView = mediaView,
			let thumbnail = self.transitionDelegate?.imageViewForMedia(at: currentIndex),
			let image = albumViewController.currentMedia?.mediaImage ?? thumbnail.image,
			!startFrame.isEmpty
		else {
			self.crossFade(from: albumViewController, duration: duration, using: context)
			return
		}

		mediaView.isHidden = true
		thumbnail.isHidden = true

		let proxy = MediaTransitionProxy(image: image, cornerRadius: 0)
		proxy.frame = startFrame
		containerView.addSubview(proxy)

		let targetFrame = containerView.convert(thumbnail.bounds, from: thumbnail)
		let targetCornerRadius = MediaTransitionProxy.cornerRadius(of: thumbnail)

		proxy.animateMaskAndCrop(to: targetCornerRadius, contentsRect: thumbnail.layer.contentsRect, duration: duration)

		UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
			proxy.frame = targetFrame
			albumViewController.setChromeAlpha(0)
		} completion: { _ in
			proxy.removeFromSuperview()
			thumbnail.isHidden = false
			mediaView.isHidden = false
			context.completeTransition(!context.transitionWasCancelled)
		}
	}

	/// Fades the viewer out.
	///
	/// - Parameters:
	///    - albumViewController: The viewer being dismissed.
	///    - duration: The duration of the fade.
	///    - context: The running transition.
	private func crossFade(from albumViewController: MediaAlbumViewController, duration: TimeInterval, using context: UIViewControllerContextTransitioning) {
		UIView.animate(withDuration: duration) {
			albumViewController.view.alpha = 0
		} completion: { _ in
			context.completeTransition(!context.transitionWasCancelled)
		}
	}
}
