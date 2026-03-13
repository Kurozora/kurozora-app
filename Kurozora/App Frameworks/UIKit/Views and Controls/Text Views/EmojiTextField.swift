//
//  EmojiTextField.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view for displaying and editing emojis.
///
/// Use an emoji text field to display emoji content and to gather emoji input from the user using the onscreen keyboard.
class EmojiTextField: UITextField {
	// MARK: - Properties
	override var textInputMode: UITextInputMode? {
		for mode in UITextInputMode.activeInputModes where mode.primaryLanguage == "emoji" {
			return mode
		}
		return super.textInputMode
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the text field.
	func sharedInit() {
		if let emojiKeyboardType = UIKeyboardType(rawValue: 124) {
			self.keyboardType = emojiKeyboardType
		}
	}
}
