//
//  MusicLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import MusicKit
import UIKit

protocol MusicLockupCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the cell's show button was tapped.
	///
	/// - Parameters:
	///    - sender: The button that was tapped.
	///    - indexPath: The index path of the cell within the collection view.
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath)

	/// Tells the delegate the cell's play button was tapped.
	///
	/// - Parameters:
	///    - cell: The cell whose play button was tapped.
	///    - indexPath: The index path of the cell within the collection view.
	func musicLockupCollectionViewCell(_ cell: MusicLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath)
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

	/// The album's container view.
	@IBOutlet weak var albumContainerView: UIView!

	/// The album artwork's border view.
	@IBOutlet weak var albumBorderView: BorderView!

	/// The album artwork image view.
	@IBOutlet weak var albumImageView: UIImageView!

	/// A button representing the playback state of the song.
	@IBOutlet weak var playButton: KButton!

	/// A button representing the show a song belongs to.
	@IBOutlet weak var showButton: KButton!

	/// A button representing the type of the song.
	@IBOutlet weak var typeButton: UIButton!

	// MARK: - Properties
	/// The index path of the cell within the parent collection view.
	var indexPath: IndexPath?

	/// The object responsible for delegating actions.
	weak var delegate: MusicLockupCollectionViewCellDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.albumContainerView.layer.cornerRadius = 22
		(self.albumImageView as? RoundedRectangleImageView)?.applyCornerRadius(22)
		self.albumImageView?.layer.borderWidth = 0
		self.albumBorderView.cornerRadius = 22

		self.playButton.highlightBackgroundColorEnabled = false
		self.playButton.springEnabled = true
		self.playButton.addBlurEffect()
		self.playButton.theme_tintColor = KThemePicker.textColor.rawValue
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.playButton.isHidden = true
		self.albumImageView?.backgroundColor = .clear
		self.albumImageView?.image = .Placeholders.musicAlbum
	}

	// MARK: - Functions
	/// Configures the cell with the given `ShowSong` object.
	///
	/// - Parameters:
	///    - showSong: The `ShowSong` object used to configure the cell.
	///    - indexPath: The index path of the cell within the collection view.
	///    - rank: The rank of the song in a ranked list.
	///    - showEpisodes: Whether to show which episodes this song played in.
	///    - showShow: Whether to show which show this song belongs to.
	///    - resolvedSong: The resolved Apple Music song.
	func configure(using showSong: ShowSong?, at indexPath: IndexPath, rank: Int? = nil, showEpisodes: Bool = true, showShow: Bool = false, resolvedSong: MKSong? = nil) {
		guard let showSong = showSong else {
			self.resetShowSong()
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.tertiaryLabel.isHidden = !showEpisodes
		self.tertiaryLabel.text = L10n.episodeLabel("\(showSong.attributes.episodes)")

		self.configureRank(rank)

		self.typeButton.isHidden = false
		self.typeButton.layerCornerRadius = 12.0
		self.typeButton.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .semibold)
		self.typeButton.setTitle("\(showSong.attributes.type.abbreviatedStringValue) #\(showSong.attributes.position)", for: .normal)
		self.typeButton.backgroundColor = showSong.attributes.type.backgroundColorValue
		self.typeButton.setTitleColor(.white, for: .normal)

		self.showButton.isHidden = !showShow
		self.showButton.setTitle(showSong.show?.attributes.title, for: .normal)

		self.configure(using: showSong.song, at: indexPath, fromShowSong: true, resolvedSong: resolvedSong)
	}

	/// Resets the `ShowSong` related views.
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
	///    - fromShowSong: Whether the method was called from the `ShowSong` overload.
	///    - resolvedSong: The resolved Apple Music song.
	func configure(using song: KKSong?, at indexPath: IndexPath, rank: Int? = nil, fromShowSong: Bool = false, resolvedSong: MKSong? = nil) {
		if !fromShowSong {
			self.configure(using: nil, at: indexPath, rank: rank, showEpisodes: false, showShow: false)
		}

		guard let song = song else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		self.indexPath = indexPath

		self.primaryLabel.text = song.attributes.title
		self.secondaryLabel.text = song.attributes.artist

		self.configureRank(rank)
		self.updateArtwork(for: song, resolvedSong: resolvedSong)
		self.configurePlayButton(for: song)
	}

	/// Configures the rank label with the given rank.
	///
	/// - Parameter rank: The rank of the song in a ranked list.
	private func configureRank(_ rank: Int?) {
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}
	}

	/// Sets the album artwork.
	///
	/// - Parameters:
	///    - song: The song whose artwork is shown.
	///    - resolvedSong: The resolved Apple Music song.
	func updateArtwork(for song: KKSong, resolvedSong: MKSong?) {
		if let urlString = song.attributes.artwork?.url, !urlString.isEmpty {
			if let backgroundColor = song.attributes.artwork?.backgroundColor {
				self.albumImageView?.backgroundColor = UIColor(hexString: backgroundColor)
			} else {
				self.albumImageView?.backgroundColor = .clear
			}
			self.albumImageView?.setImage(with: urlString, placeholder: .Placeholders.musicAlbum)
			return
		}

		if let artwork = resolvedSong?.song.artwork, let urlString = artwork.url(width: 320, height: 320)?.absoluteString {
			if let backgroundColor = artwork.backgroundColor {
				self.albumImageView?.backgroundColor = UIColor(cgColor: backgroundColor)
			} else {
				self.albumImageView?.backgroundColor = .clear
			}
			self.albumImageView?.setImage(with: urlString, placeholder: .Placeholders.musicAlbum)
			return
		}

		self.albumImageView?.backgroundColor = .clear
		self.albumImageView?.image = .Placeholders.musicAlbum
	}

	/// Configures the play button for the given song.
	///
	/// - Parameter song: The song the button plays.
	private func configurePlayButton(for song: KKSong) {
		self.playButton.isHidden = song.attributes.amID == nil
		guard !self.playButton.isHidden else { return }

		self.playButton.layerCornerRadius = self.playButton.frame.size.height / 2
		self.updatePlayButton(for: song)
	}

	/// Updates the play button's glyph to reflect whether the given song is currently playing.
	///
	/// - Parameter song: The song the button plays.
	func updatePlayButton(for song: KKSong) {
		let isCurrentSong = MusicManager.shared.currentKKSong?.id == song.id
		let systemName = isCurrentSong && MusicManager.shared.isPlaying ? "pause.fill" : "play.fill"
		self.playButton.setImage(UIImage(systemName: systemName), for: .normal)
	}

	// MARK: - IBActions
	@IBAction func playButtonPressed(_ sender: UIButton) {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.musicLockupCollectionViewCell(self, didTapPlayButtonAt: indexPath)
	}

	@IBAction func showButtonPressed(_ sender: UIButton) {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.showButtonPressed(sender, indexPath: indexPath)
	}
}
