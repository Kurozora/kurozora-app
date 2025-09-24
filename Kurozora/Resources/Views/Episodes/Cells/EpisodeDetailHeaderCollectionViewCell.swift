//
//  EpisodeDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/12/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class EpisodeDetailHeaderCollectionViewCell: BaseDetailHeaderCollectionViewCell {
	// MARK: - IBOutlet
	// Action buttons
	@IBOutlet weak var watchStatusButton: KTintedButton!

	// MARK: - Properties
	private var episode: Episode?

	var indexPath: IndexPath = IndexPath()

	// MARK: - Functions
	/// Configures the cell with the given details.
	///
	/// - Parameters:
	///    - episode: The `Episode` object used to configure the cell.
	func configure(using episode: Episode) {
		self.episode = episode

		// Configure notifications
		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleWatchStatusUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)

		// Configure watch status button
		self.configureWatchButton(with: episode.attributes.watchStatus)

		// Configure title label
		self.primaryLabel.text = episode.attributes.title

		// Configure tags label
		self.secondaryLabel.text = episode.attributes.informationString

		// Configure poster view
		if let posterBackgroundColor = episode.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		episode.attributes.posterImage(imageView: self.posterImageView)

		// Configure banner view
		if let bannerBackgroundColor = episode.attributes.banner?.backgroundColor {
			self.bannerImageView.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		episode.attributes.bannerImage(imageView: self.bannerImageView)

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
			self.configureWatchButton(with: self.episode?.attributes.watchStatus)
		}
	}

	/// Configures the watch status button of the episode.
	///
	/// - Parameter watchStatus: The WatchStatus object used to configure the button.
	func configureWatchButton(with watchStatus: WatchStatus?) {
		let watchStatusButtonTitle = self.episode?.attributes.watchStatus == .watched ? "✓ \(Trans.watched)" : Trans.markAsWatched
		self.watchStatusButton.setTitle(watchStatusButtonTitle, for: .normal)
	}
}
