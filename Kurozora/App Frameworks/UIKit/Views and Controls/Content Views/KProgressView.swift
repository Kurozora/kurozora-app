//
//  KProgressView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A view that depicts the progress of a task over time.
///
/// The [KProgressView](x-source-tag://KProgressView) class provides properties for managing the style of the progress bar and for getting and setting values that are pinned to the progress of a task.
///
/// For an indeterminate progress indicator — or a “spinner” — use an instance of the [KActivityIndicatorView](x-source-tag://KActivityIndicatorView) class.
class KProgressView: UIView {
	// MARK: - Properties
	/// The view that shows the portion of the task that isn’t completed.
	private(set) var trackView = UIView()

	/// The view that shows the portion of the task that’s completed.
	private(set) var progressView = UIView()

	/// The current progress of the progress view.
	///
	/// The current progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
	var progress: Float = 0 {
		didSet {
			let clamped = min(max(self.progress, 0), 1)

			if self.progress != clamped {
				self.progress = clamped
			}

			self.setNeedsLayout()
		}
	}

	/// The color shown for the portion of the progress bar that’s filled.
	var progressTintColor: UIColor? {
		get { self.progressView.backgroundColor }
		set { self.progressView.backgroundColor = newValue }
	}

	/// The color shown for the portion of the progress bar that isn’t filled.
	///
	/// If you set [trackTintColor](x-source-tag://KProgressView-trackTintColor) to `nil`, the track uses the tint of its parent.
	///
	/// - Tag: KProgressView-trackTintColor
	var trackTintColor: UIColor? {
		get { self.trackView.backgroundColor }
		set { self.trackView.backgroundColor = newValue }
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		let height = self.bounds.height
		self.layer.cornerRadius = height / 2

		self.trackView.frame = self.bounds
		self.trackView.layer.cornerRadius = height / 2

		let progressWidth = self.bounds.width * CGFloat(self.progress)
		self.progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: height)
		self.progressView.layer.cornerRadius = height / 2
	}

	// MARK: - Functions
	/// Configures the view by setting up its properties and subviews.
	private func configureView() {
		self.clipsToBounds = true
		self.addSubview(self.trackView)
		self.addSubview(self.progressView)

		// Defaults matching UIProgressView
		self.trackTintColor = .systemGray6
		self.progressTintColor = .tintColor

		// Accessibility setup
		self.isAccessibilityElement = true
		self.accessibilityTraits = [.updatesFrequently]
	}

	/// Adjusts the current progress of the progress view, optionally animating the change.
	///
	/// The current progress is represented by a floating-point value between 0.0 and 1.0, inclusive, where 1.0 indicates the completion of the task. The default value is 0.0. Values less than 0.0 and greater than 1.0 are pinned to those limits.
	///
	/// - Parameters:
	///    - progress: The new progress value.
	///    - animated: [true](https://developer.apple.com/documentation/swift/true) if the change should be animated, [false](https://developer.apple.com/documentation/swift/false) if the change should happen immediately.
	func setProgress(_ progress: Float, animated: Bool) {
		self.progress = progress

		if animated {
			UIView.animate(withDuration: 0.25) {
				self.layoutIfNeeded()
			}
		} else {
			self.setNeedsLayout()
		}
	}
}

// MARK: - SwiftTheme
@objc extension KProgressView {
	var theme_progressTintColor: ThemeColorPicker? {
		get { self.progressView.theme_backgroundColor }
		set { self.progressView.theme_backgroundColor = newValue }
	}

	var theme_trackTintColor: ThemeColorPicker? {
		get { self.trackView.theme_backgroundColor }
		set { self.trackView.theme_backgroundColor = newValue }
	}
}
