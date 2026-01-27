//
//  KTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/// A themed, scrollable, multiline text region.
///
/// KTextView supports the display of text using custom style information and also supports text editing. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.
///
/// KTextView also supports the display of placeholder.
class KTextView: UITextView {
	// MARK: - Views
	private let placeholderLabel = UILabel()

	// MARK: - Properties
	/// The placeholder text that the text view displays.
	///
	/// - Tag: KTextView-placeholder
	var placeholder: String? {
		didSet {
			self.placeholderLabel.text = self.placeholder
		}
	}

	/// The color of the placeholder text.
	///
	/// This property applies to the entire text string in the [placeholder](x-source-tag://KTextView-placeholder) property.
	///
	/// The default value for this property is the system’s [placeholderText](https://developer.apple.com/documentation/uikit/uicolor/3173134-placeholdertext) color, which adapts dynamically to Dark Mode changes. Setting this property to nil causes it to be reset to the default value. For more information, see [UI element colors](https://developer.apple.com/documentation/uikit/uicolor/ui_element_colors).
	var placeholderColor: UIColor? = .placeholderText {
		didSet {
			self.placeholderLabel.textColor = self.placeholderColor ?? .placeholderText
		}
	}

	/// The color of the placeholder text.
	///
	/// This property applies to the entire text string in the [placeholder](x-source-tag://KTextView-placeholder) property.
	var theme_placeholderColor: ThemeColorPicker? = KThemePicker.textFieldPlaceholderTextColor.rawValue {
		didSet {
			self.placeholderLabel.theme_textColor = self.theme_placeholderColor ?? KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}

	override var text: String! {
		didSet {
			self.placeholderLabel.isHidden = !self.text.isEmpty
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	func sharedInit() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateAttributedText), name: .ThemeUpdateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextDidBeginEditing), name: UITextView.textDidBeginEditingNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextDidEndEditing), name: UITextView.textDidEndEditingNotification, object: nil)

		self.configureView()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	/// Set attributed text with predefined attributes.
	///
	/// - Parameter text: The string to set.
	func setAttributedText(_ attributedText: NSAttributedString?) {
		self.attributedText = attributedText?.applying(attributes: [
			NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
			NSAttributedString.Key.font: self.font ?? UIFont.preferredFont(forTextStyle: .body)
		], toOccurrencesOf: attributedText?.string ?? "")
	}

	/// Update the attributed text.
	@objc private func updateAttributedText() {
		self.setAttributedText(self.attributedText)
	}

	/// Called when the user begins editing.
	@objc private func handleTextDidBeginEditing() {
		self.placeholderLabel.theme_textColor = self.theme_placeholderColor
		self.placeholderLabel.isHidden = true
	}

	/// Called when the user ends editing.
	@objc private func handleTextDidEndEditing() {
		self.placeholderLabel.isHidden = !self.text.isEmpty
	}
}

// MARK: - Configuration
private extension KTextView {
	func configureView() {
		self.configureTextView()
		self.configurePlaceholderLabel()
	}

	func configureTextView() {
		self.theme_textColor = KThemePicker.textColor.rawValue
		self.theme_tintColor = KThemePicker.tintColor.rawValue

		self.textContainerInset = .zero
		self.textContainer.lineFragmentPadding = 0
		self.font = .preferredFont(forTextStyle: .body)
	}

	func configurePlaceholderLabel() {
		self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		self.placeholderLabel.font = self.font
		self.placeholderLabel.numberOfLines = 0
		self.placeholderLabel.isHidden = !self.text.isEmpty
		self.placeholderLabel.theme_textColor = self.theme_placeholderColor
	}
}

// MARK: - Hierarchy
private extension KTextView {
	func configureViewHierarchy() {
		self.addSubview(self.placeholderLabel)
	}
}

// MARK: - Constraints
private extension KTextView {
	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor),
			self.placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}
}
