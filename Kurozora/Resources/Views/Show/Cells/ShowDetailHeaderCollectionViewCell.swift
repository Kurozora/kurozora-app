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

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.statusButton.layerCornerRadius = 6.0
			self.favoriteButton.layerCornerRadius = 15.0
			self.reminderButton.layerCornerRadius = 15.0

			self.posterImageOverlayView.isUserInteractionEnabled = false
			self.posterBoundsObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
				MainActor.assumeIsolated {
					self?.syncLiteratureMaskFrame()
				}
			}

			self.configureTrailerPlayerView()
		}
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
	///    - configuration: The values the header presents.
	///    - libraryAttributes: The user's library state for the presented item.
	func configure(using configuration: DetailHeaderConfiguration, libraryAttributes: LibraryAttributes?) {
		self.libraryKind = configuration.libraryKind

		self.sharedConfiguration()
		self.updateLibraryActions(using: libraryAttributes)

		self.primaryLabel.text = configuration.title
		self.secondaryLabel.text = configuration.tags

		self.statusButton.setTitle(configuration.statusName, for: .normal)
		self.statusButton.backgroundColor = configuration.statusColorHex.flatMap { UIColor(hexString: $0) } ?? .secondarySystemFill
		self.statusButton.isHidden = configuration.statusName?.isEmpty ?? true

		let rankLabel = configuration.rank > 0 ? "Rank #\(configuration.rank)" : "Rank -"
		self.rankButton?.setTitle(rankLabel, for: .normal)

		self.configurePoster(using: configuration)
		self.configureBanner(using: configuration)
		self.configureTrailer(using: configuration)

		self.quickDetailsView.isHidden = false
	}

	/// Applies the poster and the styling its kind calls for.
	///
	/// - Parameter configuration: The values the header presents.
	private func configurePoster(using configuration: DetailHeaderConfiguration) {
		if let posterBackgroundColor = configuration.posterBackgroundColorHex.flatMap({ UIColor(hexString: $0) }) {
			self.posterImageView.backgroundColor = posterBackgroundColor
		} else {
			self.posterImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		self.posterImageView.setLibraryImage(with: configuration.posterURLString, placeholder: .Placeholders.showPoster)
		self.posterImageView.layer.borderWidth = 0

		switch configuration.libraryKind {
		case .literatures:
			self.posterImageView.applyCornerRadius(0.0)
			self.literatureMask.frame = self.posterImageView.bounds
			self.posterImageView.mask = self.literatureMask
			self.posterImageOverlayView.isHidden = false
			self.posterBorderView?.isHidden = true
			self.visualEffectView.layerCornerRadius = 10.0
		case .shows, .games:
			self.posterImageView.applyCornerRadius(22.0)
			self.posterImageView.mask = nil
			self.posterImageOverlayView.isHidden = true
			self.posterBorderView?.isHidden = false
			self.posterBorderView?.cornerRadius = 22.0
			self.visualEffectView.layerCornerRadius = 30.0
		}
	}

	/// Applies the banner.
	///
	/// - Parameter configuration: The values the header presents.
	private func configureBanner(using configuration: DetailHeaderConfiguration) {
		if let bannerBackgroundColor = configuration.bannerBackgroundColorHex.flatMap({ UIColor(hexString: $0) }) {
			self.bannerImageView.backgroundColor = bannerBackgroundColor
		} else {
			self.bannerImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		self.bannerImageView.setLibraryImage(with: configuration.bannerURLString, placeholder: .Placeholders.showBanner)
	}

	/// Starts the trailer the configuration carries.
	///
	/// - Parameter configuration: The values the header presents.
	private func configureTrailer(using configuration: DetailHeaderConfiguration) {
		guard let trailerURLString = configuration.trailerURLString, !trailerURLString.isEmpty else {
			self.trailerPlayerView.stopTrailer()
			return
		}

		self.trailerPlayerView.streamMetadata = TrailerStreamMetadata(title: configuration.title, synopsis: configuration.synopsis, artworkURL: configuration.posterURLString)
		self.trailerPlayerView.loadTrailer(fromURL: trailerURLString)
		self.trailerPlayerView.shareHandler = { [weak self] sourceView in
			guard let self = self else { return }
			self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressShare: sourceView)
		}
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

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the given library state.
	///
	/// - Parameters:
	///    - libraryAttributes: The user's library state for the presented item.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using libraryAttributes: LibraryAttributes?, animated: Bool = false) {
		self.updateLibraryStatus(libraryAttributes?.status)
		self.updateFavoriteStatus(libraryAttributes?.favoriteStatus, animated: animated)

		// The server accepts reminders on shows only.
		let reminderStatus = self.libraryKind == .shows ? libraryAttributes?.reminderStatus : .disabled
		self.updateReminderStatus(reminderStatus, animated: animated)
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
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressFavorite: sender)
		}
	}

	@IBAction func reminderButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressReminder: sender)
		}
	}
}
