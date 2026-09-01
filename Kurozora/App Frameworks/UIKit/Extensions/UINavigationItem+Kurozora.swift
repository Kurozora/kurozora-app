//
//  UINavigationItem+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

extension UINavigationItem {
	// MARK: - Functions
	/// Hosts the given view in the navigation bar's bottom palette.
	///
	/// - Parameters:
	///    - contentView: The view to host.
	///    - height: The height the palette asks the navigation bar for.
	func setBottomPalette(contentView: UIView?, height: CGFloat) {
		let setterSelector = NSSelectorFromString(#obfuscated("_setBottomPalette:"))
		guard self.responds(to: setterSelector) else { return }

		guard let contentView = contentView else {
			self.perform(setterSelector, with: nil)
			return
		}

		guard let palette = self.makePalette(contentView: contentView) else { return }
		palette.setValue(height, forKey: #obfuscated("preferredHeight"))
		self.perform(setterSelector, with: palette)
	}

	/// Returns a palette hosting the given view.
	///
	/// - Parameter contentView: The view to host.
	///
	/// - Returns: The palette to hand to the navigation bar.
	private func makePalette(contentView: UIView) -> UIView? {
		guard let paletteClass = NSClassFromString(#obfuscated("_UINavigationBarPalette")) as? UIView.Type else { return nil }

		let initializerSelector = NSSelectorFromString(#obfuscated("initWithContentView:"))
		guard paletteClass.instancesRespond(to: initializerSelector) else { return nil }

		let allocated = paletteClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue()
		return allocated?.perform(initializerSelector, with: contentView)?.takeUnretainedValue() as? UIView
	}
}
