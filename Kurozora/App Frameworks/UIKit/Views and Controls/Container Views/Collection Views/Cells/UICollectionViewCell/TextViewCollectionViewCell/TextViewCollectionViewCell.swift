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
	@IBOutlet weak var textViewPlaceholder: UIView!
	@IBOutlet weak var moreSynopsisButton: KButton?
	@IBOutlet weak var moreSynopsisImageView: UIImageView? {
		didSet {
			self.moreSynopsisImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreButtonView: UIView?

	// MARK: - Views
	private(set) var textView: KTextView!

	// MARK: - Properties
	weak var delegate: TextViewCollectionViewCellDelegate?
	var textViewCollectionViewCellType: TextViewCollectionViewCellType = .synopsis
	var textViewContent: String? {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configureTextView()
	}

	// MARK: - Functions
	private func configureTextView() {
		let textView = KTextView()
		textView.isEditable = false
		textView.isSelectable = false
		textView.isScrollEnabled = false
		textView.bounces = false
		textView.keyboardDismissMode = .onDrag
		textView.delaysContentTouches = false
		textView.canCancelContentTouches = false

		self.textViewPlaceholder.addSubview(textView)
		textView.fillToSuperview()

		self.textView = textView
	}

	fileprivate func configureCell() {
		self.textView.textContainer.maximumNumberOfLines = self.textViewCollectionViewCellType.maximumNumberOfLinesValue
		self.textView.textContainer.lineBreakMode = .byWordWrapping
		self.textView.text = textViewContent

		self.textView.layoutManager.delegate = self
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.textViewCollectionViewCell(self, didPressButton: sender)
	}
}

// MARK: - NSLayoutManagerDelegate
extension TextViewCollectionViewCell: NSLayoutManagerDelegate {
	func layoutManager(_ layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom oldSize: CGSize) {
		self.moreButtonView?.isHidden = !(self.textView.layoutManager.numberOfLines > self.textViewCollectionViewCellType.maximumNumberOfLinesValue)
	}
}
