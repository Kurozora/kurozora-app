//
//  ExploreCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import Hero

class ExploreCell: UICollectionViewCell {
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel?
	@IBOutlet weak var genreLabel: UILabel?

	var showElement: ExploreBanner? {
		didSet {
			setup()
		}
	}

	fileprivate func setup() {
		self.hero.id = nil

		guard let showElement = showElement else { return }
		guard let showTitle = showElement.title else { return }

		titleLabel.hero.id = "explore_\(showTitle)_title"
		titleLabel.text = showElement.title

		if let genres = showElement.genres, genres.count != 0 {
			var genreNames = ""
			for (genreIndex, genreItem) in genres.enumerated() {
				if let genreName = genreItem.name {
					genreNames += genreName
				}

				if genreIndex != genres.endIndex-1 {
					genreNames += ", "
				}
			}

			genreLabel?.text = genreNames
		} else {
			genreLabel?.text = ""
		}

		bannerImageView?.hero.id = "explore_\(showTitle)_banner"
		if let backgroundThumbnail = showElement.backgroundThumbnail, backgroundThumbnail != "" {
			let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
			let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
			bannerImageView?.kf.indicatorType = .activity
			bannerImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
		} else {
			bannerImageView?.image = #imageLiteral(resourceName: "placeholder_banner")
		}

		posterImageView?.hero.id = "explore_\(showTitle)_poster"
		if let posterThumbnail = showElement.posterThumbnail, posterThumbnail != "" {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			posterImageView?.kf.indicatorType = .activity
			posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
		}

		if let score = showElement.averageRating, score != 0 {
			scoreLabel?.text = " \(score)"
			// Change color based on score
			if score >= 2.5 {
				scoreLabel?.backgroundColor = #colorLiteral(red: 1, green: 0.6941176471, blue: 0.03921568627, alpha: 1)
			} else {
				scoreLabel?.backgroundColor = #colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1)
			}
		} else {
			scoreLabel?.text = "New"
			scoreLabel?.backgroundColor = #colorLiteral(red: 0.2174585164, green: 0.8184141517, blue: 0, alpha: 1)
		}
	}
}
