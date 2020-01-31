//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class ShowDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBoutlet
	@IBOutlet weak var bannerImageView: UIImageView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showBanner(_:)))
			bannerImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var visualEffectView: UIVisualEffectView! {
		didSet {
			visualEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue)
			visualEffectView.cornerRadius = 10
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
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPoster(_:)))
			posterImageView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var favoriteButton: UIButton!

	// MARK: - Properties
	weak var delegate: ShowDetailCollectionViewControllerDelegate?

	var baseLockupCollectionViewCell: BaseLockupCollectionViewCell? = nil
	var libraryBaseCollectionViewCell: LibraryBaseCollectionViewCell? = nil
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			self.libraryStatus = showDetailsElement?.currentUser?.libraryStatus
			updateDetails()
		}
	}
	var libraryStatus: String?
}

// MARK: - Functions
extension ShowDetailHeaderCollectionViewCell {
	/**
		Configures the view from the given Explore cell if the details view was requested from the Explore page.

		- Parameter cell: The explore cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: BaseLockupCollectionViewCell?) {
		guard let cell = cell else { return }
		if cell.bannerImageView != nil {
			showTitleLabel.text = cell.primaryLabel?.text
			bannerImageView.image = cell.bannerImageView?.image
		} else {
			posterImageView.image = cell.posterImageView?.image
//			ratingScoreLabel.text = "\((cell as? SmallLockupCollectionViewCell)?.scoreButton.titleForNormal ?? "0")"
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

		// Configure airStatus label
		if let status = showDetailsElement.airStatus, !status.isEmpty {
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

		if let airingStatus = ShowDetail.AiringStatus(rawValue: showDetailsElement.airStatus ?? "Ended") {
			statusButton.setTitle(airingStatus.stringValue, for: .normal)
			statusButton.backgroundColor = airingStatus.colorValue
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

		// Configre favorite status
		updateFavoriteStatus(with: showDetailsElement)

		// Configure shadows
		shadowView.applyShadow()
		reminderButton.applyShadow()
		favoriteButton.applyShadow()

		// Display details
		quickDetailsView.isHidden = false
	}

	func updateFavoriteStatus(with showDetailsElement: ShowDetailsElement? = nil, withInt isFavorite: Int? = 0) {
		let showIsFavorite = showDetailsElement?.currentUser?.isFavorite ?? (isFavorite == 1)
		self.showDetailsElement?.currentUser?.isFavorite = showIsFavorite
		let favoriteImage = showIsFavorite ? #imageLiteral(resourceName: "Symbols/heart_fill") : #imageLiteral(resourceName: "Symbols/heart")
		favoriteButton.tag = showIsFavorite ? 1 : 0
		favoriteButton.setImage(favoriteImage, for: .normal)
		NotificationCenter.default.post(name: .KFavoriteShowsListDidChange, object: nil)
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
}

// MARK: - IBActions
extension ShowDetailHeaderCollectionViewCell {
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

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let showID = self.showDetailsElement?.id else { return }
			var isFavoriteBoolValue = self.showDetailsElement?.currentUser?.isFavorite ?? false
			isFavoriteBoolValue = !isFavoriteBoolValue
			let isFavorite = isFavoriteBoolValue.int

			KService.shared.updateFavoriteStatus(forShow: showID, isFavorite: isFavorite) { (isFavorite) in
				DispatchQueue.main.async {
					self.updateFavoriteStatus(withInt: isFavorite)
				}
			}
		}
	}
}
