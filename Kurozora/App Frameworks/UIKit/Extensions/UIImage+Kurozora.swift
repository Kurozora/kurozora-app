//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Kingfisher
import PDFKit
import UIKit

extension UIImage {
	// MARK: - Functions
	/// Returns the preview artwork for the app icon with the given name.
	///
	/// Alternative app icons stop being loadable by their `appiconset` name on iOS 18, so each
	/// one ships a matching `<name> Preview` image set. The primary icon has no `appiconset` —
	/// its name varies per build configuration — so its artwork is referenced directly instead.
	///
	/// - Parameter appIconName: The app icon name as listed in `App Icons.plist`.
	///
	/// - Returns: The app icon's preview artwork.
	static func appIconPreview(named appIconName: String) -> UIImage? {
		if appIconName == UserSettings.defaultAppIcon {
			return .kurozora
		}

		return UIImage(named: "\(appIconName) Preview")
	}

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

	/// Loads the image at the given URL through the shared image cache.
	///
	/// - Parameter urlString: The URL string of the image to load.
	///
	/// - Returns: The loaded image.
	static func load(from urlString: String?) async -> UIImage? {
		guard let urlString = urlString, !urlString.isEmpty, let imageURL = URL(string: urlString) else {
			return nil
		}

		return try? await KingfisherManager.shared.retrieveImage(with: imageURL).image
	}

	/// Merges the image with another image side by side into a single image.
	///
	/// - Parameter trailingImage: The image drawn on the trailing half.
	///
	/// - Returns: The combined image.
	func merged(with trailingImage: UIImage) -> UIImage {
		let size = CGSize(width: self.size.width + trailingImage.size.width, height: max(self.size.height, trailingImage.size.height))
		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { _ in
			self.draw(in: CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
			trailingImage.draw(in: CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
		}
	}
}
