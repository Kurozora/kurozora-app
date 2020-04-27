//
//  EpisodesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Cosmos
import SwipeCellKit

protocol EpisodesCollectionViewCellDelegate: class {
    func episodesCellWatchedButtonPressed(for cell: EpisodesCollectionViewCell)
	func episodesCellMoreButtonPressed(for cell: EpisodesCollectionViewCell)
}

class EpisodesCollectionViewCell: SwipeCollectionViewCell {
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var episodeNumberLabel: UILabel!
	@IBOutlet weak var episodeTitleLabel: UILabel!
	@IBOutlet weak var episodeFirstAiredLabel: UILabel!
	@IBOutlet weak var episodeWatchedButton: UIButton!
	@IBOutlet weak var episodeMoreButton: UIButton!
	@IBOutlet weak var cosmosView: CosmosView!

	weak var episodesDelegate: EpisodesCollectionViewCellDelegate?
	var episodesElement: EpisodeElement? = nil {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
    fileprivate func configureCellWithEpisode(watchStatus: WatchStatus) {
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

	func configureCell(withWatchStatus watchStatus: WatchStatus, shouldUpdate: Bool = false) {
		if watchStatus == .watched {
			self.episodeWatchedButton.tag = 1
			self.episodeWatchedButton.backgroundColor = .kurozora
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		} else {
			self.episodeWatchedButton.tag = 0
			self.episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			self.episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
		}

		if shouldUpdate {
			self.episodesElement?.userDetails?.watchStatus = watchStatus
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let episodesElement = episodesElement else { return }

		if let episodeScreenshot = episodesElement.screenshot {
			self.episodeImageView.setImage(with: episodeScreenshot, placeholder: R.image.placeholders.showEpisode()!)
		}

		if let episodeNumber = episodesElement.number {
			self.episodeNumberLabel.text = "Episode \(episodeNumber)"
		}

		self.episodeTitleLabel.text = episodesElement.name
		self.episodeFirstAiredLabel.text = episodesElement.firstAired

		self.shadowView.applyShadow()

		if let episodeWatchStatus = episodesElement.userDetails?.watchStatus {
			configureCell(withWatchStatus: episodeWatchStatus)
		}
	}

	// MARK: - IBActions
	@IBAction func watchedButtonPressed(_ sender: UIButton) {
		episodesDelegate?.episodesCellWatchedButtonPressed(for: self)
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		episodesDelegate?.episodesCellMoreButtonPressed(for: self)
	}
}

// MARK: - EpisodesDetailTableViewControlleDelegate
extension EpisodesCollectionViewCell: EpisodesDetailTableViewControlleDelegate {
	func updateWatchStatus(with watchStatus: WatchStatus) {
		episodesDelegate?.episodesCellWatchedButtonPressed(for: self)
	}
}
