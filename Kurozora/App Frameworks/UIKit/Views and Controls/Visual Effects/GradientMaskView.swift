//
//  GradientMaskView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view backed by a `CAGradientLayer`, designed to be applied to another view as its `mask` to fade or shape it using a gradient.
class GradientMaskView: UIView {
	// MARK: - Properties
	/// The gradient layer used to render the gradient background.
	lazy var gradientLayer: CAGradientLayer? = self.layer as? CAGradientLayer

	/// Overrides the default layer class to use CAGradientLayer.
	override open class var layerClass: AnyClass {
		return CAGradientLayer.classForCoder()
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.isUserInteractionEnabled = false
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.isUserInteractionEnabled = false
	}

	// MARK: - Factories
	/// A vertical top-to-bottom mask: fully opaque at the top through
	/// `solidUntil`, fading to fully transparent at `endsAt`.
	///
	/// Mirrors the UpNextWidget hero banner fade. Defaults to
	/// `solidUntil: 0.4`, `endsAt: 0.95`.
	///
	/// - Parameters:
	///   - solidUntil: Location (0...1) where the opaque region ends.
	///   - endsAt: Location (0...1) where the transparent region begins.
	static func bottomFade(solidUntil: CGFloat = 0.4, endsAt: CGFloat = 0.95) -> GradientMaskView {
		let view = GradientMaskView()
		view.gradientLayer?.colors = [
			UIColor.white.cgColor,
			UIColor.white.cgColor,
			UIColor.clear.cgColor
		]
		view.gradientLayer?.locations = [
			0.0,
			NSNumber(value: Float(solidUntil)),
			NSNumber(value: Float(endsAt))
		]
		view.gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
		view.gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
		return view
	}

	/// A vertical mask transparent at both edges: fading in through `topSolidFrom` and fading out from `bottomSolidUntil`.
	///
	/// - Parameters:
	///   - topSolidFrom: Location (0...1) where the opaque region begins.
	///   - bottomSolidUntil: Location (0...1) where the opaque region ends.
	static func verticalEdgeFade(topSolidFrom: CGFloat = 0.08, bottomSolidUntil: CGFloat = 0.92) -> GradientMaskView {
		let view = GradientMaskView()
		view.gradientLayer?.colors = [
			UIColor.clear.cgColor,
			UIColor.white.cgColor,
			UIColor.white.cgColor,
			UIColor.clear.cgColor
		]
		view.gradientLayer?.locations = [
			0.0,
			NSNumber(value: Float(topSolidFrom)),
			NSNumber(value: Float(bottomSolidUntil)),
			1.0
		]
		view.gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
		view.gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
		return view
	}

	/// A vertical top-to-bottom mask like ``topFade(clearUntil:solidFrom:)``, weighted towards
	/// the start of the ramp.
	///
	/// - Parameters:
	///   - midpointOpacity: The opacity halfway through the ramp. Above `0.5` front-loads it.
	///   - solidFrom: Location (0...1) where the opaque region begins.
	static func easedTopFade(midpointOpacity: CGFloat = 0.65, solidFrom: CGFloat = 1) -> GradientMaskView {
		let view = GradientMaskView()
		view.gradientLayer?.colors = [
			UIColor.clear.cgColor,
			UIColor.white.withAlphaComponent(midpointOpacity).cgColor,
			UIColor.white.cgColor
		]
		view.gradientLayer?.locations = [
			0.0,
			NSNumber(value: Float(solidFrom / 2)),
			NSNumber(value: Float(solidFrom))
		]
		view.gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
		view.gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
		return view
	}

	/// A vertical top-to-bottom mask: fully transparent through `clearUntil`, fading to fully opaque at `solidFrom`.
	///
	/// - Parameters:
	///   - clearUntil: Location (0...1) where the transparent region ends.
	///   - solidFrom: Location (0...1) where the opaque region begins.
	static func topFade(clearUntil: CGFloat = 0, solidFrom: CGFloat = 0.4) -> GradientMaskView {
		let view = GradientMaskView()
		view.gradientLayer?.colors = [
			UIColor.clear.cgColor,
			UIColor.clear.cgColor,
			UIColor.white.cgColor
		]
		view.gradientLayer?.locations = [
			0.0,
			NSNumber(value: Float(clearUntil)),
			NSNumber(value: Float(solidFrom))
		]
		view.gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
		view.gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
		return view
	}
}

extension UIView {
	private enum AssociatedKeys {
		static var gradientMaskObservation: UInt8 = 0
	}

	/// Attaches a `GradientMaskView` as this view's `mask` and keeps the
	/// mask's frame synchronized with the receiver's bounds via layer KVO.
	///
	/// Calling this again replaces any previously attached mask and its
	/// observation. The observation lifetime is tied to the receiver via
	/// associated-object storage, so it is released automatically when the
	/// receiver is deallocated.
	///
	/// - Parameter maskView: The gradient mask view to attach.
	func applyGradientMask(_ maskView: GradientMaskView) {
		maskView.frame = self.bounds
		self.mask = maskView

		let observation = self.layer.observe(\.bounds, options: [.new]) { [weak maskView] layer, _ in
			guard let maskView = maskView else { return }
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			maskView.frame = layer.bounds
			CATransaction.commit()
		}
		objc_setAssociatedObject(self, &AssociatedKeys.gradientMaskObservation, observation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
}
