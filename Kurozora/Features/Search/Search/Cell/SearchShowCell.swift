//
//  SearchShowCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

//import UIKit
//import Kingfisher
//
//class SearchShowCell: UICollectionViewCell {
//	@IBOutlet weak var posterImageView: UIImageView!
//	@IBOutlet weak var titleLabel: UILabel!
//	@IBOutlet weak var airDateLabel: UILabel!
//	@IBOutlet weak var scoreLabel: UILabel!
//	@IBOutlet weak var statusLabel: UILabel!
//
//	var searchElement: SearchElement? {
//		didSet {
//			update()
//		}
//	}
//
//	private func update() {
//		guard let searchElement = searchElement else { return }
//
//		if let posterThumbnail = searchElement.posterThumbnail, posterThumbnail != "" {
//			let posterThumbnailUrl = URL(string: posterThumbnail)
//			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
//			posterImageView.kf.indicatorType = .activity
//			posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
//		} else {
//			posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
//		}
//
//		titleLabel.text = searchElement.title
//		airDateLabel.text = searchElement.airDate
//		scoreLabel.text = "\(searchElement.averageRating ?? 0)"
//		statusLabel.text = (searchElement.status ?? "TBA")
//	}
//}
