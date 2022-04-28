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
		self.titleLabel.text = self.show.attributes.title

		if let backgroundColor = self.show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		self.show.attributes.posterImage(imageView: self.posterImageView)
	}
}
