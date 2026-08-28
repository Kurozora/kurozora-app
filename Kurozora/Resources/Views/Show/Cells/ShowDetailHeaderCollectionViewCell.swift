//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class GameDetailHeaderCollectionViewCell: ShowDetailHeaderCollectionViewCell {}

class LiteratureDetailHeaderCollectionViewCell: ShowDetailHeaderCollectionViewCell {}

class ShowDetailHeaderCollectionViewCell: BaseDetailHeaderCollectionViewCell {
	// MARK: - IBOutlet
	// Action buttons
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var libraryStatusButton: KTintedButton!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var posterImageOverlayView: UIImageView!

	// MARK: - Views
	/// The view that auto-plays the show's trailer over the banner.
	private let trailerPlayerView: KTrailerPlayerView = {
		let trailerPlayerView = KTrailerPlayerView()
		// Sound and fullscreen live in the navigation bar on this screen.
		trailerPlayerView.showsSecondaryControls = false
		trailerPlayerView.reportsNowPlaying = true
		trailerPlayerView.translatesAutoresizingMaskIntoConstraints = false
		return trailerPlayerView
	}()

	// MARK: - Properties
	var libraryStatus: LibraryStatus = .none
	var libraryKind: LibraryKind = .shows

	lazy var literatureMask: UIImageView = {
		let maskView = UIImageView(image: .bookMask)
		return maskView
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	var show: Show?
	var literature: Literature?
	var game: Game?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.statusButton.layerCornerRadius = 6.0
		self.favoriteButton.layerCornerRadius = 15.0
		self.reminderButton.layerCornerRadius = 15.0

		self.posterImageOverlayView.isUserInteractionEnabled = false
		self.posterBoundsObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
			self?.syncLiteratureMaskFrame()
		}

		self.configureTrailerPlayerView()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.trailerPlayerView.stopTrailer()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.syncLiteratureMaskFrame()
	}

	/// Pins the trailer player view on top of the banner image view.
	private func configureTrailerPlayerView() {
		guard let bannerSuperview = self.bannerImageView.superview else { return }
		bannerSuperview.insertSubview(self.trailerPlayerView, aboveSubview: self.bannerImageView)

		NSLayoutConstraint.activate([
			self.trailerPlayerView.topAnchor.constraint(equalTo: self.bannerImageView.topAnchor),
			self.trailerPlayerView.leadingAnchor.constraint(equalTo: self.bannerImageView.leadingAnchor),
			self.trailerPlayerView.trailingAnchor.constraint(equalTo: self.bannerImageView.trailingAnchor),
			self.trailerPlayerView.bottomAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor)
		])
	}
}

// MARK: - Functions
extension ShowDetailHeaderCollectionViewCell {
	/// The shared settings used to initialize the cell.
	private func sharedConfiguration() {
		// Configure shadows
		self.shadowView.applyShadow()
		self.reminderButton.applyShadow()
		self.favoriteButton.applyShadow()
	}

	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - show: The `Show` object used to configure the cell.
	func configure(using show: Show) {
		self.libraryKind = .shows
		self.literature = nil
		self.show = show

		self.sharedConfiguration()

		// Configure library status
		self.updateLibraryActions(using: show)

		// Configure title label
		self.primaryLabel.text = show.attributes.title

		// Configure tags label
		self.secondaryLabel.text = show.attributes.informationString

		// Configure airing status label
		self.statusButton.setTitle(show.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: show.attributes.status.color)

		// Configure rank button
		let rank = show.attributes.stats?.rankTotal ?? 0
		let rankLabel = rank > 0 ? "Rank #\(rank)" : "Rank -"
		self.rankButton?.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		show.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(22.0)
		self.posterImageView.layer.borderWidth = 0
		self.posterImageView.mask = nil
		self.posterImageOverlayView.isHidden = true
		self.posterBorderView?.isHidden = false
		self.posterBorderView?.cornerRadius = 22.0

		self.visualEffectView.layerCornerRadius = 30.0

		// Configure banner view
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure trailer
		self.trailerPlayerView.streamMetadata = TrailerStreamMetadata(title: show.attributes.title, synopsis: show.attributes.synopsis, artworkURL: show.attributes.poster?.url)
		self.trailerPlayerView.loadTrailer(fromURL: show.attributes.videoUrl)
		self.trailerPlayerView.shareHandler = { sourceView in
			show.openShareSheet(sourceView: sourceView, barButtonItem: nil)
		}

		// Display details
		self.quickDetailsView.isHidden = false
	}

	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - literature: The `Literature` object used to configure the cell.
	func configure(using literature: Literature) {
		self.libraryKind = .literatures
		self.show = nil
		self.literature = literature

		self.sharedConfiguration()

		// Configure library status, overlay-first via `updateLibraryActions`.
		self.libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: literature.id.rawValue, kind: .literatures)?.status ?? .none
		self.updateLibraryActions(using: literature)

		// Configure title label
		self.primaryLabel.text = literature.attributes.title

		// Configure tags label
		self.secondaryLabel.text = literature.attributes.informationString

		// Configure publishing status label
		self.statusButton.setTitle(literature.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: literature.attributes.status.color)

		// Configure rank button
		let rank = literature.attributes.stats?.rankTotal ?? 0
		let rankLabel = rank > 0 ? "Rank #\(rank)" : "Rank -"
		self.rankButton?.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		literature.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(0.0)
		self.posterImageView.layer.borderWidth = 0
		self.literatureMask.frame = self.posterImageView.bounds
		self.posterImageView.mask = self.literatureMask
		self.posterImageOverlayView.isHidden = false
		self.posterBorderView?.isHidden = true

