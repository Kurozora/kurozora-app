//
//  FloatingLyricsManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import AVKit
import Combine
import CoreImage
import Kingfisher
import KurozoraKit
import Obfuscation
import UIKit

/// A singleton that drives the floating lyrics Picture-in-Picture window.
final class FloatingLyricsManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `FloatingLyricsManager`.
	static let shared = FloatingLyricsManager()

	/// A Boolean value that indicates whether the Picture-in-Picture window is showing.
	@Published private(set) var isPictureInPictureActive = false

	/// A Boolean value that indicates whether playback can be time-synced to lyrics.
	var canTimeSync: Bool {
		return MusicManager.shared.canTimeSync
	}

	/// A Boolean value that indicates whether the device supports Picture-in-Picture.
	var isPictureInPictureSupported: Bool {
		return AVPictureInPictureController.isPictureInPictureSupported()
	}

	/// The maximum number of songs kept in the lyrics cache.
	private let lyricsCacheLimit = 16

	/// The context used to average artwork colors.
	private let colorContext = CIContext(options: [.workingColorSpace: NSNull()])

	/// The Picture-in-Picture controller, created once a synced song is available.
	private var pictureInPictureController: AVPictureInPictureController?

	/// The observation that fires a pending start once Picture-in-Picture becomes possible.
	private var startPossibleObservation: NSKeyValueObservation?

	/// Whether a start request is waiting for the controller to become ready.
	private var isStartPending = false

	/// Whether the next stop skips restoring the lyrics interface.
	private var suppressesRestoreInterface = false

	/// The view the window animates from and collapses back into.
	weak var sourceView: UIView?

	/// The window background palette derived from the current song's artwork.
	private var artworkBackgroundColors: [UIColor]?

	/// The in-flight artwork color extraction.
	private var artworkColorTask: Task<Void, Never>?

	/// The window-hosted view carrying the sample buffer layer.
	private var hostView: FloatingLyricsHostView?

	/// The video output frames are enqueued through.
	private let videoOutput = FloatingLyricsVideoOutput()

	#if targetEnvironment(macCatalyst)
	/// The player-backed output feeding the Mac Picture-in-Picture window.
	private let playerOutput = FloatingLyricsPlayerOutput()

	/// Whether the current window was opened by losing focus.
	private var didAutoStart = false

	/// Whether the app is the frontmost one.
	private var isAppActive = true
	#endif

	/// The resolved lyrics of the current song.
	private var liveLyrics: FloatingLyricsFrameBuilder.ResolvedLyrics?

	/// The fetched lyrics keyed by song, caching misses as `nil`.
	private var lyricsCache: [KurozoraItemID: Lyrics?] = [:]

	/// The cached song identifiers from least to most recently used.
	private var lyricsCacheOrder: [KurozoraItemID] = []

	/// The in-flight lyrics fetch.
	private var fetchTask: Task<Void, Never>?

	/// The set of Combine subscriptions retained by the manager.
	private var subscriptions = Set<AnyCancellable>()

	/// The timer driving live frame rendering at 30 Hz.
	private var frameTimer: DispatchSourceTimer?

	/// The settings preview currently mirroring frames.
	private weak var previewView: FloatingLyricsPreviewView?

	/// The display link driving the canned preview loop.
	private var cannedDisplayLink: CADisplayLink?

	/// The time the canned preview loop started.
	private var cannedStartTime: CFTimeInterval = 0

	/// The resolved canned sample shown in the settings preview.
	private lazy var cannedLyrics: FloatingLyricsFrameBuilder.ResolvedLyrics? = {
		guard
			let sampleData = Self.cannedSampleJSON.data(using: .utf8),
			let sample = try? JSONDecoder().decode(Lyrics.self, from: sampleData)
		else { return nil }
		return FloatingLyricsFrameBuilder.ResolvedLyrics.resolve(sample)
	}()

	// MARK: - Initializers
	override private init() {
		super.init()
	}

	// MARK: - Functions
	/// Starts following the player.
	///
	/// Called once per scene connection. Safe to call again.
	func activate() {
		guard self.subscriptions.isEmpty else { return }

		MusicManager.shared.$currentKKSong
			.removeDuplicates { $0?.id == $1?.id }
			.receive(on: RunLoop.main)
			.sink { [weak self] song in
				self?.songDidChange(song)
			}
			.store(in: &self.subscriptions)

		MusicManager.shared.$isPlaying
			.removeDuplicates()
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.playbackStateDidChange()
			}
			.store(in: &self.subscriptions)

		#if targetEnvironment(macCatalyst)
		NotificationCenter.default.addObserver(self, selector: #selector(self.appWillResignActive), name: Notification.Name("NSApplicationDidResignActiveNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.appDidBecomeActive), name: Notification.Name("NSApplicationDidBecomeActiveNotification"), object: nil)
		self.observeActiveSpaceChanges()
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// Watches for the user moving to another Space.
	///
	/// Sending a window full screen moves the user to a new Space without the app's active state
	/// changing, so the resign notification alone never sees it.
	private func observeActiveSpaceChanges() {
		guard
			let workspaceClass = NSClassFromString(#obfuscated("NSWorkspace")) as? NSObject.Type,
			let workspace = workspaceClass.value(forKey: #obfuscated("sharedWorkspace")) as? NSObject,
			let notificationCenter = workspace.value(forKey: #obfuscated("notificationCenter")) as? NotificationCenter
		else { return }

		notificationCenter.addObserver(self, selector: #selector(self.activeSpaceDidChange), name: Notification.Name(#obfuscated("NSWorkspaceActiveSpaceDidChangeNotification")), object: nil)
	}

	/// Opens the window when the app loses focus while a synced song plays.
	@objc private func appWillResignActive() {
		self.isAppActive = false
		self.autoOpenIfNeeded()
	}

	/// Reconsiders the window when the user lands on another Space.
	///
	/// The MiniPlayer travels between Spaces, so arriving somewhere it is on screen retires an
	/// automatically opened window the same way returning to the app does.
	@objc private func activeSpaceDidChange() {
		if #available(iOS 17.0, *), self.didAutoStart, MiniPlayerViewController.isFloatingOnActiveSpace {
			self.stopPictureInPicture()
			return
		}

		guard !self.isAppActive else { return }
		self.autoOpenIfNeeded()
	}

	/// Opens the window if every condition for opening it by itself is met.
	///
	/// A MiniPlayer already floating on this Space is doing the same job, so the window stays
	/// closed rather than landing on top of it.
	private func autoOpenIfNeeded() {
		if #available(iOS 17.0, *), MiniPlayerViewController.isFloatingOnActiveSpace {
			return
		}

		guard
			UserSettings.lyricsFloatingWindowAutoOpen,
			!self.isPictureInPictureActive,
			self.canTimeSync,
			MusicManager.shared.currentKKSong != nil,
			MusicManager.shared.isPlaying
		else { return }

		self.didAutoStart = true
		self.startPictureInPicture()
	}

	/// Closes an automatically opened window when the app regains focus.
	@objc private func appDidBecomeActive() {
		self.isAppActive = true

		guard self.didAutoStart else { return }
		self.stopPictureInPicture()
	}
	#endif

	/// Starts or stops the Picture-in-Picture window.
	func togglePictureInPicture() {
		if self.isPictureInPictureActive {
			self.stopPictureInPicture()
		} else {
			self.startPictureInPicture()
		}
	}

	/// Starts the Picture-in-Picture window, deferring until the controller is ready.
	func startPictureInPicture() {
		self.ensureControllerIfNeeded()
		self.positionHostView()
		self.renderLiveFrame()

		guard let controller = self.pictureInPictureController else { return }

		#if targetEnvironment(macCatalyst)
		if self.playerOutput.isReady {
			self.playerOutput.play()
			controller.startPictureInPicture()
			self.markPictureInPictureActive()
		} else {
			self.isStartPending = true
			self.updateClockState()
		}
		#else
		if controller.isPictureInPicturePossible {
			controller.startPictureInPicture()
		} else {
			self.isStartPending = true
			self.updateClockState()
		}
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// Fires a waiting start once the blank loop is loaded.
	private func playerOutputDidBecomeReady() {
		self.renderLiveFrame()

		guard self.isStartPending, let controller = self.pictureInPictureController else { return }

		self.isStartPending = false
		self.positionHostView()
		self.playerOutput.play()
		controller.startPictureInPicture()
		self.markPictureInPictureActive()
	}

	/// Marks the window active.
	private func markPictureInPictureActive() {
		guard !self.isPictureInPictureActive else { return }
		self.isPictureInPictureActive = true
		self.updateClockState()
	}
	#endif

	/// Stops the Picture-in-Picture window.
	func stopPictureInPicture() {
		self.isStartPending = false
		self.suppressesRestoreInterface = true
		self.pictureInPictureController?.stopPictureInPicture()

		#if targetEnvironment(macCatalyst)
		self.didAutoStart = false
		self.playerOutput.pause()
		self.isPictureInPictureActive = false
		#endif

		self.updateClockState()
	}

	/// Applies changed floating lyrics settings to the live window and preview.
	func settingsDidChange() {
		self.applyAutoOpenSetting(to: self.pictureInPictureController)
		self.renderLiveFrame()
		self.refreshPreviewMode()
	}

	// MARK: Preview
	/// Starts mirroring frames into the given preview view.
	///
	/// - Parameter preview: The view to render frames into.
	func beginPreview(_ preview: FloatingLyricsPreviewView) {
		self.previewView = preview
		self.refreshPreviewMode()
	}

	/// Stops mirroring frames into the preview view.
	func endPreview() {
		self.previewView = nil
		self.stopCannedLoop()
		self.updateClockState()
	}

	/// Updates the preview's source.
	private func refreshPreviewMode() {
		guard self.previewView != nil else { return }

		if self.mirrorsLiveFrames {
			self.stopCannedLoop()
			self.updateClockState()
			self.renderLiveFrame()
		} else {
			self.startCannedLoop()
		}
	}

	/// A Boolean value that indicates whether the preview mirrors the live window.
	private var mirrorsLiveFrames: Bool {
		return self.canTimeSync && MusicManager.shared.currentKKSong != nil
	}

	private func startCannedLoop() {
		guard self.cannedDisplayLink == nil else { return }

		self.cannedStartTime = CACurrentMediaTime()

		let displayLink = CADisplayLink(target: self, selector: #selector(self.cannedTick))
		displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 60, preferred: 30)
		displayLink.add(to: .main, forMode: .common)
		self.cannedDisplayLink = displayLink
	}

	private func stopCannedLoop() {
		self.cannedDisplayLink?.invalidate()
		self.cannedDisplayLink = nil
	}

	@objc private func cannedTick() {
		guard let preview = self.previewView, let cannedLyrics = self.cannedLyrics else { return }

		let durationMs = cannedLyrics.lyrics.attributes.durationMs ?? 16000
		let positionMs = Int((CACurrentMediaTime() - self.cannedStartTime) * 1000) % max(1, durationMs)
		let plan = self.makeFramePlan(resolvedLyrics: cannedLyrics, songTitle: "Kurozora", songArtist: "Kirito", backgroundColors: [FloatingLyricsRenderer.fallbackBackgroundColor], isPlaying: true)
		preview.render(FloatingLyricsFrameBuilder.frame(atPositionMs: positionMs, following: plan))
	}

	// MARK: Data
	/// Handles the player moving to a different song.
	///
	/// - Parameter song: The song now loaded in the player.
	private func songDidChange(_ song: KKSong?) {
		self.fetchTask?.cancel()
		self.fetchTask = nil
		self.artworkColorTask?.cancel()
		self.artworkColorTask = nil
		self.liveLyrics = nil
		self.artworkBackgroundColors = nil

		guard let song = song else {
			self.isStartPending = false
			if self.isPictureInPictureActive {
				self.stopPictureInPicture()
			}
			self.updateClockState()
			self.refreshPreviewMode()
			return
		}

		self.ensureControllerIfNeeded()
		self.renderLiveFrame()
		self.updateArtworkBackgroundColor(for: song)

		if let cachedEntry = self.lyricsCache[song.id] {
			self.applyLyrics(cachedEntry, for: song.id)
			return
		}

		self.fetchTask = Task { @MainActor [weak self] in
			let lyricsResponse = try? await KService.lyrics(for: SongIdentity(id: song.id)).response()
			let lyrics = lyricsResponse?.data.first

			guard let self = self, !Task.isCancelled else { return }

			self.cacheLyrics(lyrics, for: song.id)
			self.applyLyrics(lyrics, for: song.id)
		}
	}

	/// Applies fetched lyrics when they still belong to the current song.
	///
	/// - Parameters:
	///    - lyrics: The fetched lyrics.
	///    - songID: The song the lyrics belong to.
	private func applyLyrics(_ lyrics: Lyrics?, for songID: KurozoraItemID) {
		guard MusicManager.shared.currentKKSong?.id == songID else { return }

		self.liveLyrics = lyrics.map { FloatingLyricsFrameBuilder.ResolvedLyrics.resolve($0) }
		self.updateClockState()
		self.renderLiveFrame()
		self.refreshPreviewMode()
	}

	/// Stores fetched lyrics in the cache, evicting the least recently used song.
	///
	/// - Parameters:
	///    - lyrics: The fetched lyrics, `nil` when the song has none.
	///    - songID: The song the lyrics belong to.
	private func cacheLyrics(_ lyrics: Lyrics?, for songID: KurozoraItemID) {
		self.lyricsCache[songID] = lyrics
		self.lyricsCacheOrder.removeAll { $0 == songID }
		self.lyricsCacheOrder.append(songID)

		if self.lyricsCacheOrder.count > self.lyricsCacheLimit {
			let evicted = self.lyricsCacheOrder.removeFirst()
			self.lyricsCache.removeValue(forKey: evicted)
		}
	}

	// MARK: Playback
	private func playbackStateDidChange() {
		self.pictureInPictureController?.invalidatePlaybackState()

		#if targetEnvironment(macCatalyst)
		if self.isPictureInPictureActive {
			if MusicManager.shared.isPlaying {
				self.playerOutput.play()
			} else {
				self.playerOutput.pause()
			}
		}
		#endif

		self.updateClockState()
		self.renderLiveFrame()
	}

	// MARK: Frame clock
	/// Starts or stops the 10 Hz clock to match the current consumers and playback state.
	private func updateClockState() {
		let hasConsumer = self.isPictureInPictureActive || self.isStartPending || (self.previewView != nil && self.mirrorsLiveFrames)
		let needsTicks = hasConsumer && (MusicManager.shared.isPlaying || self.isStartPending)

		if needsTicks {
			self.startClock()
		} else {
			self.stopClock()
		}
	}

	private func startClock() {
		guard self.frameTimer == nil else { return }

		let timer = DispatchSource.makeTimerSource(queue: .main)
		timer.schedule(deadline: .now(), repeating: .milliseconds(33))
		timer.setEventHandler { [weak self] in
			self?.clockTick()
		}
		timer.resume()
		self.frameTimer = timer
	}

	private func stopClock() {
		self.frameTimer?.cancel()
		self.frameTimer = nil
	}

	private func clockTick() {
		self.renderLiveFrame()

		if !MusicManager.shared.isPlaying {
			self.updateClockState()
		}
	}

	/// Builds the live frame at the current playback position and hands it to every consumer.
	private func renderLiveFrame() {
		guard let song = MusicManager.shared.currentKKSong else { return }

		let positionMs = Int(MusicManager.shared.currentPlaybackSeconds * 1000)
		let plan = self.makeFramePlan(
			resolvedLyrics: self.liveLyrics,
			songTitle: song.attributes.title,
			songArtist: song.attributes.artist,
			backgroundColors: self.artworkBackgroundColors ?? [FloatingLyricsRenderer.fallbackBackgroundColor],
			isPlaying: MusicManager.shared.isPlaying
		)

		#if targetEnvironment(macCatalyst)
		let canvasSize = FloatingLyricsRenderer.canvasSize(for: plan.rows)

		if self.pictureInPictureController != nil, self.playerOutput.canvasSize != canvasSize {
			self.playerOutput.prepare(canvasSize: canvasSize) { [weak self] in
				self?.playerOutputDidBecomeReady()
			}
		}
		self.playerOutput.stage(plan: plan)
		self.playerOutput.syncAnchor(positionMs: positionMs)
		#else
		let frame = FloatingLyricsFrameBuilder.frame(atPositionMs: positionMs, following: plan)
		self.videoOutput.setCanvasSize(FloatingLyricsRenderer.canvasSize(for: plan.rows))
		self.videoOutput.enqueue(drawing: frame)
		#endif

		if self.mirrorsLiveFrames {
			self.previewView?.render(FloatingLyricsFrameBuilder.frame(atPositionMs: positionMs, following: plan))
		}
	}

	/// Snapshots everything a frame derives from besides the playback position.
	///
	/// - Parameters:
	///    - resolvedLyrics: The resolved lyrics of the song.
	///    - songTitle: The title shown when no lyric line applies.
	///    - songArtist: The artist shown when no lyric line applies.
	///    - backgroundColors: The background palette of the window.
	///    - isPlaying: Whether playback is running.
	///
	/// - Returns: The frame plan.
	private func makeFramePlan(resolvedLyrics: FloatingLyricsFrameBuilder.ResolvedLyrics?, songTitle: String, songArtist: String, backgroundColors: [UIColor], isPlaying: Bool) -> FloatingLyricsFrameBuilder.Plan {
		return FloatingLyricsFrameBuilder.Plan(
			resolvedLyrics: resolvedLyrics,
			songTitle: songTitle,
			songArtist: songArtist,
			backgroundColors: backgroundColors,
			fontSize: UserSettings.lyricsFloatingWindowFontSize,
			rows: UserSettings.lyricsFloatingWindowRows,
			showsTranslation: UserSettings.lyricsFloatingWindowShowsTranslation,
			largerText: UserSettings.lyricsLargerText,
			translationLanguage: UserSettings.lyricsTranslationLanguage,
			showsTransliteration: UserSettings.lyricsShowsTransliteration,
			crossfades: UIAccessibility.isReduceMotionEnabled,
			isPlaying: isPlaying
		)
	}

	// MARK: Picture-in-Picture
	/// Creates the Picture-in-Picture controller once a synced song is available.
	private func ensureControllerIfNeeded() {
		if let controller = self.pictureInPictureController {
			self.applyAutoOpenSetting(to: controller)
			self.attachHostViewIfNeeded()
			return
		}

		guard
			AVPictureInPictureController.isPictureInPictureSupported(),
			self.canTimeSync,
			MusicManager.shared.currentKKSong != nil
		else { return }

		self.attachHostViewIfNeeded()
		guard let hostView = self.hostView else { return }

		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])

		#if targetEnvironment(macCatalyst)
		self.playerOutput.playerLayer.frame = hostView.bounds
		if self.playerOutput.playerLayer.superlayer == nil {
			hostView.layer.addSublayer(self.playerOutput.playerLayer)
		}

		self.playerOutput.prepare(canvasSize: FloatingLyricsRenderer.canvasSize(for: UserSettings.lyricsFloatingWindowRows)) { [weak self] in
			self?.playerOutputDidBecomeReady()
		}

		let contentSource = AVPictureInPictureController.ContentSource(playerLayer: self.playerOutput.playerLayer)
		let controller = AVPictureInPictureController(contentSource: contentSource)
		controller.requiresLinearPlayback = true
		self.hideWindowControls(of: controller)
		#else
		guard let sampleBufferDisplayLayer = hostView.sampleBufferDisplayLayer else { return }

		self.installControlTimebase(on: sampleBufferDisplayLayer)

		self.videoOutput.displayLayer = sampleBufferDisplayLayer
		self.videoOutput.setCanvasSize(FloatingLyricsRenderer.canvasSize(for: UserSettings.lyricsFloatingWindowRows))

		let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: sampleBufferDisplayLayer, playbackDelegate: self)
		let controller = AVPictureInPictureController(contentSource: contentSource)
		controller.requiresLinearPlayback = true
		self.hideWindowControls(of: controller)
		#endif

		controller.delegate = self
		self.applyAutoOpenSetting(to: controller)
		self.pictureInPictureController = controller

		self.startPossibleObservation = controller.observe(\.isPictureInPicturePossible, options: [.new]) { [weak self] controller, _ in
			DispatchQueue.main.async {
				guard let self = self, self.isStartPending, controller.isPictureInPicturePossible else { return }
				self.isStartPending = false
				controller.startPictureInPicture()
			}
		}
	}

	/// Gives the layer a running host-time timebase.
	///
	/// - Parameter layer: The layer to install the timebase on.
	private func installControlTimebase(on layer: AVSampleBufferDisplayLayer) {
		guard layer.controlTimebase == nil else { return }

		var timebase: CMTimebase?
		CMTimebaseCreateWithSourceClock(allocator: kCFAllocatorDefault, sourceClock: CMClockGetHostTimeClock(), timebaseOut: &timebase)

		guard let timebase = timebase else { return }

		CMTimebaseSetTime(timebase, time: CMClockGetTime(CMClockGetHostTimeClock()))
		CMTimebaseSetRate(timebase, rate: 1)
		layer.controlTimebase = timebase
	}

	/// Hides the window's playback controls.
	///
	/// - Parameter controller: The controller to strip the controls from.
	private func hideWindowControls(of controller: AVPictureInPictureController) {
		let controlsStyleKey = #obfuscated("controlsStyle")
		let controlsStyleSetter = #obfuscated("setControlsStyle:")

		guard controller.responds(to: NSSelectorFromString(controlsStyleSetter)) else { return }
		controller.setValue(2, forKey: controlsStyleKey)
	}

	/// Extracts the window background palette from the song's artwork.
	///
	/// - Parameter song: The song whose artwork to sample.
	private func updateArtworkBackgroundColor(for song: KKSong) {
		guard let artworkURL = MusicManager.shared.currentSong?.song.artwork?.url(width: 64, height: 64) else { return }

		self.artworkColorTask = Task { @MainActor [weak self] in
			let retrieved = try? await KingfisherManager.shared.retrieveImage(with: artworkURL)

			guard let self = self, !Task.isCancelled else { return }
			guard MusicManager.shared.currentKKSong?.id == song.id else { return }
			guard let palette = Self.artworkPalette(of: retrieved?.image) else { return }

			self.artworkBackgroundColors = palette
			self.renderLiveFrame()
		}
	}

	/// The window background palette sampled from the given artwork.
	///
	/// - Parameter image: The artwork to sample.
	///
	/// - Returns: The base color followed by the pool colors.
	private static func artworkPalette(of image: UIImage?) -> [UIColor]? {
		guard let cgImage = image?.cgImage else { return nil }

		let gridSize = 3
		var bitmap = [UInt8](repeating: 0, count: gridSize * gridSize * 4)
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

		let didDraw = bitmap.withUnsafeMutableBytes { buffer -> Bool in
			guard let context = CGContext(
				data: buffer.baseAddress,
				width: gridSize,
				height: gridSize,
				bitsPerComponent: 8,
				bytesPerRow: gridSize * 4,
				space: CGColorSpaceCreateDeviceRGB(),
				bitmapInfo: bitmapInfo.rawValue
			) else { return false }

			context.interpolationQuality = .medium
			context.draw(cgImage, in: CGRect(x: 0, y: 0, width: gridSize, height: gridSize))
			return true
		}

		guard didDraw else { return nil }

		func color(atColumn column: Int, row: Int) -> UIColor {
			let offset = (row * gridSize + column) * 4
			return UIColor(red: CGFloat(bitmap[offset]) / 255, green: CGFloat(bitmap[offset + 1]) / 255, blue: CGFloat(bitmap[offset + 2]) / 255, alpha: 1)
		}

		let base = self.windowColor(from: color(atColumn: 1, row: 1), brightnessRange: 0.1...0.24)
		let pools = [
			color(atColumn: 0, row: 0),
			color(atColumn: 2, row: 0),
			color(atColumn: 2, row: 2),
			color(atColumn: 0, row: 2),
		].map { self.windowColor(from: $0, brightnessRange: 0.16...0.4) }

		return [base] + pools
	}

	/// Darkens an artwork color enough to carry white lyrics text.
	///
	/// - Parameters:
	///    - color: The sampled artwork color.
	///    - brightnessRange: The brightness band the color is clamped into.
	///
	/// - Returns: The window-safe color.
	private static func windowColor(from color: UIColor, brightnessRange: ClosedRange<CGFloat>) -> UIColor {
		var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

		return UIColor(
			hue: hue,
			saturation: min(saturation * 1.1, 0.75),
			brightness: min(max(brightness * 0.55, brightnessRange.lowerBound), brightnessRange.upperBound),
			alpha: 1
		)
	}

	/// Arms or disarms automatic start when leaving the app.
	///
	/// - Parameter controller: The controller to apply the setting to.
	private func applyAutoOpenSetting(to controller: AVPictureInPictureController?) {
		#if !targetEnvironment(macCatalyst)
		controller?.canStartPictureInPictureAutomaticallyFromInline = UserSettings.lyricsFloatingWindowAutoOpen
		#endif
	}

	/// Places the host view over the window's animation source.
	private func positionHostView() {
		guard let hostView = self.hostView, let window = hostView.window else { return }

		if let sourceView = self.sourceView, sourceView.window === window {
			hostView.frame = sourceView.convert(sourceView.bounds, to: window)
		} else {
			hostView.frame = CGRect(x: 0, y: 0, width: 108, height: 32)
		}

		#if targetEnvironment(macCatalyst)
		self.playerOutput.playerLayer.frame = hostView.bounds
		#endif
	}

	/// Installs the host view behind the key window's content.
	private func attachHostViewIfNeeded() {
		if self.hostView == nil {
			let hostView = FloatingLyricsHostView(frame: CGRect(x: 0, y: 0, width: 108, height: 32))
			hostView.isUserInteractionEnabled = false
			self.hostView = hostView
		}

		guard let hostView = self.hostView, hostView.window == nil else { return }

		let windowScenes = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.filter { !$0.session.isAuxiliaryScene }
		let windowScene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first

		guard let window = windowScene?.keyWindow ?? windowScene?.windows.first else { return }
		window.insertSubview(hostView, at: 0)
	}

	/// Presents the lyrics sheet for the current song when the window expands back into the app.
	private func presentLyricsForRestore() {
		guard
			let songID = MusicManager.shared.currentKKSong?.id,
			let topViewController = UIApplication.topViewController
		else { return }

		if let navigationController = topViewController.navigationController ?? topViewController as? UINavigationController, navigationController.viewControllers.first is LyricsViewController {
			return
		}
		if topViewController is LyricsViewController {
			return
		}

		let lyricsViewController = LyricsViewController(songID: songID)
		let navigationController = KNavigationController(rootViewController: lyricsViewController)
		navigationController.modalPresentationStyle = .pageSheet
		topViewController.present(navigationController, animated: true)
	}
}

