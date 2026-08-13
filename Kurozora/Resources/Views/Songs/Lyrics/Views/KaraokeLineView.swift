//
//  KaraokeLineView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

struct KaraokeWordPair {
	/// The text drawn larger, on the upper row of the word.
	let primary: String

	/// The text drawn smaller, on the lower row of the word.
	let secondary: String?

	/// The start time of the word, in milliseconds.
	let beginMs: Int

	/// The end time of the word, in milliseconds.
	let endMs: Int

	/// A Boolean value that indicates whether a space follows the word.
	let trailingSpace: Bool

	/// A Boolean value that indicates whether a space follows the word's pronunciation.
	let secondaryTrailingSpace: Bool

	init(primary: String, secondary: String?, beginMs: Int, endMs: Int, trailingSpace: Bool, secondaryTrailingSpace: Bool = false) {
		self.primary = primary
		self.secondary = secondary
		self.beginMs = beginMs
		self.endMs = endMs
		self.trailingSpace = trailingSpace
		self.secondaryTrailingSpace = secondaryTrailingSpace
	}
}

final class KaraokeLineView: UIView {
	// MARK: - Enums
	private enum FillMode {
		case empty
		case full
		case progress(Int)
	}

	// MARK: - Structs
	struct WordLayout {
		let pair: KaraokeWordPair

		/// The portion of the pair drawn by this layout.
		///
		/// A pair too long for one row is split across several layouts, so the text is carried
		/// here rather than read back off the pair.
		let primaryText: String

		/// The portion of the pair's pronunciation drawn by this layout.
		let secondaryText: String?

		let primaryOrigin: CGPoint
		let primarySize: CGSize
		let secondaryOrigin: CGPoint
		let secondarySize: CGSize

		init(pair: KaraokeWordPair, primaryText: String, secondaryText: String?, primaryOrigin: CGPoint, primarySize: CGSize, secondaryOrigin: CGPoint, secondarySize: CGSize) {
			self.pair = pair
			self.primaryText = primaryText
			self.secondaryText = secondaryText
			self.primaryOrigin = primaryOrigin
			self.primarySize = primarySize
			self.secondaryOrigin = secondaryOrigin
			self.secondarySize = secondarySize
		}

		init(pair: KaraokeWordPair, primaryOrigin: CGPoint, primarySize: CGSize, secondaryOrigin: CGPoint, secondarySize: CGSize) {
			self.init(pair: pair, primaryText: pair.primary, secondaryText: pair.secondary, primaryOrigin: primaryOrigin, primarySize: primarySize, secondaryOrigin: secondaryOrigin, secondarySize: secondarySize)
		}
	}

	// MARK: - Properties
	private var pairs: [KaraokeWordPair] = []
	private var offsetMs = 0
	private var layouts: [WordLayout] = []
	private var intrinsicHeight: CGFloat = 0
	private var fillMode: FillMode = .empty

	private var fromLayouts: [WordLayout]?
	private var transitionProgress: CGFloat = 1
	private var transitionDisplayLink: CADisplayLink?
	private var transitionStartTimestamp: CFTimeInterval = 0

	/// The duration of the word-layout transition when the secondary text is toggled.
	private let layoutTransitionDuration: CFTimeInterval = 0.4

	/// The width the line lays out against.
	var preferredMaxLayoutWidth: CGFloat = 0 {
		didSet {
			guard oldValue != self.preferredMaxLayoutWidth else { return }
			self.recomputeIntrinsicHeight()
		}
	}

	/// The horizontal alignment of each wrapped row.
	var textAlignment: NSTextAlignment = .natural {
		didSet {
			guard oldValue != self.textAlignment else { return }
			self.setNeedsLayout()
		}
	}

	/// The scale applied to the line's fonts, used to render secondary lines smaller.
	var fontScale: CGFloat = 1 {
		didSet {
			guard oldValue != self.fontScale else { return }
			self.recomputeIntrinsicHeight()
			self.setNeedsLayout()
		}
	}

