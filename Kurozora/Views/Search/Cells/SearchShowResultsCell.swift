//
//  SearchShowResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Cosmos

class SearchShowResultsCell: SearchBaseResultsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var showRatingLabel: UILabel!
	@IBOutlet weak var episodeCountLabel: UILabel!
	@IBOutlet weak var airDateLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var cosmosView: CosmosView!

	// MARK: - Properties
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			if showDetailsElement != nil {
				configureCell()
			}
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		primaryLabel.text = showDetailsElement.title

		if let posterThumbnail = showDetailsElement.posterThumbnail {
			searchImageView.setImage(with: posterThumbnail, placeholder: R.image.placeholders.showPoster()!)
		}

		statusLabel?.text = showDetailsElement.airStatus ?? "TBA"

		// Configure library status
		if let libraryStatus = showDetailsElement.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			actionButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			actionButton?.setTitle("ADD", for: .normal)
		}

		// Cinfigure rating
		if let watchRating = showDetailsElement.watchRating, !watchRating.isEmpty {
			showRatingLabel?.text = watchRating
			showRatingLabel?.isHidden = false
		} else {
			showRatingLabel?.isHidden = true
		}

		// Configure episode count
		if let episodeCount = showDetailsElement.episodes, episodeCount != 0 {
			episodeCountLabel?.text = "\(episodeCount) \(episodeCount == 1 ? "Episode" : "Episodes")"
			episodeCountLabel?.isHidden = false
		} else {
			episodeCountLabel?.isHidden = true
		}

		// Configure air date
		if let airDate = showDetailsElement.airDate, !airDate.isEmpty {
			airDateLabel?.text = airDate
			airDateLabel?.isHidden = false
		} else {
			airDateLabel?.isHidden = true
		}

		// Configure score
		if let score = showDetailsElement.averageRating, score != 0 {
			cosmosView?.rating = score
			scoreLabel?.text = "\(score)"
			cosmosView?.isHidden = false
			scoreLabel?.isHidden = false
		} else {
			cosmosView?.isHidden = true
			scoreLabel?.isHidden = true
		}
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			guard let libraryStatusString = self.showDetailsElement?.currentUser?.libraryStatus else { return }
			guard let showID = self.showDetailsElement?.id else { return }
			guard let userID = User.current?.id else { return }

			let libraryStatus = KKLibrary.Status.fromString(libraryStatusString)
			let alertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: libraryStatus, action: { (title, value)  in
				if libraryStatus != value {
					KService.addToLibrary(forUserID: userID, withLibraryStatus: value, showID: showID) { result in
						switch result {
						case .success:
							// Update entry in library
							self.showDetailsElement?.currentUser?.libraryStatus = value.stringValue

							let libraryUpdateNotificationName = Notification.Name("Update\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

							self.actionButton?.setTitle("\(title) ▾", for: .normal)
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
							self.showDetailsElement?.currentUser?.libraryStatus = ""
							self.actionButton?.setTitle("ADD", for: .normal)
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
}
