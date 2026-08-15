//
//  TitledTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A themed text region on a rounded background with an optional title.
final class TitledTextView: UIView {
	// MARK: - Views
	private let titleLabel = KSecondaryLabel()

	/// The text region the user writes in.
	let textView = KTextView()

	// MARK: - Initializers
	/// Creates a titled text view.
	///
	/// - Parameters:
	///    - title: The title shown above the text region. `nil` omits it.
	///    - placeholder: The placeholder shown while the text region is empty.
	///    - height: The height of the text region.
	init(title: String?, placeholder: String?, height: CGFloat = 100.0) {
		super.init(frame: .zero)
		self.configureSubviews(title: title, placeholder: placeholder, height: height)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	private func configureSubviews(title: String?, placeholder: String?, height: CGFloat) {
		self.layerCornerRadius = 12.0
		self.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue

		self.titleLabel.text = title?.uppercased(with: Locale.current)
		self.titleLabel.font = .preferredFont(forTextStyle: .caption1)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.titleLabel.isHidden = title == nil
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.titleLabel)

		self.textView.placeholder = placeholder
		self.textView.backgroundColor = .clear
		self.textView.font = .preferredFont(forTextStyle: .body)
		self.textView.adjustsFontForContentSizeCategory = true
		self.textView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.textView)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -8),

			self.textView.topAnchor.constraint(equalTo: title == nil ? self.topAnchor : self.titleLabel.bottomAnchor, constant: 8),
			self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			self.textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
			self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
		])
	}
}
