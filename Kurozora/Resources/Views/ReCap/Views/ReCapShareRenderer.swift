//
//  ReCapShareRenderer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Draws the shareable images of a Re:CAP.
enum ReCapShareRenderer {
	// MARK: - Types
	/// The font and color text is drawn in.
	private struct TextStyle {
		let font: UIFont
		let color: UIColor

		/// The attributes text of the style is drawn with.
		var attributes: [NSAttributedString.Key: Any] {
			return [.font: self.font, .foregroundColor: self.color, .kern: -0.02 * self.font.pointSize]
		}

		/// Returns the width of the given text in the style.
		///
		/// - Parameter text: The text to measure.
		///
		/// - Returns: The width of the text.
		func width(of text: String) -> CGFloat {
			return (text as NSString).size(withAttributes: self.attributes).width
		}
	}

	/// The colors of the current theme.
	private struct Theme {
		let background: UIColor
		let primaryText: UIColor
		let secondaryText: UIColor
		let placeholder: UIColor
	}

	/// How many titles each summary section lists and how large the list is drawn.
	private struct SummaryLayout {
		var counts: [Int]
		var scale: CGFloat = 1.0
		var spacing: CGFloat = 1.0
	}

	/// A line of the summary list.
	private enum SummaryRow {
		case heading(String, top: CGFloat)
		case item(rank: Int, lines: [String], top: CGFloat)
	}

	// MARK: - Properties
	/// The name of the brand shown on every card.
	private static let brandName = "Kurozora"

	/// The lowest point the summary's list may reach.
	private static let summaryBottom: CGFloat = 1800.0

	/// The share of the shorter artwork that stacked summary artworks overlap by.
	private static let summaryArtworkOverlap: CGFloat = 0.3

	/// The paths of the Kurozora logo in its 44-point box.
	private static let logoPaths = [
		"M4.26356589,25.6953027 C4.25865611,30.1220323 6.11477477,34.3424354 9.36940612,37.3048315 C6.04486859,33.8984502 5.89762765,28.4720384 9.03244888,24.886623 C12.1672701,21.3012076 17.5136377,20.7811787 21.2674782,23.6965497 C25.0213187,26.6119208 25.9007262,31.9671163 23.2799805,35.9517818 C20.6592348,39.9364472 15.4332991,41.1898517 11.3205565,38.8201669 C13.8256676,40.4665942 16.7506698,41.3407107 19.7388593,41.3359375 C28.2881704,41.3359375 35.2170543,34.3335972 35.2170543,25.6953027 C35.2170543,17.0570082 28.2881704,10.0546875 19.7388593,10.0546875 C11.1924595,10.0546875 4.26356589,17.0575967 4.26356589,25.6953027 Z",
		"M1.02325581,22.9450189 C1.02325581,24.4181799 1.17548672,25.8873356 1.47831164,27.3285372 C1.40322831,26.6431228 1.36549315,25.9540748 1.36527611,25.2644961 C1.36527611,14.9125812 9.69261577,6.5201841 19.9642832,6.5201841 C30.2359506,6.5201841 38.5632903,14.9143428 38.5632903,25.2644961 C38.5632903,35.2634982 30.7941364,43.4333429 21.0084053,43.9788605 C21.3090565,43.9917791 21.610873,44 21.9150202,44 C33.4516369,44 42.8062016,34.5735271 42.8062016,22.9450189 C42.8062016,11.3165107 33.4528022,1.890625 21.9150202,1.890625 C10.3784035,1.890625 1.02325581,11.3170979 1.02325581,22.9450189 Z",
		"M0.937984496,12.890625 C3.00055919,6.51588805 8.78568735,1.96729358 15.0930233,0 C7.6776734,0 0.937984496,4.79560892 0.937984496,12.890625 Z",
	]

