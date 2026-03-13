//
//  CameraButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class CameraButtonCollectionViewCell: UICollectionViewCell {
	// MARK: - Properties
	var imageKind: ImageKind = .profile {
		didSet {
			self.updateCornerRadius()
			self.updateAspectRatio()
		}
	}

	private var aspectRatioConstraint: NSLayoutConstraint?

	// MARK: - Views
	private let cameraButton: AdaptiveCornerButton = {
		let config = UIImage.SymbolConfiguration(textStyle: .title2).applying(UIImage.SymbolConfiguration(weight: .medium))
		let image = UIImage(systemName: "photo.on.rectangle", withConfiguration: config)

		let button = AdaptiveCornerButton()
		button.setImage(image, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.showsMenuAsPrimaryAction = true

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			button.backgroundColor = nil
			button.setTitleColor(nil, for: .normal)
			button.theme_setTitleColor(nil, forState: .normal)
			button.theme_tintColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		} else {
			button.configuration = .plain()
			button.theme_tintColor = KThemePicker.textColor.rawValue
			button.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			button.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
		return button
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.cameraButton.menu = nil
	}

	// MARK: - Functions
	func configure(with menu: UIMenu) {
		self.cameraButton.menu = menu
	}

	private func configureViews() {
		self.contentView.addSubview(self.cameraButton)

		NSLayoutConstraint.activate([
			self.cameraButton.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.cameraButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.cameraButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.cameraButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])

		self.updateCornerRadius()
		self.updateAspectRatio()
	}

	private func updateCornerRadius() {
		self.cameraButton.cornerStyle = self.imageKind.cornerStyle
	}

	private func updateAspectRatio() {
		self.aspectRatioConstraint?.isActive = false

		switch self.imageKind {
		case .profile:
			self.aspectRatioConstraint = self.cameraButton.heightAnchor.constraint(equalTo: self.cameraButton.widthAnchor)
		case .banner:
			self.aspectRatioConstraint = self.cameraButton.heightAnchor.constraint(equalTo: self.cameraButton.widthAnchor, multiplier: 1.0 / 3.0)
		}

		self.aspectRatioConstraint?.isActive = true
	}
}
