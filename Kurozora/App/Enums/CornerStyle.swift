//
//  CornerStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import CoreGraphics

extension KFillBarIndicator {
	// MARK: - Types
	/// The set of available corner style types.
	///
	/// ```swift
	/// case square
	/// case rounded
	/// case elliptical
	/// ```
	public enum CornerStyle {
		/// Corners are squared off.
		case square

		/// Corners are rounded.
		case rounded

		/// Corners are completely circular.
		case elliptical

		// MARK: - Functions
		/// Returns a `CGFloat` value indicating how much the corners should be rounded.
		///
		/// - Parameter frame: The frame that should be rounded.
		///
		/// - Returns: a `CGFloat` value indicating how much the corners should be rounded.
		func cornerRadius(for frame: CGRect) -> CGFloat {
			switch self {
			case .square:
				return 0.0
			case .rounded:
				return frame.size.height / 6.0
			case .elliptical:
				return frame.size.height / 2.0
			}
		}
	}
}
