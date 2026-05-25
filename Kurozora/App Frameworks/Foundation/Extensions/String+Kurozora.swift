//
//  String+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

/// Shared storage for text parsing caches used by `String` convenience methods.
private enum TextParsingCache {
	static let markdown = NSCache<NSString, NSAttributedString>()
	static let urlDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
}

extension String {
	// MARK: - Properties
	/// Returns the initial characters of the string using locale-aware name parsing.
	///
	/// Uses `PersonNameComponentsFormatter` with the `.abbreviated` style to produce
	/// locale-correct initials for natural names (e.g. "Hayao Miyazaki" -> "HM").
	/// Falls back to `splitInitials` for unparseable input.
	var initials: String {
		let formatter = PersonNameComponentsFormatter()

		if let components = formatter.personNameComponents(from: self) {
			let abbreviated = PersonNameComponentsFormatter.localizedString(from: components, style: .abbreviated, options: [])
			let lettersOnly = abbreviated.filter(\.isLetter)

			if !lettersOnly.isEmpty {
				return lettersOnly
			}
		}

		return self.splitInitials
	}

	/// Returns initials by splitting on whitespace, dots, and hyphens.
	///
	/// This method is not locale-aware.
	private var splitInitials: String {
		let components = self.components(separatedBy: [".", " ", "-"])
		let letterInitials = components.lazy
			.compactMap { component in component.first(where: \.isLetter) }
			.prefix(2)

		if letterInitials.isEmpty {
			return self.first.map(String.init) ?? ""
		}

		return String(letterInitials)
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

	/// Returns Markdown string as `NSAttributedString`, cached for repeated access.
	func markdownAttributedString() -> NSAttributedString? {
		let key = self as NSString
		if let cached = TextParsingCache.markdown.object(forKey: key) {
			return cached
		}
		guard let result = try? NSAttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) else {
			return nil
		}
		TextParsingCache.markdown.setObject(result, forKey: key)
		return result
	}

	/// Returns an array of URLs found in the string.
	func extractURLs() -> [URL] {
		let matches = TextParsingCache.urlDetector?.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
		return matches?.compactMap { $0.url } ?? []
	}

	/// Truncated string (limited to a given number of characters).
	///
	/// ```swift
	/// "This is a very long sentence".truncated(toLength: 14) -> "This is a very…"
	///	"Short sentence".truncated(toLength: 14) -> "Short sentence"
	/// ```
	///
	/// - Parameters:
	///   - toLength: maximum number of characters before cutting.
	///   - trailing: string to add at the end of truncated string.
	///
	/// - Returns: truncated string (this is an extr…).
	func truncated(toLength length: Int, trailing: String? = "…") -> String {
		guard 0 ..< self.count ~= length else { return self }
		return self[self.startIndex ..< index(self.startIndex, offsetBy: length)] + (trailing ?? "")
	}

	/// Returns whether `query` approximately matches the receiver, tolerating typos and partial input.
	///
	/// The comparison is case and diacritic insensitive. After trimming surrounding whitespace, the query
	/// is matched against any contiguous substring of the receiver within `maxDistance` Levenshtein edits.
	///
	/// - Parameters:
	///    - query: The text to search for.
	///    - maxDistance: The maximum edit distance to tolerate. When `nil`, a length-relative default is used.
	///
	/// - Returns: `true` if the receiver fuzzily matches `query`.
	func fuzzyContains(_ query: String, maxDistance: Int? = nil) -> Bool {
		let normalize: (String) -> String = { $0.lowercased().folding(options: .diacriticInsensitive, locale: .current) }
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		let normalizedQuery = normalize(trimmedQuery)
		let normalizedSelf = normalize(self)

		guard !normalizedQuery.isEmpty else {
			return true
		}

		if normalizedSelf.contains(normalizedQuery) {
			return true
		}

		let threshold = maxDistance ?? Swift.max(1, normalizedQuery.count / 4)
		return normalizedQuery.minimumEditDistance(toSubstringOf: normalizedSelf) <= threshold
	}

	/// Returns the minimum number of single-character edits required to transform the receiver
	/// into any contiguous substring of `text`.
	///
	/// Entry and exit anywhere in `text` are free, so the result reflects how closely the
	/// receiver approximates any window inside `text`.
	///
	/// - Parameter text: The string to search within.
	///
	/// - Returns: The minimum edit distance to any substring of `text`.
	private func minimumEditDistance(toSubstringOf text: String) -> Int {
		let pattern = Array(self)
		let target = Array(text)
		let patternLength = pattern.count
		let targetLength = target.count

		if patternLength == 0 {
			return 0
		}
		if targetLength == 0 {
			return patternLength
		}

		var previousRow = Array(repeating: 0, count: targetLength + 1)
		var currentRow = Array(repeating: 0, count: targetLength + 1)

		for patternIndex in 1 ... patternLength {
			currentRow[0] = patternIndex

			for targetIndex in 1 ... targetLength {
				let substitutionCost = pattern[patternIndex - 1] == target[targetIndex - 1] ? 0 : 1
				currentRow[targetIndex] = Swift.min(
					currentRow[targetIndex - 1] + 1,
					previousRow[targetIndex] + 1,
					previousRow[targetIndex - 1] + substitutionCost
				)
			}

			swap(&previousRow, &currentRow)
		}

		return previousRow.min() ?? patternLength
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
