//
//  EpisodeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol EpisodeLockupCollectionViewCellDelegate: AnyObject {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async
}

class EpisodeLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var episodeBorderView: BorderView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var cornerView: UIView!
	@IBOutlet weak var rankLabel: KLabel!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var seasonButton: KButton!
	@IBOutlet weak var showButton: KButton!
	@IBOutlet weak var watchStatusButton: KButton!

	// MARK: - Properties
	weak var delegate: EpisodeLockupCollectionViewCellDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.cornerView.layer.cornerRadius = 22
		self.episodeImageView?.applyCornerRadius(22)
		self.episodeImageView?.layer.borderWidth = 0
		self.episodeBorderView.cornerRadius = 22
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - episode: The `Episode` object used to configure the cell.
	///    - rank: The rank of the episode in a ranked list.
	func configure(using episode: Episode?, rank: Int? = nil) {
		guard let episode = episode else {
			self.showSkeleton()
			return
		}

		// Configure image view
		episode.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure primary label
		self.primaryLabel.text = episode.attributes.title

		// Configure ternary label
		let viewCount = episode.attributes.viewCount
		let viewCountText = viewCount == 1 ? "\(viewCount) view" : "\(viewCount) views"
		let dateText = episode.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) ?? "TBA"
		self.secondaryLabel.text = "\(viewCountText) · \(dateText)"

		// Configure season button
		self.seasonButton.theme_setTitleColor(KThemePicker.subTextColor.rawValue, forState: .normal)
		self.seasonButton.theme_tintColor = KThemePicker.subTextColor.rawValue
		self.seasonButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
		var seasonEpisodeLabel = "S\(episode.attributes.seasonNumber) · E\(episode.attributes.number)"
		if episode.attributes.numberTotal != episode.attributes.number {
			seasonEpisodeLabel += " (E\(episode.attributes.numberTotal))"
		}
		self.seasonButton.setTitle(seasonEpisodeLabel, for: .normal)

		// Configure watch button
		let watchStatusButtonTitle = episode.watchStatus == .watched ? "✓ \(L10n.watched)" : L10n.markAsWatched
		self.watchStatusButton.setTitle(watchStatusButtonTitle, for: .normal)

		// Configure show button
		self.showButton.setTitle(episode.attributes.showTitle, for: .normal)
		self.showButton.titleLabel?.numberOfLines = 0

		self.hideSkeleton()
	}


	// MARK: - IBActions
	@IBAction func showButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.episodeLockupCollectionViewCell(self, didPressShowButton: sender)
		}
	}

	@IBAction func watchStatusButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.episodeLockupCollectionViewCell(self, didPressWatchStatusButton: sender)
		}
	}

	@IBAction func seasonButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.episodeLockupCollectionViewCell(self, didPressSeasonButton: sender)
		}
	}
}
