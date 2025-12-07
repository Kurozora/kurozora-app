//
//  ReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that provides a custom reuse identifier for reusable views.
protocol ReusableView: AnyObject {
	// MARK: - Properties
	/// A string that identifies the purpose of the view.
	///
	/// The collection view identifies and queues reusable views using their reuse identifiers. The collection view sets this value when it first creates the view, and the value cannot be changed later. When your data source is prompted to provide a given view, it can use the reuse identifier to dequeue a view of the appropriate type.
	static var reuseID: String { get }
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell: ReusableView {
	static var reuseID: String {
		return String(describing: self)
	}
}

// MARK: - UITableViewCell
extension UITableViewCell: ReusableView {
	static var reuseID: String {
		return String(describing: self)
	}
}

// MARK: - UITableView
extension UITableView {
	/// Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
	///
	/// - Parameters:
	///    - identifier: A `ReusableView` class identifying the cell object to be reused.
	///    - indexPath: The index path specifying the location of the cell. Always specify the index path provided to you by your data source object. This method uses the index path to perform additional configuration based on the cell’s position in the table view.
	/// A UITableViewCell object with the associated reuse identifier. This method always returns a valid cell.
	///
	/// - Returns: The `UITableViewCell` object with the associated reuse identifier, or `nil` if the cell could not be dequeued as the correct type.
	///
	/// - Important: You must specify a cell with a matching identifier in your storyboard file. You may also register a class or nib file using the `register(_:forCellReuseIdentifier:)` or `register(_:forCellReuseIdentifier:)` method, but must do so before calling this method.
	func dequeueReusableCell<Identifier: ReusableView>(withIdentifier identifier: Identifier.Type, for indexPath: IndexPath) -> Identifier? where Identifier: UITableViewCell {
		self.dequeueReusableCell(withIdentifier: identifier.reuseID, for: indexPath) as? Identifier
	}
}

// MARK: - UICollectionView
extension UICollectionView {
	/// Dequeues a reusable cell object located by its identifier.
	///
	/// - Parameters:
	///    - identifier: A `ReusableView` class identifying the cell object to be reused.
	///    - indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.
	///
	/// - Returns: A valid `UICollectionReusableView` object, or `nil` if the cell could not be dequeued as the correct type.
	///
	/// - Important: You must register a class or nib file using the `register(_:forCellWithReuseIdentifier:) `or `register(_:forCellWithReuseIdentifier:)` method before calling this method.
	func dequeueReusableCell<Identifier: ReusableView>(withReuseIdentifier identifier: Identifier.Type, for indexPath: IndexPath) -> Identifier? where Identifier: UICollectionReusableView {
		self.dequeueReusableCell(withReuseIdentifier: identifier.reuseID, for: indexPath) as? Identifier
	}
}
