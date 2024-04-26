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
import Combine

class MusicManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `MusicManager`.
	static let shared = MusicManager()

	/// The shared instance of `ApplicationMusicPlayer`.
	private let applicationPlayer = ApplicationMusicPlayer.shared

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The set of cancellable
	private var subscriptions = Set<AnyCancellable>()

	/// The current playing song.
	@Published private(set) var currentSong: MusicKit.Song?

	/// Whether a song is playing.
	@Published private(set) var isPlaying: Bool = false

	// MARK: - Initializers
	private override init() {
		super.init()

		self.applicationPlayer.state.objectWillChange.sink { [weak self] in
			guard let self = self else { return }
			self.isPlaying = ApplicationMusicPlayer.shared.state.playbackStatus == .playing
		}
		.store(in: &self.subscriptions)
	}

	// MARK: - Functions
	/// Fetches a song from Apple Music.
	///
	/// This uses the appropriate method to fetch the song based on the user's MusicKit authorization status.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	///
	/// - Returns: The fetched `MusicKit.Song` object.
	func getSong(for appleMusicID: Int) async -> MusicKit.Song? {
		switch MusicAuthorization.currentStatus {
		case .authorized:
			return await MusicManager.shared.authorizedMusicRequest(for: appleMusicID)
		default:
			return await MusicManager.shared.unauthorizedMusicRequest(for: appleMusicID)
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
	private func unauthorizedMusicRequest(for appleMusicID: Int) async -> MusicKit.Song? {
		var song: MusicKit.Song?

		if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/us/songs/\(appleMusicID)"), let appleMusicDeveloperToken = KSettings?.appleMusicDeveloperToken {
			urlRequest.httpMethod = "GET"
			urlRequest.addValue("Bearer \(appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

			do {
				let (data, _) = try await URLSession.shared.data(for: urlRequest)
				song = handleMusicResponseData(data)
			} catch {
				print("----- Error unauthorizedMusicRequest", String(describing: error))
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

	/// Plays the give song.
	///
	/// - Parameters:
	///   - song: The song to be played.
	///   - playButton: The button that initiated the action.
	func play(song: MusicKit.Song, playButton: UIButton?) {
		Task {
			switch MusicAuthorization.currentStatus {
			case .authorized:
				do {
					if self.currentSong == song {
						if self.applicationPlayer.state.playbackStatus == .playing {
							await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
							self.applicationPlayer.pause()
						} else {
							await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
							try await self.applicationPlayer.play()
						}
					} else {
						self.applicationPlayer.queue = [song]
						await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
						self.currentSong = song
						try await self.applicationPlayer.play()
					}
				} catch {
					await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
					self.currentSong = nil
					print("----- Error play", String(describing: error))
				}
			default:
				if let songURL = song.previewAssets?.first?.url {
					let playerItem = AVPlayerItem(url: songURL)

					if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
						switch self.player?.timeControlStatus {
						case .playing:
							await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
							await self.player?.pause()
						case .paused:
							await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
							await self.player?.play()
						default: break
						}
					} else {
						self.player = AVPlayer(playerItem: playerItem)
						self.player?.actionAtItemEnd = .none
						self.currentSong = song
						await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
						await self.player?.play()

						NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
							guard let self = self else { return }

							Task {
								self.player = nil
								self.currentSong = nil
								await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
							}
						})
					}
				}
			}
		}
	}
}
