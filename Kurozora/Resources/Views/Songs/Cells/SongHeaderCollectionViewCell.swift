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

		if let appleMusicID = song.attributes.amID {
			switch MusicAuthorization.currentStatus {
			case .authorized:
				self.authorizedMusicRequest(for: appleMusicID)
//			case .denied, .restricted, .notDetermined:
			default:
				self.unauthorizedMusicrequest(for: appleMusicID)
			}
		} else {
			self.resetArtwork()
		}
	}

	/// Sends a request to Apple Music when the user authorized the app to use MusicKit.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	func authorizedMusicRequest(for appleMusicID: Int) {
		Task { [weak self] in
			guard let self = self else { return }
			guard let urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)") else { return }
			let musicDataRequest = MusicDataRequest(urlRequest: urlRequest)
			let response = try? await musicDataRequest.response()
			self.handleMusicResponseData(response?.data)
		}
	}

	/// Sends a request to Apple Music when the user hasn't authorized the app to use MusicKit.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	func unauthorizedMusicrequest(for appleMusicID: Int) {
		if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)") {
			urlRequest.httpMethod = "GET"
			urlRequest.addValue("Bearer \(Services.appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

			URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
				guard let self = self else { return }
				guard error == nil else { return }
				self.handleMusicResponseData(data)
			}.resume()
		}
	}

	/// Handles the data received from the music request.
	///
	/// - Parameters:
	///    - data: The object containing the data of the music request.
	func handleMusicResponseData(_ data: Data?) {
		var song: MusicKit.Song?

		if let data = data,
		   let songJson = try? JSON(data: data) {
			do {
				let songJsonString = songJson["data"][0]
				let songJsonData = try songJsonString.rawData()
				song = MusicKit.Song(from: songJsonData)
			} catch {
				self.resetArtwork()
			}
		}

		self.delegate?.saveAppleMusicSong(song)
		self.updateArtwork(using: song)
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
