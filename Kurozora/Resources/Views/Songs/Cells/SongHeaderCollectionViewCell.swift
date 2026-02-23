//
//  SongHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import MusicKit
import UIKit

protocol SongHeaderCollectionViewCellDelegate: AnyObject {
	func playStateChanged(_ song: MKSong?)
}

class SongHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryImageView: AlbumImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var primaryButton: KTintedButton!

	// MARK: - Properties
	private var subscriptions = Set<AnyCancellable>()

	/// A single music item.
	var song: MKSong?

	/// The Kurozora song model used for context menu actions.
	var kkSong: KKSong?

	/// The `SongHeaderCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: SongHeaderCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given song object.
	///
	/// - Parameter song: The `Song` object used to configure the cell.
	func configure(using song: KKSong) {
		self.kkSong = song
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
		let title = if MusicManager.shared.authorizationState == .authorized, MusicManager.shared.hasAMSubscription {
			MusicManager.shared.isPlaying ? Trans.pause : Trans.play
		} else {
			Trans.preview
		}

		if MusicManager.shared.currentSong == self.song, MusicManager.shared.isPlaying {
			self.primaryButton.setTitle(title, for: .normal)
			self.primaryButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		} else {
			self.primaryButton.setTitle(title, for: .normal)
			self.primaryButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}

	/// Updates the album image view.
	@MainActor
	func updateArtwork() {
		guard let song = self.song else {
			self.resetArtwork()
			return
		}
		guard let artworkURL = song.song.artwork?.url(width: 320, height: 320)?.absoluteString else { return }

		self.primaryButton.isHidden = false

		if let posterBackgroundColor = song.song.artwork?.backgroundColor {
			self.primaryImageView?.backgroundColor = UIColor(cgColor: posterBackgroundColor)
		}

		self.primaryImageView?.setImage(with: artworkURL, placeholder: #imageLiteral(resourceName: "Placeholders/Music Album"))
	}

	/// Resets the music artwork to its initial state.
	@MainActor
	private func resetArtwork() {
		self.song = nil
		self.primaryButton.isHidden = true
		self.primaryImageView?.backgroundColor = .clear
		self.primaryImageView?.image = #imageLiteral(resourceName: "Placeholders/Music Album")
	}

	// MARK: - IBActions
	@IBAction func playButtonPressed(_ sender: UIButton) {
		guard let song = self.song else { return }
		MusicManager.shared.play(song: song, playButton: sender, kkSong: self.kkSong)
		self.delegate?.playStateChanged(song)
	}
}
