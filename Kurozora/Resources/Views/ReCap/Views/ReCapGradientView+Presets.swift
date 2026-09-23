//
//  ReCapGradientView+Presets.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension ReCapGradientView {
	// MARK: - Properties
	/// The width below which the gradients use their compact metrics.
	private static let compactWidth: CGFloat = 1000.0

	/// The height of a page cluster relative to its width.
	static let pageClusterAspectRatio: CGFloat = 1.7

	// MARK: - Functions
	/// Returns the cluster drawn at the top of the Re:CAP page.
	///
	/// - Parameter pageWidth: The width of the page.
	///
	/// - Returns: The configured cluster.
	static func pageTop(pageWidth: CGFloat) -> [Blob] {
		let isWide = pageWidth >= 1260.0
		let clampedWidth: (CGFloat, CGSize) -> CGFloat = { fraction, size in
			min(max(size.width * fraction, 100.0), 200.0)
		}

		return [
			Blob(
				shape: .b,
				verticalAnchor: .top(0.05),
				horizontalAnchor: .trailing(0.02),
				width: { clampedWidth(0.27, $0) },
				aspectRatio: 2.216,
				scale: 4.0,
				flipsHorizontally: true
			),
			Blob(
				shape: .a,
				verticalAnchor: .top(isWide ? 0.05 : 0.092),
				horizontalAnchor: .trailing(isWide ? 0.0 : 0.005),
				width: { clampedWidth(0.32, $0) },
				aspectRatio: 1.365,
				scale: 2.4,
				flipsVertically: true,
				rotation: 169.0
			),
		]
	}

	/// Returns the cluster drawn at the bottom of the Re:CAP page.
	///
	/// - Returns: The configured cluster.
	static func pageBottom() -> [Blob] {
		return [
			Blob(
				shape: .d,
				verticalAnchor: .bottom(0.12),
				horizontalAnchor: .leading(0.24),
				width: { $0.width * 0.089 },
				aspectRatio: 2.909,
				scale: 9.0,
				flipsVertically: true
			),
			Blob(
				shape: .c,
				verticalAnchor: .bottom(-0.015),
				horizontalAnchor: .trailing(0.29),
				width: { $0.width * 0.1275 },
				aspectRatio: 2.535,
				scale: 7.0,
				flipsHorizontally: true
			),
		]
	}

	/// Returns the blur radius of a page cluster.
	///
	/// - Parameters:
	///    - pageWidth: The width of the page.
	///    - isTop: Whether the cluster sits at the top of the page.
	///
	/// - Returns: The blur radius.
	static func pageBlurRadius(pageWidth: CGFloat, isTop: Bool) -> CGFloat {
		guard pageWidth >= Self.compactWidth else { return pageWidth * 0.065 }
		return isTop ? 50.0 : 25.0
	}

	/// Returns the cluster drawn inside a genre card.
	///
	/// - Parameter pageWidth: The width of the page.
	///
	/// - Returns: The configured cluster.
	static func genreCard(pageWidth: CGFloat) -> [Blob] {
		let isCompact = pageWidth < Self.compactWidth

		return [
			Blob(shape: .e, verticalAnchor: .top(isCompact ? -0.03 : -0.07), horizontalAnchor: .leading(-0.015), width: { $0.width * 0.9 }, aspectRatio: 2.831, brightness: 0.9),
			Blob(shape: .f, verticalAnchor: .top(isCompact ? -0.03 : -0.06), horizontalAnchor: .leading(-0.053), width: { $0.width * 0.66 }, aspectRatio: 1.519),
			Blob(shape: .f, verticalAnchor: .top(isCompact ? 0.0 : -0.033), horizontalAnchor: .leading(-0.023), width: { $0.width * 0.303 }, aspectRatio: 1.519),
			Blob(shape: .g, verticalAnchor: .bottom(isCompact ? -0.32 : -0.69), horizontalAnchor: .trailing(-0.2), width: { $0.width * 0.9 }, aspectRatio: 1.408, opacity: 0.37),
			Blob(shape: .h, verticalAnchor: .bottom(isCompact ? -0.06 : -0.13), horizontalAnchor: .trailing(-0.2), width: { $0.width * 0.9 }, aspectRatio: 3.6, opacity: 0.41),
			Blob(shape: .i, verticalAnchor: .bottom(isCompact ? -0.18 : -0.4), horizontalAnchor: .trailing(-0.2), width: { $0.width * 0.9 }, aspectRatio: 1.961, opacity: 0.21),
		]
	}

	/// Returns the blur radius of a genre card cluster.
	///
	/// - Parameter pageWidth: The width of the page.
	///
	/// - Returns: The blur radius.
	static func genreCardBlurRadius(pageWidth: CGFloat) -> CGFloat {
		return pageWidth < Self.compactWidth ? 20.0 : 40.0
	}

	/// Returns the cluster drawn behind an entry of a comparison card.
	///
	/// - Parameter isPrevious: Whether the cluster sits behind the previous year's entry.
	///
	/// - Returns: The configured cluster.
	static func comparison(isPrevious: Bool) -> [Blob] {
		if isPrevious {
			return [
				Blob(shape: .f, verticalAnchor: .top(-0.1), horizontalAnchor: .leading(-0.19), width: { $0.width * 1.22 }, aspectRatio: 2.019, fill: .linear(angle: 229.0, locations: [0.3, 0.68]), opacity: 0.8),
			]
		}

		return [
			Blob(shape: .f, verticalAnchor: .top(-0.1), horizontalAnchor: .leading(-0.19), width: { $0.width }, aspectRatio: 1.519, fill: .linear(angle: 35.0, locations: [0.3, 0.68]), opacity: 0.8),
		]
	}
}
