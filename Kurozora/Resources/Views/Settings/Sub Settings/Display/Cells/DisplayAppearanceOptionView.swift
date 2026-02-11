//
//  DisplayAppearanceOptionView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class DisplayAppearanceOptionView: UIView {
	// MARK: - Subviews
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleToFill
		return imageView
	}()

	private let titleLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		return label
	}()

	private let selectedImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.theme_tintColor = KThemePicker.tintColor.rawValue
		imageView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		imageView.layer.cornerRadius = 15
		imageView.clipsToBounds = true
		return imageView
	}()

	private let button: UIButton = {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	// MARK: - Properties
	var didSelect: (() -> Void)?

	var isOptionEnabled: Bool = true {
		didSet {
			self.updateEnabledState()
		}
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
	func configure(title: String, image: UIImage?, isSelected: Bool) {
		self.titleLabel.text = title
		self.imageView.image = image
		self.setSelected(isSelected)
	}

	func setSelected(_ isSelected: Bool) {
		if isSelected {
			self.selectedImageView.layer.borderWidth = 0
			self.selectedImageView.image = UIImage(systemName: "checkmark.circle.fill")
		} else {
			self.selectedImageView.layer.borderWidth = 2
			self.selectedImageView.image = nil
		}
	}

	private func sharedInit() {
		self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

		self.button.addTarget(self, action: #selector(self.optionTapped), for: .touchUpInside)

		self.addSubview(self.imageView)
		self.addSubview(self.titleLabel)
		self.addSubview(self.selectedImageView)
		self.addSubview(self.button)

		NSLayoutConstraint.activate([
			self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
			self.imageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.leadingAnchor),
			self.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.imageView.trailingAnchor),
			self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.imageView.widthAnchor.constraint(equalToConstant: 62),
			self.imageView.heightAnchor.constraint(equalToConstant: 120),

			self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
			self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.leadingAnchor),
			self.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor),
			self.titleLabel.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),

			self.selectedImageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
			self.selectedImageView.widthAnchor.constraint(equalToConstant: 30),
			self.selectedImageView.heightAnchor.constraint(equalToConstant: 30),
			self.selectedImageView.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor),
			self.bottomAnchor.constraint(equalTo: self.selectedImageView.bottomAnchor),

			self.button.topAnchor.constraint(equalTo: self.topAnchor),
			self.button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
			self.bottomAnchor.constraint(equalTo: self.button.bottomAnchor)
		])

		self.updateEnabledState()
	}

	private func updateEnabledState() {
		self.button.isUserInteractionEnabled = self.isOptionEnabled
		self.alpha = self.isOptionEnabled ? 1.0 : 0.5
	}

	@objc private func optionTapped() {
		self.didSelect?()
	}
}
