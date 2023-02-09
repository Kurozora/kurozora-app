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
	@IBOutlet weak var visualEffectView: KVisualEffectView!
	@IBOutlet weak var bannerContainerView: UIView!

	// Action buttons
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var libraryStatusButton: KTintedButton!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterImageOverlayView: UIImageView!

	// MARK: - Properties
	var libraryStatus: KKLibrary.Status = .none
	var libraryKind: KKLibrary.Kind = .shows
	let mangaMask: UIImageView? = UIImageView(image: UIImage(named: "book_mask"))

	private var show: Show? = nil
	private var literature: Literature? = nil
}

// MARK: - Functions
extension ShowDetailHeaderCollectionViewCell {
	/// Updates the view with the details fetched from the server.
	func configure(using show: Show) {
		self.libraryKind = .shows
		self.literature = nil
		self.show = show
		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		// Configure library status
		self.libraryStatus = show.attributes.libraryStatus ?? .none
		self.updateLibraryActions(using: show)

		// Configure title label
		self.primaryLabel.text = show.attributes.title

		// Configure tags label
		self.secondaryLabel.text = show.attributes.informationString

		// Configure airing status label
		self.statusButton.setTitle(show.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: show.attributes.status.color)

		// Configure poster view
		if let posterBackgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		show.attributes.posterImage(imageView: self.posterImageView)
		self.posterImageOverlayView.isHidden = true
		self.posterImageView.cornerRadius = 10.0
		self.posterImageView.mask = nil

		// Configure banner view
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure shadows
		self.shadowView.applyShadow()
		self.reminderButton.applyShadow()
		self.favoriteButton.applyShadow()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	func configure(using literature: Literature) {
		self.libraryKind = .literatures
		self.show = nil
		self.literature = literature
		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		// Configure library status
		self.libraryStatus = literature.attributes.libraryStatus ?? .none
		self.updateLibraryActions(using: literature)

		// Configure title label
		self.primaryLabel.text = literature.attributes.title

		// Configure tags label
		self.secondaryLabel.text = literature.attributes.informationString

		// Configure airing status label
		self.statusButton.setTitle(literature.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: literature.attributes.status.color)

		// Configure poster view
		if let posterBackgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		literature.attributes.posterImage(imageView: self.posterImageView)
		self.posterImageOverlayView.isHidden = false
		self.posterImageView.cornerRadius = 0.0
		self.posterImageView.mask = self.mangaMask

		// Configure banner view
		if let bannerBackgroundColor = literature.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		literature.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure shadows
		self.shadowView.applyShadow()
		self.reminderButton.applyShadow()
		self.favoriteButton.applyShadow()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	func updateLibraryStatus() {
		let libraryStatus: String

		switch self.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		}

		self.libraryStatusButton.setTitle(self.libraryStatus != .none ? "\(libraryStatus.capitalized) ▾" : "ADD", for: .normal)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		guard let favoriteStatus = notification.userInfo?["favoriteStatus"] as? FavoriteStatus else { return }
		self.updateFavoriteStatus(favoriteStatus)
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		guard let reminderStatus = notification.userInfo?["reminderStatus"] as? ReminderStatus else { return }
		self.updateReminderStatus(reminderStatus)
	}

	/// Updates the `favoriteButton` appearance with the favorite status of the show.
	///
	/// - Parameter animated: A boolean value indicating whether to update changes with animations.
	func updateFavoriteStatus(_ favoriteStatus: FavoriteStatus, animated: Bool = false) {
		if self.libraryStatus == .none || favoriteStatus == .disabled {
			self.favoriteButton.isHidden = true
			self.favoriteButton.isUserInteractionEnabled = false
		} else {
			self.favoriteButton.isHidden = false
			self.favoriteButton.isUserInteractionEnabled = true

			self.favoriteButton.setImage(favoriteStatus.imageValue, for: .normal)
			NotificationCenter.default.post(name: .KFavoriteModelsListDidChange, object: nil)

			if animated {
				self.favoriteButton.animateBounce()
			}
		}
	}

	/// Updates the `reminderButton` appearance with the reminder status of the show.
	///
	/// - Parameter animated: A boolean value indicating whether to update changes with animations.
	func updateReminderStatus(_ reminderStatus: ReminderStatus, animated: Bool = false) {
		if self.libraryStatus == .none || reminderStatus == .disabled {
			self.reminderButton.isHidden = true
			self.reminderButton.isUserInteractionEnabled = false
		} else {
			self.reminderButton.isHidden = false
			self.reminderButton.isUserInteractionEnabled = true

			self.reminderButton.setImage(reminderStatus.imageValue, for: .normal)
			NotificationCenter.default.post(name: .KFavoriteModelsListDidChange, object: nil)

			if animated {
				self.reminderButton.animateBounce()
			}
		}
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the show.
	///
	/// - Parameters:
	///    - show: The show object used to udpate the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using show: Show, animated: Bool = false) {
		self.updateLibraryStatus()
		self.updateFavoriteStatus(show.attributes.favoriteStatus, animated: animated)
		self.updateReminderStatus(show.attributes.reminderStatus, animated: animated)
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the show.
	///
	/// - Parameters:
	///    - literature: The literature object used to udpate the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using literature: Literature, animated: Bool = false) {
		self.updateLibraryStatus()
		self.updateFavoriteStatus(literature.attributes.favoriteStatus, animated: animated)
		self.updateReminderStatus(literature.attributes.reminderStatus, animated: animated)
	}
}

// MARK: - IBActions
extension ShowDetailHeaderCollectionViewCell {
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let oldLibraryStatus = self.libraryStatus
			let modelID: String

