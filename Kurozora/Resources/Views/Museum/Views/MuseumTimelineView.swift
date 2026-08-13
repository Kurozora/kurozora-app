//
//  MuseumTimelineView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A density timeline that scrubs the museum hall through its years.
class MuseumTimelineView: UIControl {
	// MARK: - Views
	/// The tick views in display order.
	private var tickViews: [UIView] = []

	/// The decade labels beneath the track, indexed with their separators.
	private var decadeLabels: [UILabel] = []

	/// The vertical separators leading each decade label.
	private var decadeSeparators: [UIView] = []

	/// The floating chip shown above the touch while scrubbing.
	private let chipView = UIView()

	/// The label inside the floating chip.
	private let chipLabel = UILabel()

	// MARK: - Properties
	/// The height of the tick track.
	private let trackHeight: CGFloat = 32.0

	/// The gap between ticks and between decade labels.
	private let elementGap: CGFloat = 1.0

	/// The spacing between the track and the decade labels row.
	private let decadeRowSpacing: CGFloat = 4.0

	/// The minimum tick height as a share of the track height.
	private let minimumTickRatio: CGFloat = 0.08

	/// The years shown on the timeline, ascending.
	private var years: [MuseumYear] = []

	/// The decade start years in display order, each paired with its year count.
	private var decades: [(start: Int, yearCount: Int)] = []

	/// The highest entry count across the years.
	private var maxCount: Int = 1

	/// The index of the currently highlighted tick.
	private var activeIndex: Int?

	/// The index of the year last scrubbed to, cleared when the touch ends.
	private var scrubbedIndex: Int?

	/// The haptic generator fired when scrubbing crosses into a new year.
	private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

	/// Called with the year to reveal when the timeline is tapped or scrubbed.
	var yearSelectedHandler: ((Int) -> Void)?

