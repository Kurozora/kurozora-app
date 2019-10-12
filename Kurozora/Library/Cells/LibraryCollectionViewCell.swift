//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var posterShadowView: UIView!
	@IBOutlet weak var posterView: UIImageView!

	// MARK: - Properties
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.hero.id = nil

		guard let showDetailsElement = showDetailsElement else { return }
		guard let showTitle = showDetailsElement.title else { return }

		self.titleLabel.text = showDetailsElement.title
		self.titleLabel.hero.id = "library_\(showTitle)_title"

		self.posterView.hero.id = "library_\(showTitle)_poster"
		if let posterThumbnail = showDetailsElement.posterThumbnail {
			self.posterView.setImage(with: posterThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
		}
	}
}
