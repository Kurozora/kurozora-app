//
//  SidebarBottomProfileView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/22/25.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KSidebarBottomProfileViewDelegate: AnyObject {
	func sidebarBottomProfileViewDidTap(_ profileView: KSidebarBottomProfileView) async
}

final class KSidebarBottomProfileView: UIControl {
	// MARK: - Subviews
	private let profileImageView = ProfileImageView(frame: .zero)
	private let nameLabel = KLabel()

	private let selectedBackgroundView = CircularView()

	// MARK: - Properties
	weak var delegate: KSidebarBottomProfileViewDelegate?

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
		self.configureNotifications()
		self.refreshUser()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
		self.configureNotifications()
		self.refreshUser()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Setup
	private func configureView() {
		self.isUserInteractionEnabled = true
		self.layer.masksToBounds = false

		// Background container for selected state
		self.selectedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		self.selectedBackgroundView.isUserInteractionEnabled = false
		self.addSubview(self.selectedBackgroundView)

		// Image
		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.profileImageView.layer.cornerRadius = 22
		self.profileImageView.clipsToBounds = true
		self.addSubview(self.profileImageView)

		// Label
		self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.nameLabel)

		// Constraints
		NSLayoutConstraint.activate([
			self.selectedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			self.selectedBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			self.selectedBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
			self.selectedBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

			self.profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			self.profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			self.profileImageView.widthAnchor.constraint(equalToConstant: 44),
			self.profileImageView.heightAnchor.constraint(equalToConstant: 44),

			self.nameLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12),
			self.nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
			self.nameLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor)
		])

		self.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
	}

	private func configureNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.refreshUser), name: .KUserIsSignedInDidChange, object: nil)
	}

	// MARK: - User handling
	@objc private func refreshUser() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let user = User.current {
				user.attributes.profileImage(imageView: self.profileImageView)
				self.nameLabel.text = user.attributes.username
			} else {
				self.profileImageView.image = .Placeholders.userProfile
				self.nameLabel.text = Trans.guest
			}

			self.setNeedsLayout()
		}
	}

	// MARK: - Selection
	override var isSelected: Bool {
		didSet { self.updateSelectionState() }
	}

	private func updateSelectionState() {
		if self.isSelected {
			self.selectedBackgroundView.theme_backgroundColor = KThemePicker.tintColor.rawValue
		} else {
			self.selectedBackgroundView.backgroundColor = .clear
		}
	}

	// MARK: - Actions
	@objc private func handleTap() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.sidebarBottomProfileViewDidTap(self)
			self.isSelected = true
		}
	}

	// MARK: - Size to Fit
	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		let height: CGFloat = 60
		return CGSize(width: targetSize.width, height: height)
	}
}
