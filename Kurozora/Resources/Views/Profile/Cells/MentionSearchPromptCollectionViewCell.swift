//
//  MentionSearchPromptCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class MentionSearchPromptCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let iconContainerView: CircularView = {
		let view = CircularView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
		return view
	}()

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(systemName: "magnifyingglass")
		imageView.contentMode = .scaleAspectFit
		imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
		imageView.theme_tintColor = KThemePicker.tintedButtonTextColor.rawValue
		return imageView
	}()

	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.text = Trans.findWhoYouAreLookingFor
		return label
	}()

	private let subtitleLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.text = Trans.searchForThePersonYouWantToMention
		return label
	}()

	private let labelsStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = 0
		return stack
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureViewHierarchy()
		self.configureConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureViewHierarchy()
		self.configureConstraints()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.hideSkeleton()
	}

	// MARK: - Functions
	private func configureViewHierarchy() {
		self.contentView.addSubview(self.iconContainerView)
		self.iconContainerView.addSubview(self.iconImageView)

		self.labelsStackView.addArrangedSubview(self.titleLabel)
		self.labelsStackView.addArrangedSubview(self.subtitleLabel)
		self.contentView.addSubview(self.labelsStackView)
	}

	private func configureConstraints() {
		NSLayoutConstraint.activate([
			// Icon container
			self.iconContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.iconContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
			self.iconContainerView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: 0),
			self.iconContainerView.widthAnchor.constraint(equalToConstant: 50),
			self.iconContainerView.heightAnchor.constraint(equalToConstant: 50),

			// Center icon in container
			self.iconImageView.centerXAnchor.constraint(equalTo: self.iconContainerView.centerXAnchor),
			self.iconImageView.centerYAnchor.constraint(equalTo: self.iconContainerView.centerYAnchor),

			// Labels stack
			self.labelsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconContainerView.trailingAnchor, multiplier: 1.0),
			self.labelsStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.labelsStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 0),
			self.labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: 0)
		])
	}
}
