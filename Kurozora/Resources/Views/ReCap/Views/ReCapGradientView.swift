//
//  ReCapGradientView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreImage
import UIKit

/// A blurred cluster of Re:CAP gradient blobs.
final class ReCapGradientView: UIView {
	// MARK: - Types
	/// A gradient blob placed in the cluster.
	struct Blob {
		/// The edge the blob is measured from vertically.
		enum VerticalAnchor {
			case top(CGFloat)
			case bottom(CGFloat)
		}

		/// The edge the blob is measured from horizontally.
		enum HorizontalAnchor {
			case leading(CGFloat)
			case trailing(CGFloat)
		}

		/// The paint a blob is filled with.
		enum Fill {
			/// The recap colors under a soft highlight.
			case recap

			/// The recap colors along the given angle and stops.
			case linear(angle: CGFloat, locations: [CGFloat])
		}

		// MARK: - Properties
		let shape: ReCapGradientShape
		let verticalAnchor: VerticalAnchor
		let horizontalAnchor: HorizontalAnchor
		let width: (CGSize) -> CGFloat
		let aspectRatio: CGFloat
		var scale: CGFloat = 1.0
		var flipsHorizontally: Bool = false
		var flipsVertically: Bool = false
		var rotation: CGFloat = 0.0
		var fill: Fill = .recap
		var opacity: CGFloat = 1.0
		var brightness: CGFloat = 1.0
	}

	/// The part of the cluster that is cut off before blurring.
	enum Clipping {
		case none
		case bounds
		case vertical
	}