	// MARK: - Functions
	/// Renders the given card in the recap colors.
	///
	/// - Parameters:
	///    - card: The card to render.
	///    - colors: The recap's two colors.
	///
	/// - Returns: The rendered card.
	static func render(_ card: ReCapShareCard, colors: [UIColor]) async -> UIImage? {
		let layout: ReCapShareGlow.Layout = switch card {
		case .genres: .genres
		case .comparison: .comparison
		case .summary: .summary
		}

		guard
			colors.count == 2,
			let fieldData = NSDataAsset(name: layout.assetName)?.data
		else { return nil }

		let theme = Theme(
			background: KThemePicker.backgroundColor.colorValue,
			primaryText: KThemePicker.textColor.colorValue,
			secondaryText: KThemePicker.subTextColor.colorValue,
			placeholder: KThemePicker.blurBackgroundColor.colorValue.withAlphaComponent(1.0)
		)

		async let glowImage = ReCapShareGlow.render(layout: layout, fieldData: fieldData, first: .init(colors[0]), second: .init(colors[1]), background: .init(theme.background))
		async let artworkImages = self.loadImages(of: card.artworks)
		let (glow, images) = await (glowImage, artworkImages)

		guard let glow else { return nil }

		let format = UIGraphicsImageRendererFormat()
		format.scale = 1.0
		format.opaque = true

		return UIGraphicsImageRenderer(size: ReCapShareGlow.size, format: format).image { rendererContext in
			UIImage(cgImage: glow).draw(in: CGRect(origin: .zero, size: ReCapShareGlow.size))
			self.drawHeader(theme: theme, context: rendererContext.cgContext)

			switch card {
			case .genres(let title, let subtitle, let items):
				self.drawTitleBlock(title: title, subtitle: subtitle, theme: theme)
				self.drawGenres(items, theme: theme)
			case .comparison(let title, let subtitle, let entries):
				self.drawTitleBlock(title: title, subtitle: subtitle, theme: theme)
				self.drawComparison(entries, images: images, theme: theme, context: rendererContext.cgContext)
			case .summary(let period, let total, let sections):
				self.drawSummary(period: period, total: total, sections: sections, images: images, theme: theme, context: rendererContext.cgContext)
			}
		}
	}

	/// Returns the images of the given artworks.
	///
	/// - Parameter artworks: The artworks whose images to load.
	///
	/// - Returns: The loaded images in the order of the artworks.
	private static func loadImages(of artworks: [ReCapShareCard.Artwork]) async -> [UIImage?] {
		var images = [UIImage?](repeating: nil, count: artworks.count)

		await withTaskGroup(of: (Int, UIImage?).self) { taskGroup in
			for (index, artwork) in artworks.enumerated() {
				taskGroup.addTask {
					guard let url = artwork.url else { return (index, artwork.placeholder) }
					return (index, await UIImage.load(from: url))
				}
			}

			for await (index, image) in taskGroup {
				images[index] = image
			}
		}

		return images
	}

	// MARK: - Text
	/// Returns the baseline of a line box with the given top and height.
	///
	/// - Parameters:
	///    - top: The top of the line box.
	///    - lineHeight: The height of the line box.
	///    - font: The font of the line.
	///
	/// - Returns: The baseline of the line.
	private static func baseline(top: CGFloat, lineHeight: CGFloat, font: UIFont) -> CGFloat {
		return top + (lineHeight - (font.ascender - font.descender)) / 2.0 + font.ascender
	}

	/// Draws a line of text with its baseline at the given point.
	///
	/// - Parameters:
	///    - text: The text to draw.
	///    - style: The style of the text.
	///    - x: The horizontal anchor of the text.
	///    - baseline: The baseline of the text.
	///    - alignment: The side of the text the anchor is on.
	private static func draw(_ text: String, style: TextStyle, x: CGFloat, baseline: CGFloat, alignment: NSTextAlignment = .left) {
		let width = style.width(of: text)
		let originX: CGFloat = switch alignment {
		case .center: x - width / 2.0
		case .right: x - width
		default: x
		}

		(text as NSString).draw(at: CGPoint(x: originX, y: baseline - style.font.ascender), withAttributes: style.attributes)
	}

	/// Returns the text broken into lines that fit the width.
	///
	/// - Parameters:
	///    - text: The text to break.
	///    - style: The style of the text.
	///    - maxWidth: The width a line may take.
	///    - maxLines: The most lines to return.
	///
	/// - Returns: The lines of the text, the last one ending in an ellipsis when cut short.
	private static func wrap(_ text: String, style: TextStyle, maxWidth: CGFloat, maxLines: Int) -> [String] {
		let fits = { (line: String) in style.width(of: line) <= maxWidth }
		var lines: [String] = []
		var line = ""

		for word in text.split(whereSeparator: \.isWhitespace).map(String.init) {
			let candidate = line.isEmpty ? word : "\(line) \(word)"

			if fits(candidate) {
				line = candidate
				continue
			}

			if !line.isEmpty {
				lines.append(line)
			}

			// A word wider than the line breaks where it runs out of room.
			line = word
			while !fits(line), line.count > 1 {
				var end = line.count - 1
				while end > 1, !fits(String(line.prefix(end))) {
					end -= 1
				}
				lines.append(String(line.prefix(end)))
				line = String(line.dropFirst(end))
			}
		}

		if !line.isEmpty {
			lines.append(line)
		}

		guard lines.count > maxLines else { return lines }

		var kept = Array(lines.prefix(maxLines))
		var last = "\(kept[maxLines - 1])…"
		while !fits(last), last.count > 1 {
			last = "\(last.dropLast(2).trimmingCharacters(in: .whitespaces))…"
		}
		kept[maxLines - 1] = last

		return kept
	}

