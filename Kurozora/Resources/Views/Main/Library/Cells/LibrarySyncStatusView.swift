//
//  LibrarySyncStatusView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view showing the list's contents and sync status above the library list.
final class LibrarySyncStatusView: UIView {
	// MARK: - Views
	private let statsLabel = KLabel()
	private let statusLabel = KSecondaryLabel()
	private let stackView = UIStackView()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Shows the given stats and status.
	///
	/// - Parameters:
	///    - stats: The list's contents per media type.
	///    - status: The library's sync status.
	func configure(stats: String, status: String) {
		self.statsLabel.text = stats
		self.statsLabel.isHidden = stats.isEmpty
		self.statusLabel.text = status
		self.statusLabel.isHidden = status.isEmpty
	}

	/// The height the view needs for the given width.
	///
	/// - Parameter width: The width available to the view.
	///
	/// - Returns: The height.
	func height(fittingWidth width: CGFloat) -> CGFloat {
		return self.systemLayoutSizeFitting(
			CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		).height
	}

	private func configureView() {
		for label in [self.statsLabel, self.statusLabel] {
			label.textAlignment = .center
			label.numberOfLines = 0
			label.adjustsFontForContentSizeCategory = true
		}

		let footnote = UIFont.preferredFont(forTextStyle: .footnote)
		self.statsLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .systemFont(ofSize: footnote.pointSize, weight: .semibold))
		self.statusLabel.font = footnote

		self.stackView.axis = .vertical
		self.stackView.alignment = .fill
		self.stackView.spacing = 2.0
		self.stackView.addArrangedSubview(self.statsLabel)
		self.stackView.addArrangedSubview(self.statusLabel)
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
			self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0),
		])
	}
}
