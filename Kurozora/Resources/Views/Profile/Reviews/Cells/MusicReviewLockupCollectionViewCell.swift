//
//  MusicReviewLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit
import SwiftyJSON

protocol MusicReviewLockupCollectionViewCellDelegate: AnyObject {
	func playButtonPressed(_ sender: UIButton, cell: MusicReviewLockupCollectionViewCell)
}

class MusicReviewLockupCollectionViewCell: BaseReviewLockupCollectionViewCell {
	// MARK: - IBOutlets
	/// A button representing the state of the music.
	@IBOutlet weak var playButton: KButton!

	// MARK: - Properties
	/// A single music item.
	var song: MusicItemCollection<MusicKit.Song>.Element?

	/// The `MusicReviewLockupCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: MusicReviewLockupCollectionViewCellDelegate?

	// MARK: - Functions
	override func configure(using review: Review?, for song: KKSong?) {
		super.configure(using: review, for: song)
		self.configure(using: song)
	}

	/// Configures the cell with the given `Song` object.
	///
	/// - Parameter song: The `Song` object used to configure the cell.
	func configure(using song: KKSong?) {
		guard let song = song else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure title
		self.primaryLabel.text = song.attributes.title

		// Configure play button
		self.playButton.isHidden = true
		self.playButton.layerCornerRadius = self.playButton.height / 2
		self.playButton.addBlurEffect()
		self.playButton.theme_tintColor = KThemePicker.textColor.rawValue

		Task { [weak self] in
			guard let self = self else { return }

			if let appleMusicID = song.attributes.amID {
				let song = await MusicManager.shared.getSong(for: appleMusicID)
				self.updatePlayButton(using: song)
				self.updateArtwork(using: song)
			} else {
				self.resetArtwork()
			}
		}
	}

	/// Updates the play button using the given song.
	///
	/// - Parameters:
	///    - song: A music item that represents a song.
	func updatePlayButton(using song: MusicKit.Song?) {
		if MusicManager.shared.playingSong == song {
			self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		} else {
			self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}

	/// Updates the artwork using the given song.
	///
	/// - Parameters song: A music item that represents a song.
	func updateArtwork(using song: MusicKit.Song?) {
		self.song = song

		guard let song = song else {
			self.resetArtwork()
			return
		}
		guard let artworkURL = song.artwork?.url(width: 320, height: 320)?.absoluteString else { return }
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.playButton.isHidden = false
			self.posterImageView.backgroundColor = song.artwork?.backgroundColor?.uiColor
			self.posterImageView.setImage(with: artworkURL, placeholder: #imageLiteral(resourceName: "Placeholders/Music Album"))
		}
	}

	/// Resets the music artwork to its initial state.
	private func resetArtwork() {
		self.song = nil

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.playButton.isHidden = true
			self.posterImageView.backgroundColor = .clear
			self.posterImageView.image = #imageLiteral(resourceName: "Placeholders/Music Album")
		}
	}

	// MARK: - IBActions
	@IBAction func playButtonPressed(_ sender: UIButton) {
		self.delegate?.playButtonPressed(sender, cell: self)
	}
}
