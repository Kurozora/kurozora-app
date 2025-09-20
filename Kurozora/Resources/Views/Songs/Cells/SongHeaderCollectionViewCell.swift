//
//  SongHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit
import SwiftyJSON
import Combine

protocol SongHeaderCollectionViewCellDelegate: AnyObject {
	func playStateChanged(_ song: MKSong?)
}

class SongHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var albumImageView: AlbumImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var playButton: KTintedButton!

	// MARK: - Properties
	private var subscriptions = Set<AnyCancellable>()

	/// A single music item.
	var song: MKSong?

	/// The `SongHeaderCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: SongHeaderCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given song object.
	///
	/// - Parameter song: The `Song` object used to configure the cell.
	func configure(using song: KKSong) {
		self.primaryLabel.text = song.attributes.title
		self.secondaryLabel.text = song.attributes.artist

		MusicManager.shared.$isPlaying
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.updatePlayButton()
				self.delegate?.playStateChanged(self.song)
			}
			.store(in: &self.subscriptions)

		Task { [weak self] in
			guard let self = self else { return }

			if let appleMusicID = song.attributes.amID {
				self.song = await MusicManager.shared.getSong(for: appleMusicID)
				self.delegate?.playStateChanged(self.song)
				self.updatePlayButton()
				self.updateArtwork()
			} else {
				self.resetArtwork()
			}
		}
	}

	/// Updates the play button status.
	func updatePlayButton() {
		let title = if MusicManager.shared.authorizationState == .authorized && MusicManager.shared.hasAMSubscription {
			Trans.play
		} else {
			Trans.preview
		}

		if MusicManager.shared.currentSong == self.song && MusicManager.shared.isPlaying {
			self.playButton.setTitle(title, for: .normal)
			self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		} else {
			self.playButton.setTitle(title, for: .normal)
			self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}

	/// Updates the album image view.
	func updateArtwork() {
		guard let song = self.song else {
			self.resetArtwork()
			return
		}
		guard let artworkURL = song.song.artwork?.url(width: 320, height: 320)?.absoluteString else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.playButton.isHidden = false
			if let posterBackgroundColor = song.song.artwork?.backgroundColor {
				self.albumImageView?.backgroundColor = UIColor(cgColor: posterBackgroundColor)
			}
			self.albumImageView?.setImage(with: artworkURL, placeholder: #imageLiteral(resourceName: "Placeholders/Music Album"))
		}
	}

	/// Resets the music artwork to its initial state.
	private func resetArtwork() {
		self.song = nil

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.playButton.isHidden = true
			self.albumImageView?.backgroundColor = .clear
			self.albumImageView?.image = #imageLiteral(resourceName: "Placeholders/Music Album")
		}
	}

	// MARK: - IBActions
	@IBAction func playButtonPressed(_ sender: UIButton) {
		guard let song = self.song else { return }
		MusicManager.shared.play(song: song, playButton: sender)
		self.delegate?.playStateChanged(song)
	}
}
