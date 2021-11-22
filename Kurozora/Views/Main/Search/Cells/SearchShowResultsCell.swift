//
//  SearchShowResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SearchShowResultsCell: SearchBaseResultsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var statusLabel: KSecondaryLabel!
	@IBOutlet weak var showRatingLabel: KSecondaryLabel!
	@IBOutlet weak var episodeCountLabel: KSecondaryLabel!
	@IBOutlet weak var airDateLabel: KSecondaryLabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	var show: Show! {
		didSet {
			self.configureCell()
		}
	}
	var libraryStatus: KKLibrary.Status = .none

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard self.show != nil else { return }

		// Configure labels
		self.primaryLabel.text = self.show.attributes.title
		self.secondaryLabel.text = self.show.attributes.tagline ?? self.show.attributes.genres?.localizedJoined()
		self.statusLabel.text = self.show.attributes.status.name

		// Configure poster image
		if let posterBackroundColor = self.show.attributes.poster?.backgroundColor {
			self.searchImageView.backgroundColor = UIColor(hexString: posterBackroundColor)
		} else {
			self.searchImageView.backgroundColor = .clear
		}
		self.searchImageView.image = self.show.attributes.posterImage

		// Configure library status
		self.libraryStatus = self.show.attributes.libraryStatus ?? .none
		self.actionButton.setTitle(self.libraryStatus != .none ? "\(self.libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)

		// Cinfigure rating
		self.showRatingLabel.text = self.show.attributes.tvRating.name
		self.showRatingLabel.isHidden = false

		// Configure episode count
		let episodeCount = self.show.attributes.episodeCount
		self.episodeCountLabel.text = "\(episodeCount) \(episodeCount >= 1 ? "Episode" : "Episodes")"
		self.episodeCountLabel.isHidden = episodeCount == 0

		// Configure air date
		if let airYear = self.show.attributes.firstAired?.year {
			self.airDateLabel.text = "\(airYear)"
			self.airDateLabel.isHidden = false
		} else {
			self.airDateLabel.isHidden = true
		}

		// Configure score
		let ratingAverage = self.show.attributes.stats?.ratingAverage ?? 0.0
		self.cosmosView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"
		self.cosmosView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			let oldLibraryStatus = self.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { [weak self] (title, value)  in
				guard let self = self else { return }
				if self.libraryStatus != value {
					KService.addToLibrary(withLibraryStatus: value, showID: self.show.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success(let libraryUpdate):
							self.show.attributes.update(using: libraryUpdate)

							// Update entry in library
							self.libraryStatus = value
							self.actionButton.setTitle("\(title) ▾", for: .normal)

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
							self.actionButton.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
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
}
