//
//  SearchSuggestionResultCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SearchSuggestionResultCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var posterImageView: UIImageView!

	// MARK: - Properties
	var show: Show! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		titleLabel.text = show.attributes.title

		if let showPoster = show.attributes.poster {
			if let backgroundColor = showPoster.backgroundColor {
				posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
			}
			posterImageView.setImage(with: showPoster.url, placeholder: R.image.placeholders.showPoster()!)
		}
	}
}
