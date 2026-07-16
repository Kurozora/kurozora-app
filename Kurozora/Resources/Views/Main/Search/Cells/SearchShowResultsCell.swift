//
//  SearchShowResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SearchShowResultsCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var actionButton: KTintedButton!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var separatorView: SeparatorView!

	@IBOutlet weak var statusLabel: KSecondaryLabel!
	@IBOutlet weak var showRatingLabel: KSecondaryLabel!
	@IBOutlet weak var episodeCountLabel: KSecondaryLabel!
	@IBOutlet weak var airDateLabel: KSecondaryLabel!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var cosmosView: KCosmosView!

	// MARK: - Properties
	var libraryKind: LibraryKind = .shows
	var libraryStatus: LibraryStatus = .none

	// MARK: - Functions
	func configure(using show: Show?, libraryStatus: LibraryStatus = .none, libraryKind: LibraryKind) {
		guard let show = show else {
			showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure labels
		self.primaryLabel.text = show.attributes.title
		self.secondaryLabel.text = (show.attributes.tagline ?? "").isEmpty ? show.attributes.genres?.localizedJoined() : show.attributes.tagline
		self.statusLabel.text = show.attributes.status.name

		// Configure poster image
		if let posterBackgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		} else {
			self.posterImageView.backgroundColor = .clear
		}
		show.attributes.posterImage(imageView: self.posterImageView)

		// Configure library status — local store wins.
		self.libraryKind = libraryKind
		self.libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: show.id.rawValue, kind: libraryKind)?.status ?? .none
		let libraryStatus: String

		switch self.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
		}

		self.actionButton.setTitle(self.libraryStatus != .none ? "\(libraryStatus.capitalized(with: Locale.current)) ▾" : L10n.add.uppercased(with: Locale.current), for: .normal)

		// Configure rating
		self.showRatingLabel.text = show.attributes.tvRating.name
		self.showRatingLabel.isHidden = false

		// Configure episode count
		let episodeCount = show.attributes.episodeCount
		self.episodeCountLabel.text = "\(episodeCount) \(episodeCount == 1 ? L10n.episode : L10n.episodes)"
		self.episodeCountLabel.isHidden = episodeCount == 0

		// Configure air date
		if let airYear = show.attributes.startedAt?.components.year {
			self.airDateLabel.text = "\(airYear)"
			self.airDateLabel.isHidden = false
		} else {
			self.airDateLabel.isHidden = true
		}

		// Configure score
		let ratingAverage = show.attributes.stats?.ratingAverage ?? 0.0
		self.cosmosView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"
		self.cosmosView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
	}
}
