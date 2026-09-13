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
	/// Starts playback of the chime at the given location.
	///
	/// - Parameters:
	///    - url: The location of the chime file.
	///    - delegate: The object notified when playback finishes.
	func start(for url: URL, delegate: any AVAudioPlayerDelegate & Sendable) {
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			player.delegate = delegate
			player.prepareToPlay()
			player.play()

			self.player = player
		} catch {
			print("----- Failed to play chime audio: \(error.localizedDescription)")
		}
	}
}
