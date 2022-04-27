//
//  ServicePreviewTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// The visual representation of a single row in a table view.
///
/// A `ServicePreviewTableViewCell` object is a specialized type of view that manages the content of a service preview table row.
/// You use cells primarily to organize and present your app’s custom content, but `ServicePreviewTableViewCell` provides some specific customizations to support service preview behaviors, including:
/// - A single UIImageView which presents your service to the user.
///
/// - Tag: ServicePreviewTableViewCell
class ServicePreviewTableViewCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var previewImageView: UIImageView?

	// MARK: - Properties
	/// The image that should be displayed in the cell.
	var previewImage: UIImage? = nil {
		didSet {
			reloadCell()
		}
	}

	// MARK: - Functions
	override func sharedInit() {
		super.sharedInit()
		self.contentView.backgroundColor = .clear
	}

	// MARK: - View
	override func reloadCell() {
		self.previewImageView?.image = previewImage
	}
}
