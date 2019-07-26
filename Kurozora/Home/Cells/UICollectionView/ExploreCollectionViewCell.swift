//
//  ExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import Hero

class ExploreCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var scoreLabel: UILabel?
	@IBOutlet weak var genreLabel: UILabel?
	@IBOutlet weak var separatorView: UIView? {
		didSet {
			separatorView?.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var shadowView: UIView?
	@IBOutlet weak var colorOverlayView: UIView?
	@IBOutlet weak var backgroundColorView: UIView?

	var homeCollectionViewController: HomeCollectionViewController?
	var showElement: ExploreElement? = nil {
		didSet {
			setupCell()
		}
	}
	var genreElement: GenreElement? = nil {
		didSet {
			showElement = nil
			setupCell()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	// MARK: - Functions
	fileprivate func setupCell() {
		if showElement != nil {
			guard let showElement = showElement else { return }
			guard let showTitle = showElement.title else { return }

			self.hero.id = (posterImageView != nil) ? "explore_\(showTitle)_poster" : "explore_\(showTitle)_banner"
			titleLabel?.hero.id = (titleLabel != nil) ? "explore_\(showTitle)_title" : nil
			titleLabel?.text = showElement.title

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

			if let bannerThumbnail = showElement.banner, bannerThumbnail != "" {
				let bannerThumbnailUrl = URL(string: bannerThumbnail)
				let resource = ImageResource(downloadURL: bannerThumbnailUrl!)
				bannerImageView?.kf.indicatorType = .activity
				bannerImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
			} else {
				bannerImageView?.image = #imageLiteral(resourceName: "placeholder_banner")
			}

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
					scoreLabel?.backgroundColor = #colorLiteral(red: 0.9907178283, green: 0.8274499178, blue: 0.3669273257, alpha: 1)
				} else {
					scoreLabel?.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.262745098, blue: 0.2509803922, alpha: 1)
				}
			} else {
				scoreLabel?.text = "New"
				scoreLabel?.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.8235294118, blue: 0.2823529412, alpha: 1)
			}
		} else if genreElement != nil {
			guard let genreElement = genreElement else { return }
			guard let genreColor = genreElement.color else { return }

			titleLabel?.text = genreElement.name
			colorOverlayView?.backgroundColor = UIColor(hexString: genreColor)?.withAlphaComponent(0.6)
			backgroundColorView?.backgroundColor = UIColor(hexString: genreColor)

			if let symbol = genreElement.symbol, symbol != "" {
				let symbolUrl = URL(string: symbol)
				let resource = ImageResource(downloadURL: symbolUrl!)
				bannerImageView?.kf.indicatorType = .activity
				bannerImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
			} else {
				bannerImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
			}
		}

		self.applyShadow()
	}
}

// MARK: - UIViewControllerPreviewingDelegate
extension ExploreCollectionViewCell: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let collectionView = self.superview else { return nil }
		let storyboard = UIStoryboard(name: "details", bundle: nil)
		let showTabBarController = storyboard.instantiateInitialViewController() as! ShowDetailTabBarController
		showTabBarController.exploreCollectionViewCell = self
		showTabBarController.showID = showElement?.id

		if let showTitle = showElement?.title {
			showTabBarController.heroID = "explore_\(showTitle)"
		}

		previewingContext.sourceRect = collectionView.convert(self.frame, to: collectionView.superview)

		return showTabBarController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		homeCollectionViewController?.performSegue(withIdentifier: "ShowDetailsSegue", sender: self)
	}
}
