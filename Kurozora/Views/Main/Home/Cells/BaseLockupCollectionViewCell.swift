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
	func chooseStatusButtonPressed(_ sender: UIButton, on cell: BaseLockupCollectionViewCell)
	func reminderButtonPressed(on cell: BaseLockupCollectionViewCell)
}

class BaseLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel?
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var libraryStatusButton: KTintedButton?

	// MARK: - Properties
	var showDetailsCollectionViewController: ShowDetailsCollectionViewController?
	var libraryStatus: KKLibrary.Status = .none
	weak var baseLockupCollectionViewCellDelegate: BaseLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(with show: Show) {
		// Configure title
		self.primaryLabel?.text = show.attributes.title

		// Configure genres
		self.secondaryLabel?.text = show.attributes.tagline ?? show.attributes.genres?.localizedJoined()

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
		self.libraryStatus = show.attributes.libraryStatus ?? .none
		self.libraryStatusButton?.setTitle(self.libraryStatus != .none ? "\(self.libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)
	}

	/**
		Configures the cell with the given `Genre` obejct.

		- Parameter genre: The `Genre` object used to configure the cell.
	*/
	func configureCell(with genre: Genre) {}

	/**
		Configures the cell with the given `Theme` obejct.

		- Parameter theme: The `Theme` object used to configure the cell.
	*/
	func configureCell(with theme: Theme) {}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		self.baseLockupCollectionViewCellDelegate?.chooseStatusButtonPressed(sender, on: self)
	}
}
