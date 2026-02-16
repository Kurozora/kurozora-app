//
//  MarkdownTextFormatter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A stateless formatter that converts plain text containing markdown syntax
/// into a styled `NSAttributedString` with live visual preview.
///
/// Formatting characters (delimiters) are rendered at reduced opacity while
/// the content they wrap receives the appropriate visual treatment (bold, italic, etc.).
struct MarkdownTextFormatter {
	// MARK: - Properties
	/// The opacity applied to delimiter characters (e.g. `**`, `~~`, `_`).
	private let delimiterOpacity: CGFloat = 0.35

	/// The opacity applied to escape backslash characters.
	private let escapeOpacity: CGFloat = 0.25

	// MARK: - Functions
	/// Formats the given plain text as a styled attributed string with live markdown preview.
	///
	/// - Parameters:
	///   - text: The raw markdown text.
	///   - font: The base font to use.
	///   - textColor: The default text color.
	///   - tintColor: The color used for links, hashtags, and mentions.
	///
	/// - Returns: A styled `NSAttributedString`.
	func format(_ text: String, font: UIFont, textColor: UIColor, tintColor: UIColor) -> NSAttributedString {
		let result = NSMutableAttributedString(string: text, attributes: [
			.font: font,
			.foregroundColor: textColor
		])

		var context = FormattingContext(
			result: result,
			text: text,
			fullRange: NSRange(location: 0, length: (text as NSString).length),
			textColor: textColor,
			tintColor: tintColor,
			font: font
		)

		// Step 1: Escape sequences
		self.applyEscapeSequences(context: &context)

		// Step 2: Spoiler tags ||spoiler||
		self.applyPattern("\\|\\|(.+?)\\|\\|", style: .spoiler, context: &context)

		// Step 3: Inline code `code`
		self.applyPattern("`(.+?)`", style: .inlineCode, context: &context)

		// Step 4: Auto URLs
		self.applyAutoURLs(context: &context)

		// Step 5: Hashtags
		self.applyColorPattern("#[a-zA-Z0-9_]+", color: tintColor, context: &context)

		// Step 6: Mentions
		self.applyColorPattern("@[a-zA-Z0-9_]+", color: tintColor, context: &context)

		// Step 7: Bold **text**
		self.applyPattern("\\*\\*(.+?)\\*\\*", style: .addBoldTrait, context: &context)

		// Step 8: Underline __text__
		self.applyPattern("__(.+?)__", style: .underline, context: &context)

		// Step 9: Strikethrough ~~text~~
		self.applyPattern("~~(.+?)~~", style: .strikethrough, context: &context)

		// Step 10: Italic *text* (single star, not part of **)
		self.applyPattern("(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", style: .addItalicTrait, context: &context)

		// Step 11: Italic _text_ (single underscore, not part of __)
		self.applyPattern("(?<!_)_(?!_)(.+?)(?<!_)_(?!_)", style: .addItalicTrait, context: &context)

		// Step 12: Numbered lists
		self.applyPattern("(?m)^\\d{1,9}[.)]\\s(.+)$", style: .numberedList, context: &context)

		// Step 13: Bullet points
		self.applyPattern("(?m)^-\\s(.+)$", style: .unorderedList, context: &context)

		return result
	}
}

// MARK: - Formatting Context
private extension MarkdownTextFormatter {
	/// Bundles shared state passed through each formatting step.
	struct FormattingContext {
		let result: NSMutableAttributedString
		let text: String
		let fullRange: NSRange
		let textColor: UIColor
		let tintColor: UIColor
		let font: UIFont
		var escapedCharRanges = IndexSet()
		var consumedRanges = IndexSet()
	}

	/// Describes how to style the content portion of a matched markdown pattern.
	enum ContentStyle {
		case addBoldTrait
		case addItalicTrait
		case underline
		case strikethrough
		case numberedList
		case unorderedList
		case inlineCode
		case spoiler
	}
}

// MARK: - Escape Sequences
private extension MarkdownTextFormatter {
	func applyEscapeSequences(context: inout FormattingContext) {
		let escapableCharacters: Set<Character> = ["*", "_", "~", "[", "]", "(", ")", "#", "@", "\\", "-", "`", "|"]
		let nsText = context.text as NSString
		var index = 0

		while index < nsText.length - 1 {
			guard let unicodeScalar = UnicodeScalar(nsText.character(at: index)) else {
				index += 1
				continue
			}
			let char = Character(unicodeScalar)

			if char == "\\" {
				guard let nextUnicodeScalar = UnicodeScalar(nsText.character(at: index + 1)) else {
					index += 1
					continue
				}
				let nextChar = Character(nextUnicodeScalar)

				if escapableCharacters.contains(nextChar) {
					let backslashRange = NSRange(location: index, length: 1)
					context.result.addAttribute(
						.foregroundColor,
						value: context.textColor.withAlphaComponent(self.escapeOpacity),
						range: backslashRange
					)

					context.escapedCharRanges.insert(integersIn: index ..< index + 2)
					context.consumedRanges.insert(integersIn: index ..< index + 2)
					index += 2
					continue
				}
			}

			index += 1
		}
	}
}

