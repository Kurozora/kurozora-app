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
		// Configure title
		self.titleLabel.text = self.show.attributes.title

		// Configure poster
		if let backgroundColor = self.show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		self.posterImageView.image = self.show.attributes.posterImage
	}
}
