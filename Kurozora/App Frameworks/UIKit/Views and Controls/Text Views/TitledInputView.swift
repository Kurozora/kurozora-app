//
//  TitledInputView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A themed input on a rounded background with an optional title.
class TitledInputView: UIView {
	// MARK: - Views
	private let titleLabel = KSecondaryLabel()
	private let contentStackView = UIStackView()

	// MARK: - Initializers
	/// Creates a titled input view.
	///
	/// - Parameter title: The title shown above the input. `nil` omits it.
	init(title: String?) {
		super.init(frame: .zero)
		self.configureSubviews(title: title)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Adds the given input below the title.
	///
	/// - Parameter inputView: The view the user writes in.
	func addInputView(_ inputView: UIView) {
		self.contentStackView.addArrangedSubview(inputView)
	}

	private func configureSubviews(title: String?) {
		self.layerCornerRadius = 12.0

		self.titleLabel.text = title?.uppercased(with: Locale.current)
		self.titleLabel.font = .preferredFont(forTextStyle: .caption1)
		self.titleLabel.adjustsFontForContentSizeCategory = true
		self.titleLabel.isHidden = title == nil

		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 8
		self.contentStackView.isLayoutMarginsRelativeArrangement = true
		self.contentStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.addArrangedSubview(self.titleLabel)

		self.addSubview(self.contentStackView)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}
}
