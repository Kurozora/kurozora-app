//
//  PlaybackProgressView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

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

	/// The container holding both time labels.
	private let labelContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0
		return view
	}()

	/// The scrubber knob.
	private let thumbView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .label
		view.layer.cornerRadius = 7
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.25
		view.layer.shadowRadius = 3
		view.layer.shadowOffset = CGSize(width: 0, height: 1)
		view.alpha = 0
		return view
	}()

	// MARK: - Properties
	/// A closure invoked when the user scrubs to a new position, in seconds.
	var onSeek: ((TimeInterval) -> Void)?

	/// A closure invoked with the position the drag is previewing, in seconds, and with `nil` once the drag ends.
	var onScrubPreview: ((TimeInterval?) -> Void)?

	/// A closure invoked when the view expands into or collapses from its scrubber state.
	var onExpansionChange: ((Bool) -> Void)?

	/// Whether a song is loaded to scrub through.
	var hasContent = true {
		didSet {
			guard oldValue != self.hasContent else { return }
			self.updateLabels()
			self.updateFill()
			self.thumbView.alpha = (self.displayedExpanded && self.hasContent) ? 1 : 0
		}
	}

	/// Whether the time labels stay visible beneath the track instead of appearing above it on hover.
	var prefersPersistentLabels = false {
		didSet {
			guard oldValue != self.prefersPersistentLabels else { return }
			self.applyLabelPlacement()
		}
	}

	/// The time shown when nothing is loaded.
	private static let placeholderTime = "--:--"

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

	/// The fixed height when the labels sit persistently beneath the track.
	private let persistentHeight: CGFloat = 28

	/// The track height in the collapsed (hairline) state.
	private let collapsedTrackHeight: CGFloat = 2

	/// The track height in the expanded (capsule) state.
	private let expandedTrackHeight: CGFloat = 8

	/// The inset between the track and the bottom edge in the expanded (scrubber) state.
	private let expandedBottomInset: CGFloat = 4

	/// The scale applied to the time labels while collapsed.
	private let collapsedLabelScale: CGFloat = 0.97

	/// Whether the view is showing its expanded scrubber.
	private var isExpanded: Bool {
		return self.isHovering || self.isScrubbing
	}

	/// The expansion state currently reflected by the view.
	private var displayedExpanded = false

	private lazy var heightConstraint: NSLayoutConstraint = self.heightAnchor.constraint(equalToConstant: self.collapsedHeight)

	private lazy var trackHeightConstraint: NSLayoutConstraint = self.trackView.heightAnchor.constraint(equalToConstant: self.collapsedTrackHeight)

	private lazy var trackBottomConstraint: NSLayoutConstraint = self.trackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

	private lazy var fillWidthConstraint: NSLayoutConstraint = self.fillView.widthAnchor.constraint(equalToConstant: 0)

	private lazy var labelsAboveTrackConstraint: NSLayoutConstraint = self.labelContainer.bottomAnchor.constraint(equalTo: self.trackView.topAnchor, constant: -3)

	private lazy var labelsBelowTrackConstraint: NSLayoutConstraint = self.labelContainer.topAnchor.constraint(equalTo: self.trackView.bottomAnchor, constant: 6)

	private lazy var trackTopConstraint: NSLayoutConstraint = self.trackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4)

	private lazy var remainingTimeTrailingConstraint: NSLayoutConstraint = self.remainingTimeLabel.trailingAnchor.constraint(equalTo: self.labelContainer.trailingAnchor)

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

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		// Grabs landing just outside the thin track would otherwise move the window.
		if self.prefersPersistentLabels {
			return self.bounds.insetBy(dx: 0, dy: -10).contains(point)
		}
		return super.point(inside: point, with: event)
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
		self.addSubview(self.thumbView)
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
			self.labelsAboveTrackConstraint,

			self.currentTimeLabel.leadingAnchor.constraint(equalTo: self.labelContainer.leadingAnchor),
			self.currentTimeLabel.topAnchor.constraint(equalTo: self.labelContainer.topAnchor),
			self.currentTimeLabel.bottomAnchor.constraint(equalTo: self.labelContainer.bottomAnchor),

			self.remainingTimeTrailingConstraint,
			self.remainingTimeLabel.centerYAnchor.constraint(equalTo: self.currentTimeLabel.centerYAnchor),

			self.thumbView.centerXAnchor.constraint(equalTo: self.fillView.trailingAnchor),
			self.thumbView.centerYAnchor.constraint(equalTo: self.trackView.centerYAnchor),
			self.thumbView.widthAnchor.constraint(equalToConstant: 20),
			self.thumbView.heightAnchor.constraint(equalToConstant: 14),
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
		guard !self.isScrubbing else { return }

		self.progress = progress
		self.updateFill()
		self.updateLabels()
	}

	private func updateFill() {
		let trackWidth = self.trackView.bounds.width
		guard trackWidth > 0 else { return }
		self.fillWidthConstraint.constant = self.hasContent ? trackWidth * self.progress.fraction : 0
	}

	private func updateLabels() {
		guard self.hasContent else {
			self.currentTimeLabel.text = Self.placeholderTime
			self.remainingTimeLabel.text = Self.placeholderTime
			return
		}

		self.currentTimeLabel.text = self.timeString(from: self.progress.currentSeconds)

		if self.showsTotalTime {
			self.remainingTimeLabel.text = self.timeString(from: self.progress.durationSeconds)
		} else {
			self.remainingTimeLabel.text = "\u{2212}" + self.timeString(from: self.progress.remainingSeconds)
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

	/// Moves the time labels above or below the track for the current placement preference.
	private func applyLabelPlacement() {
		let persistent = self.prefersPersistentLabels

		self.labelsAboveTrackConstraint.isActive = !persistent
		self.trackBottomConstraint.isActive = !persistent
		self.labelsBelowTrackConstraint.isActive = persistent
		self.trackTopConstraint.isActive = persistent

		if persistent {
			self.currentTimeLabel.font = .systemFont(ofSize: 10)
			self.remainingTimeLabel.font = .systemFont(ofSize: 10)
			self.currentTimeLabel.textColor = .secondaryLabel
			self.remainingTimeLabel.textColor = .secondaryLabel
			// Track fills for the persistent scrubber.
			self.trackView.backgroundColor = .label.withAlphaComponent(0.05)
			self.fillView.backgroundColor = .label.withAlphaComponent(0.57)
			self.remainingTimeTrailingConstraint.constant = -4
			self.labelContainer.alpha = 1
			self.labelContainer.transform = .identity
			self.trackHeightConstraint.constant = 5
		}

		self.heightConstraint.constant = self.overallHeight(expanded: self.displayedExpanded)
	}

	/// The view height for the given expansion state under the current label placement.
	///
	/// - Parameter expanded: Whether the scrubber is expanded.
	///
	/// - Returns: The height in points.
	private func overallHeight(expanded: Bool) -> CGFloat {
		if self.prefersPersistentLabels {
			return self.persistentHeight
		}
		return expanded ? self.expandedHeight : self.collapsedHeight
	}

	private func setExpanded(_ expanded: Bool) {
		guard self.displayedExpanded != expanded else { return }
		self.displayedExpanded = expanded

		// With persistent labels, hovering only reveals the knob.
		if self.prefersPersistentLabels {
			let animations = { [weak self] in
				guard let self = self else { return }
				self.thumbView.alpha = (expanded && self.hasContent) ? 1 : 0
			}

			if UIAccessibility.isReduceMotionEnabled {
				animations()
			} else {
				UIView.animate(withDuration: 0.2, animations: animations)
			}
			return
		}

		self.heightConstraint.constant = self.overallHeight(expanded: expanded)
		self.trackHeightConstraint.constant = expanded ? self.expandedTrackHeight : self.collapsedTrackHeight
		self.trackBottomConstraint.constant = expanded ? -self.expandedBottomInset : 0
		self.onExpansionChange?(expanded)

		let animations = { [weak self] in
			guard let self = self else { return }
			if !self.prefersPersistentLabels {
				self.labelContainer.alpha = expanded ? 1 : 0
				self.labelContainer.transform = expanded ? .identity : CGAffineTransform(scaleX: self.collapsedLabelScale, y: self.collapsedLabelScale)
			}
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
		guard trackWidth > 0, self.hasContent else { return }

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
			self.onScrubPreview?(nil)
			self.setExpanded(self.isExpanded)
		default:
			self.isScrubbing = false
			self.onScrubPreview?(nil)
			self.setExpanded(self.isExpanded)
		}
	}

	private func previewScrub(toSeconds seconds: TimeInterval) {
		self.progress = PlaybackProgress(currentSeconds: seconds, durationSeconds: self.progress.durationSeconds)
		self.updateFill()
		self.updateLabels()
		self.layoutIfNeeded()
		self.onScrubPreview?(seconds)
	}

	@objc private func toggleTimeDisplay() {
		self.showsTotalTime.toggle()
		UserSettings.set(self.showsTotalTime, forKey: .musicAccessoryShowsTotalTime)
		self.updateLabels()
	}
}
