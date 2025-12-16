//
//  DiffableDataSourceProtocol.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that abstracts the common functionality of diffable data sources for collection views and table views.
@MainActor
protocol DiffableDataSourceProtocol {
	// MARK: - Associated Types
	/// The type that identifies sections in the data source.
	associatedtype SectionIdentifierType: Hashable
	/// The type that identifies items in the data source.
	associatedtype ItemIdentifierType: Hashable

	/// Returns a representation of the current state of the data in the collection or table view.
	///
	/// - Returns: A snapshot containing section and item identifiers in the order that they appear in the UI.
	@preconcurrency
	func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>

	/// Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes and executing a completion handler.
	///
	/// The diffable data source computes the difference between the collection or table view’s current state and the new state in the applied snapshot, which is an O(_n_) operation, where n is the number of items in the snapshot.
	///
	/// You can safely call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.
	///
	/// - Parameters:
	///    - snapshot: The snapshot that reflects the new state of the data in the collection or table view.
	///    - animatingDifferences: If [`true`](https://developer.apple.com/documentation/swift/true), the system animates the updates to the collection or table view. If [`false`](https://developer.apple.com/documentation/swift/false), the system doesn’t animate the updates to the collection or table view.
	///    - completion: A closure to execute when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue.
	@preconcurrency
	func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool, completion: (() -> Void)?)
}

// MARK: - UICollectionViewDiffableDataSource
extension UICollectionViewDiffableDataSource: DiffableDataSourceProtocol {}

// MARK: - UITableViewDiffableDataSource
extension UITableViewDiffableDataSource: DiffableDataSourceProtocol {}
