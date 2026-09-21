//
//  TrailerStreamRemuxer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import CoreMedia
import Foundation

#if !targetEnvironment(macCatalyst)
/// Rewraps a transport stream file into an MP4 file.
nonisolated final class TrailerStreamRemuxer {
	/// The failures a rewrap can end in.
	enum RemuxError: Error {
		/// The stream carries no program the rewrap understands.
		case malformedStream

		/// The stream carries a codec the rewrap cannot pass through.
		case unsupportedCodec

		/// The video file could not be written.
		case writerFailed
	}

	/// A video frame with its timing.
	private struct VideoFrame {
		let data: Data
		let presentationTime: CMTime
		let decodeTime: CMTime
		let isSync: Bool
	}

	/// A compressed audio frame with its timing.
	private struct AudioFrame {
		let data: Data
		let presentationTime: CMTime
	}

	// MARK: - Properties
	/// The size of one transport stream packet.
	private static let packetLength = 188

	/// The clock the stream's timestamps count in.
	private static let clockRate: CMTimeScale = 90_000

	/// The sample rates the audio header's index stands for.
	private static let sampleRates = [96_000, 88_200, 64_000, 48_000, 44_100, 32_000, 24_000, 22_050, 16_000, 12_000, 11_025, 8_000, 7_350]

	/// The identifier of the packets carrying the program map.
	private var programMapIdentifier: Int?

	/// The identifier of the packets carrying video.
	private var videoIdentifier: Int?

	/// The identifier of the packets carrying audio.
	private var audioIdentifier: Int?

	/// The bytes gathered so far for each stream's current unit.
	private var gatheredUnits: [Int: [UInt8]] = [:]

	/// The video's sequence parameter set.
	private var sequenceParameterSet: [UInt8]?

	/// The video's picture parameter set.
	private var pictureParameterSet: [UInt8]?

	/// The video's format.
	private var videoFormat: CMVideoFormatDescription?

	/// The audio's format.
	private var audioFormat: CMAudioFormatDescription?

	/// The audio's sample rate.
	private var audioSampleRate = 0

	/// The video frames waiting for the writer to start.
	private var heldVideoFrames: [VideoFrame] = []

	/// The audio frames waiting for the writer to start.
	private var heldAudioFrames: [AudioFrame] = []

	/// The video frame waiting for the next one to settle its duration.
	private var pendingVideoFrame: VideoFrame?

	/// The duration the last video frame was given.
	private var lastVideoDuration = CMTime(value: 3003, timescale: TrailerStreamRemuxer.clockRate)

	/// The point the audio clock has run to.
	private var audioClock: CMTime?

	/// The writer producing the video file.
	private var writer: AVAssetWriter?

	/// The writer's video input.
	private var videoInput: AVAssetWriterInput?

	/// The writer's audio input.
	private var audioInput: AVAssetWriterInput?

	/// The video samples waiting for the writer's video input to take them.
	private var videoQueue: [CMSampleBuffer] = []

	/// The audio samples waiting for the writer's audio input to take them.
	private var audioQueue: [CMSampleBuffer] = []

	/// A Boolean value indicating whether the video input has been told no more samples are coming.
	private var hasFinishedVideoInput = false

	/// A Boolean value indicating whether the audio input has been told no more samples are coming.
	private var hasFinishedAudioInput = false

	// MARK: - Functions
	/// Rewraps the given transport stream file into a video file.
	///
	/// - Parameters:
	///    - streamFileURL: The URL of the transport stream file.
	///    - videoFileURL: The URL the video file is written to.
	func remux(_ streamFileURL: URL, to videoFileURL: URL) async throws {
		let writer = try AVAssetWriter(outputURL: videoFileURL, fileType: .mp4)
		self.writer = writer

		let fileHandle = try FileHandle(forReadingFrom: streamFileURL)
		defer {
			try? fileHandle.close()
		}

		var remainder: [UInt8] = []

		while let chunk = try fileHandle.read(upToCount: Self.packetLength * 2048), !chunk.isEmpty {
			var bytes = remainder + [UInt8](chunk)
			var offset = 0

			while offset + Self.packetLength <= bytes.count {
				try await self.readPacket(bytes[offset ..< offset + Self.packetLength])
				offset += Self.packetLength
			}

			bytes.removeFirst(offset)
			remainder = bytes
		}

		for identifier in Array(self.gatheredUnits.keys) {
			try await self.finishUnit(for: identifier)
		}

		try await self.startWriterIfReady(forcing: true)

		if let pendingVideoFrame = self.pendingVideoFrame {
			try await self.write(pendingVideoFrame, duration: self.lastVideoDuration)
			self.pendingVideoFrame = nil
		}

		try await self.drainQueues(waiting: true)
		self.finishVideoInput()
		self.finishAudioInput()
		await writer.finishWriting()

		guard writer.status == .completed else {
			throw writer.error ?? RemuxError.writerFailed
		}
	}

	/// Reads one packet into its stream's unit.
	///
	/// - Parameter packet: The packet's bytes.
	private func readPacket(_ packet: ArraySlice<UInt8>) async throws {
		let bytes = Array(packet)
		guard bytes[0] == 0x47 else { throw RemuxError.malformedStream }

		let startsUnit = bytes[1] & 0x40 != 0
		let identifier = Int(bytes[1] & 0x1F) << 8 | Int(bytes[2])
		let adaptationControl = (bytes[3] >> 4) & 0x03
		var payloadStart = 4

		if adaptationControl & 0x02 != 0 {
			payloadStart += Int(bytes[4]) + 1
		}

		guard adaptationControl & 0x01 != 0, payloadStart < bytes.count else { return }
		let payload = Array(bytes[payloadStart...])

		if identifier == 0 {
			self.readProgramAssociation(payload)
		} else if identifier == self.programMapIdentifier {
			try self.readProgramMap(payload)
		} else if identifier == self.videoIdentifier || identifier == self.audioIdentifier {
			if startsUnit {
				try await self.finishUnit(for: identifier)
				self.gatheredUnits[identifier] = payload
			} else if self.gatheredUnits[identifier] != nil {
				self.gatheredUnits[identifier]?.append(contentsOf: payload)
			}
		}
	}

	/// Reads the program map's identifier out of the program association table.
	///
	/// - Parameter payload: The table's bytes.
	private func readProgramAssociation(_ payload: [UInt8]) {
		guard self.programMapIdentifier == nil, let table = Self.tableBody(of: payload, tableIdentifier: 0x00) else { return }

		var offset = 5

		while offset + 4 <= table.count {
			let programNumber = Int(table[offset]) << 8 | Int(table[offset + 1])
			let identifier = Int(table[offset + 2] & 0x1F) << 8 | Int(table[offset + 3])

			if programNumber != 0 {
				self.programMapIdentifier = identifier
				return
			}

			offset += 4
		}
	}

	/// Reads the video and audio stream identifiers out of the program map.
	///
	/// - Parameter payload: The table's bytes.
	private func readProgramMap(_ payload: [UInt8]) throws {
		guard self.videoIdentifier == nil, let table = Self.tableBody(of: payload, tableIdentifier: 0x02) else { return }

		let programInfoLength = Int(table[7] & 0x0F) << 8 | Int(table[8])
		var offset = 9 + programInfoLength

		while offset + 5 <= table.count {
			let streamType = table[offset]
			let identifier = Int(table[offset + 1] & 0x1F) << 8 | Int(table[offset + 2])
			let infoLength = Int(table[offset + 3] & 0x0F) << 8 | Int(table[offset + 4])

			switch streamType {
			case 0x1B:
				self.videoIdentifier = identifier
			case 0x0F:
				self.audioIdentifier = identifier
			case 0x24, 0x03, 0x04:
				throw RemuxError.unsupportedCodec
			default:
				break
			}

			offset += 5 + infoLength
		}

		guard self.videoIdentifier != nil else { throw RemuxError.malformedStream }
	}

	/// Returns a table's body without its pointer, header, and checksum.
	///
	/// - Parameters:
	///    - payload: The packet payload carrying the table.
	///    - tableIdentifier: The identifier the table must carry.
	///
	/// - Returns: The bytes from the transport stream identifier up to the checksum.
	private static func tableBody(of payload: [UInt8], tableIdentifier: UInt8) -> [UInt8]? {
		guard !payload.isEmpty else { return nil }

		let tableStart = Int(payload[0]) + 1
		guard tableStart + 3 <= payload.count, payload[tableStart] == tableIdentifier else { return nil }

		let sectionLength = Int(payload[tableStart + 1] & 0x0F) << 8 | Int(payload[tableStart + 2])
		let bodyStart = tableStart + 3
		let bodyEnd = min(payload.count, bodyStart + sectionLength - 4)
		guard bodyEnd > bodyStart else { return nil }

		return Array(payload[bodyStart ..< bodyEnd])
	}

	/// Turns a stream's gathered unit into frames.
	///
	/// - Parameter identifier: The identifier of the stream whose unit is complete.
	private func finishUnit(for identifier: Int) async throws {
		guard let unit = self.gatheredUnits.removeValue(forKey: identifier), unit.count > 9 else { return }
		guard unit[0] == 0x00, unit[1] == 0x00, unit[2] == 0x01 else { return }

		let flags = unit[7]
		let headerLength = Int(unit[8])
		let dataStart = 9 + headerLength
		guard dataStart <= unit.count else { return }

		var presentationTime: CMTime?
		var decodeTime: CMTime?

		if flags & 0x80 != 0, unit.count >= 14 {
			presentationTime = Self.timestamp(at: 9, in: unit)
		}

		if flags & 0x40 != 0, unit.count >= 19 {
			decodeTime = Self.timestamp(at: 14, in: unit)
		}

		let data = Array(unit[dataStart...])

		if identifier == self.videoIdentifier {
			try await self.readVideoUnit(data, presentationTime: presentationTime, decodeTime: decodeTime ?? presentationTime)
		} else {
			try await self.readAudioUnit(data, presentationTime: presentationTime)
		}
	}

	/// Reads a 33 bit timestamp out of a unit header.
	///
	/// - Parameters:
	///    - offset: The position of the timestamp's first byte.
	///    - unit: The unit's bytes.
	///
	/// - Returns: The timestamp on the stream's clock.
	private static func timestamp(at offset: Int, in unit: [UInt8]) -> CMTime {
		let value = Int64(unit[offset] & 0x0E) << 29
			| Int64(unit[offset + 1]) << 22
			| Int64(unit[offset + 2] & 0xFE) << 14
			| Int64(unit[offset + 3]) << 7
			| Int64(unit[offset + 4] >> 1)

		return CMTime(value: value, timescale: Self.clockRate)
	}

	/// Turns a video unit's byte stream into a length prefixed frame.
	///
	/// - Parameters:
	///    - data: The unit's byte stream.
	///    - presentationTime: The point the frame is shown at.
	///    - decodeTime: The point the frame is decoded at.
	private func readVideoUnit(_ data: [UInt8], presentationTime: CMTime?, decodeTime: CMTime?) async throws {
		guard let presentationTime = presentationTime, let decodeTime = decodeTime else { return }

		var frame = Data()
		var isSync = false

		for unit in Self.networkUnits(in: data) {
			guard let first = unit.first else { continue }

			switch first & 0x1F {
			case 7:
				if self.sequenceParameterSet == nil {
					self.sequenceParameterSet = unit
				}
			case 8:
				if self.pictureParameterSet == nil {
					self.pictureParameterSet = unit
				}
			case 9:
				break
			default:
				if first & 0x1F == 5 {
					isSync = true
				}

				var length = UInt32(unit.count).bigEndian
				frame.append(Data(bytes: &length, count: 4))
				frame.append(contentsOf: unit)
			}
		}

		if self.videoFormat == nil, let sequenceParameterSet = self.sequenceParameterSet, let pictureParameterSet = self.pictureParameterSet {
			self.videoFormat = try CMVideoFormatDescription(h264ParameterSets: [Data(sequenceParameterSet), Data(pictureParameterSet)], nalUnitHeaderLength: 4)
		}

		guard !frame.isEmpty else { return }

		let videoFrame = VideoFrame(data: frame, presentationTime: presentationTime, decodeTime: decodeTime, isSync: isSync)

		if self.writer?.status == .writing {
			try await self.queue(videoFrame)
		} else {
			self.heldVideoFrames.append(videoFrame)
			try await self.startWriterIfReady(forcing: false)
		}
	}

	/// Splits a byte stream on its start codes.
	///
	/// - Parameter data: The byte stream.
	///
	/// - Returns: The units between the start codes.
	private static func networkUnits(in data: [UInt8]) -> [[UInt8]] {
		var units: [[UInt8]] = []
		var unitStart: Int?
		var index = 0

		while index + 2 < data.count {
			if data[index] == 0x00, data[index + 1] == 0x00, data[index + 2] == 0x01 {
				if let start = unitStart {
					var end = index
					if end > start, data[end - 1] == 0x00 {
						end -= 1
					}
					units.append(Array(data[start ..< end]))
				}

				index += 3
				unitStart = index
				continue
			}

			index += 1
		}

		if let start = unitStart, start < data.count {
			units.append(Array(data[start...]))
		}

		return units
	}

	/// Turns an audio unit's frames into samples.
	///
	/// - Parameters:
	///    - data: The unit's bytes.
	///    - presentationTime: The point the first frame is heard at.
	private func readAudioUnit(_ data: [UInt8], presentationTime: CMTime?) async throws {
		var offset = 0

		while offset + 7 <= data.count, data[offset] == 0xFF, data[offset + 1] & 0xF0 == 0xF0 {
			let hasChecksum = data[offset + 1] & 0x01 == 0
			let headerLength = hasChecksum ? 9 : 7
			let frameLength = Int(data[offset + 3] & 0x03) << 11 | Int(data[offset + 4]) << 3 | Int(data[offset + 5] >> 5)
			guard frameLength > headerLength, offset + frameLength <= data.count else { break }

			if self.audioFormat == nil {
				try self.adoptAudioFormat(fromHeader: Array(data[offset ..< offset + 7]))
			}

			let frameDuration = CMTime(value: 1024, timescale: CMTimeScale(self.audioSampleRate))
			var frameTime = self.audioClock ?? presentationTime ?? .zero

			if let presentationTime = presentationTime, offset == 0, let audioClock = self.audioClock, abs(CMTimeSubtract(presentationTime, audioClock).seconds) > frameDuration.seconds {
				frameTime = presentationTime
			}

			let frame = AudioFrame(data: Data(data[offset + headerLength ..< offset + frameLength]), presentationTime: frameTime)
			self.audioClock = CMTimeAdd(frameTime, frameDuration)

			if self.writer?.status == .writing {
				try await self.write(frame)
			} else {
				self.heldAudioFrames.append(frame)
			}

			offset += frameLength
		}

		if self.writer?.status != .writing {
			try await self.startWriterIfReady(forcing: false)
		}
	}

	/// Builds the audio format out of a frame header.
	///
	/// - Parameter header: The frame header's bytes.
	private func adoptAudioFormat(fromHeader header: [UInt8]) throws {
		let profile = Int(header[2] >> 6) & 0x03
		let rateIndex = Int(header[2] >> 2) & 0x0F
		let channelConfiguration = Int(header[2] & 0x01) << 2 | Int(header[3] >> 6) & 0x03
		guard rateIndex < Self.sampleRates.count else { throw RemuxError.unsupportedCodec }

		let sampleRate = Self.sampleRates[rateIndex]
		let channels = channelConfiguration == 7 ? 8 : max(1, channelConfiguration)
		let objectType = profile + 1

		var description = AudioStreamBasicDescription()
		description.mSampleRate = Double(sampleRate)
		description.mFormatID = kAudioFormatMPEG4AAC
		description.mFormatFlags = UInt32(objectType)
		description.mFramesPerPacket = 1024
		description.mChannelsPerFrame = UInt32(channels)

		let audioSpecificConfig: [UInt8] = [
			UInt8(objectType << 3 | rateIndex >> 1),
			UInt8((rateIndex & 0x01) << 7 | channelConfiguration << 3)
		]

		self.audioFormat = try CMAudioFormatDescription(audioStreamBasicDescription: description, magicCookie: Self.magicCookie(wrapping: audioSpecificConfig))
		self.audioSampleRate = sampleRate
	}

	/// Wraps an audio specific config in the elementary stream descriptor chain.
	///
	/// - Parameter audioSpecificConfig: The decoder's configuration bytes.
	///
	/// - Returns: The descriptor chain the writer stores with the track.
	private static func magicCookie(wrapping audioSpecificConfig: [UInt8]) -> Data {
		let decoderSpecificInfo: [UInt8] = [0x05, UInt8(audioSpecificConfig.count)] + audioSpecificConfig
		let decoderConfig: [UInt8] = [0x04, UInt8(13 + decoderSpecificInfo.count), 0x40, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] + decoderSpecificInfo
		let syncLayerConfig: [UInt8] = [0x06, 0x01, 0x02]
		let elementaryStream: [UInt8] = [0x03, UInt8(3 + decoderConfig.count + syncLayerConfig.count), 0x00, 0x00, 0x00] + decoderConfig + syncLayerConfig

		return Data(elementaryStream)
	}

	/// Starts the writer once the formats are known.
	///
	/// - Parameter forcing: Whether to start with whatever formats are known.
	private func startWriterIfReady(forcing: Bool) async throws {
		guard let writer = self.writer, writer.status == .unknown, let videoFormat = self.videoFormat else {
			if forcing, self.videoFormat == nil {
				throw RemuxError.malformedStream
			}
			return
		}

		let awaitsAudio = self.audioIdentifier != nil && self.audioFormat == nil
		guard forcing || !awaitsAudio else { return }

		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil, sourceFormatHint: videoFormat)
		videoInput.expectsMediaDataInRealTime = false
		writer.add(videoInput)
		self.videoInput = videoInput

		if let audioFormat = self.audioFormat {
			let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil, sourceFormatHint: audioFormat)
			audioInput.expectsMediaDataInRealTime = false
			writer.add(audioInput)
			self.audioInput = audioInput
		}

		guard writer.startWriting() else {
			throw writer.error ?? RemuxError.writerFailed
		}

		var startTime = self.heldVideoFrames.first?.presentationTime ?? .zero
		if let firstAudioTime = self.heldAudioFrames.first?.presentationTime, CMTimeCompare(firstAudioTime, startTime) < 0 {
			startTime = firstAudioTime
		}
		writer.startSession(atSourceTime: startTime)

		let videoFrames = self.heldVideoFrames
		let audioFrames = self.heldAudioFrames
		self.heldVideoFrames = []
		self.heldAudioFrames = []

		for frame in videoFrames {
			try await self.queue(frame)
		}

		for frame in audioFrames {
			try await self.write(frame)
		}
	}

	/// Holds a video frame until the next one settles its duration.
	///
	/// - Parameter frame: The frame to hold.
	private func queue(_ frame: VideoFrame) async throws {
		if let pendingVideoFrame = self.pendingVideoFrame {
			var duration = CMTimeSubtract(frame.decodeTime, pendingVideoFrame.decodeTime)
			if CMTimeCompare(duration, .zero) <= 0 {
				duration = self.lastVideoDuration
			}

			self.lastVideoDuration = duration
			try await self.write(pendingVideoFrame, duration: duration)
		}

		self.pendingVideoFrame = frame
	}

	/// Writes a video frame.
	///
	/// - Parameters:
	///    - frame: The frame to write.
	///    - duration: The time the frame stays on screen.
	private func write(_ frame: VideoFrame, duration: CMTime) async throws {
		guard self.videoInput != nil, let videoFormat = self.videoFormat else { return }

		let timing = CMSampleTimingInfo(duration: duration, presentationTimeStamp: frame.presentationTime, decodeTimeStamp: frame.decodeTime)
		let sampleBuffer = try Self.sampleBuffer(for: frame.data, format: videoFormat, timing: timing)

		if !frame.isSync, var attachments = sampleBuffer.sampleAttachments.first {
			attachments[.notSync] = true
		}

		self.videoQueue.append(sampleBuffer)
		try await self.drainQueues(waiting: false)
	}

	/// Writes an audio frame.
	///
	/// - Parameter frame: The frame to write.
	private func write(_ frame: AudioFrame) async throws {
		guard self.audioInput != nil, let audioFormat = self.audioFormat else { return }

		let timing = CMSampleTimingInfo(duration: CMTime(value: 1024, timescale: CMTimeScale(self.audioSampleRate)), presentationTimeStamp: frame.presentationTime, decodeTimeStamp: .invalid)
		let sampleBuffer = try Self.sampleBuffer(for: frame.data, format: audioFormat, timing: timing)

		self.audioQueue.append(sampleBuffer)
		try await self.drainQueues(waiting: false)
	}

	/// Wraps compressed bytes into a sample buffer.
	///
	/// - Parameters:
	///    - data: The compressed bytes.
	///    - format: The format the bytes are in.
	///    - timing: The sample's timing.
	///
	/// - Returns: The sample buffer.
	private static func sampleBuffer(for data: Data, format: CMFormatDescription, timing: CMSampleTimingInfo) throws -> CMSampleBuffer {
		let blockBuffer = try CMBlockBuffer(length: data.count)
		let status = data.withUnsafeBytes { bytes -> OSStatus in
			guard let base = bytes.baseAddress else { return kCMBlockBufferBadPointerParameterErr }
			return CMBlockBufferReplaceDataBytes(with: base, blockBuffer: blockBuffer, offsetIntoDestination: 0, dataLength: data.count)
		}

		guard status == kCMBlockBufferNoErr else { throw RemuxError.writerFailed }

		return try CMSampleBuffer(dataBuffer: blockBuffer, formatDescription: format, numSamples: 1, sampleTimings: [timing], sampleSizes: [data.count])
	}

	/// Hands queued samples to whichever input can take them.
	///
	/// - Parameter waiting: Whether to stay until every queued sample is written.
	private func drainQueues(waiting: Bool) async throws {
		while !self.videoQueue.isEmpty || !self.audioQueue.isEmpty {
			var didAppend = false

			if let videoInput = self.videoInput, !self.videoQueue.isEmpty, videoInput.isReadyForMoreMediaData {
				try self.append(self.videoQueue.removeFirst(), to: videoInput)
				didAppend = true
			}

			if let audioInput = self.audioInput, !self.audioQueue.isEmpty, audioInput.isReadyForMoreMediaData {
				try self.append(self.audioQueue.removeFirst(), to: audioInput)
				didAppend = true
			}

			guard !didAppend else { continue }
			guard waiting else { return }

			if self.videoQueue.isEmpty {
				self.finishVideoInput()
			}

			if self.audioQueue.isEmpty {
				self.finishAudioInput()
			}

			guard self.writer?.status == .writing else {
				throw self.writer?.error ?? RemuxError.writerFailed
			}

			try await Task.sleep(nanoseconds: 2_000_000)
		}
	}

	/// Tells the writer the video input has no more samples coming.
	private func finishVideoInput() {
		guard !self.hasFinishedVideoInput, let videoInput = self.videoInput else { return }

		self.hasFinishedVideoInput = true
		videoInput.markAsFinished()
	}

	/// Tells the writer the audio input has no more samples coming.
	private func finishAudioInput() {
		guard !self.hasFinishedAudioInput, let audioInput = self.audioInput else { return }

		self.hasFinishedAudioInput = true
		audioInput.markAsFinished()
	}

	/// Appends one sample.
	///
	/// - Parameters:
	///    - sampleBuffer: The sample to append.
	///    - input: The input to append to.
	private func append(_ sampleBuffer: CMSampleBuffer, to input: AVAssetWriterInput) throws {
		guard input.append(sampleBuffer) else {
			throw self.writer?.error ?? RemuxError.writerFailed
		}
	}
}
#endif
