//
//  FlareView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view that arcs a soft, chromatically fringed crescent of light across its bounds.
class FlareView: UIView {
	// MARK: - Views
	/// The blurred crescent.
	private let crescentImageView = UIImageView()

	// MARK: - Properties
	/// The tint of the fringe drawn above the core of the crescent.
	var coolFringeColor: UIColor = UIColor(red: 0.38, green: 0.56, blue: 1.0, alpha: 1.0) {
		didSet {
			self.invalidateArtwork()
		}
	}

	/// The tint of the fringe drawn below the core of the crescent.
	var warmFringeColor: UIColor = UIColor(red: 1.0, green: 0.42, blue: 0.52, alpha: 1.0) {
		didSet {
			self.invalidateArtwork()
		}
	}

	/// Whether the crescent should be breathing.
	private var isAnimating = false

	/// The bounds size the artwork was last rendered for.
	private var renderedSize: CGSize = .zero

	/// The rectangle the crescent is drawn into.
	private var arcRect: CGRect {
		return CGRect(x: 0, y: self.bounds.height * 0.16, width: self.bounds.width, height: self.bounds.height * 0.34)
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	isolated deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		guard self.bounds.width > 0, self.bounds.height > 0 else { return }
		guard self.bounds.size != self.renderedSize else { return }
		self.renderedSize = self.bounds.size

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.crescentImageView.frame = self.bounds
		self.crescentImageView.image = self.makeCrescentImage()
		CATransaction.commit()

		self.updateAnimations()
	}

	// MARK: - Functions
	/// Starts the crescent breathing, unless the user has asked for reduced motion.
	func startAnimating() {
		self.isAnimating = true
		self.updateAnimations()
	}

	/// Stops the crescent breathing.
	func stopAnimating() {
		self.isAnimating = false
		self.updateAnimations()
	}

	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.isUserInteractionEnabled = false
		self.backgroundColor = .clear
		self.addSubview(self.crescentImageView)

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleMotionEnvironmentChange), name: UIApplication.didBecomeActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleMotionEnvironmentChange), name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
	}

	/// Discards the rendered artwork so the next layout pass rebuilds it.
	private func invalidateArtwork() {
		self.renderedSize = .zero
		self.setNeedsLayout()
	}

	/// Returns a point in the given rectangle from a pair of unit coordinates.
	///
	/// - Parameters:
	///    - rect: The rectangle the coordinates are relative to.
	///    - horizontal: The horizontal unit coordinate.
	///    - vertical: The vertical unit coordinate.
	///
	/// - Returns: The resolved point.
	private func point(in rect: CGRect, _ horizontal: CGFloat, _ vertical: CGFloat) -> CGPoint {
		return CGPoint(x: rect.minX + rect.width * horizontal, y: rect.minY + rect.height * vertical)
	}

	/// Returns the crescent as two cubic curves sharing both endpoints, which tapers it to a point at each tip.
	///
	/// - Parameter rect: The rectangle the crescent is drawn into.
	///
	/// - Returns: The closed crescent.
	private func crescentPath(in rect: CGRect) -> UIBezierPath {
		let path = UIBezierPath()
		path.move(to: self.point(in: rect, 0.0, 0.58))
		path.addCurve(to: self.point(in: rect, 1.0, 0.10), controlPoint1: self.point(in: rect, 0.34, 0.98), controlPoint2: self.point(in: rect, 0.70, 0.80))
		path.addCurve(to: self.point(in: rect, 0.0, 0.58), controlPoint1: self.point(in: rect, 0.70, 0.62), controlPoint2: self.point(in: rect, 0.34, 0.78))
		path.close()
		return path
	}

	/// Renders the crescent and its two fringes, additively blended and blurred.
	///
	/// - Returns: The crescent artwork.
	private func makeCrescentImage() -> UIImage? {
		let rect = self.arcRect
		let path = self.crescentPath(in: rect)
		let fringeOffset = rect.height * 0.09

		let format = UIGraphicsImageRendererFormat.default()
		format.opaque = false

		let bands: [(color: UIColor, offset: CGFloat)] = [
			(self.coolFringeColor.withAlphaComponent(0.60), -fringeOffset),
			(self.warmFringeColor.withAlphaComponent(0.55), fringeOffset),
			(UIColor.white.withAlphaComponent(0.70), 0)
		]

		let crescent = UIGraphicsImageRenderer(size: self.bounds.size, format: format).image { context in
			for band in bands {
				context.cgContext.saveGState()
				context.cgContext.translateBy(x: 0, y: band.offset)
				band.color.setFill()
				path.fill(with: .plusLighter, alpha: 1.0)
				context.cgContext.restoreGState()
			}
		}

		return GaussianBlur.blurred(crescent, radius: rect.height * 0.10)
	}

	/// Rebuilds the breathing for the current bounds, leaving the crescent still when the user has asked for reduced motion.
	private func updateAnimations() {
		self.crescentImageView.layer.removeAllAnimations()

		guard self.isAnimating, !UIAccessibility.isReduceMotionEnabled else { return }
		guard self.bounds.width > 0, self.bounds.height > 0 else { return }

		let breathe = CABasicAnimation(keyPath: "transform.scale")
		breathe.fromValue = 1.0
		breathe.toValue = 1.06
		breathe.duration = 11.0
		breathe.autoreverses = true
		breathe.repeatCount = .greatestFiniteMagnitude
		breathe.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		self.crescentImageView.layer.add(breathe, forKey: "breathe")
	}

	@objc private func handleMotionEnvironmentChange() {
		self.updateAnimations()
	}
}
