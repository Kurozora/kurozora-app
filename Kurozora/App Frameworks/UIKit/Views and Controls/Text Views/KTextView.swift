//
//  KTextView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed, scrollable, multiline text region.

	KTextView supports the display of text using custom style information and also supports text editing. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.
*/
class KTextView: UITextView {
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
		self.theme_textColor = KThemePicker.textColor.rawValue
		self.theme_tintColor = KThemePicker.tintColor.rawValue

		self.textContainerInset = .zero
		self.textContainer.lineFragmentPadding = 0
	}
}
