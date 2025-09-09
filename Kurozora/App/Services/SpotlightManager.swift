//
//  SpotlightManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices

final class SpotlightManager: NSObject {
	// MARK: - Properties
	static let shared = SpotlightManager()

	// MARK: - Initializers
	private override init() {
		super.init()
	}

	// MARK: - Functions
	/// Adds a searchable item to Spotlight index.
	func addToSpotlightSearch(contentAttributeSet: CSSearchableItemAttributeSet) {
		guard let title = contentAttributeSet.title else { return }
		let item = CSSearchableItem(uniqueIdentifier: title, domainIdentifier: "app.kurozora.tracker", attributeSet: contentAttributeSet)

		CSSearchableIndex.default().indexSearchableItems([item]) { error in
			if let error = error {
				print("----- Indexing error: \(error.localizedDescription)")
			} else {
				print("----- Search Title Added to Spotlight for \(title)")
			}
		}
	}

	/// Cleans all searchable items from Spotlight index.
	func cleanSpotlightSearch() {
		CSSearchableIndex.default().deleteAllSearchableItems { error in
			if let error = error {
				print("----- Failed to delete searchable items: \(error.localizedDescription)")
			} else {
				print("----- Successfully deleted all searchable items")
			}
		}
	}
}
