//
//  MediaInteractionController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaInteractionController: UIPercentDrivenInteractiveTransition {
	private weak var viewController: UIViewController?
	private var panGesture: UIPanGestureRecognizer?
	private(set) var hasStarted = false
	private(set) var shouldFinish = false
	private let completionThreshold: CGFloat = 0.25

	func wireToViewController(_ vc: UIViewController) {
		self.viewController = vc
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
		pan.minimumNumberOfTouches = 1
		pan.maximumNumberOfTouches = 1
		vc.view.addGestureRecognizer(pan)
		self.panGesture = pan
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard let vcView = viewController?.view else { return }
		let translation = gesture.translation(in: vcView)
		// progress based on vertical distance
		let progress = min(1.0, max(0.0, abs(translation.y) / vcView.bounds.height))

		switch gesture.state {
		case .began:
			self.hasStarted = true
			self.viewController?.dismiss(animated: true, completion: nil)
		case .changed:
			self.shouldFinish = progress > self.completionThreshold
			update(progress)
		case .cancelled, .ended:
			self.hasStarted = false
			if self.shouldFinish {
				finish()
			} else {
				cancel()
			}
		default:
			break
		}
	}
}
