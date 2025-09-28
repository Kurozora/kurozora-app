//
//  MediaPresentAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	private let startIndex: Int
	private weak var transitionDelegate: MediaTransitionDelegate?

	init(startIndex: Int, transitionDelegate: MediaTransitionDelegate?) {
		self.startIndex = startIndex
		self.transitionDelegate = transitionDelegate
	}

	func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.16
	}

	func animateTransition(using ctx: UIViewControllerContextTransitioning) {
		guard
			let toVC = ctx.viewController(forKey: .to) as? MediaAlbumViewController,
			let container = ctx.containerView as UIView?
		else { ctx.completeTransition(false); return }

		let finalFrame = ctx.finalFrame(for: toVC)
		toVC.view.frame = finalFrame
		container.addSubview(toVC.view)
		toVC.view.layoutIfNeeded()

		// Hide the actual media view until animation completes
		let mediaView = toVC.currentMediaView()
		mediaView?.isHidden = true
		toVC.view.backgroundColor = .clear
		toVC.view.alpha = 1

		// Snapshot of the tapped thumbnail
		guard
			let thumb = transitionDelegate?.imageViewForMedia(at: startIndex),
			let snapshot = makeSnapshot(from: thumb)
		else {
			toVC.view.alpha = 0
			UIView.animate(withDuration: self.transitionDuration(using: ctx), animations: {
				toVC.view.alpha = 1
			}) { _ in
				ctx.completeTransition(!ctx.transitionWasCancelled)
			}
			return
		}

		let startFrame = container.convert(thumb.bounds, from: thumb)
		snapshot.frame = startFrame
		container.addSubview(snapshot)

		// End frame should match media’s aspectFit frame inside the container
		let targetFrame = container.bounds
		let fittedTarget = aspectFitFrame(for: snapshot.image?.size ?? .zero, in: targetFrame)

		let duration = self.transitionDuration(using: ctx)
		UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
			snapshot.frame = fittedTarget
			toVC.view.backgroundColor = .black
		}, completion: { _ in
			snapshot.removeFromSuperview()
			mediaView?.isHidden = false
			ctx.completeTransition(!ctx.transitionWasCancelled)
		})
	}

	private func makeSnapshot(from imageView: UIImageView) -> UIImageView? {
		guard let image = imageView.image else { return nil }
		let snap = UIImageView(image: image)
		snap.contentMode = imageView.contentMode
		snap.clipsToBounds = imageView.clipsToBounds
		snap.layer.cornerRadius = imageView.layer.cornerRadius
		return snap
	}

	private func aspectFitFrame(for imageSize: CGSize, in boundingRect: CGRect) -> CGRect {
		let scale = min(boundingRect.width / imageSize.width,
						boundingRect.height / imageSize.height)
		let width = imageSize.width * scale
		let height = imageSize.height * scale
		let x = boundingRect.midX - width / 2
		let y = boundingRect.midY - height / 2
		return CGRect(x: x, y: y, width: width, height: height)
	}
}
