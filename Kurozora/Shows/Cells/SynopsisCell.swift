//
//  SynopsisCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

import SwiftTheme

class SynopsisCell: UITableViewCell {
	@IBOutlet weak var synopsisTextView: UITextView! {
		didSet {
			synopsisTextView.theme_textColor = KThemePicker.textColor.rawValue
			synopsisTextView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreSynopsisButton: UIButton? {
		didSet {
			moreSynopsisButton?.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreSynopsisImageView: UIImageView? {
		didSet {
			moreSynopsisImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreSynopsisView: UIView?

	weak var showDetailsElement: ShowDetailsElement? {
		didSet {
			setup()
		}
	}

	fileprivate func setup() {
		guard let showDetails = showDetailsElement else { return }
		synopsisTextView.text = showDetails.synopsis

		if moreSynopsisView != nil {
			// Synopsis text
			synopsisTextView.textContainer.maximumNumberOfLines = 8
			synopsisTextView.textContainer.lineBreakMode = .byWordWrapping

			// Synopsis background
			moreSynopsisView?.isHidden = !(synopsisTextView.layoutManager.numberOfLines > 8)

		}
	}
}

extension NSLayoutManager {
	var numberOfLines: Int {
		guard textStorage != nil else { return 0 }

		var count = 0
		enumerateLineFragments(forGlyphRange: NSMakeRange(0, numberOfGlyphs)) { _, _, _, _, _ in
			count += 1
		}
		return count
	}
}