// MARK: - Pattern Application
private extension MarkdownTextFormatter {
	func applyPattern(_ pattern: String, style: ContentStyle, context: inout FormattingContext) {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
		let matches = regex.matches(in: context.text, options: [], range: context.fullRange)

		for match in matches {
			let matchRange = match.range
			let matchIndexSet = IndexSet(integersIn: matchRange.location ..< matchRange.location + matchRange.length)

			// Skip if any part of this match overlaps with escaped or already consumed ranges
			if !matchIndexSet.isDisjoint(with: context.escapedCharRanges) { continue }
			if !matchIndexSet.isDisjoint(with: context.consumedRanges) { continue }

			let contentRange = match.range(at: 1)

			// Apply content style
			switch style {
			case .addBoldTrait:
				self.addFontTrait(.traitBold, to: context.result, range: contentRange, baseFont: context.font)
			case .addItalicTrait:
				self.addFontTrait(.traitItalic, to: context.result, range: contentRange, baseFont: context.font)
			case .underline:
				context.result.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: contentRange)
			case .strikethrough:
				context.result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: contentRange)
			case .numberedList:
				context.result.addAttribute(.paragraphStyle, value: self.numberedListParagraphStyle(), range: contentRange)
			case .unorderedList:
				context.result.addAttribute(.paragraphStyle, value: self.unorderedListParagraphStyle(), range: contentRange)
			case .inlineCode:
				context.result.addAttribute(.inlineCode, value: context.textColor.withAlphaComponent(0.1), range: contentRange)
				context.result.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: context.font.pointSize, weight: .regular), range: contentRange)
				context.result.addAttribute(.backgroundColor, value: context.textColor.withAlphaComponent(0.1), range: contentRange)
				context.result.addAttribute(.foregroundColor, value: context.textColor.withAlphaComponent(0.9), range: contentRange)
				context.result.addAttribute(.baselineOffset, value: -1, range: contentRange)
			case .spoiler:
				context.result.addAttribute(.spoiler, value: context.textColor.withAlphaComponent(0.1), range: contentRange)
				context.result.addAttribute(.spoilerHidden, value: context.textColor.withAlphaComponent(0.5), range: contentRange)
				context.result.addAttribute(.foregroundColor, value: context.textColor.withAlphaComponent(0.9), range: contentRange)
			}

			// Apply delimiter opacity
			// Compute delimiter ranges by subtracting content from the full match
			let delimiterColor = context.textColor.withAlphaComponent(self.delimiterOpacity)
			let contentIndexSet = IndexSet(integersIn: contentRange.location ..< contentRange.location + contentRange.length)
			let delimiterIndexSet = matchIndexSet.subtracting(contentIndexSet)

			for range in delimiterIndexSet.rangeView {
				context.result.addAttribute(
					.foregroundColor,
					value: delimiterColor,
					range: NSRange(location: range.lowerBound, length: range.count)
				)
			}

			context.consumedRanges.formUnion(matchIndexSet)
		}
	}

	func numberedListParagraphStyle() -> NSParagraphStyle {
		let style = NSMutableParagraphStyle()
		style.headIndent = 20
		style.firstLineHeadIndent = 0
		style.paragraphSpacing = 4
		return style
	}

	func unorderedListParagraphStyle() -> NSParagraphStyle {
		let style = NSMutableParagraphStyle()
		style.headIndent = 20
		style.firstLineHeadIndent = 0
		style.paragraphSpacing = 4
		return style
	}

	func addFontTrait(
		_ trait: UIFontDescriptor.SymbolicTraits,
		to result: NSMutableAttributedString,
		range: NSRange,
		baseFont: UIFont
	) {
		// Enumerate existing fonts in the range to preserve traits
		result.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
			let currentFont = (value as? UIFont) ?? baseFont
			let currentTraits = currentFont.fontDescriptor.symbolicTraits
			let newTraits = currentTraits.union(trait)

			if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(newTraits) {
				let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
				result.addAttribute(.font, value: newFont, range: subRange)
			}
		}
	}
}

// MARK: - Auto URLs
private extension MarkdownTextFormatter {
	func applyAutoURLs(context: inout FormattingContext) {
		let pattern = "https?://\\S+"
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
		let matches = regex.matches(in: context.text, options: [], range: context.fullRange)

		for match in matches {
			let matchRange = match.range
			let matchIndexSet = IndexSet(integersIn: matchRange.location ..< matchRange.location + matchRange.length)

			// Skip if already consumed by link syntax or escaped
			if !matchIndexSet.isDisjoint(with: context.consumedRanges) { continue }
			if !matchIndexSet.isDisjoint(with: context.escapedCharRanges) { continue }

			context.result.addAttribute(.foregroundColor, value: context.tintColor, range: matchRange)
			context.consumedRanges.formUnion(matchIndexSet)
		}
	}
}

// MARK: - Color-Only Patterns
private extension MarkdownTextFormatter {
	func applyColorPattern(_ pattern: String, color: UIColor, context: inout FormattingContext) {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
		let matches = regex.matches(in: context.text, options: [], range: context.fullRange)

		for match in matches {
			let matchRange = match.range
			let matchIndexSet = IndexSet(integersIn: matchRange.location ..< matchRange.location + matchRange.length)

			if !matchIndexSet.isDisjoint(with: context.escapedCharRanges) { continue }
			if !matchIndexSet.isDisjoint(with: context.consumedRanges) { continue }

			context.result.addAttribute(.foregroundColor, value: color, range: matchRange)
			context.consumedRanges.formUnion(matchIndexSet)
		}
	}
}
