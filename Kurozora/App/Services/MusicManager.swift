//
//  MusicManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

@preconcurrency import AVFoundation
import Combine
import MusicKit
import StoreKit
import UIKit

// MARK: - SongCache
/// A bounded in-memory cache of `MKSong` values, keyed by Apple Music identifier.
private actor SongCache {
	private let maxEntries = 256
	private var storage: [Int: MKSong] = [:]
	private var insertionOrder: [Int] = []
	private var pending: [Int: Task<MKSong?, Never>] = [:]

	/// Returns the cached song for the given identifier.
	///
	/// - Parameter appleMusicID: The Apple Music catalog identifier.
	///
	/// - Returns: The cached song, or `nil` if the identifier is not cached.
	func song(for appleMusicID: Int) -> MKSong? {
		return self.storage[appleMusicID]
	}

	/// Returns the cached songs for the given identifiers.
	///
	/// - Parameter appleMusicIDs: The Apple Music catalog identifiers to look up.
	///
	/// - Returns: A dictionary of cached songs. Missing keys indicate cache misses.
	func songs(for appleMusicIDs: [Int]) -> [Int: MKSong] {
		var result: [Int: MKSong] = [:]
		for id in appleMusicIDs {
			if let song = self.storage[id] {
				result[id] = song
			}
		}
		return result
	}

	/// Stores a song in the cache, evicting the oldest entry when the cache is full.
	///
	/// - Parameters:
	///    - song: The song to store.
	///    - appleMusicID: The Apple Music catalog identifier to associate with `song`.
	func store(_ song: MKSong, for appleMusicID: Int) {
		if self.storage[appleMusicID] == nil {
			self.insertionOrder.append(appleMusicID)
			if self.insertionOrder.count > self.maxEntries {
				let evicted = self.insertionOrder.removeFirst()
				self.storage.removeValue(forKey: evicted)
			}
		}
		self.storage[appleMusicID] = song
	}

	/// Removes the pending task for the given identifier.
	///
	/// - Parameter appleMusicID: The Apple Music catalog identifier.
	func clearPending(for appleMusicID: Int) {
		self.pending.removeValue(forKey: appleMusicID)
	}

	/// Registers a batch fetch, coalescing concurrent requests by identifier.
	///
	/// For each identifier, an existing pending task is reused when available; otherwise
	/// a new per-identifier task is registered that awaits `sharedTask`.
	///
	/// - Parameters:
	///    - appleMusicIDs: The Apple Music catalog identifiers to register.
	///    - sharedTask: The batch task that produces the fetched songs.
	///
	/// - Returns: A tuple containing the tasks the caller must await and the subset of identifiers the caller is responsible for fetching.
	func registerBatch(
		for appleMusicIDs: [Int],
		sharedTask: Task<[Int: MKSong], Never>
	) -> (pending: [Int: Task<MKSong?, Never>], toFetch: [Int]) {
		var pendingForCaller: [Int: Task<MKSong?, Never>] = [:]
		var toFetch: [Int] = []

		for id in appleMusicIDs {
			if let existing = self.pending[id] {
				pendingForCaller[id] = existing
			} else {
				toFetch.append(id)
			}
		}

		for id in toFetch {
			let perIDTask = Task.detached(priority: nil) {
				let result = await sharedTask.value
				return result[id]
			}
			self.pending[id] = perIDTask
			pendingForCaller[id] = perIDTask
		}

		return (pendingForCaller, toFetch)
	}
}

// MARK: - SetupGate
/// An actor that runs an asynchronous setup block exactly once.
private actor SetupGate {
	private var task: Task<Void, Never>?

	/// Runs `work` the first time it is invoked, and awaits the in-flight task on
	/// subsequent invocations.
	///
	/// - Parameter work: The asynchronous setup block to execute.
	func runOnce(_ work: @Sendable @escaping () async -> Void) async {
		if let task {
			await task.value
			return
		}
		let task = Task<Void, Never> { await work() }
		self.task = task
		await task.value
	}
}

// MARK: - AppleMusicSongResponse
/// A decoded response from the Apple Music catalog songs endpoint.
private struct AppleMusicSongResponse: Decodable {
	let data: [Datum]