	// MARK: - Header
	/// Draws the Re:CAP wordmark and the Kurozora brand along the top.
	///
	/// - Parameters:
	///    - theme: The colors of the current theme.
	///    - context: The context to draw in.
	private static func drawHeader(theme: Theme, context: CGContext) {
		let center: CGFloat = 206.0
		let wordmarkStyle = TextStyle(font: .systemFont(ofSize: 55.0, weight: .semibold), color: theme.primaryText)
		self.draw(L10n.reCAP, style: wordmarkStyle, x: 54.0, baseline: center + wordmarkStyle.font.capHeight / 2.0)

		let brandStyle = TextStyle(font: .systemFont(ofSize: 46.0, weight: .semibold), color: theme.primaryText)
		let brandX = ReCapShareGlow.size.width - 54.0 - brandStyle.width(of: self.brandName)
		self.draw(self.brandName, style: brandStyle, x: brandX, baseline: center + brandStyle.font.capHeight / 2.0)

		let logoSize: CGFloat = 42.0
		let unit = logoSize / 44.0
		let logoOrigin = CGPoint(x: brandX - 10.0 - logoSize + 0.5 * unit, y: center - logoSize / 2.0)
		context.saveGState()
		context.setFillColor(theme.primaryText.cgColor)
		for pathData in self.logoPaths {
			context.addPath(ReCapGradientShape.path(from: pathData, in: CGRect(origin: logoOrigin, size: CGSize(width: unit, height: unit))))
		}
		context.fillPath()
		context.restoreGState()
	}

	/// Draws a card's title and its secondary subtitle beneath.
	///
	/// - Parameters:
	///    - title: The title of the card.
	///    - subtitle: The subtitle of the card.
	///    - theme: The colors of the current theme.
	private static func drawTitleBlock(title: String, subtitle: String, theme: Theme) {
		let font = UIFont.systemFont(ofSize: 56.0, weight: .semibold)
		let lineHeight = 56.0 * 1.12
		let titleStyle = TextStyle(font: font, color: theme.primaryText)
		let subtitleStyle = TextStyle(font: font, color: theme.secondaryText)

		self.draw(self.wrap(title, style: titleStyle, maxWidth: 972.0, maxLines: 1).first ?? "", style: titleStyle, x: 54.0, baseline: self.baseline(top: 345.0, lineHeight: lineHeight, font: font))
		self.draw(self.wrap(subtitle, style: subtitleStyle, maxWidth: 972.0, maxLines: 1).first ?? "", style: subtitleStyle, x: 54.0, baseline: self.baseline(top: 345.0 + lineHeight, lineHeight: lineHeight, font: font))
	}

	// MARK: - Cards
	/// Draws the ranked genres or themes with the minutes spent on each.
	///
	/// - Parameters:
	///    - items: The ranked genres or themes.
	///    - theme: The colors of the current theme.
	private static func drawGenres(_ items: [ReCapShareCard.RankedItem], theme: Theme) {
		let font = UIFont.systemFont(ofSize: 56.0, weight: .semibold)
		let lineHeight = 56.0 * 1.215
		let pitch = lineHeight * 2.0 + 81.0
		let primaryStyle = TextStyle(font: font, color: theme.primaryText)
		let secondaryStyle = TextStyle(font: font, color: theme.secondaryText)

		for (index, item) in items.enumerated() {
			let top = 591.0 + CGFloat(index) * pitch
			let nameBaseline = self.baseline(top: top, lineHeight: lineHeight, font: font)
			self.draw(String(index + 1), style: primaryStyle, x: 52.0, baseline: nameBaseline)
			self.draw(self.wrap(item.name, style: primaryStyle, maxWidth: 880.0, maxLines: 1).first ?? "", style: primaryStyle, x: 148.0, baseline: nameBaseline)

			if let detail = item.detail {
				self.draw(self.wrap(detail, style: secondaryStyle, maxWidth: 880.0, maxLines: 1).first ?? "", style: secondaryStyle, x: 148.0, baseline: self.baseline(top: top + lineHeight, lineHeight: lineHeight, font: font))
			}
		}
	}

