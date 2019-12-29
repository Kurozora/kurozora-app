//
//  ExploreBaseCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreBaseCollectionViewCell: UICollectionViewCell {
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
	var showDetailViewController: ShowDetailViewController?
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
			self.bannerImageView?.setImage(with: bannerThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
		}

		// Configure poster
		if let posterThumbnail = showDetailsElement.posterThumbnail {
			self.posterImageView?.setImage(with: posterThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
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
			let action = UIAlertController.actionSheetWithItems(items: Library.Section.alertControllerItems, currentSelection: self.libraryStatus, action: { (title, value)  in
				guard let showID = self.showDetailsElement?.id else {return}

				KService.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
					if success {
						// Update entry in library
						self.libraryStatus = value
						self.showDetailsElement?.currentUser?.libraryStatus = value

						let libraryUpdateNotificationName = Notification.Name("Update\(value)Section")
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

// MARK: - UIViewControllerPreviewingDelegate
#if !targetEnvironment(macCatalyst)
extension ExploreBaseCollectionViewCell: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		showDetailViewController = ShowDetailViewController.instantiateFromStoryboard() as? ShowDetailViewController
		showDetailViewController?.exploreBaseCollectionViewCell = self
		showDetailViewController?.showDetailsElement = showDetailsElement

		previewingContext.sourceRect = previewingContext.sourceView.bounds

		return showDetailViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		if let showDetailViewController = showDetailViewController {
			self.parentViewController?.show(showDetailViewController, sender: nil)
		}
	}
}
#endif
