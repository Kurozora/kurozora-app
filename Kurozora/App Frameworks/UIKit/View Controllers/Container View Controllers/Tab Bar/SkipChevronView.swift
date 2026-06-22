//
//  SkipChevronView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A double-triangle skip glyph that animates as a conveyor: on each skip the leading triangle shrinks
/// and slides out, the trailing one moves to full size in its place, and a new one grows in from behind.
@available(iOS 26.0, *)
final class SkipChevronView: UIView {
	// MARK: - Direction
	enum Direction {
		case backward, forward
	}

	// MARK: - Views
	private let triangles: [UIImageView]

	// MARK: - Properties
	private let direction: Direction

	/// The center-to-center distance between the two resting triangles.
	private let triangleSpacing: CGFloat = 9

	/// The scale of a triangle as it enters or exits at the edges.
	private let edgeScale: CGFloat = 0.25

	/// The roles of the triangles by index: front, back, then the off-screen spare.
	private var order = [0, 1, 2]

	private var isAnimating = false

	/// The sign of the travel: leading edge and motion are leftward for backward, rightward for forward.
	private var dir: CGFloat {
		self.direction == .backward ? -1 : 1
	}

	// MARK: - Initializers
	init(direction: Direction) {
		self.direction = direction
		let configuration = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
		let image = UIImage(systemName: "play.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
		self.triangles = (0 ..< 3).map { _ in
			let view = UIImageView(image: image)
			view.contentMode = .center
			return view
		}

		super.init(frame: .zero)
		self.isUserInteractionEnabled = false
		self.clipsToBounds = false
		self.triangles.forEach { self.addSubview($0) }
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override var intrinsicContentSize: CGSize {
		let size = self.triangles[0].intrinsicContentSize
		return CGSize(width: size.width + self.triangleSpacing, height: size.height)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		guard !self.isAnimating else { return }
		self.layoutAtRest()
	}

	// MARK: - Functions
	/// Runs one step of the conveyor.
	func animateSkip() {
		guard !self.isAnimating, self.bounds.width > 0 else { return }
		self.isAnimating = true
		self.place(self.order[2], offset: -self.dir * self.triangleSpacing * 1.6, scale: self.edgeScale, alpha: 0)

		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
			self.place(self.order[0], offset: self.dir * self.triangleSpacing * 1.6, scale: self.edgeScale, alpha: 0)
			self.place(self.order[1], offset: self.dir * self.triangleSpacing / 2, scale: 1, alpha: 1)
			self.place(self.order[2], offset: -self.dir * self.triangleSpacing / 2, scale: 1, alpha: 1)
		} completion: { _ in
			self.isAnimating = false
			self.order = [self.order[1], self.order[2], self.order[0]]
			self.layoutAtRest()
		}
	}

	private func layoutAtRest() {
		self.place(self.order[0], offset: self.dir * self.triangleSpacing / 2, scale: 1, alpha: 1)
		self.place(self.order[1], offset: -self.dir * self.triangleSpacing / 2, scale: 1, alpha: 1)
		self.place(self.order[2], offset: -self.dir * self.triangleSpacing * 1.6, scale: self.edgeScale, alpha: 0)
	}

	private func place(_ index: Int, offset: CGFloat, scale: CGFloat, alpha: CGFloat) {
		let view = self.triangles[index]
		let flip: CGFloat = self.direction == .backward ? -1 : 1
		view.center = CGPoint(x: self.bounds.midX + offset, y: self.bounds.midY)
		view.transform = CGAffineTransform(scaleX: flip * scale, y: scale)
		view.alpha = alpha
	}
}
