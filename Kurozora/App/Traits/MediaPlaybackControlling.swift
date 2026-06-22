//
//  MediaPlaybackControlling.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import Foundation

/// A snapshot of the active player's playback position.
struct PlaybackProgress: Equatable {
	/// The current playback position in seconds.
	var currentSeconds: TimeInterval

	/// The total duration of the current song in seconds, or `0` when unknown.
	var durationSeconds: TimeInterval

	/// A zero-valued progress, used when nothing is playing.
	static let zero = PlaybackProgress(currentSeconds: 0, durationSeconds: 0)

	/// The fraction of the song that has elapsed, in the range `0...1`.
	var fraction: Double {
		guard self.durationSeconds > 0 else { return 0 }
		return min(1, max(0, self.currentSeconds / self.durationSeconds))
	}

	/// The number of seconds remaining until the song ends.
	var remainingSeconds: TimeInterval {
		return max(0, self.durationSeconds - self.currentSeconds)
	}
}

/// The repeat behavior of the playback queue.
enum PlaybackRepeatMode {
	/// Playback stops at the end of the queue.
	case off

	/// The queue repeats from the start after the last song.
	case all

	/// The current song repeats indefinitely.
	case one
}

/// A protocol that abstracts playback control so views aren't coupled to a specific player implementation.
protocol MediaPlaybackControlling: AnyObject {
	/// A publisher that emits the currently playing song, or `nil` when nothing is playing.
	var currentSongPublisher: Published<MKSong?>.Publisher { get }

	/// A publisher that emits the Kurozora song model for the currently playing song, or `nil` when unavailable.
	var currentKKSongPublisher: Published<KKSong?>.Publisher { get }

	/// A publisher that emits whether audio is currently playing.
	var isPlayingPublisher: Published<Bool>.Publisher { get }

	/// A publisher that emits the active player's playback progress.
	var playbackProgressPublisher: Published<PlaybackProgress>.Publisher { get }

	/// The currently playing song, or `nil` when nothing is playing.
	var currentSong: MKSong? { get }

	/// The Kurozora song model associated with the currently playing song, or `nil` when unavailable.
	var currentKKSong: KKSong? { get }

	/// Whether audio is currently playing.
	var isPlaying: Bool { get }

	/// A publisher that emits whether there is a song to skip forward to.
	var canSkipForwardPublisher: Published<Bool>.Publisher { get }

	/// A publisher that emits whether there is a song to skip backward to.
	var canSkipBackwardPublisher: Published<Bool>.Publisher { get }

	/// A publisher that emits whether shuffle is enabled.
	var shuffleEnabledPublisher: Published<Bool>.Publisher { get }

	/// A publisher that emits the current repeat mode.
	var repeatModePublisher: Published<PlaybackRepeatMode>.Publisher { get }

	/// Whether there is a song to skip forward to.
	var canSkipForward: Bool { get }

	/// Whether there is a song to skip backward to.
	var canSkipBackward: Bool { get }

	/// Whether shuffle is enabled.
	var shuffleEnabled: Bool { get }

	/// The current repeat mode.
	var repeatMode: PlaybackRepeatMode { get }

	/// Toggles between play and pause for the current song.
	func togglePlayPause()

	/// Seeks the active player to the given position.
	///
	/// - Parameter seconds: The position to seek to, in seconds.
	func seek(toSeconds seconds: TimeInterval)

	/// Skips to the next song in the queue.
	func skipForward()

	/// Restarts the current song when more than a few seconds have elapsed, otherwise skips to the previous song.
	func skipBackward()

	/// Toggles shuffle on or off.
	func toggleShuffle()

	/// Advances the repeat mode to its next state.
	func cycleRepeat()
}