	/// Draws this year's top title above last year's.
	///
	/// - Parameters:
	///    - entries: The two years' top titles.
	///    - images: The images of the titles' artwork.
	///    - theme: The colors of the current theme.
	///    - context: The context to draw in.
	private static func drawComparison(_ entries: [ReCapShareCard.ComparisonEntry], images: [UIImage?], theme: Theme, context: CGContext) {
		let placements: [(imageTop: CGFloat, imageX: CGFloat, textX: CGFloat)] = [(580.0, 704.0, 56.0), (1200.0, 56.0, 424.0)]

		for (index, entry) in entries.prefix(placements.count).enumerated() {
			let placement = placements[index]
			let size = self.artworkSize(of: entry.artwork.shape, width: 320.0, posterHeight: 480.0)
			let artworkRect = CGRect(x: placement.imageX + (320.0 - size.width) / 2.0, y: placement.imageTop + (480.0 - size.height) / 2.0, width: size.width, height: size.height)
			self.drawArtwork(images[safe: index] ?? nil, artwork: entry.artwork, in: artworkRect, isStacked: false, theme: theme, context: context)

			// The year's top lines up with the artwork's top.
			let yearStyle = TextStyle(font: .systemFont(ofSize: 44.0, weight: .semibold), color: theme.secondaryText)
			self.draw(entry.year, style: yearStyle, x: placement.textX, baseline: artworkRect.minY + yearStyle.font.capHeight)

			// Long names step down in size until they fit three lines.
			var nameSize: CGFloat = 80.0
			var nameStyle = TextStyle(font: .systemFont(ofSize: nameSize, weight: .medium), color: theme.primaryText)
			while nameSize > 56.0, self.wrap(entry.name, style: nameStyle, maxWidth: 600.0, maxLines: .max).count > 3 {
				nameSize -= 4.0
				nameStyle = TextStyle(font: .systemFont(ofSize: nameSize, weight: .medium), color: theme.primaryText)
			}

			let nameLineHeight = nameSize * 1.19
			for (lineIndex, line) in self.wrap(entry.name, style: nameStyle, maxWidth: 600.0, maxLines: 3).enumerated() {
				self.draw(line, style: nameStyle, x: placement.textX, baseline: self.baseline(top: placement.imageTop + 89.0 + CGFloat(lineIndex) * nameLineHeight, lineHeight: nameLineHeight, font: nameStyle.font))
			}

			if let detail = entry.detail {
				let detailStyle = TextStyle(font: .systemFont(ofSize: 42.0, weight: .semibold), color: theme.secondaryText)
				self.draw(self.wrap(detail, style: detailStyle, maxWidth: 600.0, maxLines: 1).first ?? "", style: detailStyle, x: placement.textX, baseline: self.baseline(top: placement.imageTop + 408.0, lineHeight: 42.0 * 1.2, font: detailStyle.font))
			}
		}
	}

	/// Draws the period's total and top titles beside a stack of each section's top artwork.
	///
	/// - Parameters:
	///    - period: The name of the period.
	///    - total: The total time of the period.
	///    - sections: The sections of top titles.
	///    - images: The images of the sections' artwork.
	///    - theme: The colors of the current theme.
	///    - context: The context to draw in.
	private static func drawSummary(period: String, total: String?, sections: [ReCapShareCard.Section], images: [UIImage?], theme: Theme, context: CGContext) {
		let centerX = ReCapShareGlow.size.width / 2.0
		let periodStyle = TextStyle(font: .systemFont(ofSize: 83.0, weight: .semibold), color: theme.primaryText)
		self.draw(period, style: periodStyle, x: centerX, baseline: self.baseline(top: 286.0, lineHeight: 83.0 * 1.2, font: periodStyle.font), alignment: .center)

		if let total {
			let totalStyle = TextStyle(font: .systemFont(ofSize: 41.0, weight: .semibold), color: theme.secondaryText)
			self.draw(total, style: totalStyle, x: centerX, baseline: self.baseline(top: 286.0 + 83.0 * 1.2 + 12.0, lineHeight: 41.0 * 1.2, font: totalStyle.font), alignment: .center)
		}

		let layout = self.summaryLayout(for: sections)
		self.drawSummaryList(sections, layout: layout, theme: theme)

		var top: CGFloat = 580.0
		var previousHeight: CGFloat?
		for (index, section) in sections.prefix(4).enumerated() {
			let size = self.artworkSize(of: section.artwork.shape, width: 300.0, posterHeight: 428.0)

			// Each artwork overlaps the one above by the same share of the shorter of the two.
			if let previousHeight {
				top += previousHeight - Self.summaryArtworkOverlap * min(previousHeight, size.height)
			}
			previousHeight = size.height

			let origin = CGPoint(x: index.isMultiple(of: 2) ? 700.0 : 760.0, y: top)
			self.drawArtwork(images[safe: index] ?? nil, artwork: section.artwork, in: CGRect(origin: origin, size: size), isStacked: true, theme: theme, context: context)
		}
	}

