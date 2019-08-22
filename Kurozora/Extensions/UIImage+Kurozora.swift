//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

/**
	A list of image formats.

	```
	case png
	case jpeg(CGFloat)
	```
*/
public enum ImageFormat {
	/// Indicates the image has a `png` format.
	case png

	/// Indicates the image has a `jpeg` format. This option also takes a compression value.
	case jpeg(CGFloat)
}

extension UIImage {
	/**
		Convert UIImage to Base-64.

		- Parameter format: The format of the image.

		- Returns: the Base-64 encoded string.
	*/
	public func toBase64(format: ImageFormat) -> String? {
		var imageData: Data?
		switch format {
		case .png:
			imageData = self.pngData()
		case .jpeg(let compression):
			imageData = self.jpegData(compressionQuality: compression)
		}
		return imageData?.base64EncodedString()
	}
}
