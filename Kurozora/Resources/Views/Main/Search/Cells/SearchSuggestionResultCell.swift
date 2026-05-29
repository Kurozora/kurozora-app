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
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var borderView: BorderView!

	// MARK: - Properties
	var show: Show! {
		didSet {
			configureCell()
		}
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.posterImageView.layer.borderWidth = 0
		self.borderView.cornerRadius = self.posterImageView.bounds.height / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.borderView.cornerRadius = self.posterImageView.bounds.height / 2.0
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.titleLabel.text = self.show.attributes.title

		self.show.attributes.posterImage(imageView: self.posterImageView)
	}
}
