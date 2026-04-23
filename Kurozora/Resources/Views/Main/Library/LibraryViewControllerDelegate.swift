//
//  LibraryViewControllerDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol LibraryViewControllerDelegate: AnyObject {
	/// Tells your `LibraryViewControllerDelegate` to sort the library with the specified sort type.
	///
	/// - Parameter sortType: The sort type by which the library should be sorted.
	func sortLibrary(by sortType: LibrarySortType, option: LibrarySortOption)

	/// Tells your `LibraryViewControllerDelegate` the current library kind value changed.
	func libraryViewController(_ view: LibraryViewController, didChange libraryKind: LibraryKind)
}

protocol LibraryViewControllerDataSource: AnyObject {
	/// Tells your `LibraryViewControllerDataSource` the current sort value used to sort the items in the library.
	///
	/// - Returns: The current sort value used to sort the items in the library.
	func sortValue() -> LibrarySortType

	/// Tells your `LibraryViewControllerDataSource` the current sort option value used to sort the items in the library.
	///
	/// - Returns: The current sort option value used to sort the items in the library.
	func sortOptionValue() -> LibrarySortOption
}
