//
//  StatusBarScrollRestorer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Restores a scroll view to its previous position when the status bar is tapped a second time.
final class StatusBarScrollRestorer: NSObject {
	// MARK: - Properties
	private var contentOffsetBeforeStatusBarJump: CGPoint?

	// MARK: - Functions
	/// Installs position restoration for the given scroll view.
	///
	/// - Parameter scrollView: The scroll view whose position is restored.
	func install(restoring scrollView: UIScrollView) {
		scrollView.panGestureRecognizer.addTarget(self, action: #selector(self.handlePanGesture(_:)))
	}

	/// Returns whether the given scroll view should scroll to the top.
	///
	/// - Parameter scrollView: The scroll view about to scroll to the top.
	///
	/// - Returns: `true` if the scroll view should scroll to the top.
	func shouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		if let contentOffsetBeforeStatusBarJump = self.contentOffsetBeforeStatusBarJump {
			self.contentOffsetBeforeStatusBarJump = nil
			scrollView.setContentOffset(self.clamped(contentOffsetBeforeStatusBarJump, in: scrollView), animated: true)
			return false
		}

		let minimumRestorableDistance: CGFloat = 20
		let topContentOffset = -scrollView.adjustedContentInset.top
		guard scrollView.contentOffset.y > topContentOffset + minimumRestorableDistance else { return true }

		self.contentOffsetBeforeStatusBarJump = scrollView.contentOffset

		let restingDistance = 1 / max(scrollView.traitCollection.displayScale, 1)
		scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: topContentOffset + restingDistance), animated: true)
		return false
	}

	/// Discards the remembered position of the scroll view.
	///
	/// - Parameter panGestureRecognizer: The pan gesture recognizer that changed state.
	@objc private func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
		if panGestureRecognizer.state == .began {
			self.contentOffsetBeforeStatusBarJump = nil
		}
	}

	/// Returns the given content offset limited to the scrollable range of the given scroll view.
	///
	/// - Parameters:
	///    - contentOffset: The content offset to limit.
	///    - scrollView: The scroll view providing the scrollable range.
	///
	/// - Returns: The limited content offset.
	private func clamped(_ contentOffset: CGPoint, in scrollView: UIScrollView) -> CGPoint {
		let minimumY = -scrollView.adjustedContentInset.top
		let maximumY = max(minimumY, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)

		return CGPoint(x: contentOffset.x, y: min(max(contentOffset.y, minimumY), maximumY))
	}
}
