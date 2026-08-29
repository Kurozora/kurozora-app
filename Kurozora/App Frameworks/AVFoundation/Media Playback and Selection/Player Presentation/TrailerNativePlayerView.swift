//
//  TrailerNativePlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import AVKit
import CoreImage
import UIKit

/// Reports playback changes from a trailer played with AVPlayer.
@MainActor
protocol TrailerNativePlayerViewDelegate: AnyObject {
	/// Tells the delegate the trailer is ready to play.
	///
	/// - Parameter trailerNativePlayerView: The player reporting the change.
	func trailerNativePlayerViewDidBecomeReady(_ trailerNativePlayerView: TrailerNativePlayerView)

	/// Tells the delegate the trailer could not be played.
	///
	/// - Parameter trailerNativePlayerView: The player reporting the change.
	func trailerNativePlayerViewDidFail(_ trailerNativePlayerView: TrailerNativePlayerView)

	/// Tells the delegate playback progressed.
	///
	/// - Parameters:
	///    - trailerNativePlayerView: The player reporting the change.
	///    - currentTime: The elapsed time, in seconds.
	///    - duration: The trailer's duration, in seconds.
	func trailerNativePlayerView(_ trailerNativePlayerView: TrailerNativePlayerView, didPlayTo currentTime: Double, duration: Double)

	/// Tells the delegate playback reached the end.
	///
	/// - Parameter trailerNativePlayerView: The player reporting the change.
	func trailerNativePlayerViewDidReachEnd(_ trailerNativePlayerView: TrailerNativePlayerView)

	/// Asks the delegate for the time playback resumes from.
	///
	/// - Parameter trailerNativePlayerView: The player requesting the time.
	///
	/// - Returns: The time to resume from, in seconds.
	func trailerNativePlayerViewResumePoint(_ trailerNativePlayerView: TrailerNativePlayerView) -> Double
}

/// A view that plays a trailer's video stream with AVPlayer, in front of the page that supplied it.
@MainActor
final class TrailerNativePlayerView: UIView {
	// MARK: - Views
	override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

	// MARK: - Properties
	/// The object that receives playback changes.
	weak var delegate: TrailerNativePlayerViewDelegate?

	/// The player that renders the trailer.
	private var player: AVPlayer?

	/// The observation of the item's status.
	private var statusObservation: NSKeyValueObservation?

	/// The observer of playback progress.
	private var progressObserver: Any?

	/// The observer of playback reaching the end.
	private var itemEndObserver: NSObjectProtocol?

	/// The controller that presents the trailer in Picture in Picture.
	private var pictureInPictureController: AVPictureInPictureController?

	/// The output that supplies decoded video frames.
	private var videoOutput: AVPlayerItemVideoOutput?

	/// The context that renders video frames into images.
	private static let pictureContext = CIContext(options: [.useSoftwareRenderer: false])

	/// The player that owns the Picture in Picture session.
	private(set) static weak var floatingPlayerView: TrailerNativePlayerView?

	/// A Boolean value indicating whether readiness has been reported.
	private var hasReportedReady = false

	/// The elapsed time, in seconds.
	private(set) var currentTime = 0.0

	/// The trailer's duration, in seconds.
	private(set) var duration = 0.0

	/// A Boolean value indicating whether the trailer is playing.
	private(set) var isPlaying = false

	/// The playback rate, as a multiple of normal speed.
	private var playbackRate = 1.0

	/// The time to seek to once the seek in progress finishes.
	private var pendingSeekTime: CMTime?

	/// A Boolean value indicating whether a seek is in progress.
	private var isSeeking = false

	/// A Boolean value indicating whether a trailer is playing in Picture in Picture.
	static var hasFloatingWindow: Bool {
		return Self.floatingPlayerView?.isFloating ?? false
	}

	/// A Boolean value indicating whether this player is playing in Picture in Picture.
	var isFloating: Bool {
		return self.pictureInPictureController?.isPictureInPictureActive ?? false
	}

	/// The layer that displays the video.
	private var playerLayer: AVPlayerLayer? {
		return self.layer as? AVPlayerLayer
	}

