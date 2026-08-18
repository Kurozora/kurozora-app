//
//  TitledTextField.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A themed single line field on a rounded background with an optional title.
final class TitledTextField: TitledInputView {
	// MARK: - Views
	/// The field the user types in.
	let textField = KTextField()

	// MARK: - Initializers
	/// Creates a titled text field.
	///
	/// - Parameters:
	///    - title: The title shown above the field. `nil` omits it.
	///    - placeholder: The placeholder shown while the field is empty.
	///    - height: The smallest height of the field.
	init(title: String?, placeholder: String?, height: CGFloat = 34.0) {
		super.init(title: title)
		self.configureTextField(placeholder: placeholder, height: height)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	private func configureTextField(placeholder: String?, height: CGFloat) {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		self.textField.placeholder = placeholder
		self.textField.borderStyle = .roundedRect
		self.textField.font = .systemFont(ofSize: 14)
		self.textField.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true

		self.addInputView(self.textField)
	}
}
