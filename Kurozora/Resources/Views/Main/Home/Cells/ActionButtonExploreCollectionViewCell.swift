//
//  ActionButtonExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionButtonExploreCollectionViewCell: ActionBaseExploreCollectionViewCell { }

// MARK: - Measurement
extension ActionButtonExploreCollectionViewCell {
	/// Returns the item that measures the given quick action.
	///
	/// - Parameter quickAction: The quick action the item measures.
	///
	/// - Returns: The item that measures the quick action.
	static func measurableItem(for quickAction: QuickAction) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: ActionButtonExploreCollectionViewCell.self) { cell in
			cell.configure(using: quickAction)
		}
	}
}
