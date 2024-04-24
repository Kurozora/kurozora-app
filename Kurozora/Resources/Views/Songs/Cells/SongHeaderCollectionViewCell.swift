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

protocol SongHeaderCollectionViewCellDelegate: AnyObject {
	func playButtonPressed(_ sender: UIButton, cell: SongHeaderCollectionViewCell)
	func saveAppleMusicSong(_ song: MusicKit.Song?)
}

class SongHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var albumImageView: AlbumImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var playButton: KTintedButton!

	// MARK: - Properties
	/// A single music item.
	var song: MusicItemCollection<MusicKit.Song>.Element?

	/// The `SongHeaderCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: SongHeaderCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given song object.
	///
	/// - Parameter song: The `Song` object used to configure the cell.
	func configure(using song: KKSong) {
		self.primaryLabel.text = song.attributes.title
		self.secondaryLabel.text = song.attributes.artist

		Task { [weak self] in
			guard let self = self else { return }

			if let appleMusicID = song.attributes.amID {
				let song = await MusicManager.shared.getSong(for: appleMusicID)
				self.delegate?.saveAppleMusicSong(song)
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
			self.albumImageView?.backgroundColor = song.artwork?.backgroundColor?.uiColor
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
		self.delegate?.playButtonPressed(sender, cell: self)
	}
}
