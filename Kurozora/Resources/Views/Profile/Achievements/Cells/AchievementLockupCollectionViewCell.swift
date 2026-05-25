//
//  AchievementLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class AchievementLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - Properties
	private var isUnlocked: Bool = false

	// MARK: - Views
	private let gradientView: GradientView = {
		let view = GradientView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.gradientLayer?.startPoint = CGPoint(x: 0.5, y: 1.0)
		view.gradientLayer?.endPoint = CGPoint(x: 0.5, y: 0.0)
		return view
	}()

	private let badgeRingView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		view.clipsToBounds = true
		return view
	}()

	private let badgeImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		return imageView
	}()

	private let lockImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .regular))?.withRenderingMode(.alwaysTemplate)
		imageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		return imageView
	}()

	private let badgeBorderOverlay: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.backgroundColor = .clear
		view.layer.borderWidth = 2.0
		view.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
		return view
	}()

	private let primaryLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .title2).bold
		label.textAlignment = .center
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	private let secondaryLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	private let dateLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote).bold
		label.textAlignment = .center
		label.numberOfLines = 1
		return label
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: .ThemeUpdateNotification, object: nil)
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.badgeImageView.image = nil
		self.badgeImageView.isHidden = false
		self.lockImageView.isHidden = false
		self.badgeBorderOverlay.isHidden = false
		self.dateLabel.text = nil
	}

	// MARK: - Functions
	/// Configures the cell with the given achievement.
	///
	/// - Parameter achievement: The achievement to render, or `nil` to display the skeleton state.
	func configure(using achievement: Achievement?) {
		guard let achievement = achievement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.applyCardStyling()

		self.primaryLabel.text = achievement.attributes.name
		self.secondaryLabel.text = achievement.attributes.description

		self.isUnlocked = achievement.attributes.achievedAt != nil
		self.badgeImageView.isHidden = !self.isUnlocked
		self.lockImageView.isHidden = self.isUnlocked
		self.badgeBorderOverlay.isHidden = !self.isUnlocked

		self.applyThemeColors()

		if self.isUnlocked {
			achievement.attributes.symbolImage(imageView: self.badgeImageView)
			self.dateLabel.text = achievement.attributes.achievedAt?.formatted(date: .abbreviated, time: .omitted)
		} else {
			self.dateLabel.text = nil
		}
	}

	/// Re-applies the gradient background colors from the current theme.
	@objc private func applyThemeColors() {
		self.gradientView.backgroundColors = [
			KThemePicker.backgroundColor.colorValue.cgColor,
			KThemePicker.tableViewCellBackgroundColor.colorValue.cgColor
		]
	}

	/// Applies the card's corner radius, clipping, and border.
	private func applyCardStyling() {
		self.contentView.layer.cornerRadius = 16.0
		self.contentView.clipsToBounds = true
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
	}

	private func configureSubviews() {
		let badgeSize: CGFloat = 112.0

		self.badgeRingView.layer.cornerRadius = badgeSize / 2.0
		self.badgeBorderOverlay.layer.cornerRadius = badgeSize / 2.0

		self.applyCardStyling()

		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.18
		self.layer.shadowOffset = CGSize(width: 0, height: 4)
		self.layer.shadowRadius = 10.0

		NotificationCenter.default.addObserver(self, selector: #selector(self.applyThemeColors), name: .ThemeUpdateNotification, object: nil)

		self.contentView.addSubview(self.gradientView)
		self.contentView.addSubview(self.badgeRingView)
		self.contentView.addSubview(self.primaryLabel)
		self.contentView.addSubview(self.secondaryLabel)
		self.contentView.addSubview(self.dateLabel)

		self.badgeRingView.addSubview(self.badgeImageView)
		self.badgeRingView.addSubview(self.lockImageView)
		self.badgeRingView.addSubview(self.badgeBorderOverlay)

		NSLayoutConstraint.activate([
			self.gradientView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.gradientView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.gradientView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.gradientView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.badgeRingView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.badgeRingView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 32.0),
			self.badgeRingView.widthAnchor.constraint(equalToConstant: badgeSize),
			self.badgeRingView.heightAnchor.constraint(equalTo: self.badgeRingView.widthAnchor),

			self.badgeImageView.leadingAnchor.constraint(equalTo: self.badgeRingView.leadingAnchor),
			self.badgeImageView.trailingAnchor.constraint(equalTo: self.badgeRingView.trailingAnchor),
			self.badgeImageView.topAnchor.constraint(equalTo: self.badgeRingView.topAnchor),
			self.badgeImageView.bottomAnchor.constraint(equalTo: self.badgeRingView.bottomAnchor),

			self.lockImageView.centerXAnchor.constraint(equalTo: self.badgeRingView.centerXAnchor),
			self.lockImageView.centerYAnchor.constraint(equalTo: self.badgeRingView.centerYAnchor),

			self.badgeBorderOverlay.topAnchor.constraint(equalTo: self.badgeRingView.topAnchor),
			self.badgeBorderOverlay.leadingAnchor.constraint(equalTo: self.badgeRingView.leadingAnchor),
			self.badgeBorderOverlay.trailingAnchor.constraint(equalTo: self.badgeRingView.trailingAnchor),
			self.badgeBorderOverlay.bottomAnchor.constraint(equalTo: self.badgeRingView.bottomAnchor),

			self.primaryLabel.topAnchor.constraint(equalTo: self.badgeRingView.bottomAnchor, constant: 16.0),
			self.primaryLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.primaryLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),

			self.secondaryLabel.topAnchor.constraint(equalTo: self.primaryLabel.bottomAnchor, constant: 8.0),
			self.secondaryLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.secondaryLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),

			self.dateLabel.topAnchor.constraint(greaterThanOrEqualTo: self.secondaryLabel.bottomAnchor, constant: 12.0),
			self.dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.0),
			self.dateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0),
			self.dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -32.0),

			self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 320.0)
		])
	}
}
