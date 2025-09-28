//
//  MediaDismissTransitionController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaDismissTransitionController: NSObject {
	weak var albumVC: MediaAlbumViewController?
	private var interactionInProgress = false
	private var shouldCompleteTransition = false
	private var transitionContext: UIViewControllerContextTransitioning?

	private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))

	init(albumVC: MediaAlbumViewController) {
		self.albumVC = albumVC
		super.init()
		albumVC.view.addGestureRecognizer(self.panGesture)
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard let view = gesture.view, let albumVC = albumVC else { return }
		let translation = gesture.translation(in: view)
		let progress = max(0, min(1, abs(translation.y) / view.bounds.height))

		switch gesture.state {
		case .began:
			self.interactionInProgress = true
			albumVC.dismiss(animated: true)
		case .changed:
			self.shouldCompleteTransition = progress > 0.25
			self.transitionContext?.updateInteractiveTransition(progress)

			let translationTransform = CGAffineTransform(translationX: 0, y: translation.y)
			let scale = max(0.75, 1 - progress * 0.25)
			let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
			albumVC.view.transform = translationTransform.concatenating(scaleTransform)
			albumVC.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
		case .cancelled, .ended:
			self.interactionInProgress = false
			if self.shouldCompleteTransition {
				self.transitionContext?.finishInteractiveTransition()
				UIView.animate(withDuration: 0.25) {
					albumVC.view.alpha = 0
				}
			} else {
				self.transitionContext?.cancelInteractiveTransition()
				UIView.animate(withDuration: 0.25) {
					albumVC.view.transform = .identity
					albumVC.view.backgroundColor = .black
				}
			}
			self.transitionContext?.completeTransition(self.shouldCompleteTransition)
			self.transitionContext = nil
		default: break
		}
	}
}
