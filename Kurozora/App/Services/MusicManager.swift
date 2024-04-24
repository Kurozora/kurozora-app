//
//  MusicManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit
import MusicKit
import SwiftyJSON

class MusicManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `MusicManager`.
	static let shared = MusicManager()

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	var playingSong: MusicKit.Song?

	// MARK: - Initializers
	private override init() {}

	// MARK: - Functions
	func getSong(for appleMusicID: Int) async -> MusicKit.Song? {
		switch MusicAuthorization.currentStatus {
		case .authorized:
			return await MusicManager.shared.authorizedMusicRequest(for: appleMusicID)
		default:
			return await MusicManager.shared.unauthorizedMusicrequest(for: appleMusicID)
		}
	}

	/// Sends a request to Apple Music when the user authorized the app to use MusicKit.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	///
	/// - Returns: The fetched `MusicKit.Song` object.
	private func authorizedMusicRequest(for appleMusicID: Int) async -> MusicKit.Song? {
		guard let urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)") else { return nil }
		let musicDataRequest = MusicDataRequest(urlRequest: urlRequest)
		let response = try? await musicDataRequest.response()
		return self.handleMusicResponseData(response?.data)
	}

	/// Sends a request to Apple Music when the user hasn't authorized the app to use MusicKit.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	private func unauthorizedMusicrequest(for appleMusicID: Int) async -> MusicKit.Song? {
		var song: MusicKit.Song?

		if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)"), let appleMusicDeveloperToken = KSettings?.appleMusicDeveloperToken {
			urlRequest.httpMethod = "GET"
			urlRequest.addValue("Bearer \(appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

			do {
				let (data, _) = try await URLSession.shared.data(for: urlRequest)
				song = handleMusicResponseData(data)
			} catch {
				print("----- Error unauthorizedMusicrequest", String(describing: error))
			}
		}

		return song
	}

	/// Handles the data received from the music request.
	///
	/// - Parameters:
	///    - data: The object containing the data of the music request.
	private func handleMusicResponseData(_ data: Data?) -> MusicKit.Song? {
		var song: MusicKit.Song?

		if let data = data,
		   let songJson = try? JSON(data: data) {
			do {
				let songJsonString = songJson["data"][0]
				let songJsonData = try songJsonString.rawData()
				song = MusicKit.Song(from: songJsonData)
			} catch {
				print("----- Error handleMusicResponseData", String(describing: error))
			}
		}

		return song
	}

	func play(song: MusicKit.Song, playButton: UIButton) {
		self.playingSong = song

		if let songURL = song.previewAssets?.first?.url {
			let playerItem = AVPlayerItem(url: songURL)

			if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
				switch self.player?.timeControlStatus {
				case .playing:
					playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					self.player?.pause()
				case .paused:
					playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
//				if let indexPath = self.currentPlayerIndexPath {
//					if let cell = self.collectionView.cellForItem(at: indexPath) as? MusicReviewLockupCollectionViewCell {
//						playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//					}
//				}

//				self.currentPlayerIndexPath = indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					guard let self = self else { return }
					self.player = nil
					playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
				})
			}
		}
	}
}
