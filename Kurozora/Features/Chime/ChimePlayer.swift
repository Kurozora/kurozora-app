//
//  ChimePlayer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation

/// Plays chime audio away from the main thread.
final actor ChimePlayer {
	// MARK: - Properties
	/// The window the attack envelope is sampled over.
	private static let envelopeHop: TimeInterval = 0.005

	/// The share of the loudest window that counts as the attack.
	private static let attackThreshold: Float = 0.25

	private var player: AVAudioPlayer?

	// MARK: - Functions
	/// Loads the chime at the given location.
	///
	/// - Parameters:
	///    - url: The location of the chime file.
	///    - delegate: The object notified when playback finishes.
	///
	/// - Returns: The loaded chime's duration and the time of its loudest attack.
	func load(for url: URL, delegate: any AVAudioPlayerDelegate & Sendable) -> (duration: TimeInterval, onset: TimeInterval) {
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			player.delegate = delegate

			self.player = player

			return (player.duration, Self.onset(of: url) ?? 0.0)
		} catch {
			print("----- Failed to load chime audio: \(error.localizedDescription)")
			return (0.0, 0.0)
		}
	}

	/// Returns the time from the start of the audio to its loudest attack.
	///
	/// - Parameter url: The location of the audio file.
	///
	/// - Returns: The attack's offset in seconds.
	private static func onset(of url: URL) -> TimeInterval? {
		guard let file = try? AVAudioFile(forReading: url) else { return nil }

		let frameCount = AVAudioFrameCount(file.length)
		guard frameCount > 0, let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else { return nil }

		do {
			try file.read(into: buffer)
		} catch {
			return nil
		}

		guard let samples = buffer.floatChannelData?[0] else { return nil }

		let sampleRate = file.processingFormat.sampleRate
		let hop = max(1, Int(sampleRate * Self.envelopeHop))
		let frames = Int(buffer.frameLength)

		var envelope: [Float] = []
		var start = 0

		while start + hop <= frames {
			var sum: Float = 0.0

			for index in start ..< (start + hop) {
				sum += samples[index] * samples[index]
			}

			envelope.append(sum / Float(hop))
			start += hop
		}

		guard let loudest = envelope.max(), loudest > 0.0 else { return nil }
		guard let attack = envelope.firstIndex(where: { $0 >= loudest * Self.attackThreshold }) else { return nil }

		return TimeInterval(attack) * Self.envelopeHop
	}

	/// Starts playback of the loaded chime.
	func start() {
		self.player?.prepareToPlay()
		self.player?.play()
	}

	/// Loads the chime at the given location and starts playback.
	///
	/// - Parameters:
	///    - url: The location of the chime file.
	///    - delegate: The object notified when playback finishes.
	func loadAndStart(for url: URL, delegate: any AVAudioPlayerDelegate & Sendable) {
		_ = self.load(for: url, delegate: delegate)
		self.start()
	}
}
