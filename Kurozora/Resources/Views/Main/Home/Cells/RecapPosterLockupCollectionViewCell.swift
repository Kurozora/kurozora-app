//
//  RecapPosterLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// A lockup that presents a recap as a lit poster: a duotone gradient, a radial bloom, a sweeping flare and year numerals that defocus towards their base.
class RecapPosterLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	/// The clipped, rounded card holding every layer of the poster.
	private let cardView = UIView()

	/// The duotone background of the poster.
	private let gradientView = GradientView()

	/// The radial highlight that lights the poster from behind the flare.
	private let bloomView = GradientView()

	/// The year numerals, sharp at their crown and defocused towards their base.
	private let numeralsImageView = UIImageView()

	/// The crescent of light sweeping across the poster.
	private let flareView = FlareView()

	/// The noise overlay that keeps the gradient from banding.
	private let grainView = GrainView()

	/// The hairline that defines the card's edge.
	private let borderView = BorderView()

	/// The wordmark in the poster's top leading corner.
	private let wordmarkLabel = UILabel()

	/// The app icon in the poster's top trailing corner.
	private let logoImageView = UIImageView()

	// MARK: - Properties
	/// The year the poster represents.
	private var year: Int?

	/// The color the numerals are drawn in.
	private var numeralsColor: UIColor = .white

	/// The card height the poster was last drawn for.
	private var drawnCardHeight: CGFloat = 0

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.drawPoster()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window == nil {
			self.flareView.stopAnimating()
		} else {
			self.flareView.startAnimating()
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.flareView.stopAnimating()
		self.year = nil
		self.numeralsImageView.image = nil
	}

	// MARK: - Functions
	/// Configures the cell with the given `Recap` object.
	///
	/// - Parameter recap: The `Recap` object used to configure the cell.
	func configure(using recap: Recap?) {
		guard let recap = recap else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		let firstColor = UIColor(hexString: recap.attributes.backgroundColor1) ?? UIColor(red: 0.29, green: 0.24, blue: 0.55, alpha: 1.0)
		let secondColor = UIColor(hexString: recap.attributes.backgroundColor2) ?? UIColor(red: 0.55, green: 0.24, blue: 0.44, alpha: 1.0)
		let isLightCard = firstColor.isLight && secondColor.isLight
		let foregroundColor: UIColor = isLightCard ? .black : .white

		self.gradientView.backgroundColors = self.gradientColors(from: firstColor, to: secondColor)
		self.bloomView.backgroundColors = self.bloomColors(isLightCard: isLightCard)
		self.flareView.coolFringeColor = self.litVariant(of: firstColor, hueShift: -0.06)
		self.flareView.warmFringeColor = self.litVariant(of: secondColor, hueShift: 0.06)

		self.wordmarkLabel.textColor = foregroundColor
		self.logoImageView.tintColor = foregroundColor
		self.numeralsColor = foregroundColor.withAlphaComponent(isLightCard ? 0.55 : 0.94)
		self.year = recap.attributes.year

		self.accessibilityLabel = "Re:CAP \(recap.attributes.year)"
		self.drawnCardHeight = 0
		self.setNeedsLayout()
	}

	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.isAccessibilityElement = true

		self.cardView.clipsToBounds = true
		self.cardView.layerCornerRadius = 22.0
		self.cardView.layer.cornerCurve = .continuous
		self.contentView.addSubview(self.cardView)
		self.cardView.fillToSuperview()
		self.cardView.heightAnchor.constraint(equalTo: self.cardView.widthAnchor).isActive = true

		self.gradientView.gradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.0)
		self.gradientView.gradientLayer?.endPoint = CGPoint(x: 1.0, y: 1.0)

		self.bloomView.gradientLayer?.type = .radial
		self.bloomView.gradientLayer?.startPoint = CGPoint(x: 0.72, y: 0.24)
		self.bloomView.gradientLayer?.endPoint = CGPoint(x: 1.5, y: 1.2)
		self.bloomView.gradientLayer?.locations = [0.0, 0.45, 1.0]
		self.bloomView.backgroundColors = self.bloomColors(isLightCard: false)

		self.wordmarkLabel.text = "Re:CAP"
		self.wordmarkLabel.font = .boldSystemFont(ofSize: 24.0)
		self.wordmarkLabel.textColor = .white

		self.logoImageView.image = UIImage(named: "kurozora.icon.monotone")?.withRenderingMode(.alwaysTemplate)
		self.logoImageView.contentMode = .scaleAspectFit
		self.logoImageView.tintColor = .white

		self.borderView.cornerRadius = 22.0

		for view in [self.gradientView, self.bloomView, self.numeralsImageView, self.flareView, self.grainView, self.borderView, self.wordmarkLabel, self.logoImageView] {
			view.translatesAutoresizingMaskIntoConstraints = false
			self.cardView.addSubview(view)
		}

		for view in [self.gradientView, self.bloomView, self.numeralsImageView, self.flareView, self.grainView, self.borderView] {
			view.fillToSuperview()
		}

		NSLayoutConstraint.activate([
			self.wordmarkLabel.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 16.0),
			self.wordmarkLabel.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 12.0),

			self.logoImageView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -16.0),
			self.logoImageView.centerYAnchor.constraint(equalTo: self.wordmarkLabel.centerYAnchor),
			self.logoImageView.widthAnchor.constraint(equalToConstant: 28.0),
			self.logoImageView.widthAnchor.constraint(equalTo: self.logoImageView.heightAnchor, multiplier: 21.0 / 22.0)
		])
	}

	/// Redraws the numerals at the card's current size.
	private func drawPoster() {
		let cardSize = self.contentView.bounds.size
		guard cardSize.height > 0, cardSize.height != self.drawnCardHeight else { return }
		self.drawnCardHeight = cardSize.height

		guard let year = self.year else {
			self.numeralsImageView.image = nil
			return
		}

		let pointSize = cardSize.height * 0.66
		let font = UIFont.systemFont(ofSize: pointSize, weight: .bold)
		let attributedText = NSAttributedString(string: String(format: "’%02d", year % 100), attributes: [
			.font: font,
			.kern: -pointSize * 0.045,
			.foregroundColor: self.numeralsColor
		])
		let origin = CGPoint(x: -pointSize * 0.09, y: cardSize.height * 0.93 - font.ascender)

		self.numeralsImageView.image = self.makeNumeralsImage(from: attributedText, at: origin, lineHeight: font.lineHeight, canvasSize: cardSize)
	}

	/// Renders the numerals twice across the whole card, cross fading a sharp copy into a blurred one down their height, so the blur's only hard edge lands on the card's own clipped boundary.
	///
	/// - Parameters:
	///    - attributedText: The typeset numerals.
	///    - origin: Where the numerals sit on the card.
	///    - lineHeight: The height of the numerals' line box.
	///    - canvasSize: The size of the card.
	///
	/// - Returns: The numerals artwork.
	private func makeNumeralsImage(from attributedText: NSAttributedString, at origin: CGPoint, lineHeight: CGFloat, canvasSize: CGSize) -> UIImage? {
		let format = UIGraphicsImageRendererFormat.default()
		format.opaque = false
		let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)

		let sharp = renderer.image { _ in
			attributedText.draw(at: origin)
		}

		guard let blurred = GaussianBlur.blurred(sharp, radius: lineHeight * 0.085) else { return sharp }

		let fadeStart = (origin.y + lineHeight * 0.12) / canvasSize.height
		let fadeEnd = (origin.y + lineHeight * 0.80) / canvasSize.height

		return renderer.image { context in
			let cgContext = context.cgContext

			cgContext.beginTransparencyLayer(auxiliaryInfo: nil)
			sharp.draw(at: .zero)
			cgContext.setBlendMode(.destinationIn)
			self.drawFade(in: cgContext, size: canvasSize, from: fadeStart, to: fadeEnd, opaqueAtTop: true)
			cgContext.endTransparencyLayer()

			cgContext.setBlendMode(.normal)
			cgContext.beginTransparencyLayer(auxiliaryInfo: nil)
			blurred.draw(at: .zero)
			cgContext.setBlendMode(.destinationIn)
			self.drawFade(in: cgContext, size: canvasSize, from: fadeStart, to: fadeEnd, opaqueAtTop: false)
			cgContext.endTransparencyLayer()
		}
	}

	/// Draws the vertical alpha ramp that cross fades the two numeral copies.
	///
	/// - Parameters:
	///    - cgContext: The context to draw into.
	///    - size: The size of the canvas.
	///    - from: The unit location the ramp starts at.
	///    - to: The unit location the ramp ends at.
	///    - opaqueAtTop: Whether the ramp runs from opaque to transparent.
	private func drawFade(in cgContext: CGContext, size: CGSize, from: CGFloat, to: CGFloat, opaqueAtTop: Bool) {
		let solid = UIColor.black.cgColor
		let clear = UIColor.black.withAlphaComponent(0.0).cgColor
		let colors = (opaqueAtTop ? [solid, clear] : [clear, solid]) as CFArray

		guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [from, to]) else { return }

		cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
	}

	/// Builds the poster's background stops, using the recap's two colors untouched so a card's trailing edge meets the next card's leading edge on the shared color.
	///
	/// - Parameters:
	///    - first: The color the ramp starts at.
	///    - second: The color the ramp ends at.
	///
	/// - Returns: The stops of the gradient.
	private func gradientColors(from first: UIColor, to second: UIColor) -> [CGColor] {
		return [first.cgColor, second.cgColor]
	}

	/// Builds the radial highlight's stops.
	///
	/// - Parameter isLightCard: Whether the poster's background is light.
	///
	/// - Returns: The stops of the highlight.
	private func bloomColors(isLightCard: Bool) -> [CGColor] {
		let bloomColor: UIColor = isLightCard ? .black : .white

		return [
			bloomColor.withAlphaComponent(isLightCard ? 0.10 : 0.30).cgColor,
			bloomColor.withAlphaComponent(isLightCard ? 0.03 : 0.08).cgColor,
			UIColor.clear.cgColor
		]
	}

	/// Returns the given color pushed to full brightness and rotated around the hue wheel, so the flare reads as the card's own light.
	///
	/// - Parameters:
	///    - color: The color to derive from.
	///    - hueShift: How far around the hue wheel to rotate.
	///
	/// - Returns: The derived color.
	private func litVariant(of color: UIColor, hueShift: CGFloat) -> UIColor {
		var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
		guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return color }

		return UIColor(hue: self.wrappedHue(hue + hueShift), saturation: min(saturation * 1.1, 0.85), brightness: 1.0, alpha: 1.0)
	}

	/// Returns the given hue wrapped into the zero to one range.
	///
	/// - Parameter hue: The hue to wrap.
	///
	/// - Returns: The wrapped hue.
	private func wrappedHue(_ hue: CGFloat) -> CGFloat {
		let wrapped = hue.truncatingRemainder(dividingBy: 1.0)
		return wrapped < 0 ? wrapped + 1.0 : wrapped
	}
}

// MARK: - Measurement
extension RecapPosterLockupCollectionViewCell {
	/// Returns the item that measures the given recap.
	///
	/// - Parameter recap: The recap the item measures.
	///
	/// - Returns: The item that measures the recap.
	static func measurableItem(for recap: Recap) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: RecapPosterLockupCollectionViewCell.self) { cell in
			cell.configure(using: recap)
		}
	}
}
