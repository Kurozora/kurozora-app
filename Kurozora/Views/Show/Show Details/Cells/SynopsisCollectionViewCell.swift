//
//  SynopsisCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwiftTheme

class SynopsisCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var synopsisTextView: KTextView!
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

	// MARK: - Properties
	weak var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let showDetails = showDetailsElement else { return }
		synopsisTextView.text = showDetails.synopsis

		if moreSynopsisView != nil {
			// Synopsis text
			synopsisTextView.textContainer.maximumNumberOfLines = 4
			synopsisTextView.textContainer.lineBreakMode = .byWordWrapping

			// Synopsis background
			moreSynopsisView?.isHidden = !(synopsisTextView.layoutManager.numberOfLines > 4)

		}
	}
}
