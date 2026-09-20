//
//  UIScrollView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

extension UIScrollView {
	// MARK: - Properties
	/// A boolean indicating whether the scroll edge effect styling is installed.
	private static var isScrollEdgeEffectStylingInstalled = false

	/// A boolean indicating if the scrollview is at the top
	var isAtTop: Bool {
		return contentOffset.y <= verticalOffsetForTop
	}

	/// A boolean indicating if the scrollview is at the bottom
	var isAtBottom: Bool {
		return contentOffset.y >= verticalOffsetForBottom
	}

	/// The top vertical offset for the scrollview
	var verticalOffsetForTop: CGFloat {
		let topInset = contentInset.top
		return -topInset
	}

	/// The bottom vertical offset for the scrollview
	var verticalOffsetForBottom: CGFloat {
		let scrollViewHeight = bounds.height
		let scrollContentSizeHeight = contentSize.height
		let bottomInset = contentInset.bottom
		let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
		return scrollViewBottomOffset
	}

	// MARK: - Functions
	/// Styles the scroll edge effect of every scroll view in the app.
	static func installScrollEdgeEffectStyling() {
		guard #available(iOS 27.0, macCatalyst 27.0, *) else { return }
		guard !self.isScrollEdgeEffectStylingInstalled else { return }

		self.isScrollEdgeEffectStylingInstalled = true

		self.routeLayout(of: UIScrollView.self, through: #selector(UIScrollView.styledLayoutSubviews))
		self.routeLayout(of: UITableView.self, through: #selector(UIScrollView.styledTableLayoutSubviews))
	}

	/// Routes the given class's layout through the app's scroll edge effect styling.
	///
	/// - Parameters:
	///    - scrollViewClass: The class whose layout is routed.
	///    - styledSelector: The selector standing in for the class's layout.
	private static func routeLayout(of scrollViewClass: AnyClass, through styledSelector: Selector) {
		let originalSelector = #selector(UIScrollView.layoutSubviews)

		guard
			let inheritedStyledMethod = class_getInstanceMethod(UIScrollView.self, styledSelector),
			let originalMethod = class_getInstanceMethod(scrollViewClass, originalSelector)
		else { return }

		let styledImplementation = method_getImplementation(inheritedStyledMethod)
		let styledEncoding = method_getTypeEncoding(inheritedStyledMethod)

		class_addMethod(scrollViewClass, styledSelector, styledImplementation, styledEncoding)

		guard let styledMethod = class_getInstanceMethod(scrollViewClass, styledSelector) else { return }

		if class_addMethod(scrollViewClass, originalSelector, styledImplementation, styledEncoding) {
			class_replaceMethod(scrollViewClass, styledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
		} else {
			method_exchangeImplementations(originalMethod, styledMethod)
		}
	}

	/// Reapplies the selected scroll edge effect style to every scroll view the app has loaded.
	static func restyleScrollEdgeEffects() {
		guard #available(iOS 27.0, macCatalyst 27.0, *) else { return }

		var views: [UIView] = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }

		var viewControllers = views.compactMap { ($0 as? UIWindow)?.rootViewController }

		while let viewController = viewControllers.popLast() {
			if let view = viewController.viewIfLoaded {
				views.append(view)
			}

			viewControllers.append(contentsOf: viewController.children)

			if let presented = viewController.presentedViewController {
				viewControllers.append(presented)
			}
		}

		while let view = views.popLast() {
			(view as? UIScrollView)?.applyScrollEdgeEffectStyle()
			views.append(contentsOf: view.subviews)
		}
	}

	/// Applies the scroll edge effect style to the top edge.
	@available(iOS 27.0, macCatalyst 27.0, *)
	private func applyScrollEdgeEffectStyle() {
		#if targetEnvironment(macCatalyst)
		let style = UIScrollEdgeEffect.Style.automatic
		#else
		let style = ScrollEdgeEffectStyleOption.current.style
		#endif

		if self.topEdgeEffect.style !== style {
			self.topEdgeEffect.style = style
		}

		#if targetEnvironment(macCatalyst)
		self.syncScrollEdgeEffectVisibility()
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// Shows the scroll edge effect while content sits behind the bars.
	private func syncScrollEdgeEffectVisibility() {
		guard
			let interactionClass = NSClassFromString(#obfuscated("_UIScrollEdgeEffectViewInteraction")),
			let interaction = self.interactions.lazy.compactMap({ $0 as? NSObject }).first(where: { $0.isKind(of: interactionClass) })
		else { return }

		let hoverKey = #obfuscated("isMouseHovering")
		let isContentBehindBars = self.contentOffset.y > -self.adjustedContentInset.top

		guard interaction.value(forKey: hoverKey) as? Bool != isContentBehindBars else { return }

		interaction.setValue(isContentBehindBars, forKey: hoverKey)
	}
	#endif

	/// Styles the scroll edge effect as the scroll view lays out.
	@objc private dynamic func styledLayoutSubviews() {
		self.styledLayoutSubviews()

		guard #available(iOS 27.0, macCatalyst 27.0, *) else { return }

		self.applyScrollEdgeEffectStyle()
	}

	/// Styles the scroll edge effect as the table view lays out.
	@objc private dynamic func styledTableLayoutSubviews() {
		self.styledTableLayoutSubviews()

		guard #available(iOS 27.0, macCatalyst 27.0, *) else { return }

		self.applyScrollEdgeEffectStyle()
	}

	/// Take a screenshot of the view and return it as a `UIImage`.
	///
	/// - Parameter fullScreen: A boolean value to indicate whether the screenshot should be taken of the entire scroll content or just the visible part.
	/// - Parameter format: A `ScreenshotFormat` value to indicate the format of the screenshot. Default value is `.png`. `.heic` format defaults to `.png` pre iOS 17.0.
	///
	/// - Returns: A `UIImage` of the view's content.
	func screenshot(fullScreen: Bool, format: ImageFormat = .png) -> Data? {
		let size = fullScreen ? self.contentSize : self.bounds.size

		// Save the current state of content offset and frame
		let savedContentOffset = self.contentOffset
		let savedFrame = self.frame

		// Adjust the view for rendering
		self.contentOffset = .zero
		self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		// Use UIGraphicsImageRenderer with the provided CGContext
		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image { context in
			self.layer.render(in: context.cgContext)
		}

		// Restore the original state
		self.contentOffset = savedContentOffset
		self.frame = savedFrame

		switch format {
		case .png:
			return image.pngData()
		case .jpeg(let compressionQuality):
			return image.jpegData(compressionQuality: compressionQuality)
		case .heic:
			if #available(iOS 17.0, *) {
				return image.heicData()
			} else {
				return image.pngData()
			}
		case .pdf:
			return image.pdfData()
		}
	}
}
