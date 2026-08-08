//
//  FloatingLyricsPlayerOutput.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import AVFoundation
import CoreImage
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
	private static let framesPerSecond: Int32 = 30

	/// The length of the blank source video loop in seconds.
	private static let loopSeconds = 4

	/// The player looping the blank video.
	private let player = AVQueuePlayer()

	/// The looper keeping the blank video playing.
	private var looper: AVPlayerLooper?

	/// The canvas size the current loop was built for.
	private var preparedCanvasSize: CGSize = .zero

	/// The in-flight loop preparation.
	private var preparationTask: Task<Void, Never>?

	/// The lock guarding the frame state.
	private let stateLock = NSLock()

	/// The plan frames derive from.
	private var plan: FloatingLyricsFrameBuilder.Plan?

	/// The playback position at the anchor, in milliseconds.
	private var anchorPositionMs = 0

	/// The blank loop's item time at the anchor, in seconds.
	private var anchorItemSeconds = 0.0

	/// The renderer producing frame images.
	private var frameRenderer: UIGraphicsImageRenderer?

	/// The pixel size ``frameRenderer`` renders at.
	private var frameRendererSize: CGSize = .zero

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
		self.preparationTask?.cancel()

		let cardSize = Self.cardSize
		let videoSize = CGSize(width: (cardSize.width * Self.assetScale).rounded(), height: (cardSize.height * Self.assetScale).rounded())

		self.preparationTask = Task { @MainActor [weak self] in
			guard let videoURL = await Self.blankVideoURL(for: videoSize) else { return }
			guard let self = self, !Task.isCancelled, self.canvasSize == canvasSize else { return }

			let asset = AVURLAsset(url: videoURL)
			let composition = AVMutableVideoComposition(asset: asset) { [weak self] request in
				guard let self = self else {
					request.finish(with: request.sourceImage, context: nil)
					return
				}
				request.finish(with: self.frameImage(for: request), context: nil)
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
		self.stateLock.lock()
		self.plan = plan
		self.stateLock.unlock()
	}

	/// Anchors the playback position against the blank loop's clock.
	///
	/// - Parameter positionMs: The playback position in milliseconds.
	func syncAnchor(positionMs: Int) {
		let itemSeconds = self.player.currentTime().seconds

		self.stateLock.lock()
		self.anchorPositionMs = positionMs
		self.anchorItemSeconds = itemSeconds.isFinite ? itemSeconds : 0
		self.stateLock.unlock()
	}

	/// Builds the frame image for a composition request.
	///
	/// - Parameter request: The composition request to serve.
	///
	/// - Returns: The frame image covering the request's extent.
	private func frameImage(for request: AVAsynchronousCIImageFilteringRequest) -> CIImage {
		self.stateLock.lock()
		defer {
			self.stateLock.unlock()
		}

		guard let plan = self.plan, self.canvasSize != .zero else { return request.sourceImage }

		var positionMs = self.anchorPositionMs
		if plan.isPlaying {
			var elapsedSeconds = request.compositionTime.seconds - self.anchorItemSeconds

			if elapsedSeconds < -Double(Self.loopSeconds) / 2 {
				elapsedSeconds += Double(Self.loopSeconds)
			}

			positionMs += Int(elapsedSeconds * 1000)
		}

		let frame = FloatingLyricsFrameBuilder.frame(atPositionMs: positionMs, following: plan)
		let drawingSize = Self.cardSize
		let targetSize = request.sourceImage.extent.size

		if self.frameRenderer == nil || self.frameRendererSize != targetSize {
			let format = UIGraphicsImageRendererFormat()
			format.scale = 1
			format.opaque = true
			self.frameRenderer = UIGraphicsImageRenderer(size: targetSize, format: format)
			self.frameRendererSize = targetSize
		}

		guard let renderedImage = self.frameRenderer?.image(actions: { rendererContext in
			let scale = targetSize.width / drawingSize.width
			rendererContext.cgContext.scaleBy(x: scale, y: scale)
			FloatingLyricsRenderer.draw(frame, in: rendererContext.cgContext, size: drawingSize)
		}) else { return request.sourceImage }

		return CIImage(image: renderedImage) ?? request.sourceImage
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

		return await Task.detached(priority: .userInitiated) {
			do {
				try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
				try self.writeBlankVideo(to: videoURL, size: size)
				return videoURL
			} catch {
				print("----- PiP blank video generation failed:", error.localizedDescription)
				return nil
			}
		}.value
	}

	/// Writes a silent black H.264 loop of ``loopSeconds`` at ``framesPerSecond``.
	///
	/// - Parameters:
	///    - url: The destination file URL.
	///    - size: The video size in pixels.
	private static func writeBlankVideo(to url: URL, size: CGSize) throws {
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
				Thread.sleep(forTimeInterval: 0.005)
			}
			adaptor.append(blackBuffer, withPresentationTime: CMTime(value: CMTimeValue(frameIndex), timescale: Self.framesPerSecond))
		}

		input.markAsFinished()

		let finishSemaphore = DispatchSemaphore(value: 0)
		writer.finishWriting {
			finishSemaphore.signal()
		}
		finishSemaphore.wait()

		guard writer.status == .completed else {
			throw writer.error ?? AVError(.unknown)
		}
	}
}
#endif
