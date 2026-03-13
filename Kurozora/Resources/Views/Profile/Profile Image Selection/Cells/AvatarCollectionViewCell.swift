//
//  AvatarCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ImageKindShapeView: UIView {
	var imageKind: ImageKind = .profile

	override func layoutSubviews() {
		super.layoutSubviews()

		switch self.imageKind {
		case .profile:
			self.layerCornerRadius = self.bounds.height / 2
		case .banner:
			self.layerCornerRadius = 12
		}
	}
}

class AvatarCollectionViewCell: UICollectionViewCell {
	var imageKind: ImageKind = .profile {
		didSet {
			self.containerView.imageKind = self.imageKind
			self.updateAspectRatio()
		}
	}

	private var aspectRatioConstraint: NSLayoutConstraint?

	private let containerView: ImageKindShapeView = {
		let view = ImageKindShapeView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		return view
	}()

	private let characterImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		return imageView
	}()

	private let placeholderImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "person.fill")
		imageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		return imageView
	}()

	private let initialsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		label.textColor = .white
		label.isHidden = true
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureViews() {
		self.contentView.addSubview(self.containerView)
		self.containerView.addSubview(self.characterImageView)
		self.containerView.addSubview(self.placeholderImageView)
		self.containerView.addSubview(self.initialsLabel)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.characterImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
			self.characterImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.characterImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.characterImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

			self.placeholderImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
			self.placeholderImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
			self.placeholderImageView.widthAnchor.constraint(equalToConstant: 24),
			self.placeholderImageView.heightAnchor.constraint(equalToConstant: 24),

			self.initialsLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
			self.initialsLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
			self.initialsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.containerView.leadingAnchor, constant: 2),
			self.initialsLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.containerView.trailingAnchor, constant: -2),

		])

		self.updateAspectRatio()
	}

	private func updateAspectRatio() {
		self.aspectRatioConstraint?.isActive = false

		switch self.imageKind {
		case .profile:
			self.aspectRatioConstraint = self.containerView.heightAnchor.constraint(equalTo: self.containerView.widthAnchor)
		case .banner:
			self.aspectRatioConstraint = self.containerView.heightAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1.0 / 3.0)
		}

		self.aspectRatioConstraint?.isActive = true
	}

	func configure(with character: Character?) {
		if let character = character {
			self.placeholderImageView.isHidden = true
			character.attributes.profileImage(imageView: self.characterImageView)
		} else {
			self.placeholderImageView.isHidden = false
			self.characterImageView.image = nil
		}
	}

	func configure(with image: UIImage?) {
		self.characterImageView.image = image
		self.placeholderImageView.isHidden = image != nil
	}

	func configure(with image: UIImage?, backgroundColor: UIColor) {
		self.characterImageView.image = image
		self.characterImageView.backgroundColor = .clear
		self.placeholderImageView.isHidden = image != nil
		self.containerView.backgroundColor = backgroundColor
	}

	func configure(with initials: String, backgroundColor: UIColor, font: UIFont) {
		self.initialsLabel.text = initials
		self.initialsLabel.font = font
		self.initialsLabel.isHidden = false
		self.characterImageView.isHidden = true
		self.placeholderImageView.isHidden = true
		self.containerView.backgroundColor = backgroundColor
	}

	func configure(with initials: String) {
		self.initialsLabel.text = initials
		self.initialsLabel.font = .preferredFont(forTextStyle: .body)
		self.initialsLabel.isHidden = false
		self.characterImageView.isHidden = true
		self.placeholderImageView.isHidden = true
		self.containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.characterImageView.image = nil
		self.characterImageView.isHidden = false
		self.characterImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.characterImageView.contentMode = .scaleAspectFill
		self.placeholderImageView.isHidden = false
		self.placeholderImageView.image = UIImage(systemName: "person.fill")
		self.placeholderImageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		self.initialsLabel.isHidden = true
		self.initialsLabel.text = nil
		self.containerView.backgroundColor = nil
	}
}
