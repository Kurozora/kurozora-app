//
//  EpisodeDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/12/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodeDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBoutlet
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var visualEffectView: KVisualEffectView!
	@IBOutlet weak var bannerContainerView: UIView!

	// Action buttons
	@IBOutlet weak var watchStatusButton: KTintedButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!

	// MARK: - Properties
	var episode: Episode! {
		didSet {
			self.configureCell()
		}
	}
	var indexPath: IndexPath = IndexPath()
}

// MARK: - Functions
extension EpisodeDetailHeaderCollectionViewCell {
	/// Configures the cell with the given details.
	fileprivate func configureCell() {
		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleWatchStatusUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)

		// Configure watch status button
		self.configureWatchButton(with: self.episode.attributes.watchStatus)

		// Configure title label
		self.primaryLabel.text = self.episode.attributes.title

		// Configure poster view
		if let posterBackgroundColor = self.episode.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		self.episode.attributes.posterImage(imageView: self.posterImageView)

		// Configure banner view
		if let bannerBackgroundColor = self.episode.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		self.episode.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure shadows
		self.shadowView.applyShadow()

		// Display details
		self.quickDetailsView.isHidden = false
	}

	/// Update the watch status of the episode.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleWatchStatusUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureWatchButton(with: self.episode.attributes.watchStatus)
		}
	}

	/// Configures the watch status button of the episode.
	///
	/// - Parameter watchStatus: The WatchStatus object used to configure the button.
	func configureWatchButton(with watchStatus: WatchStatus?) {
		let watchStatusButtonTitle = self.episode.attributes.watchStatus == .watched ? "✓ \(Trans.watched)" : Trans.markAsWatched
		self.watchStatusButton.setTitle(watchStatusButtonTitle, for: .normal)
	}
}

// MARK: - IBActions
extension EpisodeDetailHeaderCollectionViewCell {
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			Task {
				await self.episode.updateWatchStatus(userInfo: ["indexPath": self.indexPath])
			}
		}
	}
}