// MARK: - AVPictureInPictureControllerDelegate
extension FloatingLyricsManager: AVPictureInPictureControllerDelegate {
	func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
		self.isStartPending = false
		self.isPictureInPictureActive = true
		self.updateClockState()
		self.renderLiveFrame()
	}

	func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
		self.isStartPending = false
		self.suppressesRestoreInterface = false
		self.isPictureInPictureActive = false

		#if targetEnvironment(macCatalyst)
		self.playerOutput.pause()
		#endif

		self.updateClockState()
	}

	func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
		self.isStartPending = false
		self.isPictureInPictureActive = false
		self.updateClockState()
		print("----- Picture-in-Picture failed to start:", error.localizedDescription)
	}

	func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
		if !self.suppressesRestoreInterface {
			self.presentLyricsForRestore()
		}
		completionHandler(true)
	}
}

// MARK: - AVPictureInPictureSampleBufferPlaybackDelegate
extension FloatingLyricsManager: AVPictureInPictureSampleBufferPlaybackDelegate {
	func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
		if playing != MusicManager.shared.isPlaying {
			MusicManager.shared.togglePlayPause()
		}
	}

	func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
		return CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
	}

	func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
		return !MusicManager.shared.isPlaying
	}

	func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

	func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
		completionHandler()
	}

	func pictureInPictureControllerShouldProhibitBackgroundAudioPlayback(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
		return false
	}
}

