//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIImage {
	// MARK: - Functions
	/// Convert UIImage to Base-64.
	///
	/// - Parameter format: The format of the image.
	///
	/// - Returns: the Base-64 encoded string.
	func toBase64(format: ImageFormat) -> String? {
		var imageData: Data?
		switch format {
		case .png:
			imageData = self.pngData()
		case .jpeg(let compression):
			imageData = self.jpegData(compressionQuality: compression)
		}
		return imageData?.base64EncodedString()
	}

	/// Returns whether the given image is equal to the current image.
	///
	/// - Parameter image: The UIImage object to compare the current image with.
	///
	/// - Returns: whether the given image is equal to the current image.
	func isEqual(to image: UIImage?) -> Bool {
		guard let image = image else { return false }
		return self.pngData() == image.pngData()
	}
}
