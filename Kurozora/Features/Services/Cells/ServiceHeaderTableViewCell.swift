//
//  ServiceHeaderTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// The visual representation of a single promotional header row in a table view.
///
/// A `ServiceHeaderTableViewCell` object is a specialized type of view that displays header information about the content of a table view.
///
/// - Tag: ServiceHeaderTableViewCell
class ServiceHeaderTableViewCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var headlineLabel: KLabel!
	@IBOutlet weak var subheadLabel: KLabel!

	// MARK: - Properties
	/// The service type used to populate the cell.
	var serviceType: ServiceType? {
		didSet {
			self.reloadCell()
		}
	}

	// MARK: - Functions
	override func sharedInit() {
		super.sharedInit()
		self.contentView.backgroundColor = .clear
	}

	// MARK: - Functions
	override func reloadCell() {
		self.headlineLabel.text = serviceType?.headlineStringValue
		self.subheadLabel.text = serviceType?.subheadStringValue
	}
}