// MARK: - Canned sample
extension FloatingLyricsManager {
	/// The word-timed sample looped in the settings preview.
	private static let cannedSampleJSON = """
	{
		"id": "preview",
		"type": "lyrics",
		"attributes": {
			"source": "preview",
			"language": "ja",
			"timing": "word",
			"leadingSilenceMs": 0,
			"lyricOffsetMs": 0,
			"durationMs": 18000,
			"agents": [],
			"lines": [
				{
					"key": "L1", "position": 0, "songPart": null, "agent": null,
					"beginMs": 2000, "endMs": 5600,
					"text": "夜空を駆け抜けて",
					"words": [
						{"beginMs": 2000, "endMs": 3200, "text": "夜空を", "background": false, "trailingSpace": false},
						{"beginMs": 3200, "endMs": 4400, "text": "駆け", "background": false, "trailingSpace": false},
						{"beginMs": 4400, "endMs": 5600, "text": "抜けて", "background": false, "trailingSpace": false}
					],
					"translations": [{"language": "en", "text": "Racing through the night sky"}],
					"transliterations": [{
						"language": "ja-Latn",
						"text": "Yozora o kakenukete",
						"words": [
							{"beginMs": 2000, "endMs": 3200, "text": "Yozora o", "background": false, "trailingSpace": true},
							{"beginMs": 3200, "endMs": 4400, "text": "kake", "background": false, "trailingSpace": false},
							{"beginMs": 4400, "endMs": 5600, "text": "nukete", "background": false, "trailingSpace": true}
						]
					}]
				},
				{
					"key": "L2", "position": 1, "songPart": null, "agent": null,
					"beginMs": 6000, "endMs": 9600,
					"text": "星の海を越えて",
					"words": [
						{"beginMs": 6000, "endMs": 7200, "text": "星の", "background": false, "trailingSpace": false},
						{"beginMs": 7200, "endMs": 8400, "text": "海を", "background": false, "trailingSpace": false},
						{"beginMs": 8400, "endMs": 9600, "text": "越えて", "background": false, "trailingSpace": false}
					],
					"translations": [{"language": "en", "text": "Crossing the sea of stars"}],
					"transliterations": [{
						"language": "ja-Latn",
						"text": "Hoshi no umi o koete",
						"words": [
							{"beginMs": 6000, "endMs": 7200, "text": "Hoshi no", "background": false, "trailingSpace": true},
							{"beginMs": 7200, "endMs": 8400, "text": "umi o", "background": false, "trailingSpace": true},
							{"beginMs": 8400, "endMs": 9600, "text": "koete", "background": false, "trailingSpace": true}
						]
					}]
				},
				{
					"key": "L3", "position": 2, "songPart": null, "agent": null,
					"beginMs": 10000, "endMs": 13600,
					"text": "君と見た夢の続き",
					"words": [
						{"beginMs": 10000, "endMs": 11200, "text": "君と", "background": false, "trailingSpace": false},
						{"beginMs": 11200, "endMs": 12400, "text": "見た夢の", "background": false, "trailingSpace": false},
						{"beginMs": 12400, "endMs": 13600, "text": "続き", "background": false, "trailingSpace": false}
					],
					"translations": [{"language": "en", "text": "The dream we shared goes on"}],
					"transliterations": [{
						"language": "ja-Latn",
						"text": "Kimi to mita yume no tsuzuki",
						"words": [
							{"beginMs": 10000, "endMs": 11200, "text": "Kimi to", "background": false, "trailingSpace": true},
							{"beginMs": 11200, "endMs": 12400, "text": "mita yume no", "background": false, "trailingSpace": true},
							{"beginMs": 12400, "endMs": 13600, "text": "tsuzuki", "background": false, "trailingSpace": true}
						]
					}]
				},
				{
					"key": "L4", "position": 3, "songPart": null, "agent": null,
					"beginMs": 14000, "endMs": 17600,
					"text": "明日へと歩き出す",
					"words": [
						{"beginMs": 14000, "endMs": 15200, "text": "明日へと", "background": false, "trailingSpace": false},
						{"beginMs": 15200, "endMs": 16400, "text": "歩き", "background": false, "trailingSpace": false},
						{"beginMs": 16400, "endMs": 17600, "text": "出す", "background": false, "trailingSpace": false}
					],
					"translations": [{"language": "en", "text": "Walking on toward tomorrow"}],
					"transliterations": [{
						"language": "ja-Latn",
						"text": "Ashita e to arukidasu",
						"words": [
							{"beginMs": 14000, "endMs": 15200, "text": "Ashita e to", "background": false, "trailingSpace": true},
							{"beginMs": 15200, "endMs": 16400, "text": "aruki", "background": false, "trailingSpace": false},
							{"beginMs": 16400, "endMs": 17600, "text": "dasu", "background": false, "trailingSpace": true}
						]
					}]
				}
			]
		}
	}
	"""
}
