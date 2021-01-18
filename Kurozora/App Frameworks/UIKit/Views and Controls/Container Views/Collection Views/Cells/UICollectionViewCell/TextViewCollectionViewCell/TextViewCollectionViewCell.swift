//
//  TextViewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class TextViewCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var textView: KTextView!
	@IBOutlet weak var moreSynopsisButton: KButton?
	@IBOutlet weak var moreSynopsisImageView: UIImageView? {
		didSet {
			moreSynopsisImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreButtonView: UIView?

	// MARK: - Properties
	weak var delegate: TextViewCollectionViewCellDelegate?
	var textViewCollectionViewCellType: TextViewCollectionViewCellType = .synopsis
	var textViewContent: String? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		// Synopsis text
		textView.textContainer.maximumNumberOfLines = textViewCollectionViewCellType.maximumNumberOfLinesValue
		textView.textContainer.lineBreakMode = .byWordWrapping
		textView.text = textViewContent

		textView.layoutManager.delegate = self
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.textViewCollectionViewCell(self, didPressButton: sender)
	}
}

// MARK: - NSLayoutManagerDelegate
extension TextViewCollectionViewCell: NSLayoutManagerDelegate {
	func layoutManager(_ layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom oldSize: CGSize) {
		// Synopsis background
		self.moreButtonView?.isHidden = !(textView.layoutManager.numberOfLines > textViewCollectionViewCellType.maximumNumberOfLinesValue)
	}
}
