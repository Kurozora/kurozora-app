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
	weak var delegate: ShowDetailsCollectionViewControllerDelegate?

	var libraryBaseCollectionViewCell: LibraryBaseCollectionViewCell? = nil
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
		// Configure library status
		if let libraryStatus = self.show.attributes.libraryStatus {
			self.libraryStatus = libraryStatus
		}
		updateLibraryActions()

		// Configure title label
		self.showTitleLabel.text = self.show.attributes.title

		// Configure tags label
		self.tagsLabel.text = self.show.attributes.informationString

		// Configure airStatus label
		if let airingStatus = ShowDetail.AiringStatus(rawValue: self.show.attributes.airStatus) {
			self.statusButton.setTitle(airingStatus.stringValue, for: .normal)
			self.statusButton.backgroundColor = airingStatus.colorValue
		}

		// Configure poster view
		self.posterImageView.image = self.show.attributes.posterImage

		// Configure banner view
		self.bannerImageView.image = self.show.attributes.bannerImage

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
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)
							self.updateLibraryActions(animated: oldLibraryStatus == .none)

							let libraryUpdateNotificationName = Notification.Name("Update\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)
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
							self.libraryStatus = .none
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)
							self.updateLibraryActions(animated: true)
						case .failure:
							break
						}
					}
				}))
			}

			//Present the controller
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
		WorkflowController.shared.isSignedIn {
			KService.updateFavoriteShowStatus(self.show.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let favoriteStatus):
					self.show.attributes.favoriteStatus = favoriteStatus
					self.updateFavoriteStatus()
				case .failure:
					break
				}
			}
		}
	}

	@IBAction func raminderButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			KService.updateReminderStatus(forShow: self.show.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let reminderStatus):
					self.show.attributes.reminderStatus = reminderStatus
					self.updateReminderStatus()
				case .failure:
					break
				}
			}
		}
	}
}
