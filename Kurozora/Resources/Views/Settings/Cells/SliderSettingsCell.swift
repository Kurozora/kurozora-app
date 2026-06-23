//
//  SliderSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SliderSettingsCell: KTableViewCell {
	// MARK: - Views
	private let valueLabel = KLabel()
	private let minimumLabel = KSecondaryLabel()
	private let slider = UISlider()
	private let maximumLabel = KSecondaryLabel()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	/// The closure that formats the value label for a given value.
	private var valueFormat: (Int) -> String = { "\($0)" }

	/// The closure invoked when the slider settles on a new integer value.
	private var valueChangedHandler: ((Int) -> Void)?

	// MARK: - Functions
	override func sharedInit() {
		super.sharedInit()
		self.selectionStyle = .none

		self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
		self.valueLabel.font = .preferredFont(forTextStyle: .body)

		self.slider.translatesAutoresizingMaskIntoConstraints = false
		#if !targetEnvironment(macCatalyst)
		self.slider.minimumTrackTintColor = KThemePicker.tintColor.colorValue
		#endif
		self.slider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)

		let captionFont = UIFont.systemFont(ofSize: 13, weight: .regular)
		for label in [self.minimumLabel, self.maximumLabel] {
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = captionFont
			label.setContentHuggingPriority(.required, for: .horizontal)
			label.setContentCompressionResistancePriority(.required, for: .horizontal)
		}

		self.contentView.addSubview(self.valueLabel)
		self.contentView.addSubview(self.minimumLabel)
		self.contentView.addSubview(self.slider)
		self.contentView.addSubview(self.maximumLabel)

		NSLayoutConstraint.activate([
			self.valueLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.valueLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),

			self.minimumLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.minimumLabel.topAnchor.constraint(equalTo: self.valueLabel.bottomAnchor, constant: 8),
			self.minimumLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),

			self.slider.leadingAnchor.constraint(equalTo: self.minimumLabel.trailingAnchor, constant: 8),
			self.slider.centerYAnchor.constraint(equalTo: self.minimumLabel.centerYAnchor),

			self.maximumLabel.leadingAnchor.constraint(equalTo: self.slider.trailingAnchor, constant: 8),
			self.maximumLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.maximumLabel.centerYAnchor.constraint(equalTo: self.minimumLabel.centerYAnchor),
		])
	}

	/// Configures the cell with an integer-valued slider flanked by its bounds.
	///
	/// - Parameters:
	///    - minimumValue: The smallest selectable value.
	///    - maximumValue: The largest selectable value.
	///    - value: The current value.
	///    - valueFormat: The closure that formats the value label.
	///    - valueChangedHandler: The closure invoked with each new integer value.
	func configure(minimumValue: Int, maximumValue: Int, value: Int, valueFormat: @escaping (Int) -> String, valueChangedHandler: @escaping (Int) -> Void) {
		self.valueFormat = valueFormat

		self.slider.minimumValue = Float(minimumValue)
		self.slider.maximumValue = Float(maximumValue)
		self.slider.value = Float(value)

		self.minimumLabel.text = "\(minimumValue)s"
		self.maximumLabel.text = "\(maximumValue)s"
		self.valueLabel.text = valueFormat(value)

		self.valueChangedHandler = valueChangedHandler
	}

	@objc private func sliderValueChanged() {
		let rounded = Int(self.slider.value.rounded())
		self.slider.value = Float(rounded)
		self.valueLabel.text = self.valueFormat(rounded)
		self.valueChangedHandler?(rounded)
	}
}
