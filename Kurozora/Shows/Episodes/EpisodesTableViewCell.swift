//
//  EpisodeTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher
import SwipeCellKit

protocol EpisodesTableViewCellDelegate: class {
    func episodesCellWatchedButtonPressed(for cell: EpisodesTableViewCell)
	func episodesCellMoreButtonPressed(for cell: EpisodesTableViewCell)
}

class EpisodesTableViewCell: SwipeTableViewCell {
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var episodeNumberLabel: UILabel!
	@IBOutlet weak var episodeTitleLabel: UILabel!
	@IBOutlet weak var episodeFirstAiredLabel: UILabel!
	@IBOutlet weak var episodeWatchedButton: UIButton!
	@IBOutlet weak var episodeMoreButton: UIButton!
	@IBOutlet weak var cosmosView: CosmosView!

	weak var episodesDelegate: EpisodesTableViewCellDelegate?
	var episodesElement: EpisodesElement? = nil {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
    fileprivate func configureCellWithEpisode(watchStatus: WatchStatus) {
        switch watchStatus {
        case .disabled:
            episodeWatchedButton.isEnabled = false
			episodeWatchedButton.isHidden = true
        case .watched:
            episodeWatchedButton.isEnabled = true
			episodeWatchedButton.isHidden = false
			episodeWatchedButton.tag = 1
			episodeWatchedButton.backgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
			episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .notWatched:
            episodeWatchedButton.isEnabled = true
			episodeWatchedButton.isHidden = false
			episodeWatchedButton.tag = 0
            episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
        }
    }

	func configureCell(with watchStatus: Bool, shouldUpdate: Bool = false, withValue: Bool = false) {
		if watchStatus {
			episodeWatchedButton.tag = 1
			episodeWatchedButton.backgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
			episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		} else {
			episodeWatchedButton.tag = 0
			episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
		}

		if shouldUpdate {
			episodesElement?.userDetails?.watched = withValue
		}
	}

	fileprivate func configureCell() {
		guard let episodesElement = episodesElement else { return }

		if let episodeScreenshot = episodesElement.screenshot, episodeScreenshot != "" {
			let episodeScreenshotUrl = URL(string: episodeScreenshot)
			let resource = ImageResource(downloadURL: episodeScreenshotUrl!)

			episodeImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_episode"), options: [.transition(.fade(0.2))])
		} else {
			episodeImageView.image = #imageLiteral(resourceName: "placeholder_episode")
		}

		if let episodeNumber = episodesElement.number {
			episodeNumberLabel.text = "Episode \(episodeNumber)"
		}

		episodeTitleLabel.text = episodesElement.name
		episodeFirstAiredLabel.text = episodesElement.firstAired

		shadowView.applyShadow(shadowPathSize: CGSize(width: episodeImageView.width, height: episodeImageView.height))
		if let episodeWatched = episodesElement.userDetails?.watched {
			configureCell(with: episodeWatched)
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

extension EpisodesTableViewCell: EpisodesDetailTableViewControlleDelegate {
	func updateWatchedStatus(with watchStatus: Bool) {
		episodesDelegate?.episodesCellWatchedButtonPressed(for: self)
	}
}