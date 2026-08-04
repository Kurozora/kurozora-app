//
//  FloatingLyricsRenderer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Draws floating lyrics frames into a Core Graphics context.
///
/// The context must use UIKit's flipped coordinate space.
struct FloatingLyricsRenderer {
	// MARK: - Properties
	/// The width of the rendering canvas in pixels.
	static let canvasWidth: CGFloat = 1080

	/// The height of the one-row rendering canvas in pixels.
	static let oneRowCanvasHeight: CGFloat = 128

	/// The height of the two-row rendering canvas in pixels.
	static let twoRowCanvasHeight: CGFloat = 200

	/// The primary font of the standard font size.
	static let standardPrimaryFont = UIFont.systemFont(ofSize: 56, weight: .bold)

	/// The secondary font of the standard font size.
	static let standardSecondaryFont = UIFont.systemFont(ofSize: 34, weight: .semibold)

	/// The primary font of the big font size.
	static let bigPrimaryFont = UIFont.systemFont(ofSize: 72, weight: .bold)

	/// The secondary font of the big font size.
	static let bigSecondaryFont = UIFont.systemFont(ofSize: 44, weight: .semibold)

	/// The background color used when no artwork color is available.
	static let fallbackBackgroundColor = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)

	/// The color of sung text.
	private static let sungColor = UIColor.white

	/// The opacity of translation and pronunciation text.
	private static let translationAlpha: CGFloat = 0.7

	/// The horizontal inset of the drawable area.
	private static let horizontalInset: CGFloat = 60

	/// The vertical spacing between the two rows.
	private static let rowSpacing: CGFloat = 16

	/// The horizontal spacing between words that carry no trailing space.
	private static let pairSpacing: CGFloat = 8

	/// The radius of an interlude dot.
	private static let interludeDotRadius: CGFloat = 16

	/// The spacing between interlude dots.
	private static let interludeDotSpacing: CGFloat = 28

	/// The vertical distance content slides during a block transition, as a fraction of the canvas height.
	private static let blockSlideFraction: CGFloat = 0.4

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// The canvas size for the given number of rows.
	///
	/// - Parameter rows: The number of lyric rows in the window.
	///
	/// - Returns: The canvas size in pixels.
	static func canvasSize(for rows: LyricsFloatingWindowRows) -> CGSize {
		switch rows {
		case .one:
			return CGSize(width: self.canvasWidth, height: self.oneRowCanvasHeight)
		case .two:
			return CGSize(width: self.canvasWidth, height: self.twoRowCanvasHeight)
		}
	}

	/// The primary font for the given font size.
	///
	/// - Parameter fontSize: The font size of the window.
	///
	/// - Returns: The primary font.
	static func primaryFont(for fontSize: LyricsFloatingWindowFontSize) -> UIFont {
		switch fontSize {
		case .standard:
			return self.standardPrimaryFont
		case .big:
			return self.bigPrimaryFont
		}
	}

	/// The secondary font for the given font size.
	///
	/// - Parameter fontSize: The font size of the window.
	///
	/// - Returns: The secondary font.
	static func secondaryFont(for fontSize: LyricsFloatingWindowFontSize) -> UIFont {
		switch fontSize {
		case .standard:
			return self.standardSecondaryFont
		case .big:
			return self.bigSecondaryFont
		}
	}

	/// Draws the given frame into the context.
	///
	/// - Parameters:
	///    - frame: The frame to draw.
	///    - context: The context to draw into, in UIKit's flipped coordinate space.
	///    - size: The size of the canvas in pixels.
	static func draw(_ frame: FloatingLyricsFrame, in context: CGContext, size: CGSize) {
		UIGraphicsPushContext(context)
		defer {
			UIGraphicsPopContext()
		}

		self.drawBackground(frame.backgroundColors, in: context, size: size)

		if let transition = frame.transition, transition.progress < 1 {
			self.drawTransition(transition, of: frame, in: context, size: size)
		} else {
			self.drawContent(frame.content, of: frame, yOffset: 0, alpha: 1, in: context, size: size)
		}
	}

	/// The unit-space anchors the color pools sit on, spread across the canvas.
	private static let backgroundPoolAnchors: [CGPoint] = [
		CGPoint(x: 0.12, y: 0.1),
		CGPoint(x: 0.88, y: 0.2),
		CGPoint(x: 0.7, y: 0.95),
		CGPoint(x: 0.28, y: 0.9),
	]

	/// Fills the canvas with the artwork wash: a base color under soft overlapping color pools.
	///
	/// - Parameters:
	///    - colors: The palette; the first color is the base, the rest become pools.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawBackground(_ colors: [UIColor], in context: CGContext, size: CGSize) {
		let baseColor = colors.first ?? self.fallbackBackgroundColor
		context.setFillColor(baseColor.cgColor)
		context.fill(CGRect(origin: .zero, size: size))

		let poolRadius = size.width * 0.55

		for (index, color) in colors.dropFirst().enumerated() {
			let anchor = self.backgroundPoolAnchors[index % self.backgroundPoolAnchors.count]
			let center = CGPoint(x: anchor.x * size.width, y: anchor.y * size.height)

			let poolColors = [color.withAlphaComponent(0.85).cgColor, color.withAlphaComponent(0).cgColor] as CFArray
			guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: poolColors, locations: [0, 1]) else { continue }

			context.saveGState()
			context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: poolRadius, options: [])
			context.restoreGState()
		}
	}

	// MARK: Content
	/// Draws a frame's content vertically shifted and faded.
	///
	/// - Parameters:
	///    - content: The content to draw.
	///    - frame: The frame the content belongs to.
	///    - yOffset: The vertical shift applied to the content.
	///    - alpha: The opacity applied to the content.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawContent(_ content: FloatingLyricsFrame.Content, of frame: FloatingLyricsFrame, yOffset: CGFloat, alpha: CGFloat, in context: CGContext, size: CGSize) {
		guard alpha > 0 else { return }

		context.saveGState()
		context.setAlpha(alpha)
		context.beginTransparencyLayer(auxiliaryInfo: nil)
		defer {
			context.endTransparencyLayer()
			context.restoreGState()
		}

		let primaryFont = self.primaryFont(for: frame.fontSize)
		let secondaryFont = self.secondaryFont(for: frame.fontSize)

		switch content {
		case .lyric(let primary, let secondary):
			let layout = self.rowLayout(primaryFont: primaryFont, secondaryFont: secondaryFont, hasSecondary: secondary != nil, size: size)
			self.drawKaraokeRow(primary, positionMs: frame.positionMs, font: primaryFont, rowTop: layout.primaryTop + yOffset, in: context, size: size)

			switch secondary {
			case .text(let text):
				let lineFraction = self.fraction(positionMs: frame.positionMs, beginMs: primary.beginMs, endMs: primary.endMs, offsetMs: primary.offsetMs)
				self.drawPanningRow(text, font: secondaryFont, rowTop: layout.secondaryTop + yOffset, alpha: self.translationAlpha, panFraction: lineFraction, in: context, size: size)
			case .nextLine(let text):
				self.drawStaticRow(text, font: secondaryFont, rowTop: layout.secondaryTop + yOffset, alpha: LyricsLayout.unsungTextAlpha, in: context, size: size)
			case nil:
				break
			}
		case .interlude(let fraction):
			self.drawInterlude(fraction: fraction, yOffset: yOffset, in: context, size: size)
		case .title(let song, let artist):
			let showsArtist = frame.rows == .two
			let layout = self.rowLayout(primaryFont: primaryFont, secondaryFont: secondaryFont, hasSecondary: showsArtist, size: size)
			self.drawStaticRow(song, font: primaryFont, rowTop: layout.primaryTop + yOffset, alpha: 1, in: context, size: size)

			if showsArtist {
				self.drawStaticRow(artist, font: secondaryFont, rowTop: layout.secondaryTop + yOffset, alpha: self.translationAlpha, in: context, size: size)
			}
		case .empty:
			break
		}
	}

	/// The vertical positions of the primary and secondary rows, centered as one block.
	///
	/// - Parameters:
	///    - primaryFont: The font of the primary row.
	///    - secondaryFont: The font of the secondary row.
	///    - hasSecondary: Whether a secondary row is drawn.
	///    - size: The size of the canvas in pixels.
	///
	/// - Returns: The top of each row.
	private static func rowLayout(primaryFont: UIFont, secondaryFont: UIFont, hasSecondary: Bool, size: CGSize) -> (primaryTop: CGFloat, secondaryTop: CGFloat) {
		let blockHeight = primaryFont.lineHeight + (hasSecondary ? self.rowSpacing + secondaryFont.lineHeight : 0)
		let primaryTop = max(0, (size.height - blockHeight) / 2)
		let secondaryTop = primaryTop + primaryFont.lineHeight + self.rowSpacing
		return (primaryTop, secondaryTop)
	}

	// MARK: Transitions
	/// Draws an in-flight transition between the previous and current content.
	///
	/// - Parameters:
	///    - transition: The transition to draw.
	///    - frame: The frame the transition belongs to.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawTransition(_ transition: FloatingLyricsFrame.Transition, of frame: FloatingLyricsFrame, in context: CGContext, size: CGSize) {
		let progress = min(max(transition.progress, 0), 1)

		if transition.crossfades {
			self.drawContent(transition.from, of: frame, yOffset: 0, alpha: 1 - progress, in: context, size: size)
			self.drawContent(frame.content, of: frame, yOffset: 0, alpha: progress, in: context, size: size)
			return
		}

		if case .lyric(let toPrimary, .nextLine(let upcoming)) = frame.content, case .lyric(let fromPrimary, _) = transition.from {
			self.drawTickerTransition(fromPrimary: fromPrimary, toPrimary: toPrimary, upcoming: upcoming, of: frame, progress: progress, in: context, size: size)
			return
		}

		let slideDistance = size.height * self.blockSlideFraction
		self.drawContent(transition.from, of: frame, yOffset: -slideDistance * progress, alpha: 1 - progress, in: context, size: size)
		self.drawContent(frame.content, of: frame, yOffset: slideDistance * (1 - progress), alpha: progress, in: context, size: size)
	}

	/// Draws the two-row ticker where the upcoming line climbs into the active row.
	///
	/// - Parameters:
	///    - fromPrimary: The line scrolling out of the active row.
	///    - toPrimary: The line climbing from the second row into the active row.
	///    - upcoming: The line appearing in the second row.
	///    - frame: The frame the transition belongs to.
	///    - progress: The progress of the transition, from `0` to `1`.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawTickerTransition(fromPrimary: FloatingLyricsFrame.LineContent, toPrimary: FloatingLyricsFrame.LineContent, upcoming: String, of frame: FloatingLyricsFrame, progress: CGFloat, in context: CGContext, size: CGSize) {
		let primaryFont = self.primaryFont(for: frame.fontSize)
		let secondaryFont = self.secondaryFont(for: frame.fontSize)
		let layout = self.rowLayout(primaryFont: primaryFont, secondaryFont: secondaryFont, hasSecondary: true, size: size)

		let outgoingTop = layout.primaryTop - primaryFont.lineHeight * progress
		self.drawKaraokeRow(fromPrimary, positionMs: frame.positionMs, font: primaryFont, rowTop: outgoingTop, alpha: 1 - progress, in: context, size: size)

		let climbingFont = primaryFont.withSize(secondaryFont.pointSize + (primaryFont.pointSize - secondaryFont.pointSize) * progress)
		let climbingTop = layout.secondaryTop + (layout.primaryTop - layout.secondaryTop) * progress
		self.drawKaraokeRow(toPrimary, positionMs: frame.positionMs, font: climbingFont, rowTop: climbingTop, alpha: 1, in: context, size: size)

		self.drawStaticRow(upcoming, font: secondaryFont, rowTop: layout.secondaryTop + secondaryFont.lineHeight * (1 - progress) * 0.5, alpha: LyricsLayout.unsungTextAlpha * progress, in: context, size: size)
	}

	// MARK: Rows
	/// Draws a lyric line with the karaoke word-progressive fill.
	///
	/// - Parameters:
	///    - line: The line to draw.
	///    - positionMs: The playback position in milliseconds.
	///    - font: The font of the row.
	///    - rowTop: The top of the row.
	///    - alpha: The opacity applied to the row.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawKaraokeRow(_ line: FloatingLyricsFrame.LineContent, positionMs: Int, font: UIFont, rowTop: CGFloat, alpha: CGFloat = 1, in context: CGContext, size: CGSize) {
		guard alpha > 0 else { return }

		let words = self.drawableWords(of: line)
		let spaceWidth = (" " as NSString).size(withAttributes: [.font: font]).width

		var layouts: [(word: FloatingLyricsFrame.LineContent.Word, originX: CGFloat, width: CGFloat, fraction: CGFloat)] = []
		var penX: CGFloat = 0

		for word in words {
			let width = (word.text as NSString).size(withAttributes: [.font: font]).width
			let fraction = self.fraction(positionMs: positionMs, beginMs: word.beginMs, endMs: word.endMs, offsetMs: line.offsetMs)
			layouts.append((word, penX, width, fraction))
			penX += width + (word.trailingSpace ? spaceWidth : self.pairSpacing)
		}

		guard let lastLayout = layouts.last else { return }

		let totalWidth = lastLayout.originX + lastLayout.width
		let usableWidth = size.width - self.horizontalInset * 2
		let originX: CGFloat

		if totalWidth <= usableWidth {
			originX = self.horizontalInset + (usableWidth - totalWidth) / 2
		} else {
			var fillX: CGFloat = 0
			for layout in layouts where layout.fraction > 0 {
				fillX = layout.originX + layout.width * layout.fraction
			}

			let pan = min(max(fillX - usableWidth / 2, 0), totalWidth - usableWidth)
			originX = self.horizontalInset - pan
		}

		context.saveGState()
		context.setAlpha(alpha)
		context.beginTransparencyLayer(auxiliaryInfo: nil)

		let unsungColor = self.sungColor.withAlphaComponent(LyricsLayout.unsungTextAlpha)
		for layout in layouts {
			self.drawFilledWord(layout.word.text, at: CGPoint(x: originX + layout.originX, y: rowTop), width: layout.width, font: font, fraction: layout.fraction, unsungColor: unsungColor, in: context)
		}

		context.endTransparencyLayer()
		context.restoreGState()
	}

	/// The words drawn for a line, falling back to a single whole-line word when only line timing exists.
	///
	/// - Parameter line: The line to resolve.
	///
	/// - Returns: The words to draw.
	private static func drawableWords(of line: FloatingLyricsFrame.LineContent) -> [FloatingLyricsFrame.LineContent.Word] {
		guard line.words.isEmpty else { return line.words }
		return [FloatingLyricsFrame.LineContent.Word(text: line.text, beginMs: line.beginMs, endMs: line.endMs, trailingSpace: false)]
	}

	/// Draws a single word with its sung portion filled and a feathered fill edge.
	///
	/// - Parameters:
	///    - text: The text of the word.
	///    - origin: The top-leading corner of the word.
	///    - width: The width of the word.
	///    - font: The font of the word.
	///    - fraction: The sung fraction of the word, from `0` to `1`.
	///    - unsungColor: The color of unsung text.
	///    - context: The context to draw into.
	private static func drawFilledWord(_ text: String, at origin: CGPoint, width: CGFloat, font: UIFont, fraction: CGFloat, unsungColor: UIColor, in context: CGContext) {
		let clampedFraction = min(max(fraction, 0), 1)
		let height = font.lineHeight

		(text as NSString).draw(at: origin, withAttributes: [.font: font, .foregroundColor: unsungColor])

		guard clampedFraction > 0 else { return }

		if clampedFraction >= 1 {
			(text as NSString).draw(at: origin, withAttributes: [.font: font, .foregroundColor: self.sungColor])
			return
		}

		let fillX = origin.x + width * clampedFraction
		let feather = max(1, min(height * LyricsLayout.fillFeatherRatio, width * clampedFraction))

		context.saveGState()
		context.clip(to: CGRect(x: origin.x, y: origin.y, width: width, height: height))
		context.beginTransparencyLayer(auxiliaryInfo: nil)
		(text as NSString).draw(at: origin, withAttributes: [.font: font, .foregroundColor: self.sungColor])

		// Soften the fill's trailing edge.
		context.setBlendMode(.destinationIn)
		let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray
		if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
			context.drawLinearGradient(gradient, start: CGPoint(x: fillX - feather, y: 0), end: CGPoint(x: fillX, y: 0), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
		}

		context.endTransparencyLayer()
		context.restoreGState()
	}

	/// Draws a single static row of text, centered and truncated to the drawable width.
	///
	/// - Parameters:
	///    - text: The text to draw.
	///    - font: The font of the row.
	///    - rowTop: The top of the row.
	///    - alpha: The opacity of the text.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawStaticRow(_ text: String, font: UIFont, rowTop: CGFloat, alpha: CGFloat, in context: CGContext, size: CGSize) {
		guard alpha > 0, !text.isEmpty else { return }

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.lineBreakMode = .byTruncatingTail

		let drawRect = CGRect(x: self.horizontalInset, y: rowTop, width: size.width - self.horizontalInset * 2, height: font.lineHeight)
		(text as NSString).draw(in: drawRect, withAttributes: [
			.font: font,
			.foregroundColor: self.sungColor.withAlphaComponent(alpha),
			.paragraphStyle: paragraphStyle,
		])
	}

	/// Draws a single row of text that pans horizontally with the line's progress when it overflows.
	///
	/// - Parameters:
	///    - text: The text to draw.
	///    - font: The font of the row.
	///    - rowTop: The top of the row.
	///    - alpha: The opacity of the text.
	///    - panFraction: The elapsed fraction of the line, from `0` to `1`.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawPanningRow(_ text: String, font: UIFont, rowTop: CGFloat, alpha: CGFloat, panFraction: CGFloat, in context: CGContext, size: CGSize) {
		guard alpha > 0, !text.isEmpty else { return }

		let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
		let usableWidth = size.width - self.horizontalInset * 2

		guard textWidth > usableWidth else {
			self.drawStaticRow(text, font: font, rowTop: rowTop, alpha: alpha, in: context, size: size)
			return
		}

		let clampedFraction = min(max(panFraction, 0), 1)
		let pan = (textWidth - usableWidth) * clampedFraction

		context.saveGState()
		context.clip(to: CGRect(x: self.horizontalInset, y: rowTop, width: usableWidth, height: font.lineHeight))
		(text as NSString).draw(at: CGPoint(x: self.horizontalInset - pan, y: rowTop), withAttributes: [
			.font: font,
			.foregroundColor: self.sungColor.withAlphaComponent(alpha),
		])
		context.restoreGState()
	}

	/// Draws the interlude dots, filled to the elapsed fraction.
	///
	/// - Parameters:
	///    - fraction: The elapsed fraction of the gap, from `0` to `1`.
	///    - yOffset: The vertical shift applied to the dots.
	///    - context: The context to draw into.
	///    - size: The size of the canvas in pixels.
	private static func drawInterlude(fraction: CGFloat, yOffset: CGFloat, in context: CGContext, size: CGSize) {
		let clampedFraction = min(max(fraction, 0), 1)
		let dotCount = 3
		let totalWidth = CGFloat(dotCount) * self.interludeDotRadius * 2 + CGFloat(dotCount - 1) * self.interludeDotSpacing
		let originX = (size.width - totalWidth) / 2
		let centerY = size.height / 2 + yOffset

		for dot in 0..<dotCount {
			let dotFill = min(max(clampedFraction * CGFloat(dotCount) - CGFloat(dot), 0), 1)
			let alpha = LyricsLayout.unsungTextAlpha + (1 - LyricsLayout.unsungTextAlpha) * dotFill
			let centerX = originX + self.interludeDotRadius + CGFloat(dot) * (self.interludeDotRadius * 2 + self.interludeDotSpacing)

			context.setFillColor(self.sungColor.withAlphaComponent(alpha).cgColor)
			context.fillEllipse(in: CGRect(x: centerX - self.interludeDotRadius, y: centerY - self.interludeDotRadius, width: self.interludeDotRadius * 2, height: self.interludeDotRadius * 2))
		}
	}

	/// The sung fraction of a timed span at a playback position.
	///
	/// - Parameters:
	///    - positionMs: The playback position in milliseconds.
	///    - beginMs: The start of the span in milliseconds.
	///    - endMs: The end of the span in milliseconds.
	///    - offsetMs: The global timing offset applied to the span, in milliseconds.
	///
	/// - Returns: The fraction, from `0` to `1`.
	private static func fraction(positionMs: Int, beginMs: Int, endMs: Int, offsetMs: Int) -> CGFloat {
		let begin = beginMs + offsetMs
		let end = endMs + offsetMs
		if positionMs >= end { return 1 }
		if positionMs <= begin { return 0 }
		return CGFloat(positionMs - begin) / CGFloat(max(1, end - begin))
	}
}
