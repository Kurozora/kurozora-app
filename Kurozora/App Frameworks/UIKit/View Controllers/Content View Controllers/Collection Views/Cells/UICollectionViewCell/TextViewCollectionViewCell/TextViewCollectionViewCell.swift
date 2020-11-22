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
	@IBOutlet weak var moreSynopsisButton: KTintedButton?
	@IBOutlet weak var moreSynopsisImageView: UIImageView? {
		didSet {
			moreSynopsisImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreButtonView: UIView?

	// MARK: - Properties
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

		// Synopsis background
		moreButtonView?.isHidden = !(textView.layoutManager.numberOfLines > textViewCollectionViewCellType.maximumNumberOfLinesValue)
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = textViewContent
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.parentViewController?.present(synopsisKNavigationController, animated: true)
		}
	}
}
