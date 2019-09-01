//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class LibraryCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var posterShadowView: UIView!
	@IBOutlet weak var posterView: UIImageView!

	var libraryElement: LibraryElement? {
		didSet {
			configureCell()
		}
	}

	func configureCell() {
		self.hero.id = nil

		guard let libraryElement = libraryElement else { return }
		guard let showTitle = libraryElement.title else { return }

		self.titleLabel.text = libraryElement.title
		self.titleLabel.hero.id = "library_\(showTitle)_title"

		self.posterView.hero.id = "library_\(showTitle)_poster"
		if let posterThumbnail = libraryElement.posterThumbnail, !posterThumbnail.isEmpty {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			self.posterView.kf.indicatorType = .activity
			self.posterView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			self.posterView.image = #imageLiteral(resourceName: "placeholder_poster")
		}
	}
}
