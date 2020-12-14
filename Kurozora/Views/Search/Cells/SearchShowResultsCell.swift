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
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var showRatingLabel: UILabel!
	@IBOutlet weak var episodeCountLabel: UILabel!
	@IBOutlet weak var airDateLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	var show: Show! {
		didSet {
			configureCell()
		}
	}
	var libraryStatus: KKLibrary.Status = .none

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		primaryLabel.text = self.show.attributes.title

		searchImageView.image = self.show.attributes.posterImage

		statusLabel.text = show.attributes.airStatus

		// Configure library status
		if let libraryStatus = self.show.attributes.libraryStatus {
			self.libraryStatus = libraryStatus
		}
		actionButton?.setTitle(self.libraryStatus != .none ? "\(self.libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)

		// Cinfigure rating
		showRatingLabel.text = show.attributes.watchRating
		showRatingLabel.isHidden = false

		// Configure episode count
		let episodeCount = show.attributes.episodeCount
		episodeCountLabel.text = "\(episodeCount) \(episodeCount >= 1 ? "Episode" : "Episodes")"
		episodeCountLabel.isHidden = episodeCount == 0

		// Configure air date
		if let airYear = show.attributes.airYear {
			airDateLabel.text = "\(airYear)"
			airDateLabel.isHidden = false
		} else {
			airDateLabel.isHidden = true
		}

		// Configure score
		let score = show.attributes.averageRating
		cosmosView.rating = score
		scoreLabel.text = "\(score)"
		cosmosView.isHidden = score == 0
		scoreLabel.isHidden = score == 0
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		super.actionButtonPressed(sender)

		WorkflowController.shared.isSignedIn {
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: self.libraryStatus, action: { [weak self] (title, value)  in
				guard let self = self else { return }
				if self.libraryStatus != value {
					KService.addToLibrary(withLibraryStatus: value, showID: self.show.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success:
							// Update entry in library
							self.libraryStatus = value

							let libraryUpdateNotificationName = Notification.Name("Update\(value.sectionValue)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

							self.actionButton?.setTitle("\(title) ▾", for: .normal)
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
							self.actionButton?.setTitle("ADD", for: .normal)
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
}
