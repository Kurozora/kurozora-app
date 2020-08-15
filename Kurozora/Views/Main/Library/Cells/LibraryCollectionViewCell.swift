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
	var show: Show! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.titleLabel.text = show.attributes.title

		if let showPoster = show.attributes.poster {
			if let backgroundColor = showPoster.backgroundColor {
				self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
			}
			self.posterImageView.setImage(with: showPoster.url, placeholder: R.image.placeholders.showPoster()!)
		}
	}
}
