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
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async
}

class EpisodeLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: BannerImageView!
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

		// Configure view
		self.cornerView.layerCornerRadius = 10

		// Configure image view
		self.episodeImageView.setImage(with: episode.attributes.banner?.url ?? "", placeholder: R.image.placeholders.episodeBanner()!)

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
		let dateText = episode.attributes.startedAt?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"
		self.secondaryLabel.text = "\(viewCountText) · \(dateText)"

		// Configure season button
		self.seasonButton.theme_setTitleColor(KThemePicker.subTextColor.rawValue, forState: .normal)
		self.seasonButton.theme_tintColor = KThemePicker.subTextColor.rawValue
		self.seasonButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
		self.seasonButton.setTitle( "S\(episode.attributes.seasonNumber) · E\(episode.attributes.number) (E\(episode.attributes.numberTotal))", for: .normal)

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
