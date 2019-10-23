//
//  ExploreVideoCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ExploreVideoCollectionViewCell: ExploreBaseCollectionViewCell {
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
	@IBOutlet weak var taglineLabel: UILabel! {
		didSet {
			taglineLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var videoPlayerContainer: UIView!

	// MARK: - Properties
	var avPlayer: AVPlayer = {
		let avPlayer = AVPlayer()
		avPlayer.actionAtItemEnd = .none
		avPlayer.isMuted = true
		return avPlayer
	}()
	var avPlayerLayer: AVPlayerLayer = {
		let avPlayerLayer = AVPlayerLayer()
		avPlayerLayer.videoGravity = .resizeAspectFill
		return avPlayerLayer
	}()
	var avPlayerItem: AVPlayerItem? = nil
	var avPlayerStatus: NSKeyValueObservation? = nil
	var avPlayerTimeControl: NSKeyValueObservation? = nil
	var avPlayerViewController: AVPlayerViewController = AVPlayerViewController()
	var shouldPlay = false

	var thumbnailPlaceholder: UIImageView {
		get {
			let thumbnailPlaceholder = UIImageView(frame: CGRect(origin: .zero, size: videoPlayerContainer.frame.size))
			if let bannerThumbnail = showDetailsElement?.banner {
				thumbnailPlaceholder.setImage(with: bannerThumbnail, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
			}
			return thumbnailPlaceholder
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		// Configure tagline
		self.taglineLabel?.text = showDetailsElement.tagline

		// Configure video player
		configureVideoPlayer()
	}

	/// Configures the video player with the defined settings.
	func configureVideoPlayer() {
		guard let videoUrlString = showDetailsElement?.videoUrl else { return }
		guard let videoUrl = URL(string: videoUrlString) else { return }

		let avPlayerItem = AVPlayerItem(url: videoUrl)
		if !(self.avPlayer.currentItem?.isEqual(self.avPlayerItem) ?? false) {
			self.avPlayerItem = avPlayerItem
			self.avPlayer.replaceCurrentItem(with: avPlayerItem)
			self.avPlayerLayer.player = self.avPlayer
			self.avPlayerLayer.frame = videoPlayerContainer.bounds
			self.avPlayerViewController.player = avPlayer
			self.avPlayerViewController.exitsFullScreenWhenPlaybackEnds = true

			// Setup video thumbnail and observe play status
			setupVideoThumbnail()
			avPlayerTimeControl = self.avPlayer.observe(\.timeControlStatus, changeHandler: { (_, _) in
				if self.avPlayer.timeControlStatus == .playing {
					self.avPlayerViewController.contentOverlayView?.removeSubviews()
				}
			})

			self.parentViewController?.addChild(avPlayerViewController)
			self.avPlayerViewController.view.frame = videoPlayerContainer.bounds

			// Add avPlayerViewController view as subview to cell
			let avPlayerControllerView = avPlayerViewController.view
			videoPlayerContainer.addSubview(avPlayerControllerView!)
			avPlayerControllerView?.didMoveToSuperview()
		}
	}

	/// Sets up the video thumbnail by observing the video player status.
	fileprivate func setupVideoThumbnail() {
		avPlayerStatus = self.avPlayer.observe(\.status, changeHandler: { (_, _) in
			if self.avPlayer.status == AVPlayer.Status.readyToPlay {
				self.avPlayerViewController.contentOverlayView?.addSubview(self.thumbnailPlaceholder)
			}
		})
	}
}
