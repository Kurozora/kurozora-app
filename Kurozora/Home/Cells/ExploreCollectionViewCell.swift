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
import Hero

protocol ExploreCollectionViewCellDelegate: class {
	func playVideoForCell(with indexPath: IndexPath)
}

class ExploreBaseCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel?
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?

	@IBOutlet weak var shadowView: UIView?

	// MARK: - Properties
	weak var delegate: ExploreCollectionViewCellDelegate?
	var indexPath: IndexPath?
	var showDetailTabBarController: ShowDetailTabBarController?
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

	// MARK: - View
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		if shadowView == nil {
//			self.applyShadow(withView: bannerImageView, shadowOpacity: 1, shadowRadius: 0)
//		} else {
//			shadowView?.applyShadow(withView: posterImageView, shadowOpacity: 1, shadowRadius: 0)
//		}
//	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let showDetailsElement = showDetailsElement else { return }
		guard let showTitle = showDetailsElement.title else { return }
		guard let section = indexPath?.section else { return }

		self.hero.id = (posterImageView != nil) ? "explore_\(showTitle)_\(section)_poster" : "explore_\(showTitle)_\(section)_banner"
		self.primaryLabel?.hero.id = (primaryLabel != nil) ? "explore_\(showTitle)_\(section)_title" : nil
		self.primaryLabel?.text = showDetailsElement.title

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

			self.secondaryLabel?.text = genreNames
		} else {
			self.secondaryLabel?.text = ""
		}

		if let bannerThumbnail = showDetailsElement.banner {
			self.bannerImageView?.setImage(with: bannerThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
		}

		if let posterThumbnail = showDetailsElement.posterThumbnail {
			self.posterImageView?.setImage(with: posterThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
		}
	}
}

// MARK: - Video
class ExploreVideoCollectionViewCell: ExploreBaseCollectionViewCell {
	// MARK: - IBOutlets
	override var primaryLabel: UILabel? {
		didSet {
			primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	override var secondaryLabel: UILabel? {
		didSet {
			secondaryLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var taglineLabel: UILabel! {
		didSet {
			taglineLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var libraryStatusButton: UIButton! {
		didSet {
			libraryStatusButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
			libraryStatusButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var videoPlayerContainer: UIView!

	// MARK: - Properties
	var avPlayer: AVPlayer?
	var avPlayerLayer: AVPlayerLayer?
	var avPlayerStatus: NSKeyValueObservation? = nil
	var avPlayerTimeControl: NSKeyValueObservation? = nil
	var avPlayerViewController: AVPlayerViewController = AVPlayerViewController()
	var shouldPlay = false

	var libraryStatus: String?

	var thumbnailPlaceholder: UIImageView {
		get {
			let thumbnailPlaceholder = UIImageView(frame: CGRect(origin: .zero, size: videoPlayerContainer?.frame.size ?? .zero))
			if let bannerThumbnail = showDetailsElement?.banner {
				thumbnailPlaceholder.setImage(with: bannerThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
			}
			return thumbnailPlaceholder
		}
	}

	// MARK: - View
//	override func awakeFromNib() {
//		super.awakeFromNib()
//		avPlayerViewController = AVPlayerViewController()
//	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		// Configure tagline
		self.taglineLabel.text = showDetailsElement.tagline

		// Configure library status
		self.libraryStatus = showDetailsElement.currentUser?.libraryStatus
		if let libraryStatus = showDetailsElement.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			self.libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			self.libraryStatusButton?.setTitle("ADD", for: .normal)
		}

		// Configure video player
		configureVideoPlayer()
	}

	/// Configures the video player with the defined settings.
	func configureVideoPlayer() {
		guard let videoUrlString = showDetailsElement?.videoUrl else { return }
		guard let videoUrl = URL(string: videoUrlString) else { return }
		let avPlayerItem = AVPlayerItem(url: videoUrl)

		self.avPlayer = AVPlayer(playerItem: avPlayerItem)
		self.avPlayer?.actionAtItemEnd = .none
		self.avPlayer?.isMuted = true
		self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
		self.avPlayerLayer?.videoGravity = .resizeAspectFill
		self.avPlayerLayer?.frame = videoPlayerContainer.bounds
//		if self.avPlayerViewController == nil {
//			avPlayerViewController = AVPlayerViewController()
//		}
		avPlayerViewController.player = avPlayer
		avPlayerViewController.exitsFullScreenWhenPlaybackEnds = true

		// Setup video thumbnail and observe play status
		setupVideoThumbnail()
		avPlayerTimeControl = self.avPlayer?.observe(\.timeControlStatus, changeHandler: { (_, _) in
			if self.avPlayer?.timeControlStatus == .playing {
				self.avPlayerViewController.contentOverlayView?.removeSubviews()
			}
		})

		self.parentViewController?.addChild(avPlayerViewController)
		avPlayerViewController.view.frame = videoPlayerContainer!.bounds

		// Add avPlayerViewController view as subview to cell
		let avPlayerControllerView = avPlayerViewController.view
		videoPlayerContainer?.addSubview(avPlayerControllerView!)
		avPlayerControllerView?.didMoveToSuperview()
	}

	/// Sets up the video thumbnail by observing the video player status.
	fileprivate func setupVideoThumbnail() {
		avPlayerStatus = self.avPlayer?.observe(\.status, changeHandler: { (_, _) in
			if self.avPlayer?.status == AVPlayer.Status.readyToPlay {
				self.avPlayerViewController.contentOverlayView?.addSubview(self.thumbnailPlaceholder)
			}
		})
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let action = UIAlertController.actionSheetWithItems(items: [("Watching", "Watching"), ("Planning", "Planning"), ("Completed", "Completed"), ("On-Hold", "OnHold"), ("Dropped", "Dropped")], currentSelection: self.libraryStatus, action: { (title, value)  in
				guard let showID = self.showDetailsElement?.id else {return}

				KService.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
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

			if let libraryStatus = self.libraryStatus, !libraryStatus.isEmpty {
				action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
					KService.shared.removeFromLibrary(withID: self.showDetailsElement?.id, withSuccess: { (success) in
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

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(action, animated: true, completion: nil)
			}
		}
	}
}

// MARK: - Large
class ExploreLargeCollectionViewCell: ExploreBaseCollectionViewCell {
	@IBOutlet weak var separatorView: UIView? {
		didSet {
			separatorView?.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
}

// MARK: - Medium
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
	}
}

// MARK: - Small
class ExploreSmallCollectionViewCell: ExploreBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var scoreButton: UIButton!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		if let score = showDetailsElement.averageRating, score != 0 {
			self.scoreButton?.setTitle(" \(score)", for: .normal)
			// Change color based on score
			if score >= 2.5 {
				self.scoreButton?.backgroundColor = .kYellow
			} else {
				self.scoreButton?.backgroundColor = .kLightRed
			}
		} else {
			self.scoreButton?.setTitle("New", for: .normal)
			self.scoreButton?.backgroundColor = .kGreen
		}
	}
}

// MARK: - UIViewControllerPreviewingDelegate
#if !targetEnvironment(macCatalyst)
extension ExploreBaseCollectionViewCell: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		showDetailTabBarController = ShowDetailTabBarController.instantiateFromStoryboard() as? ShowDetailTabBarController
		showDetailTabBarController?.exploreBaseCollectionViewCell = self
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
			self.parentViewController?.present(showDetailTabBarController, animated: true, completion: nil)
		}
	}
}
#endif