	/// Returns how many titles each summary section lists and how large the list is drawn.
	///
	/// - Parameter sections: The sections of top titles.
	///
	/// - Returns: The layout of the list.
	private static func summaryLayout(for sections: [ReCapShareCard.Section]) -> SummaryLayout {
		let limit = [1: 10, 2: 5, 3: 4][sections.count] ?? 3
		var layout = SummaryLayout(counts: sections.map { min(3, $0.items.count) })
		let fits = { (layout: SummaryLayout) in self.summaryRows(sections, layout: layout).bottom <= self.summaryBottom }

		// Fewer sections list more titles, one round at a time while the list still fits.
		var grew = true
		while grew {
			grew = false
			for (index, section) in sections.enumerated() where layout.counts[index] < min(limit, section.items.count) {
				layout.counts[index] += 1
				if fits(layout) {
					grew = true
				} else {
					layout.counts[index] -= 1
				}
			}
		}

		// Long titles tighten the gaps before shrinking the list.
		while !fits(layout), layout.spacing > 0.5 {
			layout.spacing -= 0.05
		}
		while !fits(layout), layout.scale > 0.72 {
			layout.scale -= 0.02
		}

		return layout
	}

	/// Returns the rows of the summary list at the given layout.
	///
	/// - Parameters:
	///    - sections: The sections of top titles.
	///    - layout: The layout of the list.
	///
	/// - Returns: The rows of the list and where it ends.
	private static func summaryRows(_ sections: [ReCapShareCard.Section], layout: SummaryLayout) -> (rows: [SummaryRow], bottom: CGFloat) {
		let scale = layout.scale
		let itemStyle = TextStyle(font: .systemFont(ofSize: 34.0 * scale, weight: .medium), color: .white)
		let itemLineHeight = 34.0 * scale * 1.2
		var rows: [SummaryRow] = []
		var top: CGFloat = 580.0

		for (sectionIndex, section) in sections.enumerated() {
			if sectionIndex > 0 {
				top += 118.0 * scale * layout.spacing
			}

			rows.append(.heading(section.title, top: top))
			top += 48.0 * scale * 1.2 + 35.0 * scale

			for (itemIndex, item) in section.items.prefix(layout.counts[sectionIndex]).enumerated() {
				if itemIndex > 0 {
					top += 22.0 * scale
				}

				let lines = self.wrap(item, style: itemStyle, maxWidth: 600.0 - 67.0 * scale, maxLines: 3)
				rows.append(.item(rank: itemIndex + 1, lines: lines, top: top))
				top += CGFloat(lines.count) * itemLineHeight
			}
		}

		return (rows, top)
	}

	/// Draws the summary list at the given layout.
	///
	/// - Parameters:
	///    - sections: The sections of top titles.
	///    - layout: The layout of the list.
	///    - theme: The colors of the current theme.
	private static func drawSummaryList(_ sections: [ReCapShareCard.Section], layout: SummaryLayout, theme: Theme) {
		let scale = layout.scale
		let indent = 67.0 * scale
		let headingStyle = TextStyle(font: .systemFont(ofSize: 48.0 * scale, weight: .semibold), color: theme.primaryText)
		let itemFont = UIFont.systemFont(ofSize: 34.0 * scale, weight: .medium)
		let itemStyle = TextStyle(font: itemFont, color: theme.primaryText)
		let rankStyle = TextStyle(font: itemFont, color: theme.secondaryText)
		let itemLineHeight = 34.0 * scale * 1.2

		for row in self.summaryRows(sections, layout: layout).rows {
			switch row {
			case .heading(let title, let top):
				self.draw(title, style: headingStyle, x: 63.0 + indent, baseline: self.baseline(top: top, lineHeight: 48.0 * scale * 1.2, font: headingStyle.font))
			case .item(let rank, let lines, let top):
				self.draw(String(rank), style: rankStyle, x: 63.0, baseline: self.baseline(top: top, lineHeight: itemLineHeight, font: itemFont))
				for (lineIndex, line) in lines.enumerated() {
					self.draw(line, style: itemStyle, x: 63.0 + indent, baseline: self.baseline(top: top + CGFloat(lineIndex) * itemLineHeight, lineHeight: itemLineHeight, font: itemFont))
				}
			}
		}
	}

