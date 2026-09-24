//
//  ReCapKeepTrackingCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The button that leads back to tracking from an unfinished Re:CAP.
final class ReCapKeepTrackingCollectionViewCell: UICollectionViewCell {
	// MARK: - Properties
	/// Called when the button is pressed.
	var buttonPressedHandler: (() -> Void)?

	// MARK: - Views
	private let button = UIButton(type: .system)

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
	private func sharedInit() {
		var configuration = UIButton.Configuration.filled()
		configuration.cornerStyle = .capsule
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0)
		configuration.attributedTitle = AttributedString(L10n.recapKeepTracking, attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline)]))
		self.button.configuration = configuration
		self.applyThemeColors()
		self.button.translatesAutoresizingMaskIntoConstraints = false
		self.button.addAction(UIAction { [weak self] _ in
			self?.buttonPressedHandler?()
		}, for: .primaryActionTriggered)
		self.contentView.addSubview(self.button)

		NSLayoutConstraint.activate([
			self.button.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
			self.button.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.button.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor),
			self.button.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor),
			self.button.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8.0),
		])

		NotificationCenter.default.addObserver(self, selector: #selector(self.applyThemeColors), name: .ThemeUpdateNotification, object: nil)
	}

	/// Re-applies the theme's colors to the button.
	@objc private func applyThemeColors() {
		self.button.configuration?.baseBackgroundColor = KThemePicker.tintColor.colorValue
		self.button.configuration?.baseForegroundColor = KTintedButton.titleColor
	}
}