	struct Datum: Decodable {
		let song: MusicKit.Song
		let relationships: MKSong.Relationship?

		private enum CodingKeys: String, CodingKey {
			case relationships
		}

		init(from decoder: Decoder) throws {
			self.song = try MusicKit.Song(from: decoder)
			let container = try? decoder.container(keyedBy: CodingKeys.self)
			self.relationships = try container?.decodeIfPresent(MKSong.Relationship.self, forKey: .relationships)
		}
	}
}

// MARK: - MusicManager
/// A singleton that coordinates Apple Music catalog fetches, playback, and library mutations for the app.
final class MusicManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `MusicManager`.
	static let shared = MusicManager()

	/// The shared `ApplicationMusicPlayer` used for full-track playback.
	private let applicationPlayer = ApplicationMusicPlayer.shared

	/// The player used to stream song previews for unauthorized users.
	var player: AVPlayer?

	/// The observer token for the current preview item's end-of-playback notification.
	private var endTimeObserver: NSObjectProtocol?

	/// The set of Combine subscriptions retained by the manager.
	private var subscriptions = Set<AnyCancellable>()

	/// The current MusicKit authorization status.
	var authorizationState: MusicAuthorization.Status {
		return MusicAuthorization.currentStatus
	}

	// MARK: Configuration
	private let stateLock = NSLock()
	private var _hasAMSubscription: Bool = false
	private var _countryCode: String = "us"

	/// A Boolean value that indicates whether the user has an active Apple Music
	/// subscription.
	var hasAMSubscription: Bool {
		self.stateLock.lock()
		defer { self.stateLock.unlock() }
		return self._hasAMSubscription
	}

	/// The ISO storefront country code used for Apple Music catalog requests.
	var countryCode: String {
		self.stateLock.lock()
		defer { self.stateLock.unlock() }
		return self._countryCode
	}

	private let songCache = SongCache()
	private let setupGate = SetupGate()

	/// The song currently loaded in the player, or `nil` if no song is loaded.
	@Published private(set) var currentSong: MKSong?

	/// The Kurozora model associated with the current song, or `nil` if unavailable.
	@Published private(set) var currentKKSong: KKSong?

	/// A Boolean value that indicates whether a song is currently playing.
	@Published private(set) var isPlaying: Bool = false

	// MARK: - Initializers
	override private init() {
		super.init()

		self.applicationPlayer.state.objectWillChange
			.receive(on: RunLoop.main).sink { [weak self] in
				guard let self = self else { return }
				self.isPlaying = ApplicationMusicPlayer.shared.state.playbackStatus == .playing
			}
			.store(in: &self.subscriptions)
	}

	// MARK: - Setup
	/// Requests MusicKit authorization and resolves the user's subscription and
	/// storefront state. Subsequent calls await the original setup.
	private func ensureSetup() async {
		await self.setupGate.runOnce { [weak self] in
			guard let self else { return }
			_ = await MusicAuthorization.request()

			do {
				if #available(iOS 18.0, *) {
					let currentMusicSubscription = try await MusicSubscription.current
					self.setHasAMSubscription(
						!currentMusicSubscription.canBecomeSubscriber
						&& currentMusicSubscription.canPlayCatalogContent
					)
				} else {
					let capabilities = try await SKCloudServiceController().requestCapabilities()
					self.setHasAMSubscription(
						!capabilities.contains(.musicCatalogSubscriptionEligible)
						&& capabilities.contains(.musicCatalogPlayback)
					)
				}
			} catch {
				print("----- [Error] MusicKit setup failed: \(error.localizedDescription)")
				self.setHasAMSubscription(false)
			}

			let countryCode = try? await MusicDataRequest.currentCountryCode
			self.setCountryCode(countryCode ?? "us")
		}
	}

	private func setHasAMSubscription(_ value: Bool) {
		self.stateLock.lock()
		defer { self.stateLock.unlock() }
		self._hasAMSubscription = value
	}

	private func setCountryCode(_ value: String) {
		self.stateLock.lock()
		defer { self.stateLock.unlock() }
		self._countryCode = value
	}

	// MARK: - Fetching
	/// The maximum number of identifiers per Apple Music catalog request.
	private static let batchChunkSize = 300

	/// Returns the song with the given Apple Music identifier.
	///
	/// - Parameter appleMusicID: The Apple Music catalog identifier of the song.
	///
	/// - Returns: The fetched song, or `nil` if the fetch fails.
	func getSong(for appleMusicID: Int) async -> MKSong? {
		let result = await self.getSongs(for: [appleMusicID])
		return result[appleMusicID]
	}

	/// Returns the songs with the given Apple Music identifiers.
	///
	/// Cached songs are returned immediately, in-flight fetches are coalesced, and the
	/// remaining identifiers are batched into catalog requests.
	///
	/// - Parameter appleMusicIDs: The Apple Music catalog identifiers to fetch.
	///
	/// - Returns: A dictionary keyed by Apple Music identifier. Missing keys indicate fetch failures.
	func getSongs(for appleMusicIDs: [Int]) async -> [Int: MKSong] {
		guard !appleMusicIDs.isEmpty else { return [:] }
		let uniqueIDs = Array(Set(appleMusicIDs))

		var result = await self.songCache.songs(for: uniqueIDs)
		let missing = uniqueIDs.filter { result[$0] == nil }
		guard !missing.isEmpty else { return result }

		let sharedTask = Task.detached(priority: nil) { [weak self] () -> [Int: MKSong] in
			guard let self else { return [:] }
			return await self.fetchSongs(for: missing)
		}

		let (pendingMap, toFetch) = await self.songCache.registerBatch(for: missing, sharedTask: sharedTask)

		for (id, task) in pendingMap {
			if let song = await task.value {
				result[id] = song
			}
		}

		for id in toFetch {
			if let song = result[id] {
				await self.songCache.store(song, for: id)
			}
			await self.songCache.clearPending(for: id)
		}

		return result
	}

	private func fetchSongs(for appleMusicIDs: [Int]) async -> [Int: MKSong] {
		await self.ensureSetup()

		let authorized: Bool
		switch (self.authorizationState, self.hasAMSubscription) {
		case (.authorized, true):
			authorized = true
		default:
			authorized = false
		}

		var result: [Int: MKSong] = [:]
		let chunkSize = Self.batchChunkSize
		for start in stride(from: 0, to: appleMusicIDs.count, by: chunkSize) {
			let end = min(start + chunkSize, appleMusicIDs.count)
			let chunk = Array(appleMusicIDs[start..<end])
			let data = await self.requestSongs(for: chunk, authorized: authorized)
			let decoded = self.decodeSongs(from: data)
			result.merge(decoded) { _, new in new }
		}
		return result
	}

	private func requestSongs(for appleMusicIDs: [Int], authorized: Bool) async -> Data? {
		let idList = appleMusicIDs.map(String.init).joined(separator: ",")
		var urlString = "https://api.music.apple.com/v1/catalog/\(self.countryCode)/songs?ids=\(idList)"
		if authorized {
			urlString += "&relate=library"
		}
		guard let url = URL(string: urlString) else { return nil }

		if authorized {
			let urlRequest = URLRequest(url: url)
			let musicDataRequest = MusicDataRequest(urlRequest: urlRequest)
			let response = try? await musicDataRequest.response()
			return response?.data
		}

		guard let appleMusicDeveloperToken = KSettings?.appleMusicDeveloperToken else { return nil }
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("Bearer \(appleMusicDeveloperToken)", forHTTPHeaderField: "Authorization")

		do {
			let (data, _) = try await URLSession.shared.data(for: urlRequest)
			return data
		} catch {
			print("----- [Error] Unauthorized music request failed: \(error.localizedDescription)")
			return nil
		}
	}

	private func decodeSongs(from data: Data?) -> [Int: MKSong] {
		guard
			let data,
			let response = try? JSONDecoder().decode(AppleMusicSongResponse.self, from: data)
		else { return [:] }

		var result: [Int: MKSong] = [:]
		for datum in response.data {
			guard let appleMusicID = Int(datum.song.id.rawValue) else { continue }
			let isInLibrary = datum.relationships?.library?.data.first != nil
			result[appleMusicID] = MKSong(song: datum.song, isInLibrary: isInLibrary, relationship: datum.relationships)
		}
		return result
	}

	// MARK: - Playback
	/// Plays the given song, falling back to a 30-second preview when the user is not
	/// authorized for full playback.
	///
	/// - Parameters:
	///    - song: The song to play.
	///    - playButton: The button that initiated playback, if any. The button's image
	///     is updated to reflect the playback state during preview playback.
	///    - kkSong: The Kurozora model associated with `song`, if available.
	func play(song: MKSong, playButton: UIButton?, kkSong: KKSong? = nil) {
		Task { [weak self] in
			guard let self else { return }
			await self.ensureSetup()

			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
				await self.playWithMusicKit(song: song, kkSong: kkSong)
			default:
				await self.playPreview(song: song, playButton: playButton, kkSong: kkSong)
			}
		}
	}

	private func playWithMusicKit(song: MKSong, kkSong: KKSong?) async {
		do {
			if self.currentSong == song {
				if self.applicationPlayer.state.playbackStatus == .playing {
					self.applicationPlayer.pause()
				} else {
					try await self.applicationPlayer.play()
				}
			} else {
				self.applicationPlayer.queue = [song.song]
				self.currentSong = song
				self.currentKKSong = kkSong
				try await self.applicationPlayer.play()
			}
		} catch {
			self.currentSong = nil
			self.currentKKSong = nil
			print("----- [Error] MusicKit playback failed: \(error.localizedDescription)")
		}
	}

	private func playPreview(song: MKSong, playButton: UIButton?, kkSong: KKSong?) async {
		guard let songURL = song.song.previewAssets?.first?.url else { return }
		let playerItem = AVPlayerItem(url: songURL)

		if await (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
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
			return
		}

		await self.tearDownPreviewPlayer()

		let player = AVPlayer(playerItem: playerItem)
		player.actionAtItemEnd = .none
		self.player = player
		self.currentSong = song
		self.currentKKSong = kkSong
		await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		await player.play()
		self.isPlaying = true

		self.endTimeObserver = NotificationCenter.default.addObserver(
			forName: .AVPlayerItemDidPlayToEndTime,
			object: playerItem,
			queue: .main
		) { [weak self, weak playButton] _ in
			guard let self else { return }
			Task { @MainActor in
				await self.tearDownPreviewPlayer()
				playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
			}
		}
	}

	private func tearDownPreviewPlayer() async {
		if let token = self.endTimeObserver {
			NotificationCenter.default.removeObserver(token)
			self.endTimeObserver = nil
		}
		await self.player?.pause()
		self.player = nil
		self.currentSong = nil
		self.currentKKSong = nil
		self.isPlaying = false
	}

	// MARK: - Library
	/// Adds the given song to the user's Apple Music library.
	///
	/// - Parameter song: The song to add.
	/// - Returns: `true` if the song was added successfully; otherwise, `false`.
	func add(song: MKSong) async -> Bool {
		guard let url = URL(string: "https://api.music.apple.com/v1/me/library?ids[songs]=\(song.song.id)") else { return false }
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "POST"
		let musicRequest = MusicDataRequest(urlRequest: urlRequest)

		do {
			_ = try await musicRequest.response()
			if let appleMusicID = Int(song.song.id.rawValue) {
				let updated = MKSong(song: song.song, isInLibrary: true, relationship: song.relationship)
				await self.songCache.store(updated, for: appleMusicID)
			}
			return true
		} catch {
			print("----- [Error] Add to library failed: \(error.localizedDescription)")
		}

		return false
	}
}

// MARK: - MediaPlaybackControlling
extension MusicManager: MediaPlaybackControlling {
	var currentSongPublisher: Published<MKSong?>.Publisher {
		return self.$currentSong
	}

	var currentKKSongPublisher: Published<KKSong?>.Publisher {
		return self.$currentKKSong
	}

	var isPlayingPublisher: Published<Bool>.Publisher {
		return self.$isPlaying
	}

	func togglePlayPause() {
		guard let song = self.currentSong else { return }
		self.play(song: song, playButton: nil)
	}
}
