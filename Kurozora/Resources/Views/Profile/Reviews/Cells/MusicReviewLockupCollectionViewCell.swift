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

		// Configure artist
		self.secondaryLabel.text = song.attributes.artist

		// Configure play button
		self.playButton.isHidden = true
		self.playButton.layerCornerRadius = self.playButton.height / 2
		self.playButton.addBlurEffect()
		self.playButton.theme_tintColor = KThemePicker.textColor.rawValue

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
		if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)"), let appleMusicDeveloperToken = KSettings?.appleMusicDeveloperToken {
			urlRequest.httpMethod = "GET"
			urlRequest.addValue("Bearer \(appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

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
