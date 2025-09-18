//
//  MusicLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import MusicKit
import SwiftyJSON
import UIKit

protocol MusicLockupCollectionViewCellDelegate: AnyObject {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath)
}

class MusicLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	/// The primary label of the cell.
	@IBOutlet weak var primaryLabel: UILabel!

	/// The secondary label of the cell.
	@IBOutlet weak var secondaryLabel: UILabel!

	/// The tertiary label of the cell.
	@IBOutlet weak var tertiaryLabel: KSecondaryLabel!

	/// The rank label of the cell.
	@IBOutlet weak var rankLabel: KLabel!

	/// A button representing the state of the music.
	@IBOutlet weak var albumImageView: UIImageView!

	/// A button representing the state of the music.
	@IBOutlet weak var playButton: KButton!

	/// A button representing the show a music belongs to.
	@IBOutlet weak var showButton: KButton!

	/// A button representing the type of the music.
	@IBOutlet weak var typeButton: UIButton!

	private var subscriptions = Set<AnyCancellable>()

	// MARK: - Properties
	/// The index path of the cell within the parent collection view.
	var indexPath: IndexPath?

	/// A single music item.
	var song: MKSong?

	/// The `MusicLockupCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: MusicLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configures the cell with the given `ShowSong` object.
	///
	/// - Parameters:
	///    - showSong: The `ShowSong` object used to configure the cell.
	///    - indexPath: The index path of the cell within the collection view.
	///    - rank: The rank of the song in a ranked list.
	///    - showEpisodes: Whether to show which episodes this song played in.
	///    - showShow: Whether to show which show this song belongs to.
	func configure(using showSong: ShowSong?, at indexPath: IndexPath, rank: Int? = nil, showEpisodes: Bool = true, showShow: Bool = false) {
		guard let showSong = showSong else {
			self.resetShowSong()
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure episodes
		self.tertiaryLabel.isHidden = !showEpisodes
		self.tertiaryLabel.text = "Episode: \(showSong.attributes.episodes)"

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure type button
		self.typeButton.isHidden = false
		self.typeButton.layerCornerRadius = 12.0
		self.typeButton.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .semibold)
		self.typeButton.setTitle("\(showSong.attributes.type.abbreviatedStringValue) #\(showSong.attributes.position)", for: .normal)
		self.typeButton.backgroundColor = showSong.attributes.type.backgroundColorValue
		self.typeButton.setTitleColor(.white, for: .normal)

		// Configure type button
		self.showButton.isHidden = !showShow
		self.showButton.setTitle(showSong.show?.attributes.title, for: .normal)

		// Configure with song
		self.configure(using: showSong.song, at: indexPath, fromShowSong: true)
	}

	/// Resets showSong related views.
	func resetShowSong() {
		self.tertiaryLabel.isHidden = true
		self.typeButton.isHidden = true
		self.showButton.isHidden = true
	}

	/// Configures the cell with the given `Song` object.
	///
	/// - Parameters:
	///    - song: The `Song` object used to configure the cell.
	///    - indexPath: The index path of the cell within the collection view.
	///    - rank: The rank of the song in a ranked list.
	///    - fromShowSong: A boolean indicating if the method was called from `configure(using: ShowSong)` method.
	func configure(using song: KKSong?, at indexPath: IndexPath, rank: Int? = nil, fromShowSong: Bool = false) {
		if !fromShowSong {
			// Configure showSong views.
			self.configure(using: nil, at: indexPath, rank: rank, showEpisodes: false, showShow: false)
		}

		guard let song = song else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		self.indexPath = indexPath

		// Configure title
		self.primaryLabel.text = song.attributes.title

		// Configure artist
		self.secondaryLabel.text = song.attributes.artist

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure play button
		self.playButton.highlightBackgroundColorEnabled = false
		self.playButton.springEnabled = true
		self.playButton.isHidden = true
		self.playButton.layerCornerRadius = self.playButton.frame.size.height / 2
		self.playButton.addBlurEffect()
		self.playButton.theme_tintColor = KThemePicker.textColor.rawValue

		MusicManager.shared.$isPlaying
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.updatePlayButton()
			}
			.store(in: &self.subscriptions)

		Task { [weak self] in
			guard let self = self else { return }

			if let appleMusicID = song.attributes.amID {
				self.song = await MusicManager.shared.getSong(for: appleMusicID)
				self.updatePlayButton()
				self.updateArtwork()
			} else {
				self.resetArtwork()
			}
		}
	}

	/// Updates the play button status.
	func updatePlayButton() {
		if MusicManager.shared.currentSong == self.song, MusicManager.shared.isPlaying {
			self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		} else {
			self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}

	/// Updates the album image view.
	func updateArtwork() {
		guard let song = song else {
			self.resetArtwork()
			return
		}
		guard let artworkURL = song.song.artwork?.url(width: 320, height: 320)?.absoluteString else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.playButton.isHidden = false
			if let backgroundColor = song.song.artwork?.backgroundColor {
				self.albumImageView?.backgroundColor = UIColor(cgColor: backgroundColor)
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
	}

	@IBAction func showButtonPressed(_ sender: UIButton) {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.showButtonPressed(sender, indexPath: indexPath)
	}
}
