//
//  FloatingLyricsFrame.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A single rendered state of the floating lyrics window.
struct FloatingLyricsFrame {
	// MARK: - Enums
	/// The content shown by a frame.
	enum Content {
		/// A lyric line with an optional second row.
		case lyric(primary: LineContent, secondary: SecondaryContent?)

		/// An instrumental gap, filled to the elapsed fraction.
		case interlude(fraction: CGFloat)

		/// The song title and artist, shown when no lyric line applies.
		case title(song: String, artist: String)

		/// Nothing to show.
		case empty
	}

	/// The content of the second row.
	enum SecondaryContent {
		/// A static text, such as a translation or pronunciation.
		case text(String)

		/// The upcoming lyric line.
		case nextLine(String)
	}

	// MARK: - Structs
	/// A resolved lyric line ready for karaoke drawing.
	struct LineContent {
		/// A timed word of the line.
		struct Word {
			/// The text of the word.
			let text: String

			/// The start of the word in milliseconds.
			let beginMs: Int

			/// The end of the word in milliseconds.
			let endMs: Int

			/// A Boolean value that indicates whether a space follows the word.
			let trailingSpace: Bool
		}

		/// The full text of the line.
		let text: String

		/// The timed words of the line, empty when only line timing exists.
		let words: [Word]

		/// The start of the line in milliseconds.
		let beginMs: Int

		/// The end of the line in milliseconds.
		let endMs: Int

		/// The global timing offset applied to every timestamp, in milliseconds.
		let offsetMs: Int
	}

	/// An in-flight ticker transition from the previous content.
	struct Transition {
		/// The content scrolling out.
		let from: Content

		/// The progress of the transition, from `0` to `1`.
		let progress: CGFloat

		/// A Boolean value that indicates whether the transition crossfades instead of scrolling.
		let crossfades: Bool
	}

	// MARK: - Properties
	/// The content of the frame.
	let content: Content

	/// The transition from the previous content.
	let transition: Transition?

	/// The playback position in milliseconds.
	let positionMs: Int

	/// A Boolean value that indicates whether playback is running.
	let isPlaying: Bool

	/// The font size of the rendered text.
	let fontSize: LyricsFloatingWindowFontSize

	/// The number of lyric rows in the window.
	let rows: LyricsFloatingWindowRows

	/// The background palette of the window, derived from the album artwork when available.
	///
	/// The first color is the base wash; the rest are blended in as soft color pools.
	let backgroundColors: [UIColor]
}
