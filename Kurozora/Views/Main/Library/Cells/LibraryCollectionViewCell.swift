//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryBaseCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var posterShadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView!

	// MARK: - Properties
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let showDetailsElement = showDetailsElement else { return }

		self.titleLabel.text = showDetailsElement.title

		if let posterThumbnail = showDetailsElement.posterThumbnail {
			self.posterImageView.setImage(with: posterThumbnail, placeholder: R.image.placeholders.showPoster()!)
		}
	}
}
