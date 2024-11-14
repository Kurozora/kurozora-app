//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import PDFKit

extension UIImage {
	// MARK: - Functions
	/// Convert UIImage to Base-64.
	///
	/// - Parameter format: The format of the image. `.heic` format defaults to `.png` pre iOS 17.0.
	///
	/// - Returns: the Base-64 encoded string.
	func toBase64(format: ImageFormat) -> String? {
		var imageData: Data?
		switch format {
		case .png:
			imageData = self.pngData()
		case .jpeg(let compression):
			imageData = self.jpegData(compressionQuality: compression)
		case .heic:
			if #available(iOS 17.0, *) {
				imageData = self.heicData()
			} else {
				imageData = self.pngData()
			}
		case .pdf:
			imageData = self.pdfData()
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

	/// Returns a data object that contains the specified image in `PDF` format.
	///
	/// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
	///
	/// - Returns: A data object containing the PDF data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
	func pdfData() -> Data? {
		let pdfDocument = PDFDocument()
		guard let pdfPage = PDFPage(image: self) else { return nil }

		pdfDocument.insert(pdfPage, at: 0)

		return pdfDocument.dataRepresentation()
	}
}
