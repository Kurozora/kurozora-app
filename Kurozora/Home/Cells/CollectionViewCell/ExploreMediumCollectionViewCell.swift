//
//  ExploreMediumCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreMediumCollectionViewCell: ExploreBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var colorOverlayView: UIView?
	@IBOutlet weak var backgroundColorView: UIView?

	// MARK: - Functions
	override func configureCell() {
		guard let genreElement = genreElement else { return }
		guard let genreColor = genreElement.color else { return }

		primaryLabel?.text = genreElement.name
		colorOverlayView?.backgroundColor = UIColor(hexString: genreColor)?.withAlphaComponent(0.6)
		backgroundColorView?.backgroundColor = UIColor(hexString: genreColor)

		if let symbol = genreElement.symbol {
			bannerImageView?.setImage(with: symbol, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
		}

		shadowView?.applyShadow()
	}
}
