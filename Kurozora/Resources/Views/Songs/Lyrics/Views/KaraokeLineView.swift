//
//  KaraokeLineView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A word with its transliteration and playback timing.
struct KaraokeWordPair {
	/// The original text of the word.
	let original: String

	/// The transliteration of the word.
	let romaji: String?

	/// The start time of the word, in milliseconds.
	let beginMs: Int

	/// The end time of the word, in milliseconds.
	let endMs: Int

	/// A Boolean value that indicates whether a space follows the word.
	let trailingSpace: Bool
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
		let originalOrigin: CGPoint
		let originalSize: CGSize
		let romajiOrigin: CGPoint
		let romajiSize: CGSize
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

	/// The duration of the word-layout transition when pronunciation is toggled.
	private static let layoutTransitionDuration: CFTimeInterval = 0.4

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

	private var originalFont: UIFont {
		return LyricsLayout.originalFont.withSize(LyricsLayout.originalFont.pointSize * self.fontScale)
	}

	private var romajiFont: UIFont {
		return LyricsLayout.romajiFont.withSize(LyricsLayout.romajiFont.pointSize * self.fontScale)
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

		let sungColor = KThemePicker.textColor.colorValue
		let unsungColor = sungColor.withAlphaComponent(LyricsLayout.unsungTextAlpha)

		if let fromLayouts = self.fromLayouts, self.transitionProgress < 1 {
			self.drawTransition(from: fromLayouts, progress: self.transitionProgress, sungColor: sungColor, unsungColor: unsungColor, in: context)
			return
		}

		for layout in self.layouts {
			let fraction = self.fraction(for: layout.pair)
			self.draw(layout.pair.original, at: layout.originalOrigin, width: layout.originalSize.width, font: self.originalFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)

			if let romaji = layout.pair.romaji {
				self.draw(romaji, at: layout.romajiOrigin, width: layout.romajiSize.width, font: self.romajiFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
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

		let originalFont = self.originalFont
		let romajiFont = self.romajiFont
		let originalLineHeight = originalFont.lineHeight
		let hasRomaji = pairs.contains { $0.romaji != nil }
		let romajiLineHeight = hasRomaji ? romajiFont.lineHeight : 0
		let rowHeight = originalLineHeight + (hasRomaji ? LyricsLayout.originalToRomajiSpacing + romajiLineHeight : 0)
		let spaceWidth = (" " as NSString).size(withAttributes: [.font: originalFont]).width

		let pronunciationOnTop = hasRomaji && UserSettings.lyricsLargerText == .pronunciation

		var layouts: [WordLayout] = []
		var penX: CGFloat = 0
		var penY: CGFloat = LyricsLayout.activeWordLift

		for pair in pairs {
			let originalSize = (pair.original as NSString).size(withAttributes: [.font: originalFont])
			let romajiSize = pair.romaji.map { ($0 as NSString).size(withAttributes: [.font: romajiFont]) } ?? .zero
			let tileWidth = max(originalSize.width, romajiSize.width)

			if penX > 0, penX + tileWidth > width {
				penX = 0
				penY += rowHeight + LyricsLayout.rowSpacing
			}

			let originalOrigin: CGPoint
			let romajiOrigin: CGPoint
			if pronunciationOnTop {
				romajiOrigin = CGPoint(x: penX, y: penY)
				originalOrigin = CGPoint(x: penX, y: penY + romajiLineHeight + LyricsLayout.originalToRomajiSpacing)
			} else {
				originalOrigin = CGPoint(x: penX, y: penY)
				romajiOrigin = CGPoint(x: penX, y: penY + originalLineHeight + LyricsLayout.originalToRomajiSpacing)
			}
			layouts.append(WordLayout(pair: pair, originalOrigin: originalOrigin, originalSize: originalSize, romajiOrigin: romajiOrigin, romajiSize: romajiSize))

			penX += tileWidth + (pair.trailingSpace ? spaceWidth : LyricsLayout.pairSpacing)
		}

		return (layouts, layouts.isEmpty ? 0 : penY + rowHeight)
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
		for (rowY, words) in Dictionary(grouping: layouts, by: { $0.originalOrigin.y }) {
			let rowWidth = words.map { $0.originalOrigin.x + max($0.originalSize.width, $0.romajiSize.width) }.max() ?? 0
			offsetsByRow[rowY] = self.horizontalOffset(rowWidth: rowWidth, width: width)
		}

		return layouts.map { layout in
			let offset = offsetsByRow[layout.originalOrigin.y] ?? 0
			guard offset != 0 else { return layout }
			return WordLayout(
				pair: layout.pair,
				originalOrigin: CGPoint(x: layout.originalOrigin.x + offset, y: layout.originalOrigin.y),
				originalSize: layout.originalSize,
				romajiOrigin: CGPoint(x: layout.romajiOrigin.x + offset, y: layout.romajiOrigin.y),
				romajiSize: layout.romajiSize
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
		let hadRomaji = self.pairs.contains { $0.romaji != nil }
		let hasRomaji = pairs.contains { $0.romaji != nil }
		let animatesTransition = !self.pairs.isEmpty && self.bounds.width > 0 && self.pairs.count == pairs.count && hadRomaji != hasRomaji
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

			let originalOrigin = self.interpolate(from.originalOrigin, layout.originalOrigin, progress)
			self.draw(layout.pair.original, at: originalOrigin, width: layout.originalSize.width, font: self.originalFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)

			let romajiOrigin = self.interpolate(from.romajiOrigin, layout.romajiOrigin, progress)
			if let romaji = layout.pair.romaji {
				self.drawRomaji(romaji, at: romajiOrigin, width: layout.romajiSize.width, alpha: progress, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			} else if let romaji = from.pair.romaji {
				self.drawRomaji(romaji, at: romajiOrigin, width: from.romajiSize.width, alpha: 1 - progress, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
			}
		}
	}

	private func drawRomaji(_ text: String, at origin: CGPoint, width: CGFloat, alpha: CGFloat, fraction: CGFloat, sungColor: UIColor, unsungColor: UIColor, in context: CGContext) {
		context.saveGState()
		context.setAlpha(alpha)
		self.draw(text, at: origin, width: width, font: self.romajiFont, fraction: fraction, sungColor: sungColor, unsungColor: unsungColor, in: context)
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
		let raw = max(0, min(1, CGFloat(elapsed / Self.layoutTransitionDuration)))
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
