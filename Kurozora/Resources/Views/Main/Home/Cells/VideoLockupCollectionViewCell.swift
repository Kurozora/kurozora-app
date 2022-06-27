//
//  VideoLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVKit
import AVFoundation
import XCDYouTubeKit

class VideoLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var taglineLabel: KLabel!
	@IBOutlet weak var videoPlayerContainer: KTrailerPlayerView!

	// MARK: - Properties
	var avQueuePlayer: AVQueuePlayer = AVQueuePlayer()
	private var avPlayerLooper: AVPlayerLooper?
	var youtubeOperation: XCDYouTubeOperation?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.configureVideoPlayerContainer()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		// Cancel and remove youTube operation
		DispatchQueue.global(qos: .background).async {
			self.youtubeOperation?.cancel()
			self.youtubeOperation = nil
		}

		// Re-configure video player
		self.avQueuePlayer = AVQueuePlayer()
		self.configureVideoPlayerContainer()
	}

	// MARK: - Functions
	override func configure(using show: Show?) {
		super.configure(using: show)
		guard let show = show else { return }

		// Configure genres
		self.secondaryLabel?.text = show.attributes.genres?.localizedJoined()

		// Configure tagline
		self.taglineLabel?.text = show.attributes.tagline

		// Configure score
		let ratingAverage = show.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		// Configure video player
		if self.youtubeOperation == nil {
//			self.configureVideoPlayer(with: show)
		}
	}

	func configureVideoPlayerContainer() {
		self.videoPlayerContainer.player = self.avQueuePlayer
		self.videoPlayerContainer.playerLayer.videoGravity = .resizeAspectFill
		self.avQueuePlayer.actionAtItemEnd = .none
		self.avQueuePlayer.isMuted = true
	}

	/// Configures the video player with the defined settings.
	func configureVideoPlayer(with show: Show) {
		if let videoUrlString = show.attributes.videoUrl, !videoUrlString.isEmpty {
			let videoID = URLComponents(string: videoUrlString)?.queryItems?.first(where: { $0.name == "v" })?.value

			DispatchQueue.global(qos: .background).async {
				self.youtubeOperation = XCDYouTubeClient.default().getVideoWithIdentifier(videoID) { [weak self] video, error in
					guard let self = self else { return }
					if let video = video {
						let streamURLs = video.streamURLs
						let streamURL = streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? streamURLs[XCDYouTubeVideoQuality.small240.rawValue]

						if let streamURL = streamURL {
							let options = [AVURLAssetAllowsCellularAccessKey: false]
							let avURLAsset = AVURLAsset(url: streamURL, options: options)

							/// Load needed values asynchronously
							avURLAsset.loadValuesAsynchronously(forKeys: ["duration", "playable"]) {
								/// UI actions should executed on the main thread
								DispatchQueue.main.async {
									let avPlayerItem = AVPlayerItem(asset: avURLAsset)
									if self.avQueuePlayer.currentItem != avPlayerItem {
										self.avPlayerLooper = nil
										self.avPlayerLooper = AVPlayerLooper(player: self.avQueuePlayer, templateItem: avPlayerItem)
									}
									self.youtubeOperation = nil
								}
							}
						}
					} else {
						print("----- YouTube Error -----")
						print(error?.localizedDescription ?? "------ No YouTube error even though video not working")
					}
				}
			}
		}
	}
}
