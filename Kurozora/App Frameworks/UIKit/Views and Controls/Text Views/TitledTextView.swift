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

	// MARK: - Initializers
	/// Creates a titled text view.
	///
	/// - Parameters:
	///    - title: The title shown above the text region. `nil` omits it.
	///    - placeholder: The placeholder shown while the text region is empty.
	///    - height: The smallest height of the text region.
	init(title: String?, placeholder: String?, height: CGFloat = 100.0) {
		super.init(title: title)
		self.configureTextView(placeholder: placeholder, height: height)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	private func configureTextView(placeholder: String?, height: CGFloat) {
		self.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue

		self.textView.placeholder = placeholder
		self.textView.backgroundColor = .clear
		self.textView.font = .preferredFont(forTextStyle: .body)
		self.textView.adjustsFontForContentSizeCategory = true
		self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true

		self.addInputView(self.textView)
	}
}
