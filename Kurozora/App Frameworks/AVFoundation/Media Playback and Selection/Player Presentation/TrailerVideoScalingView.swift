//
//  TrailerVideoScalingView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import WebKit

/// A view that renders the web view's fixed-size page scaled to fill its bounds.
final class TrailerVideoScalingView: UIView {
	// MARK: - Properties
	/// The distance the page overshoots each edge, keeping encoder fringes clipped.
	private static let edgeOverscan: CGFloat = 2.0

	/// The size the page lays out at.
	private let referenceSize: CGSize

	/// The web view rendering the page.
	private let webView: WKWebView

	// MARK: - Initializers
	/// Creates a view that hosts the given web view.
	///
	/// - Parameters:
	///    - webView: The web view rendering the page.
	///    - referenceSize: The size the page lays out at.
	init(webView: WKWebView, referenceSize: CGSize) {
		self.webView = webView
		self.referenceSize = referenceSize
		super.init(frame: .zero)

		self.clipsToBounds = true
		self.addSubview(webView)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		let size = self.bounds.size
		guard size.width > 0, size.height > 0 else { return }

		let scale = min(
			(size.width + Self.edgeOverscan * 2.0) / self.referenceSize.width,
			(size.height + Self.edgeOverscan * 2.0) / self.referenceSize.height
		)

		self.webView.transform = .identity
		self.webView.bounds = CGRect(origin: .zero, size: self.referenceSize)
		self.webView.transform = CGAffineTransform(scaleX: scale, y: scale)
		self.webView.center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
	}
}