	/// Whether the line draws in the label color instead of the theme's text color.
	var prefersSystemColors = false {
		didSet {
			guard oldValue != self.prefersSystemColors else { return }
			self.setNeedsDisplay()
		}
	}

	/// An additional scale applied to the pronunciation row on top of ``fontScale``.
	var secondaryFontScale: CGFloat = 1 {
		didSet {
			guard oldValue != self.secondaryFontScale else { return }
			self.recomputeIntrinsicHeight()
			self.setNeedsLayout()
		}
	}

	private var primaryFont: UIFont {
		return LyricsLayout.primaryFont.withSize(LyricsLayout.primaryFont.pointSize * self.fontScale)
	}

	private var secondaryFont: UIFont {
		return LyricsLayout.secondaryFont.withSize(LyricsLayout.secondaryFont.pointSize * self.fontScale * self.secondaryFontScale)
	}

	/// A Boolean value that indicates whether words lift as they fill.
	private var liftsWords: Bool {
		switch self.fillMode {
		case .progress:
			return true
		default:
			return false
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.isOpaque = false
		self.contentMode = .redraw
		self.backgroundColor = .clear
		self.clipsToBounds = true
		NotificationCenter.default.addObserver(self, selector: #selector(self.themeChanged), name: .ThemeUpdateNotification, object: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.noIntrinsicMetric, height: self.intrinsicHeight)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.preferredMaxLayoutWidth = self.bounds.width

		let computed = self.computeLayouts(pairs: self.pairs, width: self.bounds.width).layouts
		self.layouts = self.aligned(computed, width: self.bounds.width)
		self.setNeedsDisplay()
	}

	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }

		let sungColor = self.prefersSystemColors ? UIColor.label : KThemePicker.textColor.colorValue
		let unsungColor = sungColor.withAlphaComponent(LyricsLayout.unsungTextAlpha)

		if let fromLayouts = self.fromLayouts, self.transitionProgress < 1 {
			self.drawTransition(from: fromLayouts, progress: self.transitionProgress, sungColor: sungColor, unsungColor: unsungColor, in: context)
			return
		}

		for layout in self.layouts {
			let fraction = self.fraction(for: layout.pair)

			if !layout.primaryText.isEmpty {
				self.draw(layout.primaryText, at: layout.primaryOrigin, width: layout.primarySize.width, font: self.primaryFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			}

			if let secondary = layout.secondaryText, !secondary.isEmpty {
				self.draw(secondary, at: layout.secondaryOrigin, width: layout.secondarySize.width, font: self.secondaryFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			}
		}
	}

	// MARK: - Functions
	/// Lays out the word pairs for a given width.
	///
	/// - Parameters:
	///    - pairs: The word pairs to lay out.
	///    - width: The available width.
	///
	/// - Returns: The per-word layout and the total content height.
	func computeLayouts(pairs: [KaraokeWordPair], width: CGFloat) -> (layouts: [WordLayout], height: CGFloat) {
		guard width > 0 else { return ([], 0) }

		let primaryFont = self.primaryFont
		let secondaryFont = self.secondaryFont
		let primaryLineHeight = primaryFont.lineHeight
		let hasSecondary = pairs.contains { $0.secondary != nil }
		let rowHeight = primaryLineHeight + (hasSecondary ? LyricsLayout.primaryToSecondarySpacing + secondaryFont.lineHeight : 0)
		let spaceWidth = (" " as NSString).size(withAttributes: [.font: primaryFont]).width

		let secondarySpaceWidth = (" " as NSString).size(withAttributes: [.font: secondaryFont]).width

		// A space on either row ends a word, and the next word starts past the wider row, so a
		// word stays column-aligned with its pronunciation.
		var layouts: [WordLayout] = []
		var penX: CGFloat = 0
		var penY: CGFloat = LyricsLayout.activeWordLift

		var wordStart = 0
		while wordStart < pairs.count {
			var wordEnd = wordStart
			while wordEnd < pairs.count - 1, !pairs[wordEnd].trailingSpace, !pairs[wordEnd].secondaryTrailingSpace {
				wordEnd += 1
			}
			let word = Array(pairs[wordStart...wordEnd])

			let primarySizes = word.map { ($0.primary as NSString).size(withAttributes: [.font: primaryFont]) }
			let secondarySizes = word.map { pair in pair.secondary.map { ($0 as NSString).size(withAttributes: [.font: secondaryFont]) } ?? .zero }
			let primaryRunWidth = primarySizes.reduce(0) { $0 + $1.width }
			let secondaryRunWidth = secondarySizes.reduce(0) { $0 + $1.width }
			let wordWidth = max(primaryRunWidth, secondaryRunWidth)

			let lastPair = word[word.count - 1]

			if word.count == 1, primaryRunWidth > width || secondaryRunWidth > width {
				// A line timed as a whole arrives as a single pair, so there is no pair boundary
				// to break at and the text itself has to wrap.
				let pair = word[0]

				if penX > 0 {
					penX = 0
					penY += rowHeight + LyricsLayout.rowSpacing
				}

				var rowY = penY
				for segment in self.wrappedSegments(pair.primary, font: primaryFont, width: width) {
					layouts.append(WordLayout(pair: pair, primaryText: segment.text, secondaryText: nil, primaryOrigin: CGPoint(x: 0, y: rowY), primarySize: CGSize(width: segment.width, height: primaryLineHeight), secondaryOrigin: .zero, secondarySize: .zero))
					rowY += primaryLineHeight + LyricsLayout.rowSpacing
				}

				if let secondary = pair.secondary, !secondary.isEmpty {
					rowY += LyricsLayout.primaryToSecondarySpacing - LyricsLayout.rowSpacing
					for segment in self.wrappedSegments(secondary, font: secondaryFont, width: width) {
						layouts.append(WordLayout(pair: pair, primaryText: "", secondaryText: segment.text, primaryOrigin: CGPoint(x: 0, y: rowY), primarySize: .zero, secondaryOrigin: CGPoint(x: 0, y: rowY), secondarySize: CGSize(width: segment.width, height: secondaryFont.lineHeight)))
						rowY += secondaryFont.lineHeight + LyricsLayout.rowSpacing
					}
				}

				penX = 0
				penY = rowY
				wordStart = wordEnd + 1
				continue
			}

			if wordWidth > width {
				// Scripts without spaces make the whole line one word, so a run too long for any
				// row breaks between its pairs instead of running past the edge.
				for (index, pair) in word.enumerated() {
					let pairWidth = max(primarySizes[index].width, secondarySizes[index].width)

					if penX > 0, penX + pairWidth > width {
						penX = 0
						penY += rowHeight + LyricsLayout.rowSpacing
					}

					let primaryOrigin = CGPoint(x: penX, y: penY)
					let secondaryOrigin = CGPoint(x: penX, y: penY + primaryLineHeight + LyricsLayout.primaryToSecondarySpacing)
					layouts.append(WordLayout(pair: pair, primaryOrigin: primaryOrigin, primarySize: primarySizes[index], secondaryOrigin: secondaryOrigin, secondarySize: secondarySizes[index]))

					penX += pairWidth
				}

				penX += max(lastPair.trailingSpace ? spaceWidth : 0, lastPair.secondaryTrailingSpace ? secondarySpaceWidth : 0)
				wordStart = wordEnd + 1
				continue
			}

			if penX > 0, penX + wordWidth > width {
				penX = 0
				penY += rowHeight + LyricsLayout.rowSpacing
			}

			var primaryPenX = penX
			var secondaryPenX = penX
			for (index, pair) in word.enumerated() {
				let primaryOrigin = CGPoint(x: primaryPenX, y: penY)
				let secondaryOrigin = CGPoint(x: secondaryPenX, y: penY + primaryLineHeight + LyricsLayout.primaryToSecondarySpacing)
				layouts.append(WordLayout(pair: pair, primaryOrigin: primaryOrigin, primarySize: primarySizes[index], secondaryOrigin: secondaryOrigin, secondarySize: secondarySizes[index]))

				primaryPenX += primarySizes[index].width
				secondaryPenX += secondarySizes[index].width
			}

			// Each row appends its own trailing space, and the next word starts past the farther pen.
			let primaryEndX = penX + primaryRunWidth + (lastPair.trailingSpace ? spaceWidth : 0)
			let secondaryEndX = penX + secondaryRunWidth + (lastPair.secondaryTrailingSpace ? secondarySpaceWidth : 0)
			penX = max(primaryEndX, secondaryEndX)
			wordStart = wordEnd + 1
		}

		let bottom = layouts.map { layout -> CGFloat in
			let primaryBottom = layout.primarySize.width > 0 ? layout.primaryOrigin.y + primaryLineHeight : 0
			let secondaryBottom = layout.secondarySize.width > 0 ? layout.secondaryOrigin.y + secondaryFont.lineHeight : 0
			return max(primaryBottom, secondaryBottom)
		}.max() ?? 0

		return (layouts, bottom)
	}

	/// Splits text into the rows it occupies at the given width.
	///
	/// Breaks fall after spaces and after characters in scripts that are written without them,
	/// so a Japanese line wraps between characters while a Latin word stays whole.
	///
	/// - Parameters:
	///    - text: The text to wrap.
	///    - font: The font the text is drawn in.
	///    - width: The available width.
	///
	/// - Returns: Each row's text and the width it occupies.
	private func wrappedSegments(_ text: String, font: UIFont, width: CGFloat) -> [(text: String, width: CGFloat)] {
		guard width > 0, !text.isEmpty else { return [] }

		let attributes: [NSAttributedString.Key: Any] = [.font: font]

		var tokens: [String] = []
		var token = ""
		for character in text {
			token.append(character)

			if Self.allowsBreakAfter(character) {
				tokens.append(token)
				token = ""
			}
		}
		if !token.isEmpty {
			tokens.append(token)
		}

		var segments: [(text: String, width: CGFloat)] = []
		var row = ""
		var rowWidth: CGFloat = 0

		for token in tokens {
			let tokenWidth = (token as NSString).size(withAttributes: attributes).width

			if rowWidth + tokenWidth > width, !row.isEmpty {
				segments.append((row, rowWidth))
				row = ""
				rowWidth = 0
			}

			row += token
			rowWidth += tokenWidth
		}
		if !row.isEmpty {
			segments.append((row, rowWidth))
		}

		return segments
	}

	/// Whether a row may break immediately after the given character.
	///
	/// - Parameter character: The character preceding the candidate break.
	///
	/// - Returns: Whether the break is allowed.
	private static func allowsBreakAfter(_ character: Character) -> Bool {
		if character == " " {
			return true
		}

		guard let scalar = character.unicodeScalars.first else { return false }

		switch scalar.value {
		case 0x3040...0x30FF, 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF, 0xFF66...0xFF9F:
			return true
		default:
			return false
		}
	}

	/// Shifts each wrapped row to honor the current alignment.
	///
	/// - Parameters:
	///    - layouts: The leading-aligned word layouts.
	///    - width: The available width.
	///
	/// - Returns: The alignment-adjusted layouts.
	private func aligned(_ layouts: [WordLayout], width: CGFloat) -> [WordLayout] {
		guard width > 0, !layouts.isEmpty else { return layouts }

		var offsetsByRow: [CGFloat: CGFloat] = [:]
		for (rowY, words) in Dictionary(grouping: layouts, by: { $0.primaryOrigin.y }) {
			let rowWidth = words.map { max($0.primaryOrigin.x + $0.primarySize.width, $0.secondaryOrigin.x + $0.secondarySize.width) }.max() ?? 0
			offsetsByRow[rowY] = self.horizontalOffset(rowWidth: rowWidth, width: width)
		}

		return layouts.map { layout in
			let offset = offsetsByRow[layout.primaryOrigin.y] ?? 0
			guard offset != 0 else { return layout }
			return WordLayout(
				pair: layout.pair,
				primaryOrigin: CGPoint(x: layout.primaryOrigin.x + offset, y: layout.primaryOrigin.y),
				primarySize: layout.primarySize,
				secondaryOrigin: CGPoint(x: layout.secondaryOrigin.x + offset, y: layout.secondaryOrigin.y),
				secondarySize: layout.secondarySize
			)
		}
	}

	private func horizontalOffset(rowWidth: CGFloat, width: CGFloat) -> CGFloat {
		let resolved: NSTextAlignment
		switch self.textAlignment {
		case .natural, .justified:
			resolved = self.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
		default:
			resolved = self.textAlignment
		}

		switch resolved {
		case .center:
			return max(0, (width - rowWidth) / 2)
		case .right:
			return max(0, width - rowWidth)
		default:
			return 0
		}
	}

	private func recomputeIntrinsicHeight() {
		let width = self.preferredMaxLayoutWidth > 0 ? self.preferredMaxLayoutWidth : self.bounds.width
		let height = self.computeLayouts(pairs: self.pairs, width: width).height

		guard height != self.intrinsicHeight else { return }
		self.intrinsicHeight = height
		self.invalidateIntrinsicContentSize()
	}

	/// Configures the line with its words.
	///
	/// - Parameters:
	///    - pairs: The timed word pairs of the line.
	///    - offsetMs: The global timing offset applied to every word.
	func configure(pairs: [KaraokeWordPair], offsetMs: Int) {
		let hadSecondary = self.pairs.contains { $0.secondary != nil }
		let hasSecondary = pairs.contains { $0.secondary != nil }
		let animatesTransition = !self.pairs.isEmpty && self.bounds.width > 0 && self.pairs.count == pairs.count && hadSecondary != hasSecondary
		let previousLayouts = self.layouts

		self.pairs = pairs
		self.offsetMs = offsetMs
		self.recomputeIntrinsicHeight()
		self.setNeedsLayout()

		if animatesTransition {
			self.beginLayoutTransition(from: previousLayouts)
		} else {
			self.fillMode = .empty
			self.stopLayoutTransition()
			self.setNeedsDisplay()
		}
	}

	/// Advances the fill to the given playback position.
	///
	/// - Parameter ms: The playback position in milliseconds.
	func setProgress(ms: Int) {
		self.fillMode = .progress(ms)
		self.setNeedsDisplay()
	}

	/// Reveals the whole line.
	func setFullyRevealed() {
		self.fillMode = .full
		self.setNeedsDisplay()
	}

	/// Hides the sung portion.
	func setUnrevealed() {
		self.fillMode = .empty
		self.setNeedsDisplay()
	}

	private func fraction(for pair: KaraokeWordPair) -> CGFloat {
		switch self.fillMode {
		case .empty:
			return 0
		case .full:
			return 1
		case .progress(let ms):
			let begin = pair.beginMs + self.offsetMs
			let end = pair.endMs + self.offsetMs
			if ms >= end { return 1 }
			if ms <= begin { return 0 }
			return CGFloat(ms - begin) / CGFloat(max(1, end - begin))
		}
	}

	private func draw(_ text: String, at origin: CGPoint, width: CGFloat, font: UIFont, fraction: CGFloat, sungColor: UIColor, unsungColor: UIColor, in context: CGContext) {
		let clampedFraction = min(max(fraction, 0), 1)
		let lift = self.liftsWords ? LyricsLayout.activeWordLift * sin(clampedFraction * .pi / 2) : 0
		let drawOrigin = CGPoint(x: origin.x, y: origin.y - lift)
		let height = font.lineHeight

		(text as NSString).draw(at: drawOrigin, withAttributes: [.font: font, .foregroundColor: unsungColor])

		guard clampedFraction > 0 else { return }

		if clampedFraction >= 1 {
			(text as NSString).draw(at: drawOrigin, withAttributes: [.font: font, .foregroundColor: sungColor])
			return
		}

		let fillX = drawOrigin.x + width * clampedFraction
		let feather = max(1, min(height * LyricsLayout.fillFeatherRatio, width * clampedFraction))

		context.saveGState()
		context.clip(to: CGRect(x: drawOrigin.x, y: drawOrigin.y, width: width, height: height))
		context.beginTransparencyLayer(auxiliaryInfo: nil)
		(text as NSString).draw(at: drawOrigin, withAttributes: [.font: font, .foregroundColor: sungColor])

		// Soften the fill's trailing edge.
		context.setBlendMode(.destinationIn)
		let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray
		if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
			context.drawLinearGradient(gradient, start: CGPoint(x: fillX - feather, y: 0), end: CGPoint(x: fillX, y: 0), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
		}

		context.endTransparencyLayer()
		context.restoreGState()
	}

	/// Draws the words interpolated between their previous and current layouts.
	///
	/// - Parameters:
	///    - fromLayouts: The layouts to animate from, matched to the current layouts by index.
	///    - progress: The transition progress, from `0` to `1`.
	///    - sungColor: The color of sung text.
	///    - unsungColor: The color of unsung text.
	///    - context: The drawing context.
	private func drawTransition(from fromLayouts: [WordLayout], progress: CGFloat, sungColor: UIColor, unsungColor: UIColor, in context: CGContext) {
		for (index, layout) in self.layouts.enumerated() {
			guard index < fromLayouts.count else { break }
			let from = fromLayouts[index]
			let fraction = self.fraction(for: layout.pair)

			let primaryOrigin = self.interpolate(from.primaryOrigin, layout.primaryOrigin, progress)
			self.draw(layout.primaryText, at: primaryOrigin, width: layout.primarySize.width, font: self.primaryFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)

			let secondaryOrigin = self.interpolate(from.secondaryOrigin, layout.secondaryOrigin, progress)
			if let secondary = layout.secondaryText {
				self.drawSecondary(secondary, at: secondaryOrigin, width: layout.secondarySize.width, alpha: progress, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			} else if let secondary = from.secondaryText {
				self.drawSecondary(secondary, at: secondaryOrigin, width: from.secondarySize.width, alpha: 1 - progress, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			}
		}
	}

	private func drawSecondary(_ text: String, at origin: CGPoint, width: CGFloat, alpha: CGFloat, fraction: CGFloat, sungColor: UIColor, unsungColor: UIColor, in context: CGContext) {
		context.saveGState()
		context.setAlpha(alpha)
		self.draw(text, at: origin, width: width, font: self.secondaryFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
		context.restoreGState()
	}

	private func interpolate(_ start: CGPoint, _ end: CGPoint, _ progress: CGFloat) -> CGPoint {
		return CGPoint(x: start.x + (end.x - start.x) * progress, y: start.y + (end.y - start.y) * progress)
	}

	private func beginLayoutTransition(from previousLayouts: [WordLayout]) {
		self.fromLayouts = previousLayouts
		self.transitionProgress = 0
		self.transitionStartTimestamp = 0
		self.transitionDisplayLink?.invalidate()

		let displayLink = CADisplayLink(target: self, selector: #selector(self.stepLayoutTransition(_:)))
		displayLink.add(to: .main, forMode: .common)
		self.transitionDisplayLink = displayLink
	}

	@objc private func stepLayoutTransition(_ displayLink: CADisplayLink) {
		if self.transitionStartTimestamp == 0 {
			self.transitionStartTimestamp = displayLink.timestamp
		}

		let elapsed = displayLink.timestamp - self.transitionStartTimestamp
		let raw = max(0, min(1, CGFloat(elapsed / self.layoutTransitionDuration)))
		self.transitionProgress = raw * raw * (3 - 2 * raw)
		self.setNeedsDisplay()

		if raw >= 1 {
			self.stopLayoutTransition()
		}
	}

	private func stopLayoutTransition() {
		self.transitionDisplayLink?.invalidate()
		self.transitionDisplayLink = nil
		self.fromLayouts = nil
		self.transitionProgress = 1
	}

	@objc private func themeChanged() {
		self.setNeedsDisplay()
	}
}
