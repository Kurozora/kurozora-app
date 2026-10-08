//
//  ActionLinkExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionLinkExploreCollectionViewCell: ActionBaseExploreCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var separatorView: SecondarySeparatorView?

	// MARK: - Properties
	var separatorIsHidden = false

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configure(using quickLink: QuickLink) {
		super.configure(using: quickLink)

		self.separatorView?.isHidden = self.separatorIsHidden

		self.actionButton?.highlightBackgroundColorEnabled = true
		self.actionButton?.highlightBackgroundColor = KThemePicker.backgroundColor.colorValue.lighten()
		self.actionButton?.titleLabel?.numberOfLines = 0

		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = .zero
		configuration.image = quickLink.image
		configuration.imagePadding = 8.0
		self.actionButton?.configuration = configuration
	}
}

// MARK: - Measurement
extension ActionLinkExploreCollectionViewCell {
	/// Returns the item that measures the given quick link.
	///
	/// - Parameter quickLink: The quick link the item measures.
	///
	/// - Returns: The item that measures the quick link.
	static func measurableItem(for quickLink: QuickLink) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ActionLinkExploreCollectionViewCell.self) { cell in
			cell.configure(using: quickLink)
		}
	}
}