		self.visualEffectView.layerCornerRadius = 10.0

		// Configure banner view
		if let bannerBackgroundColor = literature.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		literature.attributes.bannerImage(imageView: self.bannerImageView)

		self.trailerPlayerView.stopTrailer()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - game: The `Game` object used to configure the cell.
	func configure(using game: Game) {
		self.libraryKind = .games
		self.show = nil
		self.game = game

		self.sharedConfiguration()

		// Configure library status, overlay-first via `updateLibraryActions`.
		self.libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: game.id.rawValue, kind: .games)?.status ?? .none
		self.updateLibraryActions(using: game)

		// Configure title label
		self.primaryLabel.text = game.attributes.title

		// Configure tags label
		self.secondaryLabel.text = game.attributes.informationString

		// Configure publishing status label
		self.statusButton.setTitle(game.attributes.status.name, for: .normal)
		self.statusButton.backgroundColor = UIColor(hexString: game.attributes.status.color)

		// Configure rank button
		let rank = game.attributes.stats?.rankTotal ?? 0
		let rankLabel = rank > 0 ? "Rank #\(rank)" : "Rank -"
		self.rankButton?.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = game.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		game.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(22.0)
		self.posterImageView.layer.borderWidth = 0
		self.posterImageView.mask = nil
		self.posterImageOverlayView.isHidden = true
		self.posterBorderView?.isHidden = false
		self.posterBorderView?.cornerRadius = 22.0

		self.visualEffectView.layerCornerRadius = 30.0

		// Configure banner view
		if let bannerBackgroundColor = game.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		game.attributes.bannerImage(imageView: self.bannerImageView)

		self.trailerPlayerView.stopTrailer()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	func updateLibraryStatus(_ libraryStatus: LibraryStatus?) {
		let libraryStatus = libraryStatus ?? .none
		self.libraryStatus = libraryStatus

		let libraryStatusString: String

		switch self.libraryKind {
		case .shows:
			libraryStatusString = libraryStatus.showStringValue
		case .literatures:
			libraryStatusString = libraryStatus.literatureStringValue
		case .games:
			libraryStatusString = libraryStatus.gameStringValue
		}

		self.libraryStatusButton.setTitle(libraryStatus != .none ? "\(libraryStatusString.capitalized(with: Locale.current)) ▾" : L10n.add.uppercased(with: Locale.current), for: .normal)
	}

	/// Updates the `favoriteButton` appearance with the favorite status of the show.
	///
	/// - Parameters:
	///    - favoriteStatus: The favorite status of the show.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateFavoriteStatus(_ favoriteStatus: FavoriteStatus?, animated: Bool = false) {
		let favoriteStatus = favoriteStatus ?? .disabled

		if self.libraryStatus == .none || favoriteStatus == .disabled {
			self.favoriteButton.isHidden = true
			self.favoriteButton.isUserInteractionEnabled = false
		} else {
			self.favoriteButton.isHidden = false
			self.favoriteButton.isUserInteractionEnabled = true

			self.favoriteButton.setImage(favoriteStatus.imageValue, for: .normal)

			if animated {
				self.favoriteButton.animateBounce()
			}
		}
	}

	/// Updates the `reminderButton` appearance with the reminder status of the show.
	///
	/// - Parameters:
	///    - reminderStatus: The reminder status of the show.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateReminderStatus(_ reminderStatus: ReminderStatus?, animated: Bool = false) {
		let reminderStatus = reminderStatus ?? .disabled

		if self.libraryStatus == .none || reminderStatus == .disabled {
			self.reminderButton.isHidden = true
			self.reminderButton.isUserInteractionEnabled = false
		} else {
			self.reminderButton.isHidden = false
			self.reminderButton.isUserInteractionEnabled = true

			self.reminderButton.setImage(reminderStatus.imageValue, for: .normal)

			if animated {
				self.reminderButton.animateBounce()
			}
		}
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the show.
	///
	/// - Parameters:
	///    - show: The show object used to update the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using show: Show, animated: Bool = false) {
		let library = LibraryStore.shared.effectiveLibrary(forTrackableID: show.id.rawValue, kind: .shows)
		self.updateLibraryStatus(library?.status)
		self.updateFavoriteStatus(library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(library?.reminderStatus, animated: animated)
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the literature.
	///
	/// - Parameters:
	///    - literature: The literature object used to update the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using literature: Literature, animated: Bool = false) {
		let library = LibraryStore.shared.effectiveLibrary(forTrackableID: literature.id.rawValue, kind: .literatures)
		self.updateLibraryStatus(library?.status)
		self.updateFavoriteStatus(library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(library?.reminderStatus, animated: animated)
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the game.
	///
	/// - Parameters:
	///    - game: The game object used to update the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using game: Game, animated: Bool = false) {
		let library = LibraryStore.shared.effectiveLibrary(forTrackableID: game.id.rawValue, kind: .games)
		self.updateLibraryStatus(library?.status)
		self.updateFavoriteStatus(library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(library?.reminderStatus, animated: animated)
	}

	fileprivate func syncLiteratureMaskFrame() {
    	guard self.posterImageView?.mask === self.literatureMask else { return }
    	self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
	}
}

// MARK: - IBActions
extension ShowDetailHeaderCollectionViewCell {
	@IBAction func favoriteButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.show?.toggleFavorite()
			await self.literature?.toggleFavorite()
			await self.game?.toggleFavorite()
		}
	}

	@IBAction func reminderButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.show?.toggleReminder()
//			await self.literature?.toggleReminder(on: self)
//			await self.game?.toggleReminder(on: self)
		}
	}
}
