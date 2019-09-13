//
//  SuggestionResultCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class SuggestionResultCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var posterImageView: UIImageView?

	var searchElement: SearchElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let searchElement = searchElement else { return }
		titleLabel?.text = searchElement.title

		if let posterThumbnail = searchElement.posterThumbnail, !posterThumbnail.isEmpty {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			posterImageView?.kf.indicatorType = .activity
			posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster_image")
		}
	}
}
