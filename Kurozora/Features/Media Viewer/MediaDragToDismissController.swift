//
//  MediaDragToDismissController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Dismisses the media viewer with a drag gesture.
final class MediaDragToDismissController {
	// MARK: - Properties
	/// The vertical speed, in points per second, above which a release counts as a flick.
	private let flickVelocityThreshold: CGFloat = 250.0

	/// The fraction of the traversable distance past which a released drag dismisses.
	private let dismissProgressThreshold: CGFloat = 0.35

	/// The duration of the animation that returns the media to rest.
	private let restoreDuration: TimeInterval = 0.175

	/// The rate at which the controls fade out relative to the drag's progress.
	private let chromeFadeRate: CGFloat = 4.0

	private unowned let albumViewController: MediaAlbumViewController

	/// The distance the media travels before the backdrop is fully transparent.
	private var distanceToTraverse: CGFloat = 1.0

	/// The media's resting frame.
	private var initialMediaFrame: CGRect = .zero

	/// The grab point's offset from the media's center.
	private var touchOffsetFromCenter: CGPoint = .zero

	/// The media's resting content mode.
	private var initialContentMode: UIView.ContentMode = .scaleAspectFit

	/// A Boolean value that indicates whether a drag is moving the media.
	private(set) var isDragging = false

	// MARK: - Initializers
	init(albumViewController: MediaAlbumViewController) {
		self.albumViewController = albumViewController
	}

	// MARK: - Functions
	/// Advances the drag.
	///
	/// - Parameter gesture: The pan driving the dismissal.
	func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard
			let mediaView = self.albumViewController.currentMedia?.mediaView,
			let coordinateSpace = mediaView.superview
		else {
			return
		}

		let location = gesture.location(in: coordinateSpace)
		let translation = gesture.translation(in: coordinateSpace)

		switch gesture.state {
		case .began:
			self.beginDrag(of: mediaView, at: location)
		case .changed:
			self.updateDrag(of: mediaView, at: location, translation: translation)
		case .ended:
			self.endDrag(of: mediaView, translation: translation, velocity: gesture.velocity(in: coordinateSpace))
		case .cancelled, .failed:
			self.restore(mediaView)
		default:
			break
		}
	}

	private func beginDrag(of mediaView: UIView, at location: CGPoint) {
		self.isDragging = true
		self.initialMediaFrame = mediaView.frame

		// Measured on screen, so short media doesn't run out of travel sooner than tall media.
		let onScreenFrame = self.albumViewController.view.convert(mediaView.bounds, from: mediaView)
		self.distanceToTraverse = max(1.0, onScreenFrame.maxY * 0.9)

		self.touchOffsetFromCenter = CGPoint(
			x: location.x - mediaView.center.x,
			y: location.y - mediaView.center.y
		)

		self.initialContentMode = mediaView.contentMode
		mediaView.contentMode = .scaleAspectFill
		mediaView.clipsToBounds = true
	}

	private func updateDrag(of mediaView: UIView, at location: CGPoint, translation: CGPoint) {
		guard self.isDragging else { return }

		let progress = self.progress(for: translation)
		let remaining = 1.0 - progress

		self.albumViewController.dimmingView?.alpha = remaining
		self.albumViewController.setChromeAlpha(1.0 - progress * self.chromeFadeRate)

		mediaView.center = CGPoint(
			x: location.x - self.touchOffsetFromCenter.x,
			y: location.y - self.touchOffsetFromCenter.y
		)

		let scale = (remaining + 2.0) / 3.0
		mediaView.frame = CGRect(
			origin: mediaView.frame.origin,
			size: CGSize(
				width: self.initialMediaFrame.width * scale,
				height: self.initialMediaFrame.height * scale
			)
		)
	}

	private func endDrag(of mediaView: UIView, translation: CGPoint, velocity: CGPoint) {
		guard self.isDragging else { return }

		let isFlick = abs(velocity.y) > self.flickVelocityThreshold && abs(velocity.x) < abs(velocity.y)
		let isPastThreshold = self.progress(for: translation) >= self.dismissProgressThreshold

		guard isFlick || isPastThreshold else {
			self.restore(mediaView)
			return
		}

		self.isDragging = false
		self.albumViewController.close(using: isFlick ? .flick : .drag)
	}

	/// Returns the media, backdrop and controls to their resting state.
	///
	/// - Parameter mediaView: The view showing the media.
	private func restore(_ mediaView: UIView) {
		guard self.isDragging else { return }
		self.isDragging = false

		let restingFrame = self.initialMediaFrame
		let restingContentMode = self.initialContentMode

		UIView.animate(withDuration: self.restoreDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
			mediaView.frame = restingFrame
			self.albumViewController.dimmingView?.alpha = 1.0
			self.albumViewController.setChromeAlpha(1.0)
		} completion: { _ in
			mediaView.contentMode = restingContentMode
		}
	}

	/// Returns how far through the dismissal the given translation is.
	///
	/// - Parameter translation: The gesture's translation.
	/// - Returns: A value between `0` and `1`.
	private func progress(for translation: CGPoint) -> CGFloat {
		return min(1.0, abs(translation.y) / self.distanceToTraverse)
	}
}
