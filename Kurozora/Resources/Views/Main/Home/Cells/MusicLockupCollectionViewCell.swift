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

class MusicLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	/// The primary lable of the cell.
	@IBOutlet weak var primaryLabel: UILabel!

	/// The secondary lable of the cell.
	@IBOutlet weak var secondaryLabel: UILabel!

	/// The tertiary lable of the cell.
	@IBOutlet weak var tertiaryLable: KSecondaryLabel!

	/// A button representing the state of the music.
	@IBOutlet weak var albumImageView: UIImageView!

	/// A button representing the state of the music.
	@IBOutlet weak var playButton: KButton!

	/// A button representing the show a music belongs to.
	@IBOutlet weak var showButton: KButton!

	/// A button representing the type of the music.
	@IBOutlet weak var typeButton: UIButton!

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
	func configure(using showSong: ShowSong?, at indexPath: IndexPath, showEpisodes: Bool = true, showShow: Bool = false) {
		guard let showSong = showSong else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		self.indexPath = indexPath

		// Configure title
		self.primaryLabel.text = showSong.song.attributes.title

		// Configure artist
		self.secondaryLabel.text = showSong.song.attributes.artist

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
		self.playButton.cornerRadius = self.playButton.height / 2
		self.playButton.addBlurEffect()

		if let appleMusicID = showSong.song.attributes.amID {
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

	@IBAction func showButtonPressed(_ sender: UIButton) {
		guard let indexPath = self.indexPath else { return }
		self.delegate?.showButtonPressed(sender, indexPath: indexPath)
	}
}
