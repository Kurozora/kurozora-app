//
//  MonogramTextField.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A text field for editing monogram initials.
///
/// Hides the emoji keyboard and emoji button from all language keyboards using the private `acceptsEmoji` trait.
/// Also disables the context menu entirely.
class MonogramTextField: UITextField {
	// MARK: - Properties
	override var textInputMode: UITextInputMode? {
		if let mode = super.textInputMode, mode.primaryLanguage != "emoji" {
			return mode
		}

		return UITextInputMode.activeInputModes.first { $0.primaryLanguage != "emoji" }
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
	private func sharedInit() {
		if let traits = self.value(forKey: "textInputTraits") as? NSObject {
			traits.setValue(false, forKey: "acceptsEmoji")
		}
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}

	override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
		return nil
	}

	@available(iOS 16.0, *)
	override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
		return nil
	}
}
