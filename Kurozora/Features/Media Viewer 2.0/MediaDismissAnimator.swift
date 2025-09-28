//
//  MediaDismissAnimator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	weak var transitionDelegate: MediaTransitionDelegate?

	init(transitionDelegate: MediaTransitionDelegate?) {
		self.transitionDelegate = transitionDelegate
	}

	func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.16
	}

	func animateTransition(using ctx: UIViewControllerContextTransitioning) {
		guard
			let fromVC = ctx.viewController(forKey: .from) as? MediaAlbumViewController,
			let container = ctx.containerView as UIView?
		else { ctx.completeTransition(false); return }

		let currentIndex = fromVC.currentIndex
		self.transitionDelegate?.scrollThumbnailIntoView(for: currentIndex)

		guard
			let targetThumb = transitionDelegate?.imageViewForMedia(at: currentIndex),
			let mediaView = fromVC.currentMediaView() as? UIImageView,
			let snapshot = makeSnapshot(from: mediaView)
		else {
			self.fallbackFade(ctx: ctx, fromVC: fromVC)
			return
		}

		let startFrame = container.convert(mediaView.bounds, from: mediaView)
		snapshot.frame = startFrame
		container.addSubview(snapshot)
		mediaView.isHidden = true

		let targetFrame = container.convert(targetThumb.bounds, from: targetThumb)
		let fittedTargetFrame = self.aspectFitFrame(for: snapshot.image?.size ?? .zero, in: targetFrame)

		fromVC.view.backgroundColor = .black

		UIView.animate(withDuration: self.transitionDuration(using: ctx), delay: 0, options: [.curveEaseOut], animations: {
			snapshot.frame = fittedTargetFrame
			fromVC.view.backgroundColor = .clear
		}, completion: { _ in
			snapshot.removeFromSuperview()
			mediaView.isHidden = false
			ctx.completeTransition(!ctx.transitionWasCancelled)
		})
	}

	private func fallbackFade(ctx: UIViewControllerContextTransitioning, fromVC: UIViewController) {
		UIView.animate(withDuration: 0.25, animations: {
			fromVC.view.alpha = 0
		}, completion: { _ in
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
