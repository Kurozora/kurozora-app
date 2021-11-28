//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import EventKit
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

	// Action buttons
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var libraryStatusButton: KTintedButton!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView!

	// MARK: - Properties
	var show: Show! {
		didSet {
			self.libraryStatus = show.attributes.libraryStatus ?? .none
			updateDetails()
		}
	}
	var libraryStatus: KKLibrary.Status = .none
}

// MARK: - Functions
extension ShowDetailHeaderCollectionViewCell {
	/// Updates the view with the details fetched from the server.
	fileprivate func updateDetails() {
		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KShowFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KShowReminderIsToggled, object: nil)

		// Configure library status
		self.libraryStatus = self.show.attributes.libraryStatus ?? .none
		updateLibraryActions()

		// Configure title label
		self.showTitleLabel.text = self.show.attributes.title

		// Configure tags label
		self.tagsLabel.text = self.show.attributes.informationString

		// Configure airing status label
		self.statusButton.setTitle(self.show.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: self.show.attributes.status.color)

		// Configure poster view
		if let posterBackgroundColor = self.show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		self.show.attributes.posterImage(imageView: self.posterImageView)

		// Configure banner view
		if let bannerBackgroundColor = self.show.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		self.show.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure shadows
		self.shadowView.applyShadow()
		self.reminderButton.applyShadow()
		self.favoriteButton.applyShadow()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	func updateLibraryStatus() {
		self.libraryStatusButton.setTitle(libraryStatus != .none ? "\(libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		updateFavoriteStatus()
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		updateReminderStatus()
	}

	/**
		Updates the `favoriteButton` appearance with the favorite status of the show.

		- Parameter animated: A boolean value indicating whether to update changes with animations.
	*/
	func updateFavoriteStatus(animated: Bool = false) {
		let favoriteStatus = self.show.attributes.favoriteStatus
		if self.libraryStatus == .none || favoriteStatus == .disabled {
			self.favoriteButton.isHidden = true
			self.favoriteButton.isUserInteractionEnabled = false
		} else {
			self.favoriteButton.isHidden = false
			self.favoriteButton.isUserInteractionEnabled = true

			self.favoriteButton.setImage(favoriteStatus.imageValue, for: .normal)
			NotificationCenter.default.post(name: .KFavoriteShowsListDidChange, object: nil)

			if animated {
				self.favoriteButton.animateBounce()
			}
		}
	}

	/**
		Updates the `reminderButton` appearance with the reminder status of the show.

		- Parameter animated: A boolean value indicating whether to update changes with animations.
	*/
	func updateReminderStatus(animated: Bool = false) {
		let reminderStatus = self.show.attributes.reminderStatus
		if self.libraryStatus == .none || reminderStatus == .disabled {
			self.reminderButton.isHidden = true
			self.reminderButton.isUserInteractionEnabled = false
		} else {
			self.reminderButton.isHidden = false
			self.reminderButton.isUserInteractionEnabled = true

			self.reminderButton.setImage(reminderStatus.imageValue, for: .normal)
			NotificationCenter.default.post(name: .KFavoriteShowsListDidChange, object: nil)

			if animated {
				self.reminderButton.animateBounce()
			}
		}
	}

	/**
		Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the show.

		- Parameter animated: A boolean value indicating whether to update changes with animations.
	*/
	func updateLibraryActions(animated: Bool = false) {
		self.updateLibraryStatus()
		self.updateFavoriteStatus(animated: animated)
		self.updateReminderStatus(animated: animated)
	}
}

// MARK: - IBActions
extension ShowDetailHeaderCollectionViewCell {
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let oldLibraryStatus = self.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { [weak self] (_, value)  in
				guard let self = self else { return }
				if oldLibraryStatus != value {
					KService.addToLibrary(withLibraryStatus: value, showID: self.show.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success(let libraryUpdate):
							self.show.attributes.update(using: libraryUpdate)

							// Update entry in library
							self.libraryStatus = value
							self.updateLibraryActions(animated: oldLibraryStatus == .none)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)

							let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
						case .failure:
							break
						}
					}
				}
			})

			if self.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { [weak self] _ in
					guard let self = self else { return }
					KService.removeFromLibrary(showID: self.show.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success(let libraryUpdate):
							self.show.attributes.update(using: libraryUpdate)

							// Update edntry in library
							self.libraryStatus = .none

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)

							self.updateLibraryActions(animated: true)
						case .failure:
							break
						}
					}
				}))
			}

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(actionSheetAlertController, animated: true, completion: nil)
			}
		}
	}

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {
		self.show.toggleFavorite()
	}

	@IBAction func raminderButtonPressed(_ sender: UIButton) {
		self.show.toggleReminder()
	}
}