	/// The pan gesture recognizer that claims scrubs on the timeline.
	let scrubGestureRecognizer = UIPanGestureRecognizer()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.layoutTicks()
		self.layoutDecades()
	}

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.selectionFeedbackGenerator.prepare()
		self.scrub(to: touch.location(in: self))
		return true
	}

	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.scrub(to: touch.location(in: self))
		return true
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)

		self.finishScrubbing()
	}

	override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)

		self.finishScrubbing()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.clipsToBounds = false

		self.scrubGestureRecognizer.cancelsTouchesInView = false
		self.scrubGestureRecognizer.delaysTouchesBegan = false
		self.addGestureRecognizer(self.scrubGestureRecognizer)

		self.chipLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .semibold)
		self.chipLabel.textAlignment = .center
		self.chipView.addSubview(self.chipLabel)

		self.chipView.isHidden = true
		self.chipView.isUserInteractionEnabled = false
		self.chipView.layer.cornerRadius = 8.0
		self.chipView.layer.cornerCurve = .continuous
		self.chipView.layer.borderWidth = 1.0
		self.chipView.layer.shadowOpacity = 0.2
		self.chipView.layer.shadowRadius = 4.0
		self.chipView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
		self.addSubview(self.chipView)
	}

	/// Configures the timeline with the given years.
	///
	/// - Parameter years: The release years to draw, ascending.
	func configure(using years: [MuseumYear]) {
		self.years = years
		self.maxCount = max(1, years.map(\.count).max() ?? 1)
		self.activeIndex = nil
		self.scrubbedIndex = nil

		let decadesByStart = Dictionary(grouping: years) { museumYear in
			(museumYear.year / 10) * 10
		}
		self.decades = decadesByStart.keys.sorted().map { decadeStart in
			(start: decadeStart, yearCount: decadesByStart[decadeStart]?.count ?? 0)
		}

		self.rebuildTicks()
		self.rebuildDecades()
		self.restyle()
		self.setNeedsLayout()
	}

	/// Highlights the tick of the given year.
	///
	/// - Parameter year: The year to highlight.
	func setActiveYear(_ year: Int) {
		let index = self.years.firstIndex { $0.year == year }
		guard index != self.activeIndex else { return }

		if let activeIndex = self.activeIndex {
			self.tickViews[safe: activeIndex]?.backgroundColor = KThemePicker.borderColor.colorValue
		}

		self.activeIndex = index

		if let index = index {
			self.tickViews[safe: index]?.backgroundColor = KThemePicker.tintColor.colorValue
		}
	}

	/// Re-applies the theme's colors to the ticks, labels, and chip.
	func restyle() {
		for (index, tickView) in self.tickViews.enumerated() {
			tickView.backgroundColor = index == self.activeIndex ? KThemePicker.tintColor.colorValue : KThemePicker.borderColor.colorValue
		}

		for decadeLabel in self.decadeLabels {
			decadeLabel.textColor = KThemePicker.subTextColor.colorValue
		}

		for decadeSeparator in self.decadeSeparators {
			decadeSeparator.backgroundColor = KThemePicker.separatorColor.colorValue
		}

		self.chipView.backgroundColor = KThemePicker.tableViewCellBackgroundColor.colorValue
		self.chipView.layer.borderColor = KThemePicker.borderColor.colorValue.cgColor
		self.chipLabel.textColor = KThemePicker.textColor.colorValue
	}

	/// Rebuilds the tick views for the current years.
	private func rebuildTicks() {
		for tickView in self.tickViews {
			tickView.removeFromSuperview()
		}
		self.tickViews = []

		for _ in self.years {
			let tickView = UIView()
			tickView.isUserInteractionEnabled = false
			tickView.layer.cornerRadius = 2.0
			tickView.layer.cornerCurve = .continuous
			self.insertSubview(tickView, belowSubview: self.chipView)
			self.tickViews.append(tickView)
		}
	}

	/// Rebuilds the decade labels for the current years.
	private func rebuildDecades() {
		for decadeLabel in self.decadeLabels {
			decadeLabel.removeFromSuperview()
		}
		for decadeSeparator in self.decadeSeparators {
			decadeSeparator.removeFromSuperview()
		}
		self.decadeLabels = []
		self.decadeSeparators = []

		for decade in self.decades {
			let decadeSeparator = UIView()
			decadeSeparator.isUserInteractionEnabled = false
			self.insertSubview(decadeSeparator, belowSubview: self.chipView)
			self.decadeSeparators.append(decadeSeparator)

			let decadeLabel = UILabel()
			decadeLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
			decadeLabel.text = "\(decade.start)s"
			decadeLabel.isUserInteractionEnabled = false
			self.insertSubview(decadeLabel, belowSubview: self.chipView)
			self.decadeLabels.append(decadeLabel)
		}
	}

	/// Lays out the ticks bottom-aligned in the track.
	private func layoutTicks() {
		guard !self.tickViews.isEmpty else { return }
		let tickCount = CGFloat(self.tickViews.count)
		let tickWidth = max(0.0, (self.bounds.width - self.elementGap * (tickCount - 1)) / tickCount)

		for (index, tickView) in self.tickViews.enumerated() {
			let ratio = max(self.minimumTickRatio, CGFloat(self.years[index].count) / CGFloat(self.maxCount))
			let tickHeight = (ratio * self.trackHeight).rounded()
			tickView.frame = CGRect(
				x: CGFloat(index) * (tickWidth + self.elementGap),
				y: self.trackHeight - tickHeight,
				width: tickWidth,
				height: tickHeight
			)
		}
	}

	/// Lays out the decade labels flex-weighted by their year counts.
	private func layoutDecades() {
		guard !self.decades.isEmpty, !self.years.isEmpty else { return }
		let rowTop = self.trackHeight + self.decadeRowSpacing
		let rowHeight = self.bounds.height - rowTop
		let totalYears = CGFloat(self.years.count)
		var slotLeft: CGFloat = 0.0

		for (index, decade) in self.decades.enumerated() {
			let slotWidth = self.bounds.width * CGFloat(decade.yearCount) / totalYears
			self.decadeSeparators[safe: index]?.frame = CGRect(x: slotLeft, y: rowTop, width: 1.0, height: rowHeight)

			if let decadeLabel = self.decadeLabels[safe: index] {
				let labelWidth = max(0.0, slotWidth - 5.0)
				decadeLabel.frame = CGRect(x: slotLeft + 4.0, y: rowTop, width: labelWidth, height: rowHeight)
				decadeLabel.isHidden = decadeLabel.intrinsicContentSize.width > labelWidth
			}

			slotLeft += slotWidth
		}
	}

	/// Jumps to the year under the touch and previews it in the chip.
	///
	/// - Parameter point: The touch location in the view's coordinate space.
	private func scrub(to point: CGPoint) {
		guard !self.years.isEmpty, self.bounds.width > 0.0 else { return }

		let fraction = min(max(point.x / self.bounds.width, 0.0), 1.0)
		let index = min(Int(fraction * CGFloat(self.years.count)), self.years.count - 1)

		if index != self.scrubbedIndex {
			if self.scrubbedIndex != nil {
				self.selectionFeedbackGenerator.selectionChanged()
			}

			self.scrubbedIndex = index
			self.yearSelectedHandler?(self.years[index].year)
		}

		self.showChip(for: index, at: point.x)
	}

	/// Hides the chip and clears the scrub state when the touch ends.
	private func finishScrubbing() {
		self.scrubbedIndex = nil
		self.chipView.isHidden = true
	}

	/// Shows the chip for a year's tick above the touch.
	///
	/// - Parameters:
	///    - index: The index of the year to preview.
	///    - touchX: The touch's x position in the view's coordinate space.
	private func showChip(for index: Int, at touchX: CGFloat) {
		guard let museumYear = self.years[safe: index] else { return }

		self.chipLabel.text = L10n.yearTitlesCount(museumYear.year, museumYear.count)
		self.chipView.isHidden = false

		let labelSize = self.chipLabel.intrinsicContentSize
		let chipSize = CGSize(width: labelSize.width + 16.0, height: labelSize.height + 8.0)
		let halfWidth = chipSize.width / 2.0
		let centerX = min(max(touchX, halfWidth), self.bounds.width - halfWidth)

		self.chipView.frame = CGRect(
			x: centerX - halfWidth,
			y: -(chipSize.height + 4.0),
			width: chipSize.width,
			height: chipSize.height
		)
		self.chipLabel.frame = self.chipView.bounds
	}
}
