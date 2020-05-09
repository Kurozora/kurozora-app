//
//  EpisodeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Cosmos

class EpisodeLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var shadowImageview: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var cornerView: UIView!
	@IBOutlet weak var episodeNumberLabel: UILabel!
	@IBOutlet weak var episodeTitleLabel: KLabel!
	@IBOutlet weak var myRatingLabel: KTintedLabel!
	@IBOutlet weak var episodeFirstAiredLabel: UILabel!
	@IBOutlet weak var episodeWatchedButton: KButton!
	@IBOutlet weak var episodeMoreButton: KButton!
	@IBOutlet weak var cosmosView: CosmosView!

	// MARK: - Properties
	var simpleModeEnabled: Bool = false
	var episodeElement: EpisodeElement? = nil {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let episodeElement = episodeElement else { return }

		if let episodeScreenshot = episodeElement.screenshot {
			self.episodeImageView.setImage(with: episodeScreenshot, placeholder: R.image.placeholders.showEpisode()!)
		}

		self.episodeNumberLabel.isHidden = simpleModeEnabled
		self.episodeTitleLabel.isHidden = simpleModeEnabled
		self.myRatingLabel.isHidden = simpleModeEnabled
		self.episodeFirstAiredLabel.isHidden = simpleModeEnabled
		self.cosmosView.isHidden = simpleModeEnabled

		if let episodeWatchStatus = episodeElement.currentUser?.watchStatus {
			configureCell(with: episodeWatchStatus)
		}

		if !simpleModeEnabled {
			self.cornerView.cornerRadius = 10

			if let episodeNumber = episodeElement.number {
				self.episodeNumberLabel.text = "Episode \(episodeNumber)"
			}

			self.episodeTitleLabel.text = episodeElement.name
			self.episodeFirstAiredLabel.text = episodeElement.firstAired

			self.shadowView.applyShadow()
		} else {
			self.cornerView.cornerRadius = 0
			self.shadowImageview.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}

	func configureCell(with watchStatus: WatchStatus) {
        switch watchStatus {
        case .disabled:
            self.episodeWatchedButton.isEnabled = false
			self.episodeWatchedButton.isHidden = true
        case .watched:
            self.episodeWatchedButton.isEnabled = true
			self.episodeWatchedButton.isHidden = false
			self.episodeWatchedButton.tag = 1
			self.episodeWatchedButton.backgroundColor = .kurozora
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .notWatched:
            self.episodeWatchedButton.isEnabled = true
			self.episodeWatchedButton.isHidden = false
			self.episodeWatchedButton.tag = 0
            self.episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
        }
    }

	func configureCell(with watchStatus: WatchStatus, shouldUpdate: Bool = false) {
		configureCell(with: watchStatus)

		if shouldUpdate {
			self.episodeElement?.currentUser?.watchStatus = watchStatus
		}
	}

	/**
		Populate an action sheet for the given episode.
	*/
	func populateActionSheet() {
		let tag = self.episodeWatchedButton.tag
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { _ in
			self.watchedButtonPressed()
		}))
		alertController.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		alertController.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
			self.populateShareSheet()
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.sourceView = self.episodeMoreButton
			popoverController.sourceRect = self.episodeMoreButton.bounds
		}

		if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.parentViewController?.present(alertController, animated: true, completion: nil)
		}
	}

	func populateShareSheet() {
		guard let episodeID = episodeElement?.id else { return }
		var shareText: [String] = ["https://kurozora.app/episode/\(episodeID)\nYou should watch this episode via @KurozoraApp"]

		if let title = episodeElement?.name, !title.isEmpty {
			shareText = ["https://kurozora.app/episode/\(episodeID)\nYou should watch \"\(title)\" via @KurozoraApp"]
		}

		let activityViewController = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.sourceView = episodeMoreButton
			popoverController.sourceRect = episodeMoreButton.bounds
		}

		if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.parentViewController?.present(activityViewController, animated: true, completion: nil)
		}
	}

	func watchedButtonPressed() {
		guard let episodeID = episodeElement?.id else { return }
		let watchStatus: WatchStatus = self.episodeWatchedButton.tag == 0 ? .watched : .notWatched

		KService.updateEpisodeWatchStatus(episodeID, withWatchStatus: watchStatus) { result in
			switch result {
			case .success(let watchStatus):
				DispatchQueue.main.async {
					self.configureCell(with: watchStatus, shouldUpdate: true)
				}
			case .failure: break
			}
		}
	}

	// MARK: - IBActions
	@IBAction func watchedButtonPressed(_ sender: UIButton) {
		self.watchedButtonPressed()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.populateActionSheet()
	}
}
