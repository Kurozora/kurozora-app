//
//  LyricsInterludeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class LyricsInterludeCollectionViewCell: UITableViewCell {
	// MARK: - Views
	private let interludeView = LyricsInterludeView()

	// MARK: - Properties
	/// Whether the indicator takes the label color instead of the theme's text color.
	var prefersSystemColors = false {
		didSet { self.interludeView.prefersSystemColors = self.prefersSystemColors }
	}

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.configureSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.interludeView.hide()
	}

	// MARK: - Functions
	private func configureSubviews() {
		self.backgroundColor = .clear
		self.selectionStyle = .none
		self.contentView.clipsToBounds = true

		self.interludeView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.interludeView)

		let bottomConstraint = self.interludeView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor, constant: -16)
		bottomConstraint.priority = .defaultHigh

		NSLayoutConstraint.activate([
			self.interludeView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor, constant: 16),
			bottomConstraint,
			self.interludeView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.interludeView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.interludeView.heightAnchor.constraint(equalToConstant: 16),
		])
	}

	/// Shows or hides the breathing indicator.
	///
	/// - Parameter isActive: Whether the interlude is the active item.
	func setActive(_ isActive: Bool) {
		if isActive {
			self.interludeView.show()
		} else {
			self.interludeView.hide()
		}
	}

	/// Sets how much of the gap has elapsed.
	///
	/// - Parameters:
	///    - remainingMs: The time left in the gap before the next line, in milliseconds.
	///    - totalMs: The full duration of the gap, in milliseconds.
	func setProgress(remainingMs: Int, totalMs: Int) {
		self.interludeView.setProgress(remainingMs: remainingMs, totalMs: totalMs)
	}
}
