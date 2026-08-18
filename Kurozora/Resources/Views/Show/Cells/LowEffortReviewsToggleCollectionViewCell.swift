//
//  LowEffortReviewsToggleCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A row that reveals or hides the reviews flagged as low-effort.
class LowEffortReviewsToggleCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let titleLabel: KTintedLabel = {
		let label = KTintedLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote).bold
		label.textAlignment = .center
		return label
	}()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configures the cell with the toggle's current title.
	///
	/// - Parameter title: The title reflecting whether the low-effort reviews are shown or hidden.
	func configure(title: String) {
		self.titleLabel.text = title
	}

	private func configureSubviews() {
		self.contentView.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
		])
	}
}