	// MARK: - Properties
	/// The context that blurs the rendered blobs.
	private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])

	/// The recap colors the blobs are painted with.
	var colors: [UIColor] = [] {
		didSet {
			self.setNeedsRender()
		}
	}

	/// The blobs of the cluster.
	var blobs: [Blob] = [] {
		didSet {
			self.setNeedsRender()
		}
	}

	/// Returns the blur radius for the cluster's size.
	var blurRadius: (CGSize) -> CGFloat = { _ in 0.0 } {
		didSet {
			self.setNeedsRender()
		}
	}

	/// The part of the cluster cut off before blurring.
	var clipping: Clipping = .bounds {
		didSet {
			self.setNeedsRender()
		}
	}

	/// Returns the height the blobs' vertical positions are measured against.
	var referenceHeight: ((CGSize) -> CGFloat)? {
		didSet {
			self.setNeedsRender()
		}
	}

	/// The brightness applied to the whole cluster.
	var brightness: CGFloat = 1.0 {
		didSet {
			self.setNeedsRender()
		}
	}

	/// The layer showing the blurred blobs.
	private let imageLayer = CALayer()

	/// The size the current image was rendered for.
	private var renderedSize: CGSize = .zero

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

		guard self.bounds.size != self.renderedSize else { return }
		self.render()
	}

	// MARK: - Functions
	private func sharedInit() {
		self.isUserInteractionEnabled = false
		self.imageLayer.contentsGravity = .resize
		self.layer.addSublayer(self.imageLayer)
	}

	/// Marks the blobs as needing to be drawn again.
	private func setNeedsRender() {
		self.renderedSize = .zero
		self.setNeedsLayout()
	}

	/// Draws and blurs the blobs into the image layer.
	private func render() {
		let size = self.bounds.size
		self.renderedSize = size

		guard size.width > 0.0, size.height > 0.0, !self.blobs.isEmpty, self.colors.count == 2 else {
			self.imageLayer.contents = nil
			return
		}

		let radius = self.blurRadius(size)
		let padding = (radius * 3.0).rounded(.up)
		let canvas = CGRect(x: -padding, y: -padding, width: size.width + padding * 2.0, height: size.height + padding * 2.0)
		let isRightToLeft = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1.0
		format.opaque = false

		let image = UIGraphicsImageRenderer(size: canvas.size, format: format).image { rendererContext in
			let context = rendererContext.cgContext
			context.translateBy(x: padding, y: padding)

			switch self.clipping {
			case .none:
				break
			case .bounds:
				context.clip(to: CGRect(origin: .zero, size: size))
			case .vertical:
				context.clip(to: CGRect(x: canvas.minX, y: 0.0, width: canvas.width, height: size.height))
			}

			for blob in self.blobs {
				self.draw(blob, in: context, containerSize: size, isRightToLeft: isRightToLeft)
			}

			if self.brightness < 1.0 {
				context.setBlendMode(.sourceAtop)
				context.setFillColor(UIColor.black.withAlphaComponent(1.0 - self.brightness).cgColor)
				context.fill(canvas)
			}
		}

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.imageLayer.frame = canvas
		self.imageLayer.contents = self.blurredImage(image, radius: radius)
		CATransaction.commit()
	}

	/// Draws a blob in the given context.
	///
	/// - Parameters:
	///    - blob: The blob to draw.
	///    - context: The context to draw in.
	///    - containerSize: The size of the cluster.
	///    - isRightToLeft: Whether the layout runs right to left.
	private func draw(_ blob: Blob, in context: CGContext, containerSize: CGSize, isRightToLeft: Bool) {
		let width = blob.width(containerSize)
		let height = width / blob.aspectRatio
		let referenceHeight = self.referenceHeight?(containerSize) ?? containerSize.height
		let y: CGFloat = switch blob.verticalAnchor {
		case .top(let fraction):
			referenceHeight * fraction
		case .bottom(let fraction):
			containerSize.height - referenceHeight * fraction - height
		}
		var x: CGFloat = switch blob.horizontalAnchor {
		case .leading(let fraction):
			containerSize.width * fraction
		case .trailing(let fraction):
			containerSize.width - containerSize.width * fraction - width
		}

		if isRightToLeft {
			x = containerSize.width - x - width
		}

		let box = CGRect(x: x, y: y, width: width, height: height)
		let transform = CGAffineTransform(translationX: box.midX, y: box.midY)
			.scaledBy(x: blob.scale, y: blob.scale)
			.scaledBy(x: blob.flipsHorizontally ? -1.0 : 1.0, y: blob.flipsVertically ? -1.0 : 1.0)
			.rotated(by: blob.rotation * .pi / 180.0)
			.translatedBy(x: -box.midX, y: -box.midY)

		context.saveGState()
		context.setAlpha(blob.opacity)
		context.beginTransparencyLayer(auxiliaryInfo: nil)
		context.concatenate(transform)
		context.addPath(blob.shape.path(in: box))
		context.clip()

		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let colors = self.colors.map(\.cgColor) as CFArray
		let options: CGGradientDrawingOptions = [.drawsBeforeStartLocation, .drawsAfterEndLocation]

		switch blob.fill {
		case .recap:
			let points = Self.gradientPoints(in: box, angle: 135.0)
			if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
				context.drawLinearGradient(gradient, start: points.start, end: points.end, options: options)
			}

			let center = CGPoint(x: box.minX + box.width * 0.72, y: box.minY + box.height * 0.24)
			let radius = hypot(box.width * 0.72, box.height * 0.76)
			let highlightColors = [
				UIColor.white.withAlphaComponent(0.3).cgColor,
				UIColor.white.withAlphaComponent(0.08).cgColor,
				UIColor.white.withAlphaComponent(0.0).cgColor,
			] as CFArray
			if let highlight = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: [0.0, 0.45, 0.72]) {
				context.drawRadialGradient(highlight, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [])
			}
		case .linear(let angle, let locations):
			let points = Self.gradientPoints(in: box, angle: angle)
			if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
				context.drawLinearGradient(gradient, start: points.start, end: points.end, options: options)
			}
		}

		if blob.brightness < 1.0 {
			context.setFillColor(UIColor.black.withAlphaComponent(1.0 - blob.brightness).cgColor)
			context.fill(box)
		}

		context.endTransparencyLayer()
		context.restoreGState()
	}

	/// Returns the blurred copy of the given image.
	///
	/// - Parameters:
	///    - image: The image to blur.
	///    - radius: The blur radius.
	///
	/// - Returns: The blurred image.
	private func blurredImage(_ image: UIImage, radius: CGFloat) -> CGImage? {
		guard let cgImage = image.cgImage else { return nil }
		guard radius > 0.0 else { return cgImage }

		let inputImage = CIImage(cgImage: cgImage)
		guard let filter = CIFilter(name: "CIGaussianBlur") else { return cgImage }
		filter.setValue(inputImage.clampedToExtent(), forKey: kCIInputImageKey)
		filter.setValue(radius, forKey: kCIInputRadiusKey)

		guard let outputImage = filter.outputImage else { return cgImage }

		return Self.ciContext.createCGImage(outputImage, from: inputImage.extent)
	}

	/// Returns the end points of a linear gradient running at the given angle across a rectangle.
	///
	/// - Parameters:
	///    - rect: The rectangle the gradient covers.
	///    - angle: The angle of the gradient in degrees.
	///
	/// - Returns: The start and end points of the gradient.
	static func gradientPoints(in rect: CGRect, angle: CGFloat) -> (start: CGPoint, end: CGPoint) {
		let radians = angle * .pi / 180.0
		let direction = CGPoint(x: sin(radians), y: -cos(radians))
		let length = abs(rect.width * sin(radians)) + abs(rect.height * cos(radians))
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let offset = CGPoint(x: direction.x * length / 2.0, y: direction.y * length / 2.0)

		return (CGPoint(x: center.x - offset.x, y: center.y - offset.y), CGPoint(x: center.x + offset.x, y: center.y + offset.y))
	}
}
