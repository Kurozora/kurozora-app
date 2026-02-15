//
//  MediaPlaybackControlling.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine

/// A protocol that abstracts playback control so views aren't coupled to a specific player implementation.
protocol MediaPlaybackControlling: AnyObject {
	/// A publisher that emits the currently playing song, or `nil` when nothing is playing.
	var currentSongPublisher: Published<MKSong?>.Publisher { get }

	/// A publisher that emits the Kurozora song model for the currently playing song, or `nil` when unavailable.
	var currentKKSongPublisher: Published<KKSong?>.Publisher { get }

	/// A publisher that emits whether audio is currently playing.
	var isPlayingPublisher: Published<Bool>.Publisher { get }

	/// The currently playing song, or `nil` when nothing is playing.
	var currentSong: MKSong? { get }

	/// The Kurozora song model associated with the currently playing song, or `nil` when unavailable.
	var currentKKSong: KKSong? { get }

	/// Whether audio is currently playing.
	var isPlaying: Bool { get }

	/// Toggles between play and pause for the current song.
	func togglePlayPause()
}
