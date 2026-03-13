//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import PDFKit
import UIKit

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

	/// Saves the image to a temporary file with the specified maximum dimensions and compression quality.
	///
	/// - Parameters:
	///    - maxWidth: The maximum width allowed.
	///    - maxHeight: The maximum height allowed.
	///    - compressionQuality: The compression quality for JPEG encoding (0.0 to 1.0).
	///
	/// - Returns: The URL of the saved file, or `nil` if saving failed.
	func saveToTemporaryFile(maxWidth: CGFloat, maxHeight: CGFloat, compressionQuality: CGFloat = 0.8) -> URL? {
		let resizedImage = self.resized(maxWidth: maxWidth, maxHeight: maxHeight)

		guard let data = resizedImage.jpegData(compressionQuality: compressionQuality) else {
			return nil
		}

		let imageName = UUID().uuidString + ".jpg"
		let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)

		do {
			try data.write(to: imageURL, options: [.atomic])
			return imageURL
		} catch {
			print("Failed to save image: \(error)")
			return nil
		}
	}
}

extension URL {
	/// Loads the image from this URL, resizes it to the specified dimensions, and saves to a temporary file.
	///
	/// - Parameters:
	///    - maxWidth: The maximum width allowed.
	///    - maxHeight: The maximum height allowed.
	///    - compressionQuality: The compression quality for JPEG encoding (0.0 to 1.0).
	///
	/// - Returns: The URL of the resized image file, or `nil` if loading/resizing failed.
	func saveImageToTemporaryFile(maxWidth: CGFloat, maxHeight: CGFloat, compressionQuality: CGFloat = 0.8) -> URL? {
		guard let imageData = try? Data(contentsOf: self),
		      let image = UIImage(data: imageData)
		else {
			return nil
		}

		return image.saveToTemporaryFile(maxWidth: maxWidth, maxHeight: maxHeight, compressionQuality: compressionQuality)
	}
}
