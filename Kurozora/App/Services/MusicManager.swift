//
//  MusicManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

@preconcurrency import AVFoundation
import Combine
import Kingfisher
import MusicKit
import StoreKit
import UIKit
import UserNotifications

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

	/// Registers a batch fetch, reusing any task already pending for an identifier.
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

	/// The display link that drives playback progress updates while a song is playing.
	private var progressDisplayLink: CADisplayLink?

	/// The current MusicKit authorization status.
	var authorizationState: MusicAuthorization.Status {
		return MusicAuthorization.currentStatus
	}

	/// A Boolean value that indicates whether playback can be time-synced to lyrics.
	var canTimeSync: Bool {
		return self.authorizationState == .authorized && self.hasAMSubscription
	}

	/// The current playback position in seconds of the active player.
	var currentPlaybackSeconds: TimeInterval {
		guard !self.isQueueDormant else { return self.dormantPositionSeconds }

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			return self.applicationPlayer.playbackTime
		default:
			let previewSeconds = self.player?.currentTime().seconds
			return previewSeconds?.isFinite == true ? previewSeconds ?? 0 : 0
		}
	}

	/// The total duration in seconds of the active player's current item.
	var currentDurationSeconds: TimeInterval {
		guard !self.isQueueDormant else { return self.currentSong?.song.duration ?? 0 }

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			return self.currentSong?.song.duration ?? 0
		default:
			let previewDuration = self.player?.currentItem?.duration.seconds
			return previewDuration?.isFinite == true ? previewDuration ?? 0 : 0
		}
	}

	/// Seeks the active player to the given position in seconds.
	///
	/// - Parameter seconds: The position to seek to.
	func seek(toSeconds seconds: TimeInterval) {
		let target = max(0, seconds)

		guard !self.isQueueDormant else {
			self.dormantPositionSeconds = target
			self.refreshProgressWhilePaused(position: target)
			return
		}

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			self.applicationPlayer.playbackTime = target
		default:
			self.player?.seek(to: CMTime(seconds: target, preferredTimescale: 600))
		}
	}

	/// Seeks the active player by a relative offset within the current song.
	///
	/// - Parameter seconds: The signed number of seconds to move by.
	func seek(bySeconds seconds: TimeInterval) {
		let duration = self.currentDurationSeconds
		let target = max(0, self.currentPlaybackSeconds + seconds)
		let clamped = duration > 0 ? min(target, duration) : target

		self.seek(toSeconds: clamped)
		self.refreshProgressWhilePaused(position: clamped)
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

	/// The active player's playback progress.
	@Published private(set) var playbackProgress: PlaybackProgress = .zero

	/// Whether shuffle is enabled.
	@Published private(set) var shuffleEnabled: Bool = false

	/// The current repeat mode.
	@Published private(set) var repeatMode: PlaybackRepeatMode = .off

	/// The category the song change notification carries when skipping is offered.
	static let songChangeCategoryIdentifier = "musicSongChange"

	/// The action identifier of the song change notification's skip button.
	static let skipActionIdentifier = "musicSongChangeSkip"

	/// Whether a different song follows the current one.
	///
	/// A single song, or one repeating on its own, has nothing to skip to.
	var hasNextSong: Bool {
		return self.repeatMode != .one && self.queueSongs.count > 1
	}

	/// The songs in the current playback queue.
	private var queueSongs: [MKSong] = []

	/// The Kurozora models aligned by index with `queueSongs`.
	private var queueKKSongs: [KKSong] = []

	/// The index of the current song in the preview queue.
	private var previewQueueIndex: Int = 0

	/// Whether the queue was restored from a previous session and no player holds it yet.
	private var isQueueDormant = false

	/// Where a dormant queue resumes from, in seconds.
	private var dormantPositionSeconds: TimeInterval = 0

	/// The subscription to the application player's queue changes.
	private var queueSubscription: AnyCancellable?

	// MARK: - Initializers
	override private init() {
		super.init()

		self.applicationPlayer.state.objectWillChange
			.receive(on: RunLoop.main).sink { [weak self] in
				guard let self = self else { return }
				self.isPlaying = ApplicationMusicPlayer.shared.state.playbackStatus == .playing
			}
			.store(in: &self.subscriptions)

		self.$isPlaying
			.receive(on: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] isPlaying in
				guard let self = self else { return }
				if isPlaying {
					self.startProgressUpdates()
				} else {
					self.stopProgressUpdates()
				}
			}
			.store(in: &self.subscriptions)

		self.$currentSong
			.receive(on: RunLoop.main)
			.map { $0 == nil }
			.removeDuplicates()
			.sink { [weak self] isCleared in
				guard let self = self, isCleared else { return }
				self.playbackProgress = .zero
			}
			.store(in: &self.subscriptions)

		self.$currentSong
			.receive(on: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] song in
				guard let self = self else { return }
				self.postSongChangeNotificationIfNeeded(for: song)
				self.saveQueue()
			}
			.store(in: &self.subscriptions)

		NotificationCenter.default.addObserver(self, selector: #selector(self.saveQueue), name: UIApplication.willTerminateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.saveQueue), name: UIApplication.didEnterBackgroundNotification, object: nil)
	}

	/// Posts a local notification announcing the given song while the app is in the background.
	///
	/// - Parameter song: The song that started playing.
	private func postSongChangeNotificationIfNeeded(for song: MKSong?) {
		guard
			UserSettings.musicSongChangeNotificationsEnabled,
			let song = song,
			UIApplication.shared.applicationState != .active
		else { return }

		let content = UNMutableNotificationContent()
		content.title = song.song.title
		content.body = song.song.artistName

		if self.hasNextSong {
			content.categoryIdentifier = Self.songChangeCategoryIdentifier
		}

		let artworkURL = song.song.artwork?.url(width: 512, height: 512)

		Task {
			if let attachment = await Self.artworkAttachment(for: artworkURL) {
				content.attachments = [attachment]
			}

			let request = UNNotificationRequest(identifier: "musicSongChange", content: content, trigger: nil)
			try? await UNUserNotificationCenter.current().add(request)
		}
	}

	/// Fetches the artwork and writes it somewhere the notification can attach it from.
	///
	/// - Parameter url: The artwork's address.
	///
	/// - Returns: The attachment carrying the artwork.
	private static func artworkAttachment(for url: URL?) async -> UNNotificationAttachment? {
		guard let url = url else { return nil }

		return await withCheckedContinuation { continuation in
			KingfisherManager.shared.retrieveImage(with: url) { result in
				guard
					let image = try? result.get().image,
					let data = image.jpegData(compressionQuality: 0.9)
				else {
					continuation.resume(returning: nil)
					return
				}

				let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")

				do {
					try data.write(to: fileURL)
					continuation.resume(returning: try UNNotificationAttachment(identifier: "artwork", url: fileURL, options: nil))
				} catch {
					continuation.resume(returning: nil)
				}
			}
		}
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
	private let batchChunkSize = 300

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
	/// Serves cached songs immediately and batches the rest into catalog requests.
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
		let chunkSize = self.batchChunkSize
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
	func play(song: MKSong, playButton: UIButton? = nil, kkSong: KKSong? = nil) {
		self.play(songs: [song], kkSongs: kkSong.map { [$0] } ?? [], startingAt: 0, playButton: playButton)
	}

	/// Plays the song at the given index of a queue, falling back to a 30-second preview when the
	/// user is not authorized for full playback.
	///
	/// - Parameters:
	///    - songs: The songs forming the playback queue.
	///    - kkSongs: The Kurozora models aligned by index with `songs`, when available.
	///    - index: The index of the song to start playing.
	///    - playButton: The button that initiated playback, if any.
	func play(songs: [MKSong], kkSongs: [KKSong] = [], startingAt index: Int, playButton: UIButton? = nil) {
		guard songs.indices.contains(index) else { return }
		let song = songs[index]

		Task { [weak self] in
			guard let self else { return }
			await self.ensureSetup()

			self.queueSongs = songs
			self.queueKKSongs = songs.count == kkSongs.count ? kkSongs : []
			self.previewQueueIndex = index

			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
				await self.playWithMusicKit(song: song, startingAt: index)
			default:
				await self.playPreview(song: song, playButton: playButton, kkSong: self.kkSong(at: index))
			}

			// A queue a player now holds is no longer the restored one.
			self.isQueueDormant = false
			self.dormantPositionSeconds = 0
		}
	}

	/// Plays the song at the given index of a queue built from the given Kurozora songs.
	///
	/// - Parameters:
	///    - kkSongs: The Kurozora songs forming the playback queue, aligned by index with the caller's items.
	///    - index: The index of the song to start playing.
	func play(kkSongs: [KKSong?], startingAt index: Int) {
		guard kkSongs.indices.contains(index) else { return }

		Task { [weak self] in
			guard let self else { return }

			let songsByID = await self.getSongs(for: kkSongs.compactMap { $0?.attributes.amID })

			var queueSongs: [MKSong] = []
			var queueKKSongs: [KKSong] = []
			var startIndex = 0

			for (offset, kkSong) in kkSongs.enumerated() {
				if offset == index {
					startIndex = queueSongs.count
				}

				guard
					let kkSong = kkSong,
					let appleMusicID = kkSong.attributes.amID,
					let song = songsByID[appleMusicID]
				else { continue }

				queueSongs.append(song)
				queueKKSongs.append(kkSong)
			}

			guard !queueSongs.isEmpty else { return }

			self.play(songs: queueSongs, kkSongs: queueKKSongs, startingAt: min(startIndex, queueSongs.count - 1))
		}
	}

	/// Plays the given song with the application player.
	///
	/// - Parameters:
	///    - song: The song to play.
	///    - index: The index in the queue at which playback should begin.
	private func playWithMusicKit(song: MKSong, startingAt index: Int) async {
		// A dormant queue has no player to toggle.
		if self.currentSong == song, !self.isQueueDormant {
			do {
				if self.applicationPlayer.state.playbackStatus == .playing {
					self.applicationPlayer.pause()
				} else {
					try await self.applicationPlayer.play()
				}
			} catch {
				print("----- [Error] MusicKit playback failed: \(error.localizedDescription)")
			}
			return
		}

		do {
			#if !targetEnvironment(macCatalyst)
			if #available(iOS 18.0, *) {
				self.applicationPlayer.transition = UserSettings.musicCrossfadeEnabled
					? .crossfade(duration: TimeInterval(UserSettings.musicCrossfadeDuration.rawValue))
					: .none
			}
			#endif

			let queuedSongs = Array(self.queueSongs[index...])
			self.applicationPlayer.queue = ApplicationMusicPlayer.Queue(for: queuedSongs.map { $0.song })
			self.applicationPlayer.state.shuffleMode = self.shuffleEnabled ? .songs : .off
			self.applicationPlayer.state.repeatMode = self.repeatMode.musicKitRepeatMode
			self.observeQueue()
			self.currentSong = song
			self.currentKKSong = self.kkSong(for: song)
			try await self.applicationPlayer.play()
		} catch {
			print("----- [Error] MusicKit playback failed: \(error.localizedDescription)")
		}
	}

	/// Plays the given preview.
	///
	/// - Parameters:
	///    - song: The song whose preview to play.
	///    - playButton: The button to reflect the play state on, if any.
	///    - kkSong: The Kurozora model associated with `song`, if available.
	///    - restart: Whether to restart from the beginning when `song` is already loaded, instead of toggling play/pause.
	///    - resumePlayback: Whether to begin playback after loading. When `false`, the song loads paused at its start.
	private func playPreview(song: MKSong, playButton: UIButton?, kkSong: KKSong?, restart: Bool = false, resumePlayback: Bool = true) async {
		guard let songURL = song.song.previewAssets?.first?.url else { return }
		let playerItem = AVPlayerItem(url: songURL)

		if await (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
			if restart {
				self.seek(toSeconds: 0)
				if resumePlayback {
					await self.player?.play()
					self.isPlaying = true
				} else {
					await self.player?.pause()
					self.isPlaying = false
					self.refreshProgressWhilePaused(position: 0)
				}
			} else {
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
			}
			return
		}

		await self.tearDownPreviewPlayer()

		let player = AVPlayer(playerItem: playerItem)
		player.actionAtItemEnd = .none
		self.player = player
		self.currentSong = song
		self.currentKKSong = kkSong

		if resumePlayback {
			await playButton?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
			await player.play()
			self.isPlaying = true
		} else {
			await playButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
			self.isPlaying = false
			self.refreshProgressWhilePaused(position: 0)
		}

		self.endTimeObserver = NotificationCenter.default.addObserver(
			forName: .AVPlayerItemDidPlayToEndTime,
			object: playerItem,
			queue: .main
		) { [weak self] _ in
			guard let self else { return }
			Task { @MainActor in
				await self.handlePreviewEnded()
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

	// MARK: - Queue
	/// Re-subscribes to the application player's queue to track the current entry.
	private func observeQueue() {
		self.queueSubscription = self.applicationPlayer.queue.objectWillChange
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.syncCurrentEntry()
			}
	}

	/// Syncs the current song and Kurozora model from the application player's current entry.
	private func syncCurrentEntry() {
		guard
			let itemID = self.applicationPlayer.queue.currentEntry?.item?.id,
			let mkSong = self.queueSongs.first(where: { $0.song.id == itemID })
		else { return }

		self.currentSong = mkSong
		self.currentKKSong = self.kkSong(for: mkSong)
		self.refreshProgressWhilePaused()
	}

	/// Advances to the next song in the queue, honoring the repeat mode.
	func skipForward() {
		Task { [weak self] in
			guard let self else { return }

			guard !self.isQueueDormant else {
				self.moveDormantQueue(by: 1)
				return
			}

			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
				let wasPlaying = self.isPlaying
				switch self.repeatMode {
				case .one:
					self.applicationPlayer.restartCurrentEntry()
				case .off where self.isAtLastQueueEntry:
					self.endMusicKitPlayback()
					return
				default:
					try? await self.applicationPlayer.skipToNextEntry()
				}
				if !wasPlaying {
					self.applicationPlayer.pause()
				}
			default:
				await self.skipPreview(by: 1, resumePlayback: self.isPlaying)
			}
		}
	}

	/// Whether the application player is positioned on the last entry of its queue.
	private var isAtLastQueueEntry: Bool {
		guard let currentEntry = self.applicationPlayer.queue.currentEntry else { return false }
		return self.applicationPlayer.queue.entries.last?.id == currentEntry.id
	}

	/// Ends application player playback and clears the now-playing state.
	private func endMusicKitPlayback() {
		self.queueSubscription?.cancel()
		self.queueSubscription = nil
		self.applicationPlayer.stop()
		self.currentSong = nil
		self.currentKKSong = nil
		self.isPlaying = false
	}

	/// Steps to the previous song, restarting the current one when it is already underway.
	func skipBackward() {
		Task { [weak self] in
			guard let self else { return }

			if self.currentPlaybackSeconds > 3 {
				self.seek(toSeconds: 0)
				self.refreshProgressWhilePaused(position: 0)
				return
			}

			guard !self.isQueueDormant else {
				self.moveDormantQueue(by: -1)
				return
			}

			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
				let wasPlaying = self.isPlaying
				if self.repeatMode == .one {
					self.applicationPlayer.restartCurrentEntry()
				} else {
					try? await self.applicationPlayer.skipToPreviousEntry()
				}
				if !wasPlaying {
					self.applicationPlayer.pause()
				}
				self.refreshProgressWhilePaused(position: 0)
			default:
				await self.skipPreview(by: -1, resumePlayback: self.isPlaying)
			}
		}
	}

	/// Toggles shuffle on or off.
	func toggleShuffle() {
		self.shuffleEnabled.toggle()

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			self.applicationPlayer.state.shuffleMode = self.shuffleEnabled ? .songs : .off
		default:
			break
		}
	}

	/// Advances the repeat mode to its next state.
	func cycleRepeat() {
		self.repeatMode = switch self.repeatMode {
		case .off: .all
		case .all: .one
		case .one: .off
		}

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			self.applicationPlayer.state.repeatMode = self.repeatMode.musicKitRepeatMode
		default:
			break
		}
	}

	/// Plays the song reached by moving `offset` positions through the preview queue, honoring the repeat mode.
	///
	/// - Parameters:
	///    - offset: The signed number of songs to move by.
	///    - resumePlayback: Whether the reached song begins playing.
	private func skipPreview(by offset: Int, resumePlayback: Bool) async {
		guard !self.queueSongs.isEmpty else { return }

		if self.repeatMode == .one {
			if let song = self.currentSong {
				await self.playPreview(song: song, playButton: nil, kkSong: self.currentKKSong, restart: true, resumePlayback: resumePlayback)
			}
			return
		}

		var newIndex = self.previewQueueIndex + offset

		if newIndex >= self.queueSongs.count {
			guard self.repeatMode == .all else {
				await self.tearDownPreviewPlayer()
				return
			}
			newIndex = 0
		} else if newIndex < 0 {
			newIndex = self.repeatMode == .all ? self.queueSongs.count - 1 : 0
		}

		self.previewQueueIndex = newIndex
		await self.playPreview(song: self.queueSongs[newIndex], playButton: nil, kkSong: self.kkSong(at: newIndex), restart: true, resumePlayback: resumePlayback)
	}

	/// Advances the preview player when the current preview reaches its end.
	private func handlePreviewEnded() async {
		await self.skipPreview(by: 1, resumePlayback: true)
	}

	private func kkSong(at index: Int) -> KKSong? {
		return index < self.queueKKSongs.count ? self.queueKKSongs[index] : nil
	}

	private func kkSong(for song: MKSong) -> KKSong? {
		guard
			let index = self.queueSongs.firstIndex(where: { $0 == song }),
			index < self.queueKKSongs.count
		else { return nil }
		return self.queueKKSongs[index]
	}

	// MARK: - Session
	/// Saves the queue so the next launch picks it up where this one left off.
	@objc private func saveQueue() {
		// Nothing has played yet, which is not a queue worth forgetting.
		guard !self.queueSongs.isEmpty else { return }

		guard self.queueKKSongs.count == self.queueSongs.count else {
			MusicQueueStore.clear()
			return
		}

		let index = self.currentSong.flatMap { song in self.queueSongs.firstIndex(of: song) } ?? self.previewQueueIndex
		let snapshot = MusicQueueStore.Snapshot(
			songs: self.queueSongs,
			kkSongs: self.queueKKSongs,
			index: index,
			positionSeconds: self.currentPlaybackSeconds,
			shuffleEnabled: self.shuffleEnabled,
			repeatMode: self.repeatMode
		)

		MusicQueueStore.save(snapshot)
	}

	/// Loads the queue the previous session left behind.
	///
	/// Playback begins only once it is asked for.
	func restoreQueue() {
		guard self.queueSongs.isEmpty, self.currentSong == nil else { return }
		guard
			let snapshot = MusicQueueStore.load(),
			snapshot.songs.indices.contains(snapshot.index),
			snapshot.kkSongs.count == snapshot.songs.count
		else { return }

		self.queueSongs = snapshot.songs
		self.queueKKSongs = snapshot.kkSongs
		self.previewQueueIndex = snapshot.index
		self.shuffleEnabled = snapshot.shuffleEnabled
		self.repeatMode = snapshot.repeatMode
		self.dormantPositionSeconds = snapshot.positionSeconds
		self.isQueueDormant = true
		self.currentSong = snapshot.songs[snapshot.index]
		self.currentKKSong = self.kkSong(at: snapshot.index)
		self.refreshProgressWhilePaused(position: snapshot.positionSeconds)
	}

	/// Hands the dormant queue to a player and resumes it where the last session left off.
	private func wakeQueue() async {
		guard self.queueSongs.indices.contains(self.previewQueueIndex) else { return }

		let index = self.previewQueueIndex
		let position = self.dormantPositionSeconds

		await self.ensureSetup()

		switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
		case (.authorized, true):
			await self.playWithMusicKit(song: self.queueSongs[index], startingAt: index)
		default:
			await self.playPreview(song: self.queueSongs[index], playButton: nil, kkSong: self.kkSong(at: index))
		}

		self.isQueueDormant = false
		self.dormantPositionSeconds = 0

		guard position > 0 else { return }
		self.seek(toSeconds: position)
	}

	/// Steps the dormant queue by the given offset, leaving the player asleep.
	///
	/// - Parameter offset: The signed number of songs to move by.
	private func moveDormantQueue(by offset: Int) {
		guard !self.queueSongs.isEmpty else { return }

		var index = self.previewQueueIndex

		// A song repeating on its own has nowhere to move to, so it starts over instead.
		if self.repeatMode != .one {
			index += offset

			if index >= self.queueSongs.count {
				index = self.repeatMode == .all ? 0 : self.queueSongs.count - 1
			} else if index < 0 {
				index = self.repeatMode == .all ? self.queueSongs.count - 1 : 0
			}
		}

		self.previewQueueIndex = index
		self.dormantPositionSeconds = 0
		self.currentSong = self.queueSongs[index]
		self.currentKKSong = self.kkSong(at: index)
		self.refreshProgressWhilePaused(position: 0)
	}

	// MARK: - Progress
	/// Starts the display link that publishes playback progress.
	private func startProgressUpdates() {
		guard self.progressDisplayLink == nil else { return }

		let displayLink = CADisplayLink(target: self, selector: #selector(self.updateProgress))
		displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 8, maximum: 30, preferred: 15)
		displayLink.add(to: .main, forMode: .common)
		self.progressDisplayLink = displayLink

		self.updateProgress()
	}

	/// Stops the display link and captures the final playback position.
	private func stopProgressUpdates() {
		self.progressDisplayLink?.invalidate()
		self.progressDisplayLink = nil

		if self.currentSong != nil {
			self.updateProgress()
		}
	}

	/// Publishes a snapshot of the active player's current position and duration.
	@objc private func updateProgress() {
		let duration = self.currentDurationSeconds
		let safeDuration = duration.isFinite && duration > 0 ? duration : 0
		self.playbackProgress = PlaybackProgress(currentSeconds: self.currentPlaybackSeconds, durationSeconds: safeDuration)
	}

	/// Publishes a progress snapshot while paused.
	///
	/// - Parameter position: The position to publish. Pass `nil` to read the live player position.
	private func refreshProgressWhilePaused(position: TimeInterval? = nil) {
		guard !self.isPlaying else { return }

		let publish: () -> Void = { [weak self] in
			guard let self, !self.isPlaying else { return }

			guard let position = position else {
				self.updateProgress()
				return
			}

			let duration = self.currentDurationSeconds
			let safeDuration = duration.isFinite && duration > 0 ? duration : 0
			self.playbackProgress = PlaybackProgress(currentSeconds: max(0, position), durationSeconds: safeDuration)
		}

		if Thread.isMainThread {
			publish()
		} else {
			DispatchQueue.main.async(execute: publish)
		}
	}

	// MARK: - Library
	/// Adds the given song to the user's Apple Music library.
	///
	/// - Parameter song: The song to add.
	/// - Returns: Whether the song was added.
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

	var playbackProgressPublisher: Published<PlaybackProgress>.Publisher {
		return self.$playbackProgress
	}

	var shuffleEnabledPublisher: Published<Bool>.Publisher {
		return self.$shuffleEnabled
	}

	var repeatModePublisher: Published<PlaybackRepeatMode>.Publisher {
		return self.$repeatMode
	}

	func togglePlayPause() {
		guard self.currentSong != nil else { return }

		Task { [weak self] in
			guard let self else { return }

			guard !self.isQueueDormant else {
				await self.wakeQueue()
				return
			}

			switch (MusicAuthorization.currentStatus, self.hasAMSubscription) {
			case (.authorized, true):
				if self.applicationPlayer.state.playbackStatus == .playing {
					self.applicationPlayer.pause()
				} else {
					try? await self.applicationPlayer.play()
				}
			default:
				switch self.player?.timeControlStatus {
				case .playing:
					await self.player?.pause()
					self.isPlaying = false
				case .paused:
					await self.player?.play()
					self.isPlaying = true
				default:
					break
				}
			}
		}
	}
}

// MARK: - PlaybackRepeatMode
extension PlaybackRepeatMode {
	/// The equivalent MusicKit repeat mode.
	var musicKitRepeatMode: MusicKit.MusicPlayer.RepeatMode {
		switch self {
		case .off: return .none
		case .all: return .all
		case .one: return .one
		}
	}
}
