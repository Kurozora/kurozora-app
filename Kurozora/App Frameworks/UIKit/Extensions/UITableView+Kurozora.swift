//
//  UITableView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableView {
	// MARK: - Properties
	/// Number of all rows in all sections of tableView.
	///
	/// - Returns: The count of all rows in the tableView.
	var numberOfRows: Int {
		var section = 0
		var rowCount = 0
		while section < self.numberOfSections {
			rowCount += self.numberOfRows(inSection: section)
			section += 1
		}
		return rowCount
	}

	// MARK: - Functions
	// Set table header view & add Auto layout.
	func setTableHeaderView(headerView: UIView?) {
		guard let headerView = headerView else { return }
		headerView.translatesAutoresizingMaskIntoConstraints = false

		// Set first.
		self.tableHeaderView = headerView

		// Then setup AutoLayout.
		headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
		headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
	}

	/// Update header view's frame.
	func updateHeaderViewFrame() {
		guard let headerView = self.tableHeaderView else { return }

		// Update the size of the header based on its internal content.
		headerView.layoutIfNeeded()

		// Trigger table view to know that header should be updated.
		let header = self.tableHeaderView
		self.tableHeaderView = header
	}

	/// Safely scrolls through the table view until a row that an index path identifies is at a particular location on the screen.
	///
	/// Invoking this method doesn’t cause the delegate to receive a [`scrollViewDidScroll(_:)`](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/scrollviewdidscroll(_:)) message, as is normal for programmatically invoked user interface operations.
	///
	///
	/// - Parameters:
	///    - indexPath:
	///        An index path that identifies a row in the table view by its row index and its section index.
	///
	///        `NSNotFound` is a valid row index for scrolling to a section with zero rows.
	///    - scrollPosition:
	///        A constant that identifies a relative position in the table view (top, middle, bottom) for row when scrolling concludes. See [`UITableView.ScrollPosition`](https://developer.apple.com/documentation/uikit/uitableview/scrollposition) for descriptions of valid constants.
	///    - animated:
	///        [`true`](https://developer.apple.com/documentation/swift/true) if you want to animate the change in position; [`false`](https://developer.apple.com/documentation/swift/false) if it should be immediate.
	func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
		guard indexPath.section < numberOfSections else { return }
		guard indexPath.row < self.numberOfRows(inSection: indexPath.section) else { return }
		self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
	}

	/// Reload data with a completion handler.
	///
	/// - Parameter completion: completion handler to run after reloadData finishes.
	func reloadData(_ completion: @escaping () -> Void) {
		UIView.animate(withDuration: 0, animations: {
			self.reloadData()
		}, completion: { _ in
			completion()
		})
	}
}

extension UITableView {
	/// A registration for the table view’s cells.
	///
	/// Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data item type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
	///
	/// The following example creates a cell registration for cells of type [UITableViewCell](https://developer.apple.com/documentation/uikit/uitableviewcell). It creates a content configuration with a system default style, customizes the content and appearance of the configuration, and then assigns the configuration to the cell.
	///
	/// ```swift
	/// let cellRegistration = UITableView.CellRegistration<UITableViewCell, Int> { cell, indexPath, item in
	///    var contentConfiguration = cell.defaultContentConfiguration()
	///
	///    contentConfiguration.text = "\(item)"
	///    contentConfiguration.textProperties.color = .lightGray
	///
	///    cell.contentConfiguration = contentConfiguration
	/// }
	/// ```
	///
	/// After you create a cell registration, you pass it in to [dequeueConfiguredReusableCell(using:for:item:)](x-source-tag://UIKit-UITableView-DequeueConfiguredReusableCell), which you call from your data source’s cell provider.
	///
	/// ```swift
	/// dataSource = UITableViewDiffableDataSource<Section, Int>(tableView: tableView) {
	///     (tableView: UITableView, indexPath: IndexPath, itemIdentifier: Int) -> UITableViewCell? in
	///	    return tableView.dequeueConfiguredReusableCell(using: cellRegistration,
	///							   for: indexPath,
	///							   item: itemIdentifier)
	/// }
	/// ```
	///
	/// You don’t need to call [register(_:forCellWithReuseIdentifier:)](https://developer.apple.com/documentation/uikit/uitableview/1614937-register) or [register(_:forCellWithReuseIdentifier:)](https://developer.apple.com/documentation/uikit/uitableview/1614888-register). The table view registers your cell automatically when you pass the cell registration to [dequeueConfiguredReusableCell(using:for:item:)](x-source-tag://UIKit-UITableView-DequeueConfiguredReusableCell).
	///
	/// - Important: Do not create your cell registration inside a [UITableViewDiffableDataSource.CellProvider](https://developer.apple.com/documentation/uikit/uitableviewdiffabledatasource/cellprovider) closure; doing so prevents cell reuse, and generates an exception in iOS 15 and higher.
	///
	/// - Tag: UIKit-UITableView-CellRegistration
	struct CellRegistration<Cell, Item> where Cell: UITableViewCell {
		// swiftlint:disable nesting
		// A closure that handles the cell registration and configuration.
		typealias Handler = (_ cell: Cell, _ indexPath: IndexPath, _ itemIdentifier: Item) -> Void

		/// A closure that handles the cell registration and configuration.
		fileprivate let handler: Handler

		/// An object that contains Interface Builder nib file of a cell.
		fileprivate let cellNib: UINib?

		/// The reusable identifier of the cell.
		fileprivate let identifier: String

		/// Creates a cell registration with the specified registration handler.
		///
		/// - Parameters:
		///   - handler: The closure that handles the cell registration and configuration.
		init(handler: @escaping UITableView.CellRegistration<Cell, Item>.Handler) {
			self.handler = handler
			self.cellNib = nil
			self.identifier = "\(type(of: Item.self))_\(type(of: Cell.self))"
		}

		/// Creates a cell registration with the specified registration handler and nib file.
		///
		/// - Parameters:
		///   - cellNib: The `UINib` object that contains the Interface Builder nib file of the cell.
		///   - handler: The closure that handles the cell registration and configuration.
		init(cellNib: UINib, handler: @escaping UITableView.CellRegistration<Cell, Item>.Handler) {
			self.handler = handler
			self.cellNib = cellNib
			self.identifier = "\(type(of: Item.self))_\(type(of: Cell.self))"
		}
		// swiftlint:enable nesting
	}

	/// Dequeues a configured reusable cell object.
	///
	/// - Parameters:
	///    - registration: The cell registration for configuring the cell object. See [UITableView.CellRegistration](x-source-tag://UIKit-UITableView-CellRegistration).
	///    - indexPath: The index path that specifies the location of the cell in the table view.
	///    - item: The item that provides data for the cell.
	///
	/// - Returns: A configured reusable cell object.
	///
	/// - Tag: UIKit-UITableView-DequeueConfiguredReusableCell
	func dequeueConfiguredReusableCell<Cell, Item>(using registration: UITableView.CellRegistration<Cell, Item>, for indexPath: IndexPath, item: Item?) -> Cell where Cell: UITableViewCell {
		if let cellNib = registration.cellNib {
			self.register(cellNib, forCellReuseIdentifier: registration.identifier)
		}

		if let cell = self.dequeueReusableCell(withIdentifier: registration.identifier) as? Cell {
			registration.handler(cell, indexPath, item!)
			return cell
		}

		let cell = Cell(style: .default, reuseIdentifier: registration.identifier)
		registration.handler(cell, indexPath, item!)
		return cell
	}
}
