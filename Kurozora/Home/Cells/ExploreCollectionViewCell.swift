//
//  ExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import AVKit
import AVFoundation
import UIKit
import Kingfisher
import Hero

protocol ExploreCollectionViewCellDelegate: class {
	func playVideoForCell(with indexPath: IndexPath)
}

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
	@IBOutlet weak var libraryStatusButton: UIButton? {
		didSet {
			libraryStatusButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
			libraryStatusButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	@IBOutlet weak var videoPlayerContainer: UIView?

	var avPlayerViewController: AVPlayerViewController?
	var avPlayer: AVPlayer?
	var avPlayerLayer: AVPlayerLayer?
	var indexPath: IndexPath?
	weak var delegate: ExploreCollectionViewCellDelegate?
	var shouldPlay = false

	var homeCollectionViewController: HomeCollectionViewController?
	var showDetailsElement: ShowDetailsElement? = nil {
		didSet {
			configureCell()
		}
	}
	var genreElement: GenreElement? = nil {
		didSet {
			showDetailsElement = nil
			configureCell()
		}
	}
	var libraryStatus: String?
	var showDetailTabBarController: ShowDetailTabBarController?

	var thumbnailPlaceholder: UIImageView {
		get { return getVideoThumbnail() }
	}
	var avPlayerStatus: NSKeyValueObservation? = nil

	override func awakeFromNib() {
		super.awakeFromNib()
		avPlayerViewController = AVPlayerViewController()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if shadowView == nil {
			self.applyShadow()
		} else {
			shadowView?.applyShadow()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		if showDetailsElement != nil {
			guard let showDetailsElement = showDetailsElement else { return }
			guard let showTitle = showDetailsElement.title else { return }
			guard let section = indexPath?.section else { return }

			self.libraryStatus = showDetailsElement.currentUser?.libraryStatus

			if self.taglineLabel != nil {
				self.configureVideoCell()
			}

			self.hero.id = (posterImageView != nil) ? "explore_\(showTitle)_\(section)_poster" : "explore_\(showTitle)_\(section)_banner"
			self.titleLabel?.hero.id = (titleLabel != nil) ? "explore_\(showTitle)_\(section)_title" : nil
			self.titleLabel?.text = showDetailsElement.title

			if let genres = showDetailsElement.genres, genres.count != 0 {
				var genreNames = ""
				for (genreIndex, genreItem) in genres.enumerated() {
					if let genreName = genreItem.name {
						genreNames += genreName
					}

					if genreIndex != genres.endIndex-1 {
						genreNames += ", "
					}
				}

				self.genreLabel?.text = genreNames
			} else {
				self.genreLabel?.text = ""
			}

			if let bannerThumbnail = showDetailsElement.banner, !bannerThumbnail.isEmpty {
				let bannerThumbnailUrl = URL(string: bannerThumbnail)
				let resource = ImageResource(downloadURL: bannerThumbnailUrl!)
				self.bannerImageView?.kf.indicatorType = .activity
				self.bannerImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"), options: [.transition(.fade(0.2))])
			} else {
				self.bannerImageView?.image = #imageLiteral(resourceName: "placeholder_banner_image")
			}

			if let posterThumbnail = showDetailsElement.posterThumbnail, !posterThumbnail.isEmpty {
				let posterThumbnailUrl = URL(string: posterThumbnail)
				let resource = ImageResource(downloadURL: posterThumbnailUrl!)
				self.posterImageView?.kf.indicatorType = .activity
				self.posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
			} else {
				self.posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster_image")
			}

			if let score = showDetailsElement.averageRating, score != 0 {
				self.scoreButton?.setTitle(" \(score)", for: .normal)
				// Change color based on score
				if score >= 2.5 {
					self.scoreButton?.backgroundColor = #colorLiteral(red: 0.9907178283, green: 0.8274499178, blue: 0.3669273257, alpha: 1)
				} else {
					self.scoreButton?.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.262745098, blue: 0.2509803922, alpha: 1)
				}
			} else {
				self.scoreButton?.setTitle("New", for: .normal)
				self.scoreButton?.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.8235294118, blue: 0.2823529412, alpha: 1)
			}
		} else if genreElement != nil {
			configureGenreCell()
		}
	}

	/// Configures the video cell with the necessary details.
	func configureVideoCell() {
		self.titleLabel?.theme_textColor = KThemePicker.textColor.rawValue
		self.genreLabel?.theme_textColor = KThemePicker.subTextColor.rawValue

		// Configure tagline
		self.taglineLabel?.text = showDetailsElement?.tagline

		// Configure library status
		if let libraryStatus = showDetailsElement?.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			self.libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			self.libraryStatusButton?.setTitle("ADD", for: .normal)
		}

		// Configure video
		configureVideoPlayer()
	}

	/// Configures the genre cell with the necessary details.
	func configureGenreCell() {
		guard let genreElement = genreElement else { return }
		guard let genreColor = genreElement.color else { return }

		titleLabel?.text = genreElement.name
		colorOverlayView?.backgroundColor = UIColor(hexString: genreColor)?.withAlphaComponent(0.6)
		backgroundColorView?.backgroundColor = UIColor(hexString: genreColor)

		if let symbol = genreElement.symbol, !symbol.isEmpty {
			let symbolUrl = URL(string: symbol)
			let resource = ImageResource(downloadURL: symbolUrl!)
			bannerImageView?.kf.indicatorType = .activity
			bannerImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
		} else {
			bannerImageView?.image = #imageLiteral(resourceName: "placeholder_poster_image")
		}
	}

	/**
		Return a UIImage object containing a video thumbnail.
	
		- Returns: a UIImage object containing a video thumbnail
	*/
	func getVideoThumbnail() -> UIImageView {
		guard let showDetailsElement = showDetailsElement else { return UIImageView(image: #imageLiteral(resourceName: "placeholder_banner_image")) }
		if let bannerThumbnail = showDetailsElement.banner, !bannerThumbnail.isEmpty {
			let bannerThumbnailUrl = URL(string: bannerThumbnail)
			let resource = ImageResource(downloadURL: bannerThumbnailUrl!)
			let thumbnailPlaceholder = UIImageView(frame: CGRect(origin: .zero, size: videoPlayerContainer?.frame.size ?? .zero))
			thumbnailPlaceholder.kf.indicatorType = .activity
			thumbnailPlaceholder.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"), options: [.transition(.fade(0.2))])
			return thumbnailPlaceholder
		} else {
			return UIImageView(image: #imageLiteral(resourceName: "placeholder_banner_image"))
		}
	}

	/// Configures the video player with the right settings.
	func configureVideoPlayer() {
		guard let videoUrlString = showDetailsElement?.videoUrl else { return }
		guard let videoUrl = URL(string: videoUrlString) else { return }
		let avPlayerItem = AVPlayerItem(url: videoUrl)

		self.avPlayer = AVPlayer(playerItem: avPlayerItem)
		avPlayerStatus = self.avPlayer?.observe(\.status, changeHandler: { (_, _) in
			if self.avPlayer?.status == AVPlayer.Status.readyToPlay {
				self.avPlayerViewController?.contentOverlayView?.addSubview(self.thumbnailPlaceholder)
			}
		})
		addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
		self.avPlayer?.actionAtItemEnd = .none
		self.avPlayer?.isMuted = true
		self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
		self.avPlayerLayer?.videoGravity = .resizeAspectFill
		self.avPlayerLayer?.frame = videoPlayerContainer!.bounds
		if self.avPlayerViewController == nil {
			avPlayerViewController = AVPlayerViewController()
		}
		avPlayerViewController?.player = avPlayer
		avPlayerViewController?.exitsFullScreenWhenPlaybackEnds = true

		homeCollectionViewController?.addChild(avPlayerViewController!)
		avPlayerViewController?.view.frame = videoPlayerContainer!.bounds

		// Add avPlayerViewController view as subview to cell
		let avPlayerControllerView = avPlayerViewController!.view
		videoPlayerContainer?.addSubview(avPlayerControllerView!)
		avPlayerControllerView?.didMoveToSuperview()
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		let action = UIAlertController.actionSheetWithItems(items: [("Planning", "Planning"), ("Watching", "Watching"), ("Completed", "Completed"), ("Dropped", "Dropped"), ("On-Hold", "OnHold")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.showDetailsElement?.id else {return}

			Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
				if success {
					// Update entry in library
					self.libraryStatus = value
					self.showDetailsElement?.currentUser?.libraryStatus = value

					let libraryUpdateNotificationName = Notification.Name("Update\(title)Section")
					NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

					self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
				}
			})
		})

		if let libraryStatus = libraryStatus, !libraryStatus.isEmpty {
			action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
				Service.shared.removeFromLibrary(withID: self.showDetailsElement?.id, withSuccess: { (success) in
					if success {
						self.libraryStatus = ""

						self.libraryStatusButton?.setTitle("ADD", for: .normal)
					}
				})
			}))
		}
		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		// Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}

		if (homeCollectionViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.homeCollectionViewController?.present(action, animated: true, completion: nil)
		}
	}

//	// MARK: - Observable
//	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//		if (object as? AVPlayer) != nil {
//			if keyPath == "status" {
//				if avPlayer?.status == AVPlayer.Status.readyToPlay {
//					avPlayerViewController?.contentOverlayView?.addSubview(thumbnailPlaceholder)
//				}
//			}
//		}
//	}
}

// MARK: - UIViewControllerPreviewingDelegate
extension ExploreCollectionViewCell: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		showDetailTabBarController = ShowDetailTabBarController.instantiateFromStoryboard() as? ShowDetailTabBarController
		showDetailTabBarController?.exploreCollectionViewCell = self
		showDetailTabBarController?.showDetailsElement = showDetailsElement
		showDetailTabBarController?.modalPresentationStyle = .overFullScreen

		if let showTitle = showDetailsElement?.title, let section = indexPath?.section {
			showDetailTabBarController?.heroID = "explore_\(showTitle)_\(section)"
		}

		previewingContext.sourceRect = previewingContext.sourceView.bounds

		return showDetailTabBarController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		if let showDetailTabBarController = showDetailTabBarController {
			homeCollectionViewController?.present(showDetailTabBarController, animated: true, completion: nil)
		}
	}
}
