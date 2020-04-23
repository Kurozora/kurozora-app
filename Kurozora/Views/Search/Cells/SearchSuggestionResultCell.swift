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
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var posterImageView: UIImageView?

	// MARK: - Properties
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let showDetailsElement = showDetailsElement else { return }
		titleLabel?.text = showDetailsElement.title

		if let posterThumbnail = showDetailsElement.posterThumbnail {
			posterImageView?.setImage(with: posterThumbnail, placeholder: R.image.placeholders.showPoster()!)
		}
	}
}
