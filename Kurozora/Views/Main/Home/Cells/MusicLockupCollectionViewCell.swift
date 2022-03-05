//
//  MusicLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit
import SwiftyJSON

protocol MusicLockupCollectionViewCellDelegate: AnyObject {
	func playButtonPressed(_ sender: UIButton, cell: MusicLockupCollectionViewCell)
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath)
}

class MusicLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet var tertiaryLable: KSecondaryLabel!

	/// A button representing the type of the music.
	@IBOutlet var playButton: KButton!

	/// A button representing the show a music belongs to.
	@IBOutlet var showButton: KButton!

	/// A button representing the type of the music.
	@IBOutlet var typeButton: UIButton!

	// MARK: - Properties
	/// The index path of the cell within the parent collection view.
	var indexPath: IndexPath?

	/// A single music item.
	var song: MusicItemCollection<MusicKit.Song>.Element?

	/// The `MusicLockupCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: MusicLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configures the cell with the given `ShowSong` object.
	///
	/// - Parameter showSong: The `ShowSong` objet used to confgiure the cell.
	/// - Parameter indexPath: The index path of the cell within the collection view.
	/// - Parameter showEpisodes: Whether to show which episodes this song played in.
	/// - Parameter showShow: Whether to show which show this song belongs to.
	override func configureCell(with showSong: ShowSong, at indexPath: IndexPath, showEpisodes: Bool = true, showShow: Bool = false) {
		self.indexPath = indexPath

		// Configure title
		self.primaryLabel?.text = showSong.song.attributes.title

		// Configure artist
		self.secondaryLabel?.text = showSong.song.attributes.artist

		// Configure episodes
		self.tertiaryLable.isHidden = !showEpisodes
		self.tertiaryLable.text = "Episode: \(showSong.attributes.episodes)"

		// Confgiure type button
		self.typeButton.setTitle("\(showSong.attributes.type.abbreviatedStringValue) #\(showSong.attributes.position)", for: .normal)
		self.typeButton.backgroundColor = showSong.attributes.type.backgroundColorValue
		self.typeButton.setTitleColor(.white, for: .normal)

		// Confgiure type button
		self.showButton.isHidden = !showShow
		self.showButton.setTitle(showSong.show?.attributes.title, for: .normal)

		// Configure play button
		self.playButton.isHidden = true
		self.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)

		if let appleMusicID = showSong.song.attributes.amID {
			let developerToken = "eyJraWQiOiIzOExGSjhTNkJLIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiI0N1pFVTVKNEJGIiwiaWF0IjoxNjM4NzM2NzM2LCJleHAiOjE2NTQyODg3MzYsImF1ZCI6Imh0dHBzOi8vYXBwbGVpZC5hcHBsZS5jb20iLCJzdWIiOiJhcHAua3Vyb3pvcmEud2ViLnRyYWNrZXIifQ.YPmoT2FOQzCZU2TLRj8IRD6HdLaCp0-GiM5ZD2aQ4_AlvwNvpSZyYp5sWVaQP_z1nzIFxKHGIj_GM15VxZWLNw"
			if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/jp/songs/\(appleMusicID)") {
				urlRequest.httpMethod = "GET"
				urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")

				URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
					guard error == nil else { return }
					var song: MusicKit.Song?

					if let data = data,
					   let songJson = try? JSON(data: data) {
						do {
							let songJsonString = songJson["data"][0]
							let songJsonData = try songJsonString.rawData()
							song = MusicKit.Song(from: songJsonData)
							self.updateArtwork(using: song)
						} catch {
							self.resetArtwork()
						}
					}

					self.updateArtwork(using: song)
				}.resume()
			}
		} else {
			self.resetArtwork()
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
		DispatchQueue.main.async {
			self.playButton.isHidden = false
			self.posterImageView?.backgroundColor = song.artwork?.backgroundColor?.uiColor
			self.posterImageView?.setImage(with: artworkURL, placeholder: #imageLiteral(resourceName: "Placeholders/Music Album"))
		}
	}

	private func resetArtwork() {
		self.song = nil

		DispatchQueue.main.async {
			self.playButton.isHidden = true
			self.posterImageView?.backgroundColor = .clear
			self.posterImageView?.image = #imageLiteral(resourceName: "Placeholders/Music Album")
		}
	}

	// MARK: - IBActions
	@IBAction func playButtonPressed(_ sender: UIButton) {
		self.delegate?.playButtonPressed(sender, cell: self)
	}

	@IBAction func showButtonPressed(_ sender: UIButton) {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.showButtonPressed(sender, indexPath: indexPath)
	}
}
