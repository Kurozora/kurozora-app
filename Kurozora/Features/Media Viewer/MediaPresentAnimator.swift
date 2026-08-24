//
//  MediaPresentAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// Grows the tapped thumbnail into the fullscreen media viewer.
final class MediaPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	// MARK: - Properties
	private let startIndex: Int
	private weak var transitionDelegate: MediaTransitionDelegate?

	/// The thumbnail the viewer grows from.
	private var thumbnail: UIImageView? {
		return self.transitionDelegate?.imageViewForMedia(at: self.startIndex)
	}

	// MARK: - Initializers
	init(startIndex: Int, transitionDelegate: MediaTransitionDelegate?) {
		self.startIndex = startIndex
		self.transitionDelegate = transitionDelegate
	}

	// MARK: - Functions
	func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
		guard let thumbnail = self.thumbnail else { return 0.4 }
		return thumbnail.bounds.width < MediaTransitionProxy.smallThumbnailWidth ? 0.6 : 0.4
	}

	func animateTransition(using context: UIViewControllerContextTransitioning) {
		guard let albumViewController = context.viewController(forKey: .to) as? MediaAlbumViewController else {
			context.completeTransition(false)
			return
		}

		let containerView = context.containerView
		albumViewController.view.frame = context.finalFrame(for: albumViewController)
		containerView.addSubview(albumViewController.view)
		albumViewController.view.layoutIfNeeded()

		let duration = self.transitionDuration(using: context)

		guard let thumbnail = self.thumbnail, let image = thumbnail.image else {
			self.crossFade(to: albumViewController, duration: duration, using: context)
			return
		}

		let mediaView = albumViewController.currentMedia?.mediaView
		mediaView?.isHidden = true
		thumbnail.isHidden = true
		albumViewController.setChromeAlpha(0)

		let proxy = MediaTransitionProxy(image: image, cornerRadius: MediaTransitionProxy.cornerRadius(of: thumbnail))
		proxy.frame = containerView.convert(thumbnail.bounds, from: thumbnail)
		proxy.layer.contentsRect = thumbnail.layer.contentsRect
		containerView.addSubview(proxy)

		let targetFrame = self.targetFrame(for: mediaView, image: image, in: containerView)
		let isSmallThumbnail = thumbnail.bounds.width < MediaTransitionProxy.smallThumbnailWidth
		let damping: CGFloat = isSmallThumbnail ? 0.9 : 1.0
		let initialVelocity: CGFloat = isSmallThumbnail ? 16.0 : 4.0

		proxy.animateMaskAndCrop(to: 0, contentsRect: CGRect(x: 0, y: 0, width: 1, height: 1), duration: duration)

		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, options: [.allowUserInteraction]) {
			proxy.frame = targetFrame
			albumViewController.setChromeAlpha(1)
		} completion: { _ in
			proxy.removeFromSuperview()
			thumbnail.isHidden = false
			mediaView?.isHidden = false
			context.completeTransition(!context.transitionWasCancelled)
		}
	}

	/// Returns the rect the media settles into.
	///
	/// - Parameters:
	///    - mediaView: The renderer's media view.
	///    - image: The image being presented.
	///    - containerView: The transition's container.
	/// - Returns: The rect in `containerView`'s coordinate space.
	private func targetFrame(for mediaView: UIView?, image: UIImage, in containerView: UIView) -> CGRect {
		guard let mediaView = mediaView else {
			return MediaTransitionProxy.aspectFitRect(for: image.size, in: containerView.bounds)
		}

		let renderedFrame = containerView.convert(mediaView.bounds, from: mediaView)
		if !renderedFrame.isEmpty {
			return renderedFrame
		}

		return MediaTransitionProxy.aspectFitRect(for: image.size, in: containerView.bounds)
	}

	/// Fades the viewer in.
	///
	/// - Parameters:
	///    - albumViewController: The viewer being presented.
	///    - duration: The duration of the fade.
	///    - context: The running transition.
	private func crossFade(to albumViewController: MediaAlbumViewController, duration: TimeInterval, using context: UIViewControllerContextTransitioning) {
		albumViewController.view.alpha = 0

		UIView.animate(withDuration: duration) {
			albumViewController.view.alpha = 1
		} completion: { _ in
			context.completeTransition(!context.transitionWasCancelled)
		}
	}
}
