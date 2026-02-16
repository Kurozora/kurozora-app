//
//  KTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A themed, scrollable, multiline text region.
///
/// KTextView supports the display of text using custom style information and also supports text editing. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.
///
/// KTextView also supports the display of placeholder.
class KTextView: UITextView {
	// MARK: - Views
	private let placeholderLabel = UILabel()
	private var customLayoutManager = RichTextLayoutManager()

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

	/// When `true`, the owning controller manages attributed text formatting
	/// and `KTextView` skips its own `updateAttributedText()` on theme changes.
	var managedFormattingMode: Bool = false

	override var text: String! {
		didSet {
			self.placeholderLabel.isHidden = !self.text.isEmpty
		}
	}

	override var attributedText: NSAttributedString! {
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

	override var layoutManager: NSLayoutManager {
		return self.customLayoutManager
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
		guard !self.managedFormattingMode else { return }
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

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }

		let point = touch.location(in: self)

		let index = self.layoutManager.characterIndex(
			for: point,
			in: textContainer,
			fractionOfDistanceBetweenInsertionPoints: nil
		)

		guard index < self.attributedText.length else {
			super.touchesEnded(touches, with: event)
			return
		}

		var range = NSRange(location: 0, length: 0)

		if self.attributedText.attribute(.spoilerHidden, at: index, effectiveRange: &range) != nil {
			self.revealSpoiler(in: range)
			return
		}

		super.touchesEnded(touches, with: event)
	}

	private func revealSpoiler(in range: NSRange) {
		guard let mutable = attributedText.mutableCopy() as? NSMutableAttributedString else { return }

		mutable.removeAttribute(.spoilerHidden, range: range)
		mutable.removeAttribute(.foregroundColor, range: range)

		self.attributedText = mutable
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

		self.backgroundColor = nil
		self.textContainerInset = .zero
		self.textContainer.lineFragmentPadding = 0
		self.font = .preferredFont(forTextStyle: .body)

		self.customLayoutManager.textStorage = self.textStorage
		self.customLayoutManager.addTextContainer(self.textContainer)
		self.textContainer.replaceLayoutManager(self.customLayoutManager)
	}

	func configurePlaceholderLabel() {
		self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		self.placeholderLabel.font = self.font
		self.placeholderLabel.numberOfLines = 0
		self.placeholderLabel.isHidden = !self.text.isEmpty
		self.placeholderLabel.theme_textColor = self.theme_placeholderColor
	}

	func configureViewHierarchy() {
		self.addSubview(self.placeholderLabel)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor),
			self.placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}
}

// MARK: - NSAttributedString Keys
extension NSAttributedString.Key {
	static let inlineCode = NSAttributedString.Key("inlineCode")
	static let spoiler = NSAttributedString.Key("spoiler")
	static let spoilerHidden = NSAttributedString.Key("spoilerHidden")
}

final class RichTextLayoutManager: NSLayoutManager {
	var cornerRadius: CGFloat = 6
	var horizontalPadding: CGFloat = 4
	var verticalPadding: CGFloat = 0

	override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
		super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

		guard let textStorage = textStorage,
		      let textContainer = textContainers.first else { return }

		let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)

		textStorage.enumerateAttribute(.inlineCode, in: characterRange, options: []) { value, range, _ in
			guard let value = value as? UIColor else { return }
			let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
			var rect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)

			rect.origin.x += origin.x
			rect.origin.y += origin.y

			rect = rect.insetBy(dx: -self.horizontalPadding, dy: -self.verticalPadding)

			let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

			value.setFill()
			path.fill()
		}

		textStorage.enumerateAttribute(.spoiler, in: characterRange, options: []) { value, range, _ in
			guard let value = value as? UIColor else { return }
			let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
			var rect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)

			rect.origin.x += origin.x
			rect.origin.y += origin.y

			rect = rect.insetBy(dx: -self.horizontalPadding, dy: -self.verticalPadding)

			let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

			value.setFill()
			path.fill()
		}
	}
}
