//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ShowDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBoutlet
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var visualEffectView: KVisualEffectView! {
		didSet {
			visualEffectView.cornerRadius = 10
		}
	}
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var moreButton: UIButton!

	// Action buttons
	@IBOutlet weak var libraryStatusButton: KTintedButton!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView!
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
		if let posterImage = showDetailsElement.poster {
			posterImageView.setImage(with: posterImage, placeholder: R.image.placeholders.showPoster()!)
		}

		// Configure banner view
		if let bannerImage = showDetailsElement.banner {
			bannerImageView.setImage(with: bannerImage, placeholder: R.image.placeholders.showBanner()!)
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

	func updateFavoriteStatus(with showDetailsElement: ShowDetailsElement? = nil, withFavoriteStatus favoriteStatus: FavoriteStatus = .unfavorite) {
		let showIsFavorite = showDetailsElement?.currentUser?.isFavorite ?? (favoriteStatus == .favorite)
		self.showDetailsElement?.currentUser?.isFavorite = showIsFavorite
		let favoriteImage = showIsFavorite ? R.image.symbols.heart_fill() : R.image.symbols.heart()
		favoriteButton.tag = showIsFavorite ? 1 : 0
		favoriteButton.setImage(favoriteImage, for: .normal)
		NotificationCenter.default.post(name: .KFavoriteShowsListDidChange, object: nil)
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

		let activityViewController = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sender = sender as? UIBarButtonItem {
				popoverController.barButtonItem = sender
			} else {
				popoverController.sourceView = sender as? UIButton
				popoverController.sourceRect = sender.bounds
			}
		}
		self.parentViewController?.present(activityViewController, animated: true, completion: nil)
	}

	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let libraryStatusString = self.libraryStatus else { return }
			guard let showID = self.showDetailsElement?.id else { return }
			guard let userID = User.current?.id else { return }

			let libraryStatus = KKLibrary.Status.fromString(libraryStatusString)
			let alertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: libraryStatus, action: { (title, value)  in
				if libraryStatus != value {
					KService.addToLibrary(forUserID: userID, withLibraryStatus: value, showID: showID) { result in
						switch result {
						case .success:
							// Update entry in library
							self.libraryStatus = value.stringValue
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)

							let libraryUpdateNotificationName = Notification.Name("Update\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

							self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
						case .failure:
							break
						}
					}
				}
			})

			if !libraryStatusString.isEmpty {
				alertController.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
					KService.removeFromLibrary(forUserID: userID, showID: showID) { result in
						switch result {
						case .success:
							self.libraryStatus = ""
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)
							self.libraryStatusButton.setTitle("ADD", for: .normal)
						case .failure:
							break
						}
					}
				}))
			}
			alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

			//Present the controller
			if let popoverController = alertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(alertController, animated: true, completion: nil)
			}
		}
	}

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let showID = self.showDetailsElement?.id else { return }
			var isFavoriteBoolValue = self.showDetailsElement?.currentUser?.isFavorite ?? false
			isFavoriteBoolValue = !isFavoriteBoolValue

			if let favoriteStatus = FavoriteStatus(rawValue: isFavoriteBoolValue.int), let userID = User.current?.id {
				KService.updateFavoriteStatus(forUserID: userID, forShow: showID, withFavoriteStatus: favoriteStatus) { result in
					switch result {
					case .success(let favoriteStatus):
						DispatchQueue.main.async {
							self.updateFavoriteStatus(withFavoriteStatus: favoriteStatus)
						}
					case .failure:
						break
					}
				}
			}
		}
	}
}
