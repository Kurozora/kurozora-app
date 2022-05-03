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
	@IBOutlet weak var ternaryLabel: UILabel?
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var shadowImageView: UIImageView?
	@IBOutlet weak var libraryStatusButton: KTintedButton?

	// MARK: - Properties
	var showDetailsCollectionViewController: ShowDetailsCollectionViewController?
	var libraryStatus: KKLibrary.Status = .none
	weak var delegate: BaseLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the `Show` object.
	///
	/// - Parameter show: The `Show` object used to configure the cell.
	func configure(using show: Show?) {
		guard let show = show else { return }
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
		self.libraryStatus = show.attributes.libraryStatus ?? .none
		self.libraryStatusButton?.setTitle(self.libraryStatus != .none ? "\(self.libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		self.delegate?.chooseStatusButtonPressed(sender, on: self)
	}
}
