//
//  String+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension String {
	// MARK: - Properties
	/// Returns the initial characters (up to 2 characters) of the string separated by a whitespace or a dot. For example "John Appleseed" and "John.Appleseed" returns "JA". Returned value is case insensitive which means "john appleseed" will return "ja".
	var initials: String {
		let stringSeparatedByWhiteSpace = self.components(separatedBy: [".", " ", "-"])
		return stringSeparatedByWhiteSpace.reduce("") { ($0 == "" ? "" : "\($0.first ?? " ")") + "\($1.first ?? " ")" }
	}

	/// Returns a copy of the sequence with the first element capitalized.
	var capitalizedFirstLetter: String {
		return self.prefix(1).capitalized + self.dropFirst()
	}

	/// Check if string is valid email format.
	///
	/// - Note: Note that this property does not validate the email address against an email server. It merely attempts
	/// to determine whether its format is suitable for an email address.
	///
	/// ```swift
	/// "john@doe.com".isValidEmail -> true
	/// ```
	var isValidEmail: Bool {
		let regex =
			"^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
		return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
	}

	// MARK: - Functions
	/// Returns HTML string as `NSAttributedString`.
	///
	/// - Parameters:
	///    - color: The color to apply to the string.
	///    - font: The font to apply to the string.
	func htmlAttributedString(color: UIColor? = nil, font: UIFont? = nil) -> NSAttributedString? {
		let htmlTemplate = """
		<!doctype html>
		<html>
		  <head>
			<style>
			  body {
				font-family: -apple-system;
				font-size: 17px;
			  }
			</style>
		  </head>
		  <body>
			\(self.replacingOccurrences(of: "<hr />", with: "* * *"))
		  </body>
		</html>
		"""
		guard let data = htmlTemplate.data(using: .utf16) else {
			return nil
		}

		guard let attributedString = try? NSAttributedString(
			data: data,
			options: [.documentType: NSAttributedString.DocumentType.html],
			documentAttributes: nil
		) else {
			return nil
		}

		return attributedString.applying(attributes: [
			.foregroundColor: color ?? KThemePicker.textColor.colorValue,
			.font: font ?? UIFont.preferredFont(forTextStyle: .body),
		], toOccurrencesOf: self)
	}

	/// Returns Markdown string as `NSAttributedString`.
	func markdownAttributedString() -> NSAttributedString? {
		return try? NSAttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
	}

	/// Returns an array of URLs found in the string.
	func extractURLs() -> [URL] {
		let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
		let matches = detector?.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

		return matches?.compactMap { $0.url } ?? []
	}

	/// Truncated string (limited to a given number of characters).
	///
	/// ```swift
	/// "This is a very long sentence".truncated(toLength: 14) -> "This is a very..."
	///	"Short sentence".truncated(toLength: 14) -> "Short sentence"
	/// ```
	///
	/// - Parameters:
	///   - toLength: maximum number of characters before cutting.
	///   - trailing: string to add at the end of truncated string.
	///
	/// - Returns: truncated string (this is an extr...).
	func truncated(toLength length: Int, trailing: String? = "...") -> String {
		guard 0 ..< self.count ~= length else { return self }
		return self[self.startIndex ..< index(self.startIndex, offsetBy: length)] + (trailing ?? "")
	}
}

extension NSAttributedString {
	/// Apply attributes to occurrences of a given string.
	///
	/// - Parameters:
	///   - attributes: Dictionary of attributes.
	///   - target: a subsequence string for the attributes to be applied to.
	///
	/// - Returns: An NSAttributedString with attributes applied on the target string.
	func applying(attributes: [Key: Any], toOccurrencesOf target: some StringProtocol) -> NSAttributedString {
		let pattern = "\\Q\(target)\\E"

		return self.applying(attributes: attributes, toRangesMatching: pattern)
	}

	/// Apply attributes to substrings matching a regular expression.
	///
	/// - Parameters:
	///   - attributes: Dictionary of attributes.
	///   - pattern: a regular expression to target.
	///   - options: The regular expression options that are applied to the expression during matching. See
	/// NSRegularExpression.Options for possible values.
	///
	/// - Returns: An NSAttributedString with attributes applied to substrings matching the pattern.
	func applying(attributes: [Key: Any], toRangesMatching pattern: String, options: NSRegularExpression.Options = []) -> NSAttributedString {
		guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: options) else { return self }

		let matches = regularExpression.matches(in: string, options: [], range: NSRange(0 ..< length))
		let result = NSMutableAttributedString(attributedString: self)

		for match in matches {
			result.addAttributes(attributes, range: match.range)
		}

		return result
	}
}
