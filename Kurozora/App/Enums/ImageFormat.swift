//
//  ImageFormat.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import CoreGraphics

/// A set of available image formats.
///
/// ```
/// case png
/// case jpeg(_ compressionQuality:)
/// case heic
/// case pdf
/// ```
public enum ImageFormat {
	// MARK: - Cases
	/// Indicates the image has a `png` format.
	case png

	/// Indicates the image has a `jpeg` format. This option also takes a compression value.
	case jpeg(_ compressionQuality: CGFloat)

	/// Indicates the image has a `hec` format.
	case heic

	/// Indicates the image has a `PDF` format. Uses `png` format for the image.
	case pdf
}
