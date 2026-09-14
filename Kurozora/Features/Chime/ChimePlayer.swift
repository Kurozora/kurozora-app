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
	private var player: AVAudioPlayer?

	// MARK: - Functions
	/// Loads the chime at the given location.
	///
	/// - Parameters:
	///    - url: The location of the chime file.
	///    - delegate: The object notified when playback finishes.
	///
	/// - Returns: The loaded chime's duration.
	func load(for url: URL, delegate: any AVAudioPlayerDelegate & Sendable) -> TimeInterval {
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			player.delegate = delegate

			self.player = player

			return player.duration
		} catch {
			print("----- Failed to load chime audio: \(error.localizedDescription)")
			return 0.0
		}
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
