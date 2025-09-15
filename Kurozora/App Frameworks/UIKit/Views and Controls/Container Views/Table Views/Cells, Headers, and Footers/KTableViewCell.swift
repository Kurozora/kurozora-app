//
//  KTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// The visual representation of a single row in a table view.
///
/// A `KTableViewCell` object is a specialized type of view that manages the content of a single table row.
/// You use cells primarily to organize and present your app’s custom content, but `KTableViewCell` provides some specific customizations to support reloading behaviors, including:
/// - A [configureCell()](x-source-tag://KTableViewCell-configureCell) method for configuring the data inside the cell.
/// - A [reloadCell()](x-source-tag://KTableViewCell-reloadCell) method for reloading the data inside the cell.
class KTableViewCell: UITableViewCell, SkeletonDisplayable {
	// MARK: - Properties
	var isSkeletonEnabled: Bool {
		return true
	}

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		if self.isSkeletonEnabled {
			self.showSkeleton()
		}
	}

	// MARK: - Functions
	/// The shared settings used to initialize the table view cell.
	func sharedInit() {
		self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
	}

	/// Reloads the views in the table view cell.
	///
	/// The default implementation of this method does nothing. You need to override this method and provide the data that needs to be reloaded.
	/// You also need to decide when and how you should reload the view by calling this method somewhere in your table view cell implementation.
	///
	/// - Tag: KTableViewCell-reloadCell
	func reloadCell() { }
}
