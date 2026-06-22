//
//  PlaybackProgressView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A bottom-anchored progress bar that shows a hairline by default and expands into a
/// scrubber with time labels while hovered or scrubbed.
@available(iOS 26.0, *)
final class PlaybackProgressView: UIView {
	// MARK: - Views
	private let trackView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .label.withAlphaComponent(0.25)
		view.layer.cornerRadius = 1.5
		view.clipsToBounds = true
		return view
	}()

	private let fillView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .label
		return view
	}()

	private let currentTimeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .label
		return label
	}()

	private let remainingTimeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .label
		label.textAlignment = .right
		label.isUserInteractionEnabled = true
		return label
	}()

	/// The container holding both time labels, scaled and faded as one unit so they grow from the center outward.
	private let labelContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0
		return view
	}()

	// MARK: - Properties
	/// A closure invoked when the user scrubs to a new position, in seconds.
	var onSeek: ((TimeInterval) -> Void)?

	/// A closure invoked when the view expands into or collapses from its scrubber state.
	var onExpansionChange: ((Bool) -> Void)?

	/// The latest published playback progress.
	private var progress: PlaybackProgress = .zero

	/// Whether the trailing label shows total time instead of remaining time.
	private var showsTotalTime: Bool = UserSettings.musicAccessoryShowsTotalTime

	/// Whether a pointer is currently hovering the view.
	private var isHovering = false

	/// Whether the user is currently scrubbing.
	private var isScrubbing = false

	/// The height of the view in its collapsed (hairline) state.
	private let collapsedHeight: CGFloat = 14

	/// The height of the view in its expanded (scrubber) state.
	private let expandedHeight: CGFloat = 50

	/// The track height in the collapsed (hairline) state.
	private let collapsedTrackHeight: CGFloat = 2

	/// The track height in the expanded (capsule) state.
	private let expandedTrackHeight: CGFloat = 8

	/// The inset between the track and the bottom edge in the expanded (scrubber) state.
	private let expandedBottomInset: CGFloat = 4

	/// The scale applied to the time labels while collapsed, from which they grow as the scrubber expands.
	private let collapsedLabelScale: CGFloat = 0.97

	/// Whether the view is showing its expanded scrubber.
	private var isExpanded: Bool {
		return self.isHovering || self.isScrubbing
	}

	/// The expansion state currently reflected by the view, used to skip redundant transitions.
	private var displayedExpanded = false

	private lazy var heightConstraint: NSLayoutConstraint = self.heightAnchor.constraint(equalToConstant: self.collapsedHeight)

	private lazy var trackHeightConstraint: NSLayoutConstraint = self.trackView.heightAnchor.constraint(equalToConstant: self.collapsedTrackHeight)

	private lazy var trackBottomConstraint: NSLayoutConstraint = self.trackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

	private lazy var fillWidthConstraint: NSLayoutConstraint = self.fillView.widthAnchor.constraint(equalToConstant: 0)

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.trackView.layer.cornerRadius = self.trackView.bounds.height / 2
		self.updateFill()
	}

	// MARK: - Functions
	private func sharedInit() {
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureGestures()
		self.updateLabels()

		self.labelContainer.transform = CGAffineTransform(scaleX: self.collapsedLabelScale, y: self.collapsedLabelScale)
	}

	private func configureViewHierarchy() {
		self.trackView.addSubview(self.fillView)

		self.labelContainer.addSubview(self.currentTimeLabel)
		self.labelContainer.addSubview(self.remainingTimeLabel)

		self.addSubview(self.labelContainer)
		self.addSubview(self.trackView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.heightConstraint,

			self.trackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.trackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.trackBottomConstraint,
			self.trackHeightConstraint,

			self.fillView.leadingAnchor.constraint(equalTo: self.trackView.leadingAnchor),
			self.fillView.topAnchor.constraint(equalTo: self.trackView.topAnchor),
			self.fillView.bottomAnchor.constraint(equalTo: self.trackView.bottomAnchor),
			self.fillWidthConstraint,

			self.labelContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.labelContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.labelContainer.bottomAnchor.constraint(equalTo: self.trackView.topAnchor, constant: -3),

			self.currentTimeLabel.leadingAnchor.constraint(equalTo: self.labelContainer.leadingAnchor),
			self.currentTimeLabel.topAnchor.constraint(equalTo: self.labelContainer.topAnchor),
			self.currentTimeLabel.bottomAnchor.constraint(equalTo: self.labelContainer.bottomAnchor),

			self.remainingTimeLabel.trailingAnchor.constraint(equalTo: self.labelContainer.trailingAnchor),
			self.remainingTimeLabel.centerYAnchor.constraint(equalTo: self.currentTimeLabel.centerYAnchor),
		])
	}

	private func configureGestures() {
		let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(self.handleHover(_:)))
		self.addGestureRecognizer(hoverGestureRecognizer)

		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleScrub(_:)))
		self.addGestureRecognizer(panGestureRecognizer)

		let toggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toggleTimeDisplay))
		self.remainingTimeLabel.addGestureRecognizer(toggleGestureRecognizer)
	}

	/// Updates the view with the latest playback progress.
	///
	/// - Parameter progress: The progress snapshot to display.
	func configure(with progress: PlaybackProgress) {
		self.progress = progress
		self.updateFill()

		if !self.isScrubbing {
			self.updateLabels()
		}
	}

	private func updateFill() {
		let trackWidth = self.trackView.bounds.width
		guard trackWidth > 0 else { return }
		self.fillWidthConstraint.constant = trackWidth * self.progress.fraction
	}

	private func updateLabels() {
		self.currentTimeLabel.text = self.timeString(from: self.progress.currentSeconds)

		if self.showsTotalTime {
			self.remainingTimeLabel.text = self.timeString(from: self.progress.durationSeconds)
		} else {
			self.remainingTimeLabel.text = "-" + self.timeString(from: self.progress.remainingSeconds)
		}
	}

	/// Returns a formatted string representing the given duration.
	///
	/// - Parameter seconds: The duration to format.
	///
	/// - Returns: The formatted string.
	private func timeString(from seconds: TimeInterval) -> String {
		let totalSeconds = max(0, Int(seconds.rounded()))
		return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
	}

	private func setExpanded(_ expanded: Bool) {
		guard self.displayedExpanded != expanded else { return }
		self.displayedExpanded = expanded

		self.heightConstraint.constant = expanded ? self.expandedHeight : self.collapsedHeight
		self.trackHeightConstraint.constant = expanded ? self.expandedTrackHeight : self.collapsedTrackHeight
		self.trackBottomConstraint.constant = expanded ? -self.expandedBottomInset : 0
		self.onExpansionChange?(expanded)

		let animations = { [weak self] in
			guard let self = self else { return }
			self.labelContainer.alpha = expanded ? 1 : 0
			self.labelContainer.transform = expanded ? .identity : CGAffineTransform(scaleX: self.collapsedLabelScale, y: self.collapsedLabelScale)
			self.superview?.layoutIfNeeded()
		}

		if UIAccessibility.isReduceMotionEnabled {
			animations()
		} else {
			UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: animations)
		}
	}

	@objc private func handleHover(_ gestureRecognizer: UIHoverGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began, .changed:
			self.isHovering = true
		default:
			self.isHovering = false
		}
		self.setExpanded(self.isExpanded)
	}

	@objc private func handleScrub(_ gestureRecognizer: UIPanGestureRecognizer) {
		let trackWidth = self.trackView.bounds.width
		guard trackWidth > 0 else { return }

		let locationX = gestureRecognizer.location(in: self.trackView).x
		let fraction = min(1, max(0, locationX / trackWidth))
		let seconds = fraction * self.progress.durationSeconds

		switch gestureRecognizer.state {
		case .began:
			self.isScrubbing = true
			self.setExpanded(true)
			self.previewScrub(toSeconds: seconds)
		case .changed:
			self.previewScrub(toSeconds: seconds)
		case .ended:
			self.isScrubbing = false
			self.onSeek?(seconds)
			self.setExpanded(self.isExpanded)
		default:
			self.isScrubbing = false
			self.setExpanded(self.isExpanded)
		}
	}

	private func previewScrub(toSeconds seconds: TimeInterval) {
		self.progress = PlaybackProgress(currentSeconds: seconds, durationSeconds: self.progress.durationSeconds)
		self.updateFill()
		self.updateLabels()
		self.layoutIfNeeded()
	}

	@objc private func toggleTimeDisplay() {
		self.showsTotalTime.toggle()
		UserSettings.set(self.showsTotalTime, forKey: .musicAccessoryShowsTotalTime)
		self.updateLabels()
	}
}
