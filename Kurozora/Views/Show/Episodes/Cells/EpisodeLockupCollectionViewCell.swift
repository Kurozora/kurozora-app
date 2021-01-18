//
//  EpisodeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

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
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	weak var delegate: EpisodeLockupCollectionViewCellDelegate?
	var simpleModeEnabled: Bool = false
	var episode: Episode! {
		didSet {
			self.configureWatchButton()
		}
	}
	var watchStatus: WatchStatus = .disabled

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureWatchButton() {
		if let episodePreviewImage = self.episode.attributes.previewImage {
			self.episodeImageView.setImage(with: episodePreviewImage, placeholder: R.image.placeholders.showEpisode()!)
		}

		self.episodeNumberLabel.isHidden = self.simpleModeEnabled
		self.episodeTitleLabel.isHidden = self.simpleModeEnabled
		self.myRatingLabel.isHidden = self.simpleModeEnabled
		self.episodeFirstAiredLabel.isHidden = self.simpleModeEnabled
		self.cosmosView.isHidden = self.simpleModeEnabled

		if let watchStatus = self.episode.attributes.watchStatus {
			self.watchStatus = watchStatus
		}
		self.configureWatchButton(with: self.watchStatus)

		if !self.simpleModeEnabled {
			self.cornerView.cornerRadius = 10

			let episodeNumber = self.episode.attributes.number
			self.episodeNumberLabel.text = "Episode \(episodeNumber)"

			self.episodeTitleLabel.text = self.episode.attributes.title
			self.episodeFirstAiredLabel.text = self.episode.attributes.firstAired

			self.shadowView.applyShadow()
		} else {
			self.cornerView.cornerRadius = 0
			self.shadowImageview.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}

	func configureWatchButton(with watchStatus: WatchStatus) {
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

	// MARK: - IBActions
	@IBAction func watchedButtonPressed(_ sender: UIButton) {
		self.episode.updateWatchStatus()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.episodeLockupCollectionViewCell(self, didPressMoreButton: sender)
	}
}
