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
	@IBOutlet weak var taglineLabel: UILabel? {
		didSet {
			taglineLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var scoreButton: UIButton?
	@IBOutlet weak var genreLabel: UILabel?
	@IBOutlet weak var separatorView: UIView? {
		didSet {
			separatorView?.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var shadowView: UIView?
	@IBOutlet weak var colorOverlayView: UIView?
	@IBOutlet weak var backgroundColorView: UIView?
	@IBOutlet weak var listButton: UIButton?
	@IBOutlet weak var videoWebView: UIWebView?

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
	var section: Int?
	var libraryStatus: String?

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	// MARK: - Functions
	@IBAction func chooseStatusButtonPressed(_ sender: AnyObject) {
		let action = UIAlertController.actionSheetWithItems(items: [("Planning", "Planning"),("Watching","Watching"),("Completed","Completed"),("Dropped","Dropped"),("On-Hold", "OnHold")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.showElement?.id else {return}

			Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
				if success {
					// Update entry in library
					self.libraryStatus = value
					self.showElement?.userProfile?.libraryStatus = value

					let libraryUpdateNotificationName = Notification.Name("Update\(title)Section")
					NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

					let mutableAttributedTitle = NSMutableAttributedString()
					let  attributedTitleString = NSAttributedString(string: "\(title) ", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
					let attributedIconString = NSAttributedString(string: "", attributes: [.font : UIFont.init(name: "FontAwesome", size: 15)!])
					mutableAttributedTitle.append(attributedTitleString)
					mutableAttributedTitle.append(attributedIconString)

					self.listButton?.setAttributedTitle(mutableAttributedTitle, for: .normal)
				}
			})
		})

		if let libraryStatus = libraryStatus, !libraryStatus.isEmpty {
			action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
				Service.shared.removeFromLibrary(withID: self.showElement?.id, withSuccess: { (success) in
					if success {
						self.libraryStatus = ""

						let mutableAttributedTitle = NSMutableAttributedString()
						let  attributedTitleString = NSAttributedString(string: "ADD", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
						mutableAttributedTitle.append(attributedTitleString)
						self.listButton?.setAttributedTitle(mutableAttributedTitle, for: .normal)
					}
				})
			}))
		}
		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController, let homeCollectionViewController = self.homeCollectionViewController {
			popoverController.sourceView = homeCollectionViewController.view
			popoverController.sourceRect = CGRect(x: homeCollectionViewController.view.bounds.midX, y: homeCollectionViewController.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.homeCollectionViewController?.present(action, animated: true, completion: nil)
	}

	fileprivate func setupCell() {
		if showElement != nil {
			guard let showElement = showElement else { return }
			guard let showTitle = showElement.title else { return }
			guard let section = section else { return }

			libraryStatus = showElement.userProfile?.libraryStatus

			if taglineLabel != nil {
				guard let videoWebView = videoWebView else { return }
				self.titleLabel?.theme_textColor = KThemePicker.textColor.rawValue
				self.genreLabel?.theme_textColor = KThemePicker.subTextColor.rawValue

				// Configure library status
				if let libraryStatus = showElement.userProfile?.libraryStatus, !libraryStatus.isEmpty {
					let mutableAttributedTitle = NSMutableAttributedString()
					let  attributedTitleString = NSAttributedString(string: "\(libraryStatus.capitalized) ", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
					let attributedIconString = NSAttributedString(string: "", attributes: [.font : UIFont.init(name: "FontAwesome", size: 15)!])
					mutableAttributedTitle.append(attributedTitleString)
					mutableAttributedTitle.append(attributedIconString)

					listButton?.setAttributedTitle(mutableAttributedTitle, for: .normal)
				} else {
					listButton?.setTitle("ADD", for: .normal)
				}

				if let videoRequest = URLRequest(urlString: "https://www.youtube-nocookie.com/embed/l_98K4_6UQ0?&playsinline=1") {
					videoWebView.loadRequest(videoRequest)
				}

				videoWebView.scrollView.isScrollEnabled = false
				videoWebView.scrollView.bounces = false

				shadowView?.applyShadow()
			}

			self.hero.id = (posterImageView != nil) ? "explore_\(showTitle)_\(section)_poster" : "explore_\(showTitle)_\(section)_banner"
			titleLabel?.hero.id = (titleLabel != nil) ? "explore_\(showTitle)_\(section)_title" : nil
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
				scoreButton?.setTitle(" \(score)", for: .normal)
				// Change color based on score
				if score >= 2.5 {
					scoreButton?.backgroundColor = #colorLiteral(red: 0.9907178283, green: 0.8274499178, blue: 0.3669273257, alpha: 1)
				} else {
					scoreButton?.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.262745098, blue: 0.2509803922, alpha: 1)
				}
			} else {
				scoreButton?.setTitle("New", for: .normal)
				scoreButton?.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.8235294118, blue: 0.2823529412, alpha: 1)
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

		if taglineLabel == nil {
			self.applyShadow()
		}
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

		if let showTitle = showElement?.title, let section = section {
			showTabBarController.heroID = "explore_\(showTitle)_\(section)"
		}

		previewingContext.sourceRect = collectionView.convert(self.frame, to: collectionView.superview)

		return showTabBarController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		homeCollectionViewController?.performSegue(withIdentifier: "ShowDetailsSegue", sender: self)
	}
}
