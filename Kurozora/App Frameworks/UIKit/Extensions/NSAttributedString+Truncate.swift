//
//  NSAttributedString+Truncate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension NSAttributedString {
	/// Returns a copy truncated to `toLines` lines with `suffix` appended at the cut point.
	///
	/// - Parameters:
	///   - toLines: The maximum number of lines to retain.
	///   - width: The container width used for measurement, in points.
	///   - font: The font used for measurement.
	///   - suffix: The attributed suffix appended at the cut point.
	///
	/// - Returns: The truncated string, or `self` when no truncation is required.
	func kkTruncated(toLines: Int, width: CGFloat, font: UIFont, suffix: NSAttributedString) -> NSAttributedString {
		guard toLines > 0, width > 0, self.length > 0 else { return self }

		let measurement = NSMutableAttributedString(attributedString: self)
		measurement.addAttribute(.font, value: font, range: NSRange(location: 0, length: measurement.length))

		let textStorage = NSTextStorage(attributedString: measurement)
		let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
		textContainer.lineFragmentPadding = 0
		textContainer.lineBreakMode = .byWordWrapping
		textContainer.maximumNumberOfLines = 0

		let layoutManager = NSLayoutManager()
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		_ = layoutManager.glyphRange(for: textContainer)

		var lineCount = 0
		var lineLimitLastGlyph = NSNotFound

		layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)) { _, _, _, glyphRange, stop in
			lineCount += 1
			if lineCount == toLines {
				lineLimitLastGlyph = NSMaxRange(glyphRange)
			} else if lineCount > toLines {
				stop.pointee = true
			}
		}

		guard lineCount > toLines, lineLimitLastGlyph != NSNotFound else { return self }

		let characterRange = layoutManager.characterRange(forGlyphRange: NSRange(location: 0, length: lineLimitLastGlyph), actualGlyphRange: nil)
		var cutLocation = characterRange.length
		let nsString = self.string as NSString
		let trimSet = CharacterSet.whitespacesAndNewlines

		while cutLocation > 0 {
			let lastIndex = cutLocation - 1
			let scalar = nsString.character(at: lastIndex)

			if let unicodeScalar = Unicode.Scalar(scalar), trimSet.contains(unicodeScalar) {
				cutLocation -= 1
			} else {
				break
			}
		}

		let result = NSMutableAttributedString(attributedString: self.attributedSubstring(from: NSRange(location: 0, length: cutLocation)))
		result.append(suffix)
		return result
	}
}
