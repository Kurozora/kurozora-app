//
//  EpisodeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol EpisodeLockupCollectionViewCellDelegate: AnyObject {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton)
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton)
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton)
}

class EpisodeLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var cornerView: UIView!
	@IBOutlet weak var rankLabel: UILabel!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var ternaryLabel: KSecondaryLabel!
	@IBOutlet weak var showButton: KButton!
	@IBOutlet weak var watchStatusButton: KButton!

	// MARK: - Properties
	weak var delegate: EpisodeLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using episode: Episode?, rank: Int? = nil) {
		guard let episode = episode else {
			self.showSkeleton()
			return
		}

		// Configure view
		self.cornerView.layerCornerRadius = 10

		// Configure image view
		self.episodeImageView.setImage(with: episode.attributes.banner?.url ?? "", placeholder: R.image.placeholders.episodeBanner()!)

		// Confgiure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
		}

		// Configure secondary label
		self.secondaryLabel.text = "S\(episode.attributes.seasonNumber) · E\(episode.attributes.number)"

		// Configure primary label
		self.primaryLabel.text = episode.attributes.title

		// Configure ternary label
		let viewCount = episode.attributes.viewCount
		let viewCountText = viewCount == 1 ? "\(viewCount) view" : "\(viewCount) views"
		let dateText = episode.attributes.startedAt?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"
		self.ternaryLabel.text = "\(viewCountText) · \(dateText)"

		// Configure watch button
		let watchStatusButtonTitle = episode.attributes.watchStatus == .watched ? "✓ \(Trans.watched)" : Trans.markAsWatched
		self.watchStatusButton.setTitle(watchStatusButtonTitle, for: .normal)

		// Configure show button
		self.showButton.setTitle(episode.attributes.showTitle, for: .normal)
		self.showButton.titleLabel?.numberOfLines = 0

		self.hideSkeleton()
	}

	// MARK: - IBActions
	@IBAction func showButtonPressed(_ sender: UIButton) {
		self.delegate?.episodeLockupCollectionViewCell(self, didPressShowButton: sender)
	}

	@IBAction func watchStatusButtonPressed(_ sender: UIButton) {
		self.delegate?.episodeLockupCollectionViewCell(self, didPressWatchStatusButton: sender)
	}
}
