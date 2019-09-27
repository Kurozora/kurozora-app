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

		if let posterThumbnail = showDetailsElement.posterThumbnail, !posterThumbnail.isEmpty {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			posterImageView?.kf.indicatorType = .activity
			posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster_image")
		}
	}
}
