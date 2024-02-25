//
//  BaseLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol BaseLockupCollectionViewCellDelegate: AnyObject {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton)
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton)
}

class BaseLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel?
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var ternaryLabel: UILabel?
	@IBOutlet weak var bannerImageView: BannerImageView?
	@IBOutlet weak var posterImageView: PosterImageView?
	@IBOutlet weak var shadowImageView: UIImageView?
	@IBOutlet weak var libraryStatusButton: KTintedButton?

	// MARK: - Properties
	var showDetailsCollectionViewController: ShowDetailsCollectionViewController?
	var libraryStatus: KKLibrary.Status = .none
	var libraryKind: KKLibrary.Kind = .shows
	weak var delegate: BaseLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the `Show` object.
	///
	/// - Parameter show: The `Show` object used to configure the cell.
	func configure(using show: Show?) {
		self.libraryKind = .shows
		guard let show = show else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		// Configure title
		self.primaryLabel?.text = show.attributes.title

		// Configure genres
		self.secondaryLabel?.text = (show.attributes.tagline ?? "").isEmpty ? show.attributes.genres?.localizedJoined() : show.attributes.tagline

		// Configure banner
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor {
			self.bannerImageView?.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		if self.bannerImageView != nil {
			show.attributes.bannerImage(imageView: self.bannerImageView!)
		}

		// Configure poster
		if let posterBackgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView?.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		if self.posterImageView != nil {
			show.attributes.posterImage(imageView: self.posterImageView!)
		}

		// Configure library status
		self.configureLibraryStatus(with: show.attributes.library?.status ?? .none)
	}

	/// Configure the cell with the `Literature` object.
	///
	/// - Parameter literature: The `Literature` object used to configure the cell.
	func configure(using literature: Literature?) {
		self.libraryKind = .literatures
		guard let literature = literature else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		// Configure title
		self.primaryLabel?.text = literature.attributes.title

		// Configure genres
		self.secondaryLabel?.text = (literature.attributes.tagline ?? "").isEmpty ? literature.attributes.genres?.localizedJoined() : literature.attributes.tagline

		// Configure banner
		if let bannerBackgroundColor = literature.attributes.banner?.backgroundColor {
			self.bannerImageView?.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		if self.bannerImageView != nil {
			literature.attributes.bannerImage(imageView: self.bannerImageView!)
		}

		// Configure poster
		if let posterBackgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView?.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		if self.posterImageView != nil {
			literature.attributes.posterImage(imageView: self.posterImageView!)
		}

		// Configure library status
		self.configureLibraryStatus(with: literature.attributes.library?.status ?? .none)
	}

	/// Configure the cell with the `Game` object.
	///
	/// - Parameter game: The `Game` object used to configure the cell.
	func configure(using game: Game?) {
		self.libraryKind = .games
		guard let game = game else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		// Configure title
		self.primaryLabel?.text = game.attributes.title

		// Configure genres
		self.secondaryLabel?.text = (game.attributes.tagline ?? "").isEmpty ? game.attributes.genres?.localizedJoined() : game.attributes.tagline

		// Configure banner
		if let bannerBackgroundColor = game.attributes.banner?.backgroundColor {
			self.bannerImageView?.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		if self.bannerImageView != nil {
			game.attributes.bannerImage(imageView: self.bannerImageView!)
		}

		// Configure poster
		if let posterBackgroundColor = game.attributes.poster?.backgroundColor {
			self.posterImageView?.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		if self.posterImageView != nil {
			game.attributes.posterImage(imageView: self.posterImageView!)
		}

		// Configure library status
		self.configureLibraryStatus(with: game.attributes.library?.status ?? .none)
	}

	func configureLibraryStatus(with libraryStatus: KKLibrary.Status) {
		self.libraryStatus = libraryStatus

		var libraryStatusString: String
		switch self.libraryKind {
		case .shows:
			libraryStatusString = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatusString = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatusString = self.libraryStatus.gameStringValue
		}

		self.libraryStatusButton?.setTitle(self.libraryStatus != .none ? "\(libraryStatusString.capitalized) ▾" : "ADD", for: .normal)
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		self.delegate?.baseLockupCollectionViewCell(self, didPressStatus: sender)
	}
}
