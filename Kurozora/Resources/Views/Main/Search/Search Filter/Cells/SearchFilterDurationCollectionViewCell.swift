//
//  SearchFilterDurationCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import SwiftTheme
import UIKit

// MARK: - ClockFaceView
/// A circular face ringed with tick marks.
final class ClockFaceView: UIView {
	// MARK: - Views
	private var tickViews: [UIView] = []

	// MARK: - Properties
	/// The number of ticks drawn around the face.
	private static let tickCount = 24

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

		self.layerCornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
		self.layoutTicks()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.clipsToBounds = true

		self.tickViews = (0..<Self.tickCount).map { _ in
			let tickView = UIView()
			self.addSubview(tickView)
			return tickView
		}
	}

	/// Places every tick around the face.
	private func layoutTicks() {
		let radius = min(self.bounds.width, self.bounds.height) / 2.0
		guard radius > 0 else { return }

		let tickLength = radius * 0.16
		let tickWidth = radius * 0.05
		let distance = radius - tickLength

		for (index, tickView) in self.tickViews.enumerated() {
			let angle = (CGFloat(index) / CGFloat(Self.tickCount)) * 2.0 * .pi

			tickView.transform = .identity
			tickView.bounds = CGRect(x: 0, y: 0, width: tickWidth, height: tickLength)
			tickView.layerCornerRadius = tickWidth / 2.0
			tickView.center = CGPoint(
				x: self.bounds.midX + sin(angle) * distance,
				y: self.bounds.midY - cos(angle) * distance
			)
			tickView.transform = CGAffineTransform(rotationAngle: angle)
		}
	}

	/// Paints the ticks in the given color.
	///
	/// - Parameter color: The color to paint the ticks.
	func setTickColor(_ color: ThemeColorPicker) {
		self.tickViews.forEach { tickView in
			tickView.theme_backgroundColor = color
		}
	}
}

// MARK: - SearchFilterDurationCollectionViewCell
class SearchFilterDurationCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let clockFaceView = ClockFaceView()
	private let valueLabel = KLabel()
	private let unitLabel = KLabel()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

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
	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.clockFaceView.translatesAutoresizingMaskIntoConstraints = false

		self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
		self.valueLabel.textAlignment = .center
		self.valueLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 22.0, weight: .bold))
		self.valueLabel.adjustsFontForContentSizeCategory = true

		self.unitLabel.translatesAutoresizingMaskIntoConstraints = false
		self.unitLabel.textAlignment = .center
		self.unitLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12.0, weight: .bold))
		self.unitLabel.adjustsFontForContentSizeCategory = true

		let stackView = UIStackView(arrangedSubviews: [self.valueLabel, self.unitLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center

		self.contentView.addSubview(self.clockFaceView)
		self.clockFaceView.addSubview(stackView)

		NSLayoutConstraint.activate([
			self.clockFaceView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.clockFaceView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.clockFaceView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.clockFaceView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.clockFaceView.heightAnchor.constraint(equalTo: self.clockFaceView.widthAnchor),

			stackView.centerXAnchor.constraint(equalTo: self.clockFaceView.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: self.clockFaceView.centerYAnchor),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.clockFaceView.leadingAnchor, constant: 8.0),
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.clockFaceView.trailingAnchor, constant: -8.0)
		])
	}

	/// Configures the cell with the given duration.
	///
	/// - Parameters:
	///    - duration: The duration in seconds.
	///    - isSelected: Whether the duration is the chosen one.
	func configureCell(duration: TimeInterval, isSelected: Bool) {
		let (value, unit) = Self.parts(of: duration)
		self.valueLabel.text = value
		self.unitLabel.text = unit

		self.isAccessibilityElement = true
		self.accessibilityLabel = L10n.underDuration("\(value) \(unit)")
		self.accessibilityTraits = isSelected ? [.button, .selected] : .button

		if isSelected {
			self.clockFaceView.theme_backgroundColor = KThemePicker.tintColor.rawValue
			self.clockFaceView.setTickColor(KThemePicker.tintedButtonTextColor.rawValue)
			self.valueLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
			self.unitLabel.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
		} else {
			self.clockFaceView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			self.clockFaceView.setTickColor(KThemePicker.subTextColor.rawValue)
			self.valueLabel.theme_textColor = KThemePicker.textColor.rawValue
			self.unitLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	/// The number and unit a duration reads as.
	///
	/// - Parameter duration: The duration in seconds.
	///
	/// - Returns: The number and the unit to show.
	static func parts(of duration: TimeInterval) -> (String, String) {
		let usesHours = duration >= 3600
		let unit: UnitDuration = usesHours ? .hours : .minutes
		let amount = usesHours ? duration / 3600 : duration / 60

		let value = Self.numberFormatter.string(from: NSNumber(value: Int(amount.rounded()))) ?? ""

		return (value, Self.measurementFormatter.string(from: unit).localizedUppercase)
	}

	/// The formatter that writes a duration's number.
	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = LanguageManager.shared.locale
		formatter.numberStyle = .decimal
		return formatter
	}()

	/// The formatter that writes a duration's unit.
	private static let measurementFormatter: MeasurementFormatter = {
		let formatter = MeasurementFormatter()
		formatter.locale = LanguageManager.shared.locale
		formatter.unitStyle = .short
		formatter.unitOptions = .providedUnit
		return formatter
	}()
}
