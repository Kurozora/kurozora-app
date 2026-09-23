//
//  ReCapBackdropView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The gradient glows at the top and bottom of the Re:CAP page.
@MainActor
final class ReCapBackdrop {
	// MARK: - Views
	private let topGradientView = ReCapGradientView()

	private let bottomGradientView = ReCapGradientView()

	// MARK: - Properties
	/// The recap colors the glows are painted with.
	var colors: [UIColor] = [] {
		didSet {
			guard self.colors != oldValue else { return }
			self.topGradientView.colors = self.colors
			self.bottomGradientView.colors = self.colors
		}
	}

	/// The height the bottom glow is stretched by above the bottom of the page.
	private static let bottomGlowExtraHeight: CGFloat = 150.0

	/// The width the glows were configured for.
	private var configuredWidth: CGFloat = 0.0

	// MARK: - Initializers
	init() {
		self.bottomGradientView.clipping = .vertical
	}

	// MARK: - Functions
	/// Places the glows behind the content of the given scroll view.
	///
	/// - Parameter scrollView: The scroll view of the page.
	func install(in scrollView: UIScrollView) {
		scrollView.insertSubview(self.bottomGradientView, at: 0)
		scrollView.insertSubview(self.topGradientView, at: 0)
	}

	/// Positions the glows for the current scroll position of the given scroll view.
	///
	/// - Parameter scrollView: The scroll view of the page.
	func layout(in scrollView: UIScrollView) {
		let width = scrollView.bounds.width
		guard width > 0.0 else { return }

		let clusterHeight = (width / ReCapGradientView.pageClusterAspectRatio).rounded()
		let insets = scrollView.adjustedContentInset
		let offsetY = scrollView.contentOffset.y

		if width != self.configuredWidth {
			self.configuredWidth = width
			self.topGradientView.blobs = ReCapGradientView.pageTop(pageWidth: width)
			self.topGradientView.blurRadius = { _ in ReCapGradientView.pageBlurRadius(pageWidth: width, isTop: true) }
			self.bottomGradientView.blobs = ReCapGradientView.pageBottom()
			self.bottomGradientView.blurRadius = { _ in ReCapGradientView.pageBlurRadius(pageWidth: width, isTop: false) }
		}

		let topY = min(offsetY, -insets.top)
		self.topGradientView.frame = CGRect(x: scrollView.contentOffset.x, y: topY, width: width, height: clusterHeight)

		let pageBottom = max(scrollView.contentSize.height + insets.bottom, scrollView.bounds.height - insets.top)
		let screenBottom = offsetY + scrollView.bounds.height
		let stretch = max(screenBottom - pageBottom, 0.0)

		let bottomHeight = clusterHeight + Self.bottomGlowExtraHeight + stretch
		let bottomScale = bottomHeight / clusterHeight
		let bottomShift = stretch - (bottomHeight - clusterHeight) / 2.0

		self.bottomGradientView.transform = .identity
		self.bottomGradientView.frame = CGRect(x: scrollView.contentOffset.x, y: pageBottom - clusterHeight, width: width, height: clusterHeight)
		self.bottomGradientView.transform = CGAffineTransform(translationX: 0.0, y: bottomShift).scaledBy(x: 1.0, y: bottomScale)

		scrollView.sendSubviewToBack(self.bottomGradientView)
		scrollView.sendSubviewToBack(self.topGradientView)
	}
}
