//
//  FloatingLyricsFrameBuilder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// Derives floating lyrics frames as a pure function of playback position.
struct FloatingLyricsFrameBuilder {
	// MARK: - Structs
	/// A lyric line or instrumental gap on the lyrics timeline.
	struct TimelineItem {
		/// The index of the line in the lyrics, or `nil` for an interlude.
		let lineIndex: Int?

		/// The start of the item in milliseconds.
		let beginMs: Int

		/// The end of the item in milliseconds.
		let endMs: Int
	}

	/// Lyrics together with their derived timeline.
	struct ResolvedLyrics {
		/// The source lyrics.
		let lyrics: Lyrics

		/// The lines and interludes in playback order.
		let items: [TimelineItem]

		/// The global timing offset applied to every timestamp, in milliseconds.
		let offsetMs: Int

		/// Builds the timeline of lines and interludes for the given lyrics.
		///
		/// - Parameter lyrics: The lyrics to resolve.
		///
		/// - Returns: The resolved lyrics.
		static func resolve(_ lyrics: Lyrics) -> ResolvedLyrics {
			var items: [TimelineItem] = []
			var previousEndMs = 0

			for (index, line) in lyrics.attributes.lines.enumerated() {
				let beginMs = line.beginMs ?? previousEndMs

				if beginMs - previousEndMs >= FloatingLyricsFrameBuilder.gapThresholdMs {
					items.append(TimelineItem(lineIndex: nil, beginMs: previousEndMs, endMs: beginMs))
				}

				items.append(TimelineItem(lineIndex: index, beginMs: beginMs, endMs: line.endMs ?? beginMs))
				previousEndMs = line.endMs ?? beginMs
			}

			return ResolvedLyrics(lyrics: lyrics, items: items, offsetMs: lyrics.attributes.lyricOffsetMs ?? 0)
		}
	}

	/// An immutable snapshot of everything a frame derives from besides the playback position.
	struct Plan {
		/// The resolved lyrics of the song.
		let resolvedLyrics: ResolvedLyrics?

		/// The title shown when no lyric line applies.
		let songTitle: String

		/// The artist shown when no lyric line applies.
		let songArtist: String

		/// The background palette of the window.
		let backgroundColors: [UIColor]

		/// The font size of the window.
		let fontSize: LyricsFloatingWindowFontSize

		/// The number of lyric rows in the window.
		let rows: LyricsFloatingWindowRows

		/// Whether the second row shows the in-app translation preference.
		let showsTranslation: Bool

		/// The text shown larger when a line and its pronunciation both appear.
		let largerText: LyricsLargerText

		/// The selected lyrics translation language.
		let translationLanguage: String?

		/// Whether the lyrics transliteration is shown in-app.
		let showsTransliteration: Bool

		/// Whether line transitions crossfade instead of scrolling.
		let crossfades: Bool

		/// Whether playback is running.
		let isPlaying: Bool
	}

	// MARK: - Properties
	/// The duration of the ticker transition between lines, in milliseconds.
	static let transitionDurationMs = 300

	/// The gap length at or above which an interlude is shown, in milliseconds.
	static let gapThresholdMs = 4000

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// The frame for a playback position.
	///
	/// - Parameters:
	///    - positionMs: The playback position in milliseconds.
	///    - plan: The plan the frame derives from.
	///
	/// - Returns: The resolved frame.
	static func frame(atPositionMs positionMs: Int, following plan: Plan) -> FloatingLyricsFrame {
		guard let resolved = plan.resolvedLyrics, !resolved.items.isEmpty else {
			return FloatingLyricsFrame(
				content: .title(song: plan.songTitle, artist: plan.songArtist),
				transition: nil,
				positionMs: positionMs,
				isPlaying: plan.isPlaying,
				fontSize: plan.fontSize,
				rows: plan.rows,
				backgroundColors: plan.backgroundColors
			)
		}

		let activeIndex = self.activeItemIndex(in: resolved, forPositionMs: positionMs)
		let content = self.content(of: resolved, at: activeIndex, positionMs: positionMs, following: plan)

		var transition: FloatingLyricsFrame.Transition?
		if resolved.items.indices.contains(activeIndex), activeIndex > 0 {
			let activeStartMs = resolved.items[activeIndex].beginMs + resolved.offsetMs
			let elapsedMs = positionMs - activeStartMs

			if elapsedMs >= 0, elapsedMs < Self.transitionDurationMs {
				let previousContent = self.content(of: resolved, at: activeIndex - 1, positionMs: positionMs, following: plan)

				switch (previousContent, content) {
				case (.lyric, .lyric):
					transition = FloatingLyricsFrame.Transition(
						from: previousContent,
						progress: CGFloat(elapsedMs) / CGFloat(Self.transitionDurationMs),
						crossfades: plan.crossfades
					)
				default:
					break
				}
			}
		}

		return FloatingLyricsFrame(
			content: content,
			transition: transition,
			positionMs: positionMs,
			isPlaying: plan.isPlaying,
			fontSize: plan.fontSize,
			rows: plan.rows,
			backgroundColors: plan.backgroundColors
		)
	}

	/// The index of the item covering a playback position.
	///
	/// - Parameters:
	///    - resolved: The lyrics to search.
	///    - positionMs: The playback position in milliseconds.
	///
	/// - Returns: The active index, or `-1` before the first item.
	private static func activeItemIndex(in resolved: ResolvedLyrics, forPositionMs positionMs: Int) -> Int {
		var index = -1

		for (itemIndex, item) in resolved.items.enumerated() {
			if item.beginMs + resolved.offsetMs <= positionMs {
				index = itemIndex
			} else {
				break
			}
		}

		return index
	}

