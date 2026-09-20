//
//  CountdownCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class CountdownCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	/// The caption naming what the countdown leads to.
	private let captionLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .footnote)
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	/// The recurring schedule the release follows.
	private let scheduleLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	/// The stack holding the caption above the schedule.
	private lazy var captionStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [self.captionLabel, self.scheduleLabel])
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.spacing = 2.0
		return stackView
	}()

	/// The four segments of the countdown.
	private let segmentViews = [CountdownSegmentView(), CountdownSegmentView(), CountdownSegmentView(), CountdownSegmentView()]

	/// The stack holding the countdown segments in a row.
	private lazy var segmentsStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: self.segmentViews)
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		return stackView
	}()

	/// The stack holding the schedule beside the countdown.
	private lazy var rootStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [self.captionStackView, self.segmentsStackView])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = 16.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	// MARK: - Properties
	/// The date the countdown runs out on.
	private var targetDate: Date?

	/// The timer driving the countdown.
	private var timer: Timer?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	isolated deinit {
		self.stopCountdown()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.stopCountdown()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass else { return }

		self.updateCaptionVisibility()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layerCornerRadius = 22.0
		self.layer.cornerCurve = .continuous

		self.captionStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.segmentsStackView.setContentHuggingPriority(.required, for: .horizontal)
		self.segmentsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

		self.contentView.addSubview(self.rootStackView)

		NSLayoutConstraint.activate([
			self.rootStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16.0),
			self.rootStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.rootStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),
			self.rootStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16.0)
		])

		self.updateCaptionVisibility()
	}

	/// Configure the cell with the given countdown details.
	///
	/// - Parameters:
	///    - caption: The caption naming what the countdown leads to.
	///    - schedule: The recurring schedule the release follows.
	///    - targetDate: The date the countdown runs out on.
	func configure(caption: String, schedule: String?, targetDate: Date) {
		self.captionLabel.text = caption.localizedUppercase
		self.scheduleLabel.text = schedule
		self.scheduleLabel.isHidden = schedule?.isEmpty ?? true
		self.targetDate = targetDate

		self.segmentViews[0].configure(unit: L10n.countdownUnitDays)
		self.segmentViews[1].configure(unit: L10n.countdownUnitHours)
		self.segmentViews[2].configure(unit: L10n.countdownUnitMinutes)
		self.segmentViews[3].configure(unit: L10n.countdownUnitSeconds)

		self.startCountdown()
	}

	/// Hides the schedule beside the countdown at compact widths.
	private func updateCaptionVisibility() {
		let isCompact = self.traitCollection.horizontalSizeClass == .compact

		self.captionStackView.isHidden = isCompact
		self.segmentViews.first?.setShowsSeparator(!isCompact)
	}

	/// Starts the timer driving the countdown.
	private func startCountdown() {
		self.updateCountdown()
		self.timer?.invalidate()

		let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.updateCountdown()
			}
		}
		RunLoop.main.add(timer, forMode: .common)
		self.timer = timer
	}

	/// Stops the timer driving the countdown.
	private func stopCountdown() {
		self.timer?.invalidate()
		self.timer = nil
	}

	/// Writes the time left onto the segments.
	private func updateCountdown() {
		guard let targetDate = self.targetDate else { return }

		let now = Date()
		let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: max(targetDate, now))

		self.segmentViews[0].configure(value: components.day ?? 0)
		self.segmentViews[1].configure(value: components.hour ?? 0)
		self.segmentViews[2].configure(value: components.minute ?? 0)
		self.segmentViews[3].configure(value: components.second ?? 0)
	}
}

// MARK: - CountdownSegmentView
/// A view that pairs one unit of a countdown with its remaining value.
private final class CountdownSegmentView: UIView {
	// MARK: - Views
	/// The hairline separating the segment from the one before it.
	private let separatorView: SeparatorView = {
		let separatorView = SeparatorView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		return separatorView
	}()

	/// The value left on this unit.
	private let valueLabel: KLabel = {
		let label = KLabel()
		label.font = UIFont.preferredFont(forTextStyle: .title3).bold
		label.adjustsFontForContentSizeCategory = true
		label.textAlignment = .center
		return label
	}()

	/// The name of the unit.
	private let unitLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .footnote)
		label.adjustsFontForContentSizeCategory = true
		label.textAlignment = .center
		return label
	}()

	/// The stack holding the value above the unit.
	private lazy var labelStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [self.valueLabel, self.unitLabel])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 2.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.addSubview(self.separatorView)
		self.addSubview(self.labelStackView)

		NSLayoutConstraint.activate([
			self.separatorView.topAnchor.constraint(equalTo: self.topAnchor),
			self.separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.separatorView.widthAnchor.constraint(equalToConstant: 1.5),

			self.labelStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.labelStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.labelStackView.leadingAnchor.constraint(equalTo: self.separatorView.trailingAnchor, constant: 12.0),
			self.labelStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0)
		])
	}

	/// Names the unit the segment counts.
	///
	/// - Parameter unit: The name of the unit.
	func configure(unit: String) {
		self.unitLabel.text = unit
	}

	/// Reveals or hides the hairline before the segment.
	///
	/// - Parameter showsSeparator: Whether the hairline is drawn.
	func setShowsSeparator(_ showsSeparator: Bool) {
		self.separatorView.isHidden = !showsSeparator
	}

	/// Writes the value left on the segment's unit.
	///
	/// - Parameter value: The value left on the unit.
	func configure(value: Int) {
		self.valueLabel.text = "\(value)"
	}
}
