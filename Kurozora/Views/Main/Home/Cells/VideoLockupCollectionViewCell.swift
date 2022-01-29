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

class VideoLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	override var primaryLabel: UILabel? {
		didSet {
			primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	override var secondaryLabel: UILabel? {
		didSet {
			secondaryLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var taglineLabel: KLabel!
	@IBOutlet weak var videoPlayerContainer: UIView!

	// MARK: - Properties
	var avPlayerStatus: NSKeyValueObservation? = nil
	var avPlayerTimeControl: NSKeyValueObservation? = nil
	var avPlayerViewController: AVPlayerViewController = {
		let avPlayerViewController = AVPlayerViewController()
		avPlayerViewController.exitsFullScreenWhenPlaybackEnds = true
		avPlayerViewController.player = AVPlayer()
		avPlayerViewController.player?.actionAtItemEnd = .none
		avPlayerViewController.player?.isMuted = true
		return avPlayerViewController
	}()
	var thumbnailPlaceholder: UIImageView = UIImageView()

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		videoPlayerContainer.addSubview(avPlayerViewController.view)
		avPlayerViewController.view.fillToSuperview()
		setupAVPlayerControllerThumbnail()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		avPlayerViewController.player?.pause()
		avPlayerViewController.player = AVPlayer()
	}

	// MARK: - Functions
	override func configureCell(with show: Show) {
		super.configureCell(with: show)

		// Configure genres
		self.secondaryLabel?.text = show.attributes.genres?.localizedJoined()

		// Configure tagline
		self.taglineLabel?.text = show.attributes.tagline

		// Configure banner
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor {
			self.thumbnailPlaceholder.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.thumbnailPlaceholder)

		// Configure video player
		configureVideoPlayer(with: show)
	}

	/// Configures the video player with the defined settings.
	func configureVideoPlayer(with show: Show) {
		if let videoUrlString = show.attributes.videoUrl, !videoUrlString.isEmpty {
			if let videoUrl = URL(string: videoUrlString) {
				let avPlayerItem = AVPlayerItem(url: videoUrl)
				self.avPlayerViewController.player?.replaceCurrentItem(with: avPlayerItem)
			}
		} else {
			addThumbnailPlaceholder()
			self.avPlayerViewController.showsPlaybackControls = false
		}
	}

	/// Sets up the necessary AVPlayerController observers to add and remove the video thumbnail.
	func setupAVPlayerControllerThumbnail() {
		addThumbnailToAVPlayerController()
		observeAVPlayerControllerPlayStatus()
	}

	func addThumbnailPlaceholder() {
		self.avPlayerViewController.contentOverlayView?.removeSubviews()
		self.avPlayerViewController.contentOverlayView?.addSubview(self.thumbnailPlaceholder)
		self.thumbnailPlaceholder.fillToSuperview()
	}

	/// Adds a thumbnail to the video player.
	fileprivate func addThumbnailToAVPlayerController() {
		avPlayerStatus = self.avPlayerViewController.player?.observe(\.status, changeHandler: { (_, _) in
			if self.avPlayerViewController.player?.status == .readyToPlay {
				self.addThumbnailPlaceholder()
				self.avPlayerViewController.showsPlaybackControls = true
			}
		})
	}

	/// Observes and removes the video thumbnail when the video is playing.
	fileprivate func observeAVPlayerControllerPlayStatus() {
		avPlayerTimeControl = self.avPlayerViewController.player?.observe(\.timeControlStatus, changeHandler: { (_, _) in
			if self.avPlayerViewController.player?.timeControlStatus == .playing {
				self.avPlayerViewController.contentOverlayView?.removeSubviews()
			}
		})
	}
}
