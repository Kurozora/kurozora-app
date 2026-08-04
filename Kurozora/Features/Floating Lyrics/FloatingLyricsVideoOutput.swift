//
//  FloatingLyricsVideoOutput.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// Renders floating lyrics frames into pixel buffers and enqueues them on a sample buffer layer.
final class FloatingLyricsVideoOutput {
	// MARK: - Properties
	/// The layer frames are enqueued into.
	weak var displayLayer: AVSampleBufferDisplayLayer?

	/// The size of the rendering canvas in pixels.
	private(set) var canvasSize: CGSize = .zero

	/// The pool of pixel buffers matching ``canvasSize``.
	private var pixelBufferPool: CVPixelBufferPool?

	/// The format description matching the pool's buffers.
	private var formatDescription: CMVideoFormatDescription?

	// MARK: - Functions
	/// Sets the rendering canvas size.
	///
	/// - Parameter size: The canvas size in pixels.
	func setCanvasSize(_ size: CGSize) {
		guard size != self.canvasSize else { return }

		self.canvasSize = size
		self.pixelBufferPool = nil
		self.formatDescription = nil

		let poolAttributes: [CFString: Any] = [
			kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
			kCVPixelBufferWidthKey: Int(size.width),
			kCVPixelBufferHeightKey: Int(size.height),
			kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
		]

		var pool: CVPixelBufferPool?
		CVPixelBufferPoolCreate(nil, nil, poolAttributes as CFDictionary, &pool)
		self.pixelBufferPool = pool
	}

	/// Renders the given frame and enqueues it for display.
	///
	/// - Parameter lyricsFrame: The frame to render.
	func enqueue(drawing lyricsFrame: FloatingLyricsFrame) {
		guard let displayLayer = self.displayLayer, let pixelBufferPool = self.pixelBufferPool else { return }

		if displayLayer.status == .failed || displayLayer.requiresFlushToResumeDecoding {
			displayLayer.flush()
			self.formatDescription = nil
		}

		var pooledBuffer: CVPixelBuffer?
		CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pooledBuffer)
		guard let pixelBuffer = pooledBuffer else { return }

		self.render(lyricsFrame, into: pixelBuffer)

		guard let sampleBuffer = self.makeSampleBuffer(wrapping: pixelBuffer) else { return }
		displayLayer.enqueue(sampleBuffer)
	}

	/// Draws the given frame into the pixel buffer through the shared renderer.
	///
	/// - Parameters:
	///    - lyricsFrame: The frame to draw.
	///    - pixelBuffer: The buffer to draw into.
	private func render(_ lyricsFrame: FloatingLyricsFrame, into pixelBuffer: CVPixelBuffer) {
		CVPixelBufferLockBaseAddress(pixelBuffer, [])
		defer {
			CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
		}

		let width = CVPixelBufferGetWidth(pixelBuffer)
		let height = CVPixelBufferGetHeight(pixelBuffer)
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

		guard let context = CGContext(
			data: CVPixelBufferGetBaseAddress(pixelBuffer),
			width: width,
			height: height,
			bitsPerComponent: 8,
			bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: bitmapInfo.rawValue
		) else { return }

		context.translateBy(x: 0, y: CGFloat(height))
		context.scaleBy(x: 1, y: -1)

		FloatingLyricsRenderer.draw(lyricsFrame, in: context, size: CGSize(width: width, height: height))
	}

	/// Wraps a pixel buffer in an immediately-displayed sample buffer.
	///
	/// - Parameter pixelBuffer: The buffer to wrap.
	///
	/// - Returns: The sample buffer ready for enqueueing.
	private func makeSampleBuffer(wrapping pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
		if self.formatDescription == nil {
			var formatDescription: CMVideoFormatDescription?
			CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
			self.formatDescription = formatDescription
		}

		guard let formatDescription = self.formatDescription else { return nil }

		var timingInfo = CMSampleTimingInfo(
			duration: .invalid,
			presentationTimeStamp: CMClockGetTime(CMClockGetHostTimeClock()),
			decodeTimeStamp: .invalid
		)

		var wrappedBuffer: CMSampleBuffer?
		CMSampleBufferCreateReadyWithImageBuffer(
			allocator: nil,
			imageBuffer: pixelBuffer,
			formatDescription: formatDescription,
			sampleTiming: &timingInfo,
			sampleBufferOut: &wrappedBuffer
		)

		guard let sampleBuffer = wrappedBuffer else { return nil }

		if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true) as? [CFMutableDictionary], let attachment = attachments.first {
			CFDictionarySetValue(
				attachment,
				Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque(),
				Unmanaged.passUnretained(kCFBooleanTrue).toOpaque()
			)
		}

		return sampleBuffer
	}
}
