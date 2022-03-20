//
//  EpisodeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

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
	var episodeDataRequest: DataRequest?

	// MARK: - Initializers
	deinit {
		self.episodeDataRequest?.cancel()
		self.episodeDataRequest = nil
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.episodeDataRequest?.cancel()
		self.episodeDataRequest = nil
		self.prepareSkeleton()
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using episode: Episode?) {
		guard let episode = episode else {
			self.prepareSkeleton()
			return
		}
		self.backgroundColor = nil
		self.contentView.isHidden = false

		self.episodeImageView.setImage(with: episode.attributes.banner?.url ?? "", placeholder: R.image.placeholders.episodeBanner()!)

		// Configure watch status
		self.configureWatchButton(with: episode.attributes.watchStatus)

		// Configure cosmos view
		let userRating = episode.attributes.givenRating
		self.cosmosView.rating = userRating ?? 0.0

		// Configure episode number label
		let episodeNumber = episode.attributes.numberTotal
		self.episodeNumberLabel.text = "Episode \(episodeNumber)"

		// Configure episode title label
		self.episodeTitleLabel.text = episode.attributes.title
		self.episodeFirstAiredLabel.text = episode.attributes.firstAired?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"

		// Round corners
		self.cornerView.cornerRadius = 10

		// Apply shadow
		self.shadowView.applyShadow()
	}

	fileprivate func prepareSkeleton() {
		self.roundCorners(.allCorners, radius: 10.0)
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.isHidden = true
	}

	/**
		Configures the watch button of the episode.

		- Parameter watchStatus: The WatchStatus object used to configure the button.
	*/
	func configureWatchButton(with watchStatus: WatchStatus?) {
		switch watchStatus ?? .disabled {
		case .disabled:
			self.episodeWatchedButton.isEnabled = false
			self.episodeWatchedButton.isHidden = true
		case .watched:
			self.episodeWatchedButton.isEnabled = true
			self.episodeWatchedButton.isHidden = false
			self.episodeWatchedButton.backgroundColor = .kurozora
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		case .notWatched:
			self.episodeWatchedButton.isEnabled = true
			self.episodeWatchedButton.isHidden = false
			self.episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
		}
    }

	// MARK: - IBActions
	@IBAction func watchedButtonPressed(_ sender: UIButton) {
		self.delegate?.episodeLockupCollectionViewCell(self, didPressWatchButton: sender)
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.episodeLockupCollectionViewCell(self, didPressMoreButton: sender)
	}
}
