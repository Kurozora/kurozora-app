//
//  ImageActivityItemProvider.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Kingfisher
import UIKit

/// A share-sheet item provider that resolves its image off the main thread.
final class ImageActivityItemProvider: UIActivityItemProvider, @unchecked Sendable {
	// MARK: - Properties
	/// The closure that resolves the image to share.
	private let imageProvider: @Sendable () -> UIImage?

	override var item: Any {
		return self.imageProvider() ?? (self.placeholderItem as Any)
	}

	// MARK: - Initializers
	/// Creates a provider that resolves its image using the given closure.
	///
	/// - Parameters:
	///    - placeholder: The image displayed until the resolved image is available.
	///    - imageProvider: A closure that returns the image to share.
	init(placeholder: UIImage, imageProvider: @escaping @Sendable () -> UIImage?) {
		self.imageProvider = imageProvider
		super.init(placeholderItem: placeholder)
	}

	/// Creates a provider that loads its image from the given URL.
	///
	/// - Parameters:
	///    - urlString: The URL string of the image to load.
	///    - placeholder: The image displayed until the loaded image is available.
	convenience init(urlString: String?, placeholder: UIImage) {
		self.init(placeholder: placeholder) {
			ImageActivityItemProvider.loadImage(for: urlString)
		}
	}

	// MARK: - Functions
	/// Loads the image at the given URL.
	///
	/// - Parameter urlString: The URL string of the image to load.
	///
	/// - Returns: The loaded image.
	static func loadImage(for urlString: String?) -> UIImage? {
		guard let urlString = urlString, !urlString.isEmpty, let imageURL = URL(string: urlString) else {
			return nil
		}

		let semaphore = DispatchSemaphore(value: 0)

		KingfisherManager.shared.retrieveImage(with: imageURL, options: [.callbackQueue(.untouch)]) { _ in
			semaphore.signal()
		}
		semaphore.wait()

		return ImageCache.default.retrieveImageInMemoryCache(forKey: imageURL.absoluteString)
	}
}
