//
//  BaseLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel?
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var shadowView: UIView?
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var libraryStatusButton: UIButton? {
		didSet {
			libraryStatusButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
			libraryStatusButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	// MARK: - Properties
	var showDetailCollectionViewController: ShowDetailCollectionViewController?
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

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let showDetailsElement = showDetailsElement else { return }

		self.primaryLabel?.text = showDetailsElement.title

		// Configure genres
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

		// Configure banner
		if let bannerThumbnail = showDetailsElement.banner {
			self.bannerImageView?.setImage(with: bannerThumbnail, placeholder: R.image.placeholders.show_banner_image()!)
		}

		// Configure poster
		if let posterThumbnail = showDetailsElement.posterThumbnail {
			self.posterImageView?.setImage(with: posterThumbnail, placeholder: R.image.placeholders.show_poster_image()!)
		}

		// Configure library status
		self.libraryStatus = showDetailsElement.currentUser?.libraryStatus
		if let libraryStatus = showDetailsElement.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			self.libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			self.libraryStatusButton?.setTitle("ADD", for: .normal)
		}

		// Add shadow
		shadowView?.applyShadow()
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let libraryStatusString = self.libraryStatus else { return }
			guard let showID = self.showDetailsElement?.id else { return }
			guard let userID = User.current?.id else { return }

			let libraryStatus = KKLibrary.Status.fromString(libraryStatusString)
			let action = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: libraryStatus, action: { (title, value)  in
				guard let showID = self.showDetailsElement?.id else {return}

				KService.addToLibrary(forUserID: userID, withLibraryStatus: value, showID: showID) { result in
					switch result {
					case .success:
						// Update entry in library
						self.libraryStatus = value.stringValue
						self.showDetailsElement?.currentUser?.libraryStatus = value.sectionValue

						let libraryUpdateNotificationName = Notification.Name("Update\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

						self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
					case .failure:
						break
					}
				}
			})

			if !libraryStatusString.isEmpty {
				action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
					KService.removeFromLibrary(forUserID: userID, showID: showID) { result in
						switch result {
						case .success:
							self.libraryStatus = ""
							self.libraryStatusButton?.setTitle("ADD", for: .normal)
						case .failure:
							break
						}
					}
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

// MARK: - UIViewControllerPreviewingDelegate
#if !targetEnvironment(macCatalyst)
extension BaseLockupCollectionViewCell: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		showDetailCollectionViewController = R.storyboard.showDetails.showDetailCollectionViewController()
		showDetailCollectionViewController?.showDetailsElement = showDetailsElement

		previewingContext.sourceRect = previewingContext.sourceView.bounds

		return showDetailCollectionViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		if let showDetailCollectionViewController = showDetailCollectionViewController {
			self.parentViewController?.show(showDetailCollectionViewController, sender: nil)
		}
	}
}
#endif
