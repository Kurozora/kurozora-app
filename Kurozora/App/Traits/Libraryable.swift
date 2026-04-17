//
//  Libraryable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A type whose library entry can be read and updated.
protocol Libraryable: AnyObject {
	/// The unique identifier of the model.
	var id: KurozoraItemID { get }

	/// The cached library attributes of the model.
	var libraryAttributes: LibraryAttributes? { get }

	/// Applies the given update to the model's library attributes.
	///
	/// - Parameter libraryUpdate: The update to merge into the library attributes.
	func updateLibrary(using libraryUpdate: LibraryUpdate)

	/// Toggles the favorite status of the model.
	///
	/// - Parameter viewController: The view controller used to present alerts, or `nil` to fall back to the top view controller.
	func toggleFavorite(on viewController: UIViewController?) async

	/// Toggles the reminder status of the model.
	///
	/// - Parameter viewController: The view controller used to present alerts, or `nil` to fall back to the top view controller.
	func toggleReminder(on viewController: UIViewController?) async
}

extension Show: Libraryable {
	var libraryAttributes: LibraryAttributes? { self.attributes.library }

	func updateLibrary(using libraryUpdate: LibraryUpdate) {
		self.attributes.library?.update(using: libraryUpdate)
	}
}

extension Literature: Libraryable {
	var libraryAttributes: LibraryAttributes? { self.attributes.library }

	func updateLibrary(using libraryUpdate: LibraryUpdate) {
		self.attributes.library?.update(using: libraryUpdate)
	}
}

extension Game: Libraryable {
	var libraryAttributes: LibraryAttributes? { self.attributes.library }

	func updateLibrary(using libraryUpdate: LibraryUpdate) {
		self.attributes.library?.update(using: libraryUpdate)
	}
}
