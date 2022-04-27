//
//  KSelectableTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/11/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

/// A themed, scrollable, multiline text region.
///
/// KSelectableTextView supports the display of text using custom style information and also supports URL selection. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.
class KSelectableTextView: KTextView {
	// MARK: - Functions
	override func sharedInit() {
		super.sharedInit()

		self.delegate = self
		self.isEditable = false
		self.isSelectable = true
		self.dataDetectorTypes = [.link, .calendarEvent, .lookupSuggestion]
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard super.point(inside: point, with: event) else { return false }
		guard let pos = self.closestPosition(to: point) else { return false }
		guard let range = self.tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }
		let startIndex = self.offset(from: beginningOfDocument, to: range.start)
		return self.attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
	}
}

// MARK: - UITextViewDelegate
extension KSelectableTextView: UITextViewDelegate {
	public func textViewDidChangeSelection(_ textView: UITextView) {
		textView.selectedTextRange = nil
	}
}