	// MARK: - Artwork
	/// Returns the size of an artwork shape at the given width and poster height.
	///
	/// - Parameters:
	///    - shape: The shape of the artwork.
	///    - width: The width of the artwork.
	///    - posterHeight: The height of a poster at that width.
	///
	/// - Returns: The size of the artwork.
	private static func artworkSize(of shape: ReCapShareCard.Artwork.Shape, width: CGFloat, posterHeight: CGFloat) -> CGSize {
		switch shape {
		case .square, .circle:
			return CGSize(width: width, height: width)
		case .book:
			return CGSize(width: width, height: min(width * 160.0 / 112.0, posterHeight))
		case .poster:
			return CGSize(width: width, height: posterHeight)
		}
	}

	/// Returns the outline of an artwork shape.
	///
	/// - Parameters:
	///    - shape: The shape of the artwork.
	///    - rect: The rectangle the artwork fills.
	///
	/// - Returns: The outline of the artwork.
	private static func artworkPath(of shape: ReCapShareCard.Artwork.Shape, in rect: CGRect) -> UIBezierPath {
		switch shape {
		case .circle:
			return UIBezierPath(ovalIn: rect)
		case .square:
			return UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.2133)
		case .book:
			return UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 4.0 / 112.0)
		case .poster:
			return UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.07)
		}
	}

	/// Draws an artwork in its shape.
	///
	/// - Parameters:
	///    - image: The image of the artwork.
	///    - artwork: The artwork to draw.
	///    - rect: The rectangle the artwork fills.
	///    - isStacked: Whether the artwork sits in a stack that casts shadows.
	///    - theme: The colors of the current theme.
	///    - context: The context to draw in.
	private static func drawArtwork(_ image: UIImage?, artwork: ReCapShareCard.Artwork, in rect: CGRect, isStacked: Bool, theme: Theme, context: CGContext) {
		let path = self.artworkPath(of: artwork.shape, in: rect)

		context.saveGState()
		if isStacked {
			context.setShadow(offset: CGSize(width: 0.0, height: 24.0), blur: 60.0, color: UIColor.black.withAlphaComponent(0.45).cgColor)
		}
		(artwork.color ?? theme.placeholder).setFill()
		path.fill()
		context.restoreGState()

		if artwork.shape != .book {
			context.saveGState()
			path.lineWidth = 4.0
			(isStacked ? UIColor.black.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.14)).setStroke()
			path.stroke()
			context.restoreGState()
		}

		context.saveGState()
		path.addClip()
		if let image {
			let coverScale = max(rect.width / image.size.width, rect.height / image.size.height)
			let drawSize = CGSize(width: image.size.width * coverScale, height: image.size.height * coverScale)
			image.draw(in: CGRect(x: rect.midX - drawSize.width / 2.0, y: rect.midY - drawSize.height / 2.0, width: drawSize.width, height: drawSize.height))
		}

		// The spine and sheen of the app's book covers.
		if artwork.shape == .book, let spine = CGGradient(
			colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
			colors: [
				UIColor(red: 223.0 / 255.0, green: 218.0 / 255.0, blue: 218.0 / 255.0, alpha: 0.318).cgColor,
				UIColor(red: 227.0 / 255.0, green: 227.0 / 255.0, blue: 227.0 / 255.0, alpha: 0.12).cgColor,
				UIColor(red: 21.0 / 255.0, green: 21.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0).cgColor,
				UIColor.white.cgColor,
			] as CFArray,
			locations: [0.0, 0.952, 0.956, 1.0]
		) {
			context.setAlpha(0.4)
			context.setBlendMode(.lighten)
			context.drawLinearGradient(spine, start: CGPoint(x: rect.maxX, y: rect.midY), end: CGPoint(x: rect.minX + rect.width * 0.0036, y: rect.midY), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
		}
		context.restoreGState()
	}
}