	/// The video's frame rate, in frames per second.
	var currentFrameRate: Double? {
		let track = self.player?.currentItem?.tracks.first { $0.assetTrack?.mediaType == .video }

		// The live reading ramps up from below the real rate.
		let readings = [Double(track?.assetTrack?.nominalFrameRate ?? 0.0), Double(track?.currentVideoFrameRate ?? 0.0)]

		return readings.first { $0 >= 10.0 && $0 <= 120.0 }
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.backgroundColor = .clear
		self.playerLayer?.videoGravity = .resizeAspect
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func didMoveToSuperview() {
		super.didMoveToSuperview()

		guard self.superview != nil, !self.isFloating else { return }

		self.refreshPicture()
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)

		// The video takes no presses of its own.
		return hitView === self ? nil : hitView
	}

	// MARK: - Functions
	/// Loads the given stream and plays it from the given time.
	///
	/// - Parameters:
	///    - streamURL: The URL to stream from.
	///    - seconds: The time to start from, in seconds.
	///    - isMuted: Whether playback starts muted.
	///    - volume: The volume, from `0` to `1`.
	///    - rate: The playback rate, as a multiple of normal speed.
	func load(_ streamURL: URL, startingAt seconds: Double, isMuted: Bool, volume: Double, rate: Double) {
		self.teardown()

		let item = AVPlayerItem(url: streamURL)
		let player = AVPlayer(playerItem: item)
		player.isMuted = isMuted
		player.volume = Float(min(max(0.0, volume), 1.0))
		player.actionAtItemEnd = .pause

		self.player = player
		self.playbackRate = rate
		self.playerLayer?.player = player
		self.applyPlaybackRate()
		self.observeReadiness(of: item, startingAt: seconds, rate: rate)
		self.observeProgress(of: player)
		self.observeItemEnd(of: item)
	}

	/// Resumes playback.
	func play() {
		self.isPlaying = true
		self.applyPlaybackRate()
	}

	/// Pauses playback.
	func pause() {
		self.isPlaying = false
		self.player?.pause()
	}

	/// Redraws the frame the video is stopped on.
	func refreshPicture() {
		guard let player = self.player else { return }

		player.seek(to: player.currentTime(), toleranceBefore: .zero, toleranceAfter: .zero)
	}

	/// Captures the frame the video is stopped on.
	///
	/// - Returns: The captured frame.
	func capturePicture() async -> UIImage? {
		guard let item = self.player?.currentItem else { return nil }

		// A streaming item supplies frames only through an output attached to it.
		if self.videoOutput == nil {
			let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
			self.videoOutput = videoOutput
			item.add(videoOutput)
		}

		guard let videoOutput = self.videoOutput else { return nil }

		self.refreshPicture()

		for _ in 0..<20 {
			try? await Task.sleep(nanoseconds: 50_000_000)

			let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
			guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else { continue }

			return Self.makePicture(from: pixelBuffer)
		}

		print("----- [Trailer] No video frame available to capture")
		return nil
	}

	/// Renders the given video frame into an image.
	///
	/// - Parameter pixelBuffer: The video frame to render.
	///
	/// - Returns: The rendered image.
	private static func makePicture(from pixelBuffer: CVPixelBuffer) -> UIImage? {
		let frameImage = CIImage(cvPixelBuffer: pixelBuffer)
		guard let renderedImage = Self.pictureContext.createCGImage(frameImage, from: frameImage.extent) else { return nil }

		return UIImage(cgImage: renderedImage)
	}

	/// Steps the video by whole frames.
	///
	/// - Parameter count: The number of frames to step, stepping back when negative.
	///
	/// - Returns: `true` if the item could step.
	func stepFrames(_ count: Int) -> Bool {
		guard let item = self.player?.currentItem else { return false }
		guard count > 0 ? item.canStepForward : item.canStepBackward else { return false }

		item.step(byCount: count)
		return true
	}

	/// Seeks to the given time.
	///
	/// - Parameter seconds: The time to seek to, in seconds.
	func seek(to seconds: Double) {
		self.pendingSeekTime = CMTime(seconds: max(0.0, seconds), preferredTimescale: 600)

		guard !self.isSeeking else { return }

		self.runPendingSeek()
	}

