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
import StoreKit

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

	/// The current authorization state.
	var authrizationState: MusicAuthorization.Status {
		return MusicAuthorization.currentStatus
	}

	/// Whether the user has an Apple Music subscription.
	private(set) var hasAMSubscription: Bool = false

	/// The country code of Apple Music.
	private(set) var countryCode: String = "us"

	/// The current playing song.
	@Published private(set) var currentSong: MKSong?

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

		Task {
			do {
				let capabilities = try await SKCloudServiceController().requestCapabilities()
				self.hasAMSubscription = !capabilities.contains(.musicCatalogSubscriptionEligible) && capabilities.contains(.musicCatalogPlayback)
			} catch {
				self.hasAMSubscription = false
			}

			let countryCode = try? await MusicDataRequest.currentCountryCode
			self.countryCode = countryCode ?? "us"
		}
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
	func getSong(for appleMusicID: Int) async -> MKSong? {
		switch (self.authrizationState, self.hasAMSubscription) {
		case (.authorized, true):
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
	private func authorizedMusicRequest(for appleMusicID: Int) async -> MKSong? {
		guard let urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/\(self.countryCode)/songs/\(appleMusicID)?relate=library") else { return nil }
		let musicDataRequest = MusicDataRequest(urlRequest: urlRequest)
		let response = try? await musicDataRequest.response()
		return await self.handleMusicResponseData(response?.data)
	}

	/// Sends a request to Apple Music when the user hasn't authorized the app to use MusicKit.
	///
	/// - Parameters:
	///    - appleMusicID: The id of the music for which the data should be fetched.
	private func unauthorizedMusicRequest(for appleMusicID: Int) async -> MKSong? {
		var song: MKSong?

		if var urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/catalog/\(self.countryCode)/songs/\(appleMusicID)"), let appleMusicDeveloperToken = KSettings?.appleMusicDeveloperToken {
			urlRequest.httpMethod = "GET"
			urlRequest.addValue("Bearer \(appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

			do {
				let (data, _) = try await URLSession.shared.data(for: urlRequest)
				song = await self.handleMusicResponseData(data)
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
	private func handleMusicResponseData(_ data: Data?) async -> MKSong? {
		var song: MKSong?

		if let data = data, let songJSON = try? JSON(data: data) {
			do {
				let songJSONString = songJSON["data"][0]
				let songJSONData = try songJSONString.rawData()
				guard let musicKitSong = MusicKit.Song(from: songJSONData) else { return nil }
				let relationship = await self.getRelationship(json: songJSON)
				let isInLibrary = await self.hasSongInLibrary(relationship: relationship)
				song = MKSong(song: musicKitSong, isInLibrary: isInLibrary, relationship: relationship)
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
	func play(song: MKSong, playButton: UIButton?) {
		Task {
			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
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
						self.applicationPlayer.queue = [song.song]
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
				if let songURL = song.song.previewAssets?.first?.url {
					let playerItem = AVPlayerItem(url: songURL)

					if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
						switch self.player?.timeControlStatus {
						case .playing:
							await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
							await self.player?.pause()
							self.isPlaying = false
						case .paused:
							await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
							await self.player?.play()
							self.isPlaying = true
						default: break
						}
					} else {
						if self.isPlaying {
							self.player = nil
							self.currentSong = nil
							self.isPlaying = false
						}

						self.player = AVPlayer(playerItem: playerItem)
						self.player?.actionAtItemEnd = .none
						self.currentSong = song
						await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
						await self.player?.play()
						self.isPlaying = true

						NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
							guard let self = self else { return }

							Task {
								self.player = nil
								self.currentSong = nil
								self.isPlaying = false
								await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
							}
						})
					}
				}
			}
		}
	}

	/// Add a song to the user's library by using its identifier.
	///
	/// - Parameters:
	///    - song: The song to be added to the library.
	///
	/// - Returns: A `Bool` indicating whether the insert operation was successful or not.
	func add(song: MKSong) async -> Bool {
		guard let url = URL(string: "https://api.music.apple.com/v1/me/library?ids[songs]=\(song.song.id)") else { return false }
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "POST"
		let musicRequest = MusicDataRequest(urlRequest: urlRequest)

		do {
			_ = try await musicRequest.response()
			return true
		} catch {
			print("----- Error adding to library", String(describing: error))
		}

		return false
	}

	/// Get the relationship properties from a song response.
	///
	/// - Parameters:
	///    - json: The JSON object containing the song data.
	///
	/// - Returns: The relationship properties of the song.
	private func getRelationship(json: JSON?) async -> MKSong.Relationship? {
		if let relationshipData = try? json?["data"].array?.first?["relationships"].rawData() {
			do {
				return try JSONDecoder().decode(MKSong.Relationship.self, from: relationshipData)
			} catch {
				print("----- Error decoding", String(describing: error))
				return nil
			}
		}

		return nil
	}

	/// Determine whether a song is in the user's library.
	///
	/// - Parameters:
	///    - json: The JSON object containing the song data.
	///
	/// - Returns: A `Bool` indicating whether the song is in the user's library or not.
	private func hasSongInLibrary(relationship: MKSong.Relationship?) async -> Bool {
		guard let relationship = relationship else { return false }
		guard let libraryID = relationship.library?.data.first?.id else { return false }
		guard let urlRequest = URLRequest(urlString: "https://api.music.apple.com/v1/me/library/songs/\(libraryID)") else { return false }

		let musicDataRequest = MusicDataRequest(urlRequest: urlRequest)
		guard (try? await musicDataRequest.response()) != nil else { return false }

		return true
	}
}