	/// The content shown for a timeline item.
	///
	/// - Parameters:
	///    - resolved: The lyrics the item belongs to.
	///    - index: The index of the item, or `-1` before the first item.
	///    - positionMs: The playback position in milliseconds.
	///    - plan: The plan the content derives from.
	///
	/// - Returns: The resolved content.
	private static func content(of resolved: ResolvedLyrics, at index: Int, positionMs: Int, following plan: Plan) -> FloatingLyricsFrame.Content {
		guard resolved.items.indices.contains(index) else {
			return .title(song: plan.songTitle, artist: plan.songArtist)
		}

		let item = resolved.items[index]

		guard let lineIndex = item.lineIndex else {
			let elapsed = positionMs - (item.beginMs + resolved.offsetMs)
			let total = max(1, item.endMs - item.beginMs)
			return .interlude(fraction: CGFloat(elapsed) / CGFloat(total))
		}

		let line = resolved.lyrics.attributes.lines[lineIndex]
		let primary = self.lineContent(for: line, offsetMs: resolved.offsetMs, largerText: plan.largerText)

		guard plan.rows == .two else {
			return .lyric(primary: primary, secondary: nil)
		}

		if plan.showsTranslation {
			let secondaryText = self.secondaryText(for: line, following: plan)
			return .lyric(primary: primary, secondary: secondaryText.map { .text($0) })
		}

		let upcoming = self.nextLine(in: resolved, after: index).map { self.primaryText(for: $0, largerText: plan.largerText) }
		return .lyric(primary: primary, secondary: upcoming.map { .nextLine($0) })
	}

	/// The next lyric line after a timeline index, skipping interludes.
	///
	/// - Parameters:
	///    - resolved: The lyrics to search.
	///    - index: The timeline index to search after.
	///
	/// - Returns: The next line.
	private static func nextLine(in resolved: ResolvedLyrics, after index: Int) -> Lyrics.Line? {
		for item in resolved.items.dropFirst(index + 1) {
			if let lineIndex = item.lineIndex {
				return resolved.lyrics.attributes.lines[lineIndex]
			}
		}
		return nil
	}

	/// Resolves a line into drawable karaoke content, honoring the larger text setting.
	///
	/// - Parameters:
	///    - line: The line to resolve.
	///    - offsetMs: The global timing offset in milliseconds.
	///    - largerText: The text shown larger when a line and its pronunciation both appear.
	///
	/// - Returns: The resolved line content.
	private static func lineContent(for line: Lyrics.Line, offsetMs: Int, largerText: LyricsLargerText) -> FloatingLyricsFrame.LineContent {
		let transliteration = line.transliterations.first
		let usesPronunciation = largerText == .pronunciation && self.transliterationDiffers(transliteration, from: line.text)

		let text: String
		let words: [Lyrics.Word]

		if usesPronunciation, let transliteration = transliteration {
			text = transliteration.text
			words = transliteration.words.filter { !$0.background }
		} else {
			text = line.text
			words = line.words.filter { !$0.background }
		}

		return FloatingLyricsFrame.LineContent(
			text: text,
			words: words.map { FloatingLyricsFrame.LineContent.Word(text: $0.text, beginMs: $0.beginMs, endMs: $0.endMs, trailingSpace: $0.trailingSpace) },
			beginMs: line.beginMs ?? 0,
			endMs: line.endMs ?? (line.beginMs ?? 0),
			offsetMs: offsetMs
		)
	}

	/// The text a line shows in the active row, honoring the larger text setting.
	///
	/// - Parameters:
	///    - line: The line to resolve.
	///    - largerText: The text shown larger when a line and its pronunciation both appear.
	///
	/// - Returns: The primary text.
	private static func primaryText(for line: Lyrics.Line, largerText: LyricsLargerText) -> String {
		let transliteration = line.transliterations.first

		if largerText == .pronunciation, self.transliterationDiffers(transliteration, from: line.text), let transliteration = transliteration {
			return transliteration.text
		}

		return line.text
	}

	/// The second-row text for a line, following the in-app lyrics preferences.
	///
	/// - Parameters:
	///    - line: The line to resolve.
	///    - plan: The plan carrying the lyrics preferences.
	///
	/// - Returns: The secondary text.
	private static func secondaryText(for line: Lyrics.Line, following plan: Plan) -> String? {
		if let language = plan.translationLanguage, let translation = line.translations.first(where: { $0.language == language }) {
			return translation.text
		}

		let transliteration = line.transliterations.first
		let hasRomaji = self.transliterationDiffers(transliteration, from: line.text)
		let romajiSecondary: String? = plan.largerText == .pronunciation ? line.text : transliteration?.text

		if plan.showsTransliteration, hasRomaji {
			return romajiSecondary
		}

		if let translation = line.translations.first {
			return translation.text
		}

		return hasRomaji ? romajiSecondary : nil
	}

	/// Whether the transliteration adds romanization beyond the original line.
	///
	/// - Parameters:
	///    - transliteration: The line's transliteration.
	///    - original: The original line text.
	///
	/// - Returns: `true` when the transliteration differs from the original.
	private static func transliterationDiffers(_ transliteration: Lyrics.Transliteration?, from original: String) -> Bool {
		guard let transliteration = transliteration else { return false }
		return transliteration.text.trimmingCharacters(in: .whitespacesAndNewlines) != original.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
