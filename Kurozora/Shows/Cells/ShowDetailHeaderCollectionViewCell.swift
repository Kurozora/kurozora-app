//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Cosmos

class ShowDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBoutlet
	@IBOutlet weak var bannerImageView: UIImageView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showBanner(_:)))
			bannerImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var shadowImageView: UIImageView! {
		didSet {
			shadowImageView.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var moreButton: UIButton!

	// Action buttons
	@IBOutlet weak var libraryStatusButton: UIButton! {
		didSet {
			libraryStatusButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			libraryStatusButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel! {
		didSet {
			showTitleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPoster(_:)))
			posterImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var trailerButton: UIButton!
	@IBOutlet weak var trailerLabel: UILabel! {
		didSet {
			trailerLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var favoriteButton: UIButton!

	// Analytics view
	@IBOutlet weak var ratingView: UIView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showRating(_:)))
			ratingView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var ratingTitleLabel: UILabel! {
		didSet {
			ratingTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var rankTitleLabel: UILabel! {
		didSet {
			rankTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageTitleLabel: UILabel! {
		didSet {
			ageTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var ratingScoreLabel: UILabel! {
		didSet {
			ratingScoreLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var rankScoreLabel: UILabel! {
		didSet {
			rankScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageScoreLabel: UILabel! {
		didSet {
			ageScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	weak var delegate: ShowDetailCollectionViewControllerDelegate?

	var exploreBaseCollectionViewCell: ExploreBaseCollectionViewCell? = nil
	var libraryBaseCollectionViewCell: LibraryBaseCollectionViewCell? = nil
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			self.libraryStatus = showDetailsElement?.currentUser?.libraryStatus
			updateDetails()
		}
	}
	var libraryStatus: String?

	// MARK: - Functions
	/**
	Configures the view from the given Explore cell if the details view was requested from the Explore page.

	- Parameter cell: The explore cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: ExploreBaseCollectionViewCell?) {
		guard let cell = cell else { return }
		if cell.bannerImageView != nil {
			showTitleLabel.text = cell.primaryLabel?.text
			bannerImageView.image = cell.bannerImageView?.image
		} else {
			posterImageView.image = cell.posterImageView?.image
			ratingScoreLabel.text = "\((cell as? ExploreSmallCollectionViewCell)?.scoreButton.titleForNormal ?? "0")"
		}
	}

	/**
	Configures the view from the given Library cell if the details view was requested from the Library page.

	- Parameter cell: The library cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: LibraryBaseCollectionViewCell?) {
		guard let cell = cell else { return }
		showTitleLabel.text = cell.titleLabel?.text
		bannerImageView.image = (cell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image
		posterImageView.image = cell.posterImageView?.image
	}

	/// Updates the view with the details fetched from the server.
	fileprivate func updateDetails() {
		guard let showDetailsElement = showDetailsElement else { return }
		guard let currentUser = showDetailsElement.currentUser else { return }

		// Configure library status
		if let libraryStatus = currentUser.libraryStatus, !libraryStatus.isEmpty {
			self.libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			libraryStatusButton.setTitle("ADD", for: .normal)
		}

		// Configure title label
		if let title = showDetailsElement.title, !title.isEmpty {
			showTitleLabel.text = title
		} else {
			showTitleLabel.text = "Unknown"
		}

		// Configure tags label
		tagsLabel.text = showDetailsElement.informationString

		// Configure status label
		if let status = showDetailsElement.status, !status.isEmpty {
			statusButton.setTitle(status, for: .normal)
			if status == "Ended" {
				statusButton.backgroundColor = .dropped
			} else {
				statusButton.backgroundColor = .planning
			}
		} else {
			statusButton.setTitle("TBA", for: .normal)
			statusButton.backgroundColor = .onHold
		}

		if let airingStatus = ShowDetail.AiringStatus(rawValue: showDetailsElement.status ?? "Ended") {
			statusButton.setTitle(airingStatus.stringValue, for: .normal)
			statusButton.backgroundColor = airingStatus.colorValue
		}

		// Configure rating
		if let averageRating = showDetailsElement.averageRating, let ratingCount = showDetailsElement.ratingCount, averageRating > 0.00 {
			cosmosView.rating = averageRating
			ratingScoreLabel.text = "\(averageRating)"
			ratingTitleLabel.text = "\(ratingCount) Ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		} else {
			cosmosView.rating = 0.0
			ratingScoreLabel.text = "0.0"
			ratingTitleLabel.text = "Not enough ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		}

		// Configure rank label
		if let rankScore = showDetailsElement.rank {
			rankScoreLabel.text = rankScore > 0 ? "#\(rankScore)" : "-"
		}

		// Configure age label
		if let ageScore = showDetailsElement.age {
			ageScoreLabel.text = !ageScore.isEmpty ? ageScore : "-"
		}

		// Configure poster view
		if posterImageView.image == nil {
			if let posterThumb = showDetailsElement.posterThumbnail {
				posterImageView.setImage(with: posterThumb, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
			}
		}

		// Configure banner view
		if bannerImageView.image == nil {
			if let bannerImage = showDetailsElement.banner {
				bannerImageView.setImage(with: bannerImage, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
			}
		}

		if let videoUrl = showDetailsElement.videoUrl, !videoUrl.isEmpty {
			trailerButton.isHidden = false
			trailerLabel.isHidden = false
		} else {
			trailerButton.isHidden = true
			trailerLabel.isHidden = true
		}

		// Configure shadows
		shadowView.applyShadow()
		reminderButton.applyShadow()
		favoriteButton.applyShadow()

		// Display details
		quickDetailsView.isHidden = false
	}

	// MARK: - IBActions
	@IBAction func favoriteButtonPressed(_ sender: Any) {

	}

	@IBAction func closeButtonPressed(_ sender: UIButton) {
		self.parentViewController?.navigationController?.popViewController(animated: true)
	}

	@IBAction func moreButtonPressed(_ sender: AnyObject) {
		guard let showID = showDetailsElement?.id else { return }
		var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

		if let title = showDetailsElement?.title, !title.isEmpty {
			shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			if let sender = sender as? UIBarButtonItem {
				popoverController.barButtonItem = sender
			} else {
				popoverController.sourceView = sender as? UIButton
				popoverController.sourceRect = sender.bounds
			}
		}

		if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.parentViewController?.present(activityVC, animated: true, completion: nil)
		}
	}

	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let action = UIAlertController.actionSheetWithItems(items: Library.Section.alertControllerItems, currentSelection: self.libraryStatus, action: { (title, value)  in
				guard let showID = self.showDetailsElement?.id else { return }

				if self.libraryStatus != value {
					KService.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
						if success {
							// Update entry in library
							self.libraryStatus = value
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)

							let libraryUpdateNotificationName = Notification.Name("Update\(value)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

							self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
						}
					})
				}
			})

			if let libraryStatus = self.libraryStatus, !libraryStatus.isEmpty {
				action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
					KService.shared.removeFromLibrary(withID: self.showDetailsElement?.id, withSuccess: { (success) in
						if success {
							self.libraryStatus = ""

							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)

							self.libraryStatusButton.setTitle("ADD", for: .normal)
						}
					})
				}))
			}
			action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

			//Present the controller
			if let popoverController = action.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(action, animated: true, completion: nil)
			}
		}
	}

	@objc func showRating(_ gestureRecognizer: UIGestureRecognizer) {
		parentCollectionView?.safeScrollToItem(at: IndexPath(row: 0, section: ShowDetail.Section.rating.rawValue), at: .centeredVertically, animated: true)
	}

	@objc func showBanner(_ gestureRecognizer: UIGestureRecognizer) {
		if let banner = showDetailsElement?.banner, !banner.isEmpty {
			parentViewController?.presentPhotoViewControllerWith(url: banner, from: bannerImageView)
		} else {
			parentViewController?.presentPhotoViewControllerWith(string: "placeholder_banner_image", from: bannerImageView)
		}
	}

	@objc func showPoster(_ gestureRecognizer: UIGestureRecognizer) {
		if let poster = showDetailsElement?.poster, !poster.isEmpty {
			parentViewController?.presentPhotoViewControllerWith(url: poster, from: posterImageView)
		} else {
			parentViewController?.presentPhotoViewControllerWith(string: "placeholder_poster_image", from: posterImageView)
		}
	}

	@IBAction func playTrailerPressed(_ sender: UIButton) {
		if let videoUrl = showDetailsElement?.videoUrl, !videoUrl.isEmpty {
			parentViewController?.presentVideoViewControllerWith(string: videoUrl)
		}
	}
}

// MARK: - ShowCastCellDelegate
extension ShowDetailHeaderCollectionViewCell: ShowCastCellDelegate {
	func presentPhoto(withString string: String, from imageView: UIImageView) {
		parentViewController?.presentPhotoViewControllerWith(string: string, from: imageView)
	}

	func presentPhoto(withImage image: UIImage, from imageView: UIImageView) {
		parentViewController?.presentPhotoViewControllerWith(image: image, from: imageView)
	}

	func presentPhoto(withUrl url: String, from imageView: UIImageView) {
		parentViewController?.presentPhotoViewControllerWith(url: url, from: imageView)
	}
}
