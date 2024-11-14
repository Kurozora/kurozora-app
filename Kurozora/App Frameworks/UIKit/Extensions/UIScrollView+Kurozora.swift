//
//  UIScrollView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UIScrollView {
	// MARK: - Properties
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
