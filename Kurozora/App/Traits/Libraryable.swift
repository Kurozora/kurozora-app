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
@MainActor
protocol Libraryable {
	/// The unique identifier of the model.
	var id: KurozoraItemID { get }

	/// The authenticated user's library state for the model.
	var libraryAttributes: LibraryAttributes? { get }

	/// Toggles the favorite status of the model.
	///
	/// - Parameter viewController: The view controller used to present alerts, or `nil` to fall back to the top view controller.
	func toggleFavorite(on viewController: UIViewController?) async

	/// Toggles the reminder status of the model.
	///
	/// - Parameter viewController: The view controller used to present alerts, or `nil` to fall back to the top view controller.
	func toggleReminder(on viewController: UIViewController?) async

	/// Toggles the public-visibility status of the model.
	///
	/// - Parameter viewController: The view controller used to present alerts, or `nil` to fall back to the top view controller.
	func toggleVisibility(on viewController: UIViewController?) async

	/// Adds the model to the user's library with the given status.
	///
	/// - Parameter status: The library status to assign.
	func addToLibrary(status: LibraryStatus) async

	/// Removes the model from the user's library.
	func removeFromLibrary() async
}

extension Show: Libraryable {}

extension Literature: Libraryable {}

extension Game: Libraryable {}