	/// Performs the pending seek, followed by any seek requested while it ran.
	///
	/// A new seek cancels the one in progress, so a run of them has to be served in turn.
	private func runPendingSeek() {
		guard let player = self.player, let seekTime = self.pendingSeekTime else { return }

		self.pendingSeekTime = nil
		self.isSeeking = true
		let wasPlaying = self.isPlaying

		player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
			DispatchQueue.main.async { [weak self] in
				MainActor.assumeIsolated {
					guard let self = self else { return }

					self.isSeeking = false

					guard self.pendingSeekTime == nil else {
						self.runPendingSeek()
						return
					}

					guard wasPlaying else { return }

					self.applyPlaybackRate()
				}
			}
		}
	}

	/// Mutes or unmutes playback.
	///
	/// - Parameter isMuted: Whether playback is muted.
	func setMuted(_ isMuted: Bool) {
		self.player?.isMuted = isMuted
	}

	/// Sets the playback volume.
	///
	/// - Parameter volume: The volume, from `0` to `1`.
	func setVolume(_ volume: Double) {
		self.player?.volume = Float(min(max(0.0, volume), 1.0))
	}

	/// Sets the playback rate.
	///
	/// - Parameter rate: The rate, as a multiple of normal speed.
	func setPlaybackRate(_ rate: Double) {
		self.playbackRate = rate
		self.applyPlaybackRate()
	}

	/// Applies the playback rate to the player.
	///
	/// AVPlayer resets its rate on every play, seek and stall.
	private func applyPlaybackRate() {
		guard let player = self.player else { return }

		// A stall resets rate but not defaultRate.
		if #available(iOS 16.0, *) {
			player.defaultRate = Float(self.playbackRate)
		}

		guard self.isPlaying else { return }

		player.rate = Float(self.playbackRate)
	}

	/// Limits the resolution the stream plays at.
	///
	/// - Parameter height: The maximum height to stream, with `0` for adaptive.
	func setMaximumHeight(_ height: Double) {
		guard height > 0.0 else {
			self.player?.currentItem?.preferredMaximumResolution = .zero
			return
		}

		self.player?.currentItem?.preferredMaximumResolution = CGSize(width: (height * 16.0 / 9.0).rounded(), height: height)
	}

	/// Starts or stops Picture in Picture.
	func togglePictureInPicture() {
		guard AVPictureInPictureController.isPictureInPictureSupported(), let playerLayer = self.playerLayer else {
			print("----- [Trailer] Picture in Picture is unavailable")
			return
		}

		guard let pictureInPictureController = self.pictureInPictureController ?? AVPictureInPictureController(playerLayer: playerLayer) else {
			print("----- [Trailer] Picture in Picture is unavailable")
			return
		}

		pictureInPictureController.delegate = self
		self.pictureInPictureController = pictureInPictureController

		if pictureInPictureController.isPictureInPictureActive {
			pictureInPictureController.stopPictureInPicture()
		} else {
			Self.floatingPlayerView = self
			pictureInPictureController.startPictureInPicture()
			NotificationCenter.default.post(name: .KTrailerFloatingWindowDidChange, object: nil)
		}
	}

	/// Stops the Picture in Picture session, whichever player started it.
	static func closeFloatingWindow() {
		Self.floatingPlayerView?.pictureInPictureController?.stopPictureInPicture()
	}

	/// Replaces the stream being played, keeping Picture in Picture active.
	///
	/// - Parameters:
	///    - streamURL: The URL to stream from.
	///    - isMuted: Whether playback starts muted.
	///    - volume: The volume, from `0` to `1`.
	func adopt(_ streamURL: URL, isMuted: Bool, volume: Double) {
		guard let player = self.player else {
			self.load(streamURL, startingAt: 0.0, isMuted: isMuted, volume: volume, rate: 1.0)
			return
		}

		let item = AVPlayerItem(url: streamURL)
		self.releaseVideoOutput()
		self.hasReportedReady = false
		self.currentTime = 0.0
		self.duration = 0.0
		player.isMuted = isMuted
		player.volume = Float(min(max(0.0, volume), 1.0))
		player.replaceCurrentItem(with: item)

		self.observeReadiness(of: item, startingAt: 0.0, rate: self.playbackRate)
		self.observeItemEnd(of: item)
	}

	/// Stops playback and removes every observer.
	func teardown() {
		if let progressObserver = self.progressObserver {
			self.player?.removeTimeObserver(progressObserver)
		}

		if let itemEndObserver = self.itemEndObserver {
			NotificationCenter.default.removeObserver(itemEndObserver)
		}

		if Self.floatingPlayerView === self {
			Self.floatingPlayerView = nil
		}

		self.releaseVideoOutput()
		self.pictureInPictureController = nil
		self.statusObservation = nil
		self.progressObserver = nil
		self.itemEndObserver = nil
		self.pendingSeekTime = nil
		self.isSeeking = false
		self.hasReportedReady = false
		self.isPlaying = false
		self.currentTime = 0.0
		self.duration = 0.0

		self.player?.pause()
		self.player = nil
		self.playerLayer?.player = nil
	}

	/// Removes the video output from the current item.
	private func releaseVideoOutput() {
		guard let videoOutput = self.videoOutput else { return }

		self.player?.currentItem?.remove(videoOutput)
		self.videoOutput = nil
	}

	/// Observes the given item until it becomes playable.
	///
	/// - Parameters:
	///    - item: The item to observe.
	///    - seconds: The time to start from, in seconds.
	///    - rate: The playback rate, as a multiple of normal speed.
	private func observeReadiness(of item: AVPlayerItem, startingAt seconds: Double, rate: Double) {
		self.statusObservation = item.observe(\.status, options: [.initial, .new]) { item, _ in
			let status = item.status
			let length = item.duration.seconds
			let reason = item.error?.localizedDescription ?? "unknown"

			DispatchQueue.main.async { [weak self] in
				MainActor.assumeIsolated {
					guard let self = self, !self.hasReportedReady else { return }

					switch status {
					case .readyToPlay:
						self.hasReportedReady = true
						self.duration = length.isFinite ? length : 0.0
						self.startPlayback(from: seconds, rate: rate)
					case .failed:
						self.hasReportedReady = true
						print("----- [Trailer] The player refused the stream: \(reason)")
						self.delegate?.trailerNativePlayerViewDidFail(self)
					default:
						break
					}
				}
			}
		}
	}

	/// Seeks to the resume point and starts playback.
	///
	/// - Parameters:
	///    - seconds: The time to start from, in seconds.
	///    - rate: The playback rate, as a multiple of normal speed.
	private func startPlayback(from seconds: Double, rate: Double) {
		// Read now, since the page keeps playing while the stream loads.
		let resumePoint = self.delegate?.trailerNativePlayerViewResumePoint(self) ?? seconds
		self.playbackRate = rate

		// Exact, so the handover neither repeats nor drops the opening seconds.
		self.player?.seek(to: CMTime(seconds: max(0.0, resumePoint), preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
			DispatchQueue.main.async { [weak self] in
				MainActor.assumeIsolated {
					guard let self = self else { return }

					self.isPlaying = true
					self.applyPlaybackRate()
					self.player?.playImmediately(atRate: Float(rate))
					self.delegate?.trailerNativePlayerViewDidBecomeReady(self)
				}
			}
		}
	}

	/// Observes playback progress.
	///
	/// - Parameter player: The player to observe.
	private func observeProgress(of player: AVPlayer) {
		self.progressObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { [weak self] time in
			MainActor.assumeIsolated {
				guard let self = self else { return }

				let duration = player.currentItem?.duration.seconds ?? 0.0
				self.currentTime = time.seconds.isFinite ? time.seconds : 0.0
				self.duration = duration.isFinite ? duration : self.duration

				self.delegate?.trailerNativePlayerView(self, didPlayTo: self.currentTime, duration: self.duration)
			}
		}
	}

	/// Observes playback reaching the end.
	///
	/// - Parameter item: The item to observe.
	private func observeItemEnd(of item: AVPlayerItem) {
		self.itemEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				guard let self = self else { return }

				self.isPlaying = false
				self.delegate?.trailerNativePlayerViewDidReachEnd(self)
			}
		}
	}
}

// MARK: - AVPictureInPictureControllerDelegate
extension TrailerNativePlayerView: AVPictureInPictureControllerDelegate {
	func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
		guard TrailerNativePlayerView.floatingPlayerView === self else { return }

		TrailerNativePlayerView.floatingPlayerView = nil
		self.refreshPicture()
		NotificationCenter.default.post(name: .KTrailerFloatingWindowDidChange, object: nil)
	}
}
