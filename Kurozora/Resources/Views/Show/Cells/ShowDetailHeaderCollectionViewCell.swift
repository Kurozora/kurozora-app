//
//  ShowDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol BaseDetailHeaderCollectionViewCellDelegate: AnyObject {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int)
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async
}

class BaseDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlet
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var visualEffectView: KVisualEffectView!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var rankButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!

	weak var delegate: BaseDetailHeaderCollectionViewCellDelegate?

	// MARK: - Functions
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure visual effect
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.visualEffectView.effect = UIGlassEffect(style: .clear)
		}
		self.visualEffectView.layerCornerRadius = 10.0

		// Configure poster
		self.posterImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPoster))
		self.posterImageView.addGestureRecognizer(posterTap)

		// Configure banner
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapBanner))
		self.bannerImageView.addGestureRecognizer(bannerTap)
	}

	@objc private func didTapBanner(_ sender: UIImageView) {
        #if DEBUG
		self.delegate?.baseDetailHeaderCollectionViewCell(self, didTapImage: sender, at: 1)
        #endif
	}

	@objc private func didTapPoster(_ sender: UIImageView) {
        #if DEBUG
		self.delegate?.baseDetailHeaderCollectionViewCell(self, didTapImage: sender, at: 0)
        #endif
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressStatus: sender)
		}
	}
}

class ShowDetailHeaderCollectionViewCell: BaseDetailHeaderCollectionViewCell {
	// MARK: - IBOutlet
	// Action buttons
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var libraryStatusButton: KTintedButton!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var posterImageOverlayView: UIImageView!

	// MARK: - Properties
	var libraryStatus: KKLibrary.Status = .none
	var libraryKind: KKLibrary.Kind = .shows

	lazy var literatureMask: CALayer = {
		let literatureMask = CALayer()
		literatureMask.contents = UIImage(named: "book_mask")?.cgImage
		literatureMask.frame = self.posterImageView.bounds
		return literatureMask
	}()

	var show: Show?
	var literature: Literature?
	var game: Game?
}

// MARK: - Functions
extension ShowDetailHeaderCollectionViewCell {
	/// The shared settings used to initialize the cell.
	private func sharedConfiguration() {
		// Configure notifications
		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

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
		self.rankButton.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		show.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(10.0)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView.isHidden = true

		// Configure banner view
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.bannerImageView)

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

		// Configure library status
		self.libraryStatus = literature.attributes.library?.status ?? .none
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
		self.rankButton.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		literature.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(0.0)
		self.posterImageView.layer.mask = self.literatureMask
		self.posterImageOverlayView.isHidden = false

		// Configure banner view
		if let bannerBackgroundColor = literature.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		literature.attributes.bannerImage(imageView: self.bannerImageView)

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

		// Configure library status
		self.libraryStatus = game.attributes.library?.status ?? .none
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
		self.rankButton.setTitle(rankLabel, for: .normal)

		// Configure poster view
		if let posterBackgroundColor = game.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		game.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView.applyCornerRadius(18.0)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView.isHidden = true

		// Configure banner view
		if let bannerBackgroundColor = game.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		game.attributes.bannerImage(imageView: self.bannerImageView)

		// Display details
		self.quickDetailsView.isHidden = false
	}

	func updateLibraryStatus(_ libraryStatus: KKLibrary.Status?) {
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

		self.libraryStatusButton.setTitle(libraryStatus != .none ? "\(libraryStatusString.capitalized) ▾" : Trans.add.uppercased(), for: .normal)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		guard let favoriteStatus = notification.userInfo?["favoriteStatus"] as? FavoriteStatus else { return }
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateFavoriteStatus(favoriteStatus)
		}
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		guard let reminderStatus = notification.userInfo?["reminderStatus"] as? ReminderStatus else { return }
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateReminderStatus(reminderStatus)
		}
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
		self.updateLibraryStatus(show.attributes.library?.status)
		self.updateFavoriteStatus(show.attributes.library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(show.attributes.library?.reminderStatus, animated: animated)
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the literature.
	///
	/// - Parameters:
	///    - literature: The literature object used to update the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using literature: Literature, animated: Bool = false) {
		self.updateLibraryStatus(literature.attributes.library?.status)
		self.updateFavoriteStatus(literature.attributes.library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(literature.attributes.library?.reminderStatus, animated: animated)
	}

	/// Updates `favoriteButton`, `reminderButton` and `libraryStatusButton` with the attributes of the game.
	///
	/// - Parameters:
	///    - game: The game object used to update the actions.
	///    - animated: A boolean value indicating whether to update changes with animations.
	func updateLibraryActions(using game: Game, animated: Bool = false) {
		self.updateLibraryStatus(game.attributes.library?.status)
		self.updateFavoriteStatus(game.attributes.library?.favoriteStatus, animated: animated)
		self.updateReminderStatus(game.attributes.library?.reminderStatus, animated: animated)
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
