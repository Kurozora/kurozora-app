//
//  SynopsisCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SynopsisCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var synopsisTextView: KTextView!
	@IBOutlet weak var moreSynopsisButton: KTintedButton?
	@IBOutlet weak var moreSynopsisImageView: UIImageView? {
		didSet {
			moreSynopsisImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var moreSynopsisView: UIView?

	// MARK: - Properties
	var synopsisText: String? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		synopsisTextView.text = synopsisText

		if moreSynopsisView != nil {
			// Synopsis text
			synopsisTextView.textContainer.maximumNumberOfLines = 4
			synopsisTextView.textContainer.lineBreakMode = .byWordWrapping

			// Synopsis background
			moreSynopsisView?.isHidden = !(synopsisTextView.layoutManager.numberOfLines > 4)
		}
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.synopsis = synopsisText
			}
			self.parentViewController?.present(synopsisKNavigationController)
		}
	}
}
