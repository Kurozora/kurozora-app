//
//  FloatingLyricsPlayerOutput.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import AVFoundation
import UIKit

/// Feeds lyric frames into an `AVPlayerLayer` for the Mac Picture-in-Picture window.
final class FloatingLyricsPlayerOutput {
	// MARK: - Properties
	/// The layer the Picture-in-Picture controller presents.
	let playerLayer = AVPlayerLayer()

	/// The size of the logical rendering canvas in pixels.
	private(set) var canvasSize: CGSize = .zero

	/// The scale between the blank video's natural size and the card.
	private static let assetScale: CGFloat = 0.5

	/// The scale between the composed output and the card.
	private static let outputScale: CGFloat = 2

	/// The drawing width of the card.
	private static let cardWidth: CGFloat = 760

	/// The aspect ratio of the card.
	private static let cardAspect: CGFloat = 1.9

	/// The size of the card in pixels.
	private static var cardSize: CGSize {
		return CGSize(width: self.cardWidth, height: (self.cardWidth / self.cardAspect).rounded())
	}

	/// The frames per second of the blank source video.
	private nonisolated static let framesPerSecond: Int32 = 30

	/// The length of the blank source video loop in seconds.
	private nonisolated static let loopSeconds = 4

	/// The player looping the blank video.
	private let player = AVQueuePlayer()

	/// The looper keeping the blank video playing.
	private var looper: AVPlayerLooper?

	/// The canvas size the current loop was built for.
	private var preparedCanvasSize: CGSize = .zero

	/// The in-flight loop preparation.
	private var preparationTask: Task<Void, Never>?

	/// The frame state shared with the compositor thread.
	private let frameSource = FloatingLyricsFrameSource(cardSize: FloatingLyricsPlayerOutput.cardSize, loopSeconds: Double(FloatingLyricsPlayerOutput.loopSeconds))

	/// A Boolean value that indicates whether the loop matching the canvas is loaded.
	var isReady: Bool {
		return self.looper != nil && self.preparedCanvasSize == self.canvasSize
	}

	// MARK: - Initializers
	init() {
		self.player.isMuted = true
		self.player.preventsDisplaySleepDuringVideoPlayback = false
		self.playerLayer.player = self.player
		self.playerLayer.videoGravity = .resizeAspect
	}

	// MARK: - Functions
	/// Loads the blank loop for the given canvas size.
	///
	/// - Parameters:
	///    - canvasSize: The canvas size in pixels.
	///    - completion: Called on the main queue once the loop is ready.
	func prepare(canvasSize: CGSize, completion: @escaping () -> Void) {
		guard canvasSize != .zero else { return }

		if canvasSize == self.preparedCanvasSize, self.looper != nil {
			completion()
			return
		}

		self.canvasSize = canvasSize
		self.frameSource.setCanvasSize(canvasSize)
		self.preparationTask?.cancel()

		let cardSize = Self.cardSize
		let videoSize = CGSize(width: (cardSize.width * Self.assetScale).rounded(), height: (cardSize.height * Self.assetScale).rounded())

		self.preparationTask = Task { @MainActor [weak self] in
			guard let videoURL = await Self.blankVideoURL(for: videoSize) else { return }
			guard let self = self, !Task.isCancelled, self.canvasSize == canvasSize else { return }

			let asset = AVURLAsset(url: videoURL)
			let frameSource = self.frameSource
			let composition = AVMutableVideoComposition(asset: asset) { request in
				request.finish(with: frameSource.image(for: request), context: nil)
			}
			composition.renderScale = Float(Self.outputScale / Self.assetScale)

			let templateItem = AVPlayerItem(asset: asset)
			templateItem.videoComposition = composition

			self.player.removeAllItems()
			self.looper = AVPlayerLooper(player: self.player, templateItem: templateItem)
			self.preparedCanvasSize = canvasSize
			completion()
		}
	}

	/// Starts the blank loop.
	func play() {
		self.player.play()
	}

	/// Pauses the blank loop.
	func pause() {
		self.player.pause()
	}

	/// Stages the plan frames derive from.
	///
	/// - Parameter plan: The plan to derive frames from.
	func stage(plan: FloatingLyricsFrameBuilder.Plan) {
		self.frameSource.stage(plan: plan)
	}

	/// Anchors the playback position against the blank loop's clock.
	///
	/// - Parameter positionMs: The playback position in milliseconds.
	func syncAnchor(positionMs: Int) {
		self.frameSource.syncAnchor(positionMs: positionMs, itemSeconds: self.player.currentTime().seconds)
	}

	// MARK: Blank video
	/// The cached blank video for the given size, generating it on first use.
	///
	/// - Parameter size: The video size in pixels.
	///
	/// - Returns: The file URL of the blank video.
	private static func blankVideoURL(for size: CGSize) async -> URL? {
		guard let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }

		let directoryURL = cachesURL.appendingPathComponent("FloatingLyrics", isDirectory: true)
		let videoURL = directoryURL.appendingPathComponent("blank-\(Int(size.width))x\(Int(size.height)).mp4")

		if FileManager.default.fileExists(atPath: videoURL.path) {
			return videoURL
		}

		do {
			try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
			try await self.writeBlankVideo(to: videoURL, size: size)
			return videoURL
		} catch {
			print("----- PiP blank video generation failed:", error.localizedDescription)
			return nil
		}
	}

	/// Writes a silent black H.264 loop of ``loopSeconds`` at ``framesPerSecond``.
	///
	/// - Parameters:
	///    - url: The destination file URL.
	///    - size: The video size in pixels.
	@concurrent private static func writeBlankVideo(to url: URL, size: CGSize) async throws {
		let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)

		let videoSettings: [String: Any] = [
			AVVideoCodecKey: AVVideoCodecType.h264,
			AVVideoWidthKey: Int(size.width),
			AVVideoHeightKey: Int(size.height),
		]
		let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		input.expectsMediaDataInRealTime = false

		let bufferAttributes: [String: Any] = [
			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
			kCVPixelBufferWidthKey as String: Int(size.width),
			kCVPixelBufferHeightKey as String: Int(size.height),
		]
		let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: bufferAttributes)

		writer.add(input)
		writer.startWriting()
		writer.startSession(atSourceTime: .zero)

		guard let pixelBufferPool = adaptor.pixelBufferPool else {
			throw AVError(.unknown)
		}

		var pooledBuffer: CVPixelBuffer?
		CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pooledBuffer)
		guard let blackBuffer = pooledBuffer else {
			throw AVError(.unknown)
		}

		CVPixelBufferLockBaseAddress(blackBuffer, [])
		if let baseAddress = CVPixelBufferGetBaseAddress(blackBuffer) {
			memset(baseAddress, 0, CVPixelBufferGetBytesPerRow(blackBuffer) * CVPixelBufferGetHeight(blackBuffer))
		}
		CVPixelBufferUnlockBaseAddress(blackBuffer, [])

		let frameCount = Self.loopSeconds * Int(Self.framesPerSecond)
		for frameIndex in 0..<frameCount {
			while !input.isReadyForMoreMediaData {
				try await Task.sleep(nanoseconds: 5_000_000)
			}
			adaptor.append(blackBuffer, withPresentationTime: CMTime(value: CMTimeValue(frameIndex), timescale: Self.framesPerSecond))
		}

		input.markAsFinished()
		await writer.finishWriting()

		guard writer.status == .completed else {
			throw writer.error ?? AVError(.unknown)
		}
	}
}
#endif