			switch self.libraryKind {
			case .shows:
				guard let show = self.show else { return }
				modelID = String(show.id)
			case .literatures:
				guard let literatures = self.literature else { return }
				modelID = literatures.id
			}

			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: self.libraryKind), currentSelection: oldLibraryStatus, action: { [weak self] (_, value)  in
				guard let self = self else { return }

				if oldLibraryStatus != value {
					Task {
						do {
							let libraryUpdateResponse = try await KService.addToLibrary(self.libraryKind, withLibraryStatus: value, modelID: modelID).value

							// Update entry in library
							self.libraryStatus = value

							switch self.libraryKind {
							case .shows:
								guard let show = self.show else { return }
								show.attributes.update(using: libraryUpdateResponse.data)
								self.updateLibraryActions(using: show, animated: oldLibraryStatus == .none)
							case .literatures:
								guard let literature = self.literature else { return }
								literature.attributes.update(using: libraryUpdateResponse.data)
								self.updateLibraryActions(using: literature, animated: oldLibraryStatus == .none)
							}

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)

							let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
						} catch let error as KKAPIError {
//							self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
							print("----- Add to library failed", error.message)
						}
					}
				}
			})

			if self.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive, handler: { _ in
					Task {
						do {
							let libraryUpdateResponse = try await KService.removeFromLibrary(self.libraryKind, modelID: modelID).value

							switch self.libraryKind {
							case .shows:
								guard let show = self.show else { return }
								show.attributes.update(using: libraryUpdateResponse.data)
								self.updateLibraryActions(using: show, animated: true)
							case .literatures:
								guard let literature = self.literature else { return }
								literature.attributes.update(using: libraryUpdateResponse.data)
								self.updateLibraryActions(using: literature, animated: true)
							}

							// Update edntry in library
							self.libraryStatus = .none

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						} catch let error as KKAPIError {
//							self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
							print("----- Remove from library failed", error.message)
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
		self.show?.toggleFavorite()
		self.literature?.toggleFavorite()
	}

	@IBAction func raminderButtonPressed(_ sender: UIButton) {
		self.show?.toggleReminder()
//		self.literature?.toggleReminder()
	}
}
