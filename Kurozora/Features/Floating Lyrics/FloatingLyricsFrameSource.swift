//
//  FloatingLyricsFrameSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import AVFoundation
import CoreImage
import UIKit

/// The lock-guarded lyric state the Mac compositor derives frames from on its own thread.
nonisolated final class FloatingLyricsFrameSource: @unchecked Sendable {
	// MARK: - Properties
	/// The state shared between the main actor and the compositor thread.
	private nonisolated struct State {
		/// The plan frames derive from.
		var plan: FloatingLyricsFrameBuilder.Plan?

		/// The playback position at the anchor, in milliseconds.
		var anchorPositionMs = 0

		/// The blank loop's item time at the anchor, in seconds.
		var anchorItemSeconds = 0.0

		/// The size of the logical rendering canvas in pixels.
		var canvasSize: CGSize = .zero

		/// The renderer producing frame images.
		var frameRenderer: UIGraphicsImageRenderer?

		/// The pixel size ``frameRenderer`` renders at.
		var frameRendererSize: CGSize = .zero
	}

	/// The drawing size of the card.
	private let cardSize: CGSize

	/// The length of the blank source video loop in seconds.
	private let loopSeconds: Double

	/// The lock guarding ``state``.
	private let lock = NSLock()

	/// The shared state, read and written only through ``withState(_:)``.
	private var state = State()

	// MARK: - Initializers
	/// Creates a frame source drawing into a card of the given size.
	///
	/// - Parameters:
	///    - cardSize: The drawing size of the card.
	///    - loopSeconds: The length of the blank source video loop in seconds.
	init(cardSize: CGSize, loopSeconds: Double) {
		self.cardSize = cardSize
		self.loopSeconds = loopSeconds
	}

	// MARK: - Functions
	/// Stages the plan frames derive from.
	///
	/// - Parameter plan: The plan to derive frames from.
	func stage(plan: FloatingLyricsFrameBuilder.Plan) {
		self.withState { state in
			state.plan = plan
		}
	}

	/// Anchors the playback position against the blank loop's clock.
	///
	/// - Parameters:
	///    - positionMs: The playback position in milliseconds.
	///    - itemSeconds: The blank loop's item time in seconds.
	func syncAnchor(positionMs: Int, itemSeconds: Double) {
		self.withState { state in
			state.anchorPositionMs = positionMs
			state.anchorItemSeconds = itemSeconds.isFinite ? itemSeconds : 0
		}
	}

	/// Sets the size of the logical rendering canvas.
	///
	/// - Parameter canvasSize: The canvas size in pixels.
	func setCanvasSize(_ canvasSize: CGSize) {
		self.withState { state in
			state.canvasSize = canvasSize
		}
	}

	/// Builds the frame image for a composition request.
	///
	/// - Parameter request: The composition request to serve.
	///
	/// - Returns: The frame image covering the request's extent.
	func image(for request: AVAsynchronousCIImageFilteringRequest) -> CIImage {
		let compositionSeconds = request.compositionTime.seconds
		let targetSize = request.sourceImage.extent.size

		let renderedImage = self.withState { state -> UIImage? in
			guard let plan = state.plan, state.canvasSize != .zero else { return nil }

			var positionMs = state.anchorPositionMs
			if plan.isPlaying {
				var elapsedSeconds = compositionSeconds - state.anchorItemSeconds

				if elapsedSeconds < -self.loopSeconds / 2 {
					elapsedSeconds += self.loopSeconds
				}

				positionMs += Int(elapsedSeconds * 1000)
			}

			let frame = FloatingLyricsFrameBuilder.frame(atPositionMs: positionMs, following: plan)

			if state.frameRenderer == nil || state.frameRendererSize != targetSize {
				let format = UIGraphicsImageRendererFormat()
				format.scale = 1
				format.opaque = true
				state.frameRenderer = UIGraphicsImageRenderer(size: targetSize, format: format)
				state.frameRendererSize = targetSize
			}

			let drawingSize = self.cardSize
			return state.frameRenderer?.image { rendererContext in
				let scale = targetSize.width / drawingSize.width
				rendererContext.cgContext.scaleBy(x: scale, y: scale)
				FloatingLyricsRenderer.draw(frame, in: rendererContext.cgContext, size: drawingSize)
			}
		}

		guard let renderedImage else { return request.sourceImage }

		return CIImage(image: renderedImage) ?? request.sourceImage
	}

	/// Runs the given work with exclusive access to the shared state.
	///
	/// - Parameter body: The work to run on the state.
	///
	/// - Returns: The value returned by `body`.
	private func withState<Result>(_ body: (inout State) -> Result) -> Result {
		self.lock.lock()
		defer { self.lock.unlock() }

		return body(&self.state)
	}
}
#endif
