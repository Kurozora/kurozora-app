//
//  LocalLibraryEntry+Libraryable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Libraryable
extension LocalLibraryEntry: Libraryable {
	// MARK: - Properties
	var id: KurozoraItemID {
		return KurozoraItemID(self.trackableID)
	}

	var libraryAttributes: LibraryAttributes? {
		return LibraryStore.shared.effectiveLibrary(forTrackableID: self.trackableID, kind: self.kind)
	}

	// MARK: - Functions
	func toggleFavorite(on viewController: UIViewController?) async {
		guard let slug = User.current?.attributes.slug else { return }

		let isFavorited = self.libraryAttributes?.favoriteStatus == .favorited
		await LibraryOutbox.shared.enqueueSetFavorite(!isFavorited, trackableID: self.trackableID, userSlug: slug, kind: self.kind)
	}

	func toggleReminder(on viewController: UIViewController?) async {
		guard self.kind == .shows, let slug = User.current?.attributes.slug else { return }

		let isReminded = self.libraryAttributes?.reminderStatus == .reminded
		await LibraryOutbox.shared.enqueueSetReminder(!isReminded, trackableID: self.trackableID, userSlug: slug, kind: self.kind)
	}

	func toggleVisibility(on viewController: UIViewController?) async {
		await self.markAsHidden(!self.isHidden)
	}

	func addToLibrary(status: LibraryStatus) async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueSetStatus(status, trackableID: self.trackableID, userSlug: slug, kind: self.kind, seed: nil)
		ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: status))
	}
}
