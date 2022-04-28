//
//  ImageFormat.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

/// A set of available image formats.
///
/// ```
/// case png
/// case jpeg(CGFloat)
/// ```
public enum ImageFormat {
	// MARK: - Cases
	/// Indicates the image has a `png` format.
	case png

	/// Indicates the image has a `jpeg` format. This option also takes a compression value.
	case jpeg(CGFloat)
}
