//
//  TitledTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A themed text region on a rounded background with an optional title.
final class TitledTextView: TitledInputView {
	// MARK: - Views
	/// The text region the user writes in.
	let textView = KTextView()

	// MARK: - Properties
	/// The number of lines the text region shows before it scrolls.
	private let visibleLines: Int

	/// The constraint holding the text region's smallest height.
	private var minimumHeightConstraint: NSLayoutConstraint!

	// MARK: - Initializers
	/// Creates a titled text view.
	///
	/// - Parameters:
	///    - title: The title shown above the text region.
	///    - placeholder: The placeholder shown while the text region is empty.
	///    - visibleLines: The number of lines the text region shows before it scrolls.
	init(title: String?, placeholder: String?, visibleLines: Int = 4) {
		self.visibleLines = visibleLines
		super.init(title: title)
		self.configureTextView(placeholder: placeholder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }

		self.updateMinimumHeight()
	}

	// MARK: - Functions
	private func configureTextView(placeholder: String?) {
		self.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue

		self.textView.placeholder = placeholder
		self.textView.backgroundColor = .clear
		self.textView.font = .preferredFont(forTextStyle: .body)
		self.textView.adjustsFontForContentSizeCategory = true

		self.minimumHeightConstraint = self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0)
		self.minimumHeightConstraint.isActive = true
		self.updateMinimumHeight()

		self.addInputView(self.textView)
	}

	/// Sizes the text region to the lines it shows at the reader's text size.
	private func updateMinimumHeight() {
		let font = self.textView.font ?? .preferredFont(forTextStyle: .body)
		let textContainerInset = self.textView.textContainerInset

		self.minimumHeightConstraint.constant = (font.lineHeight * CGFloat(self.visibleLines)).rounded() + textContainerInset.top + textContainerInset.bottom
	}
}
