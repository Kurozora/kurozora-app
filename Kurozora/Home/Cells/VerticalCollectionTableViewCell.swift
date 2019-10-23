//
//  VerticalCollectionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class VerticalCollectionTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: SelfSizingCollectionView!

	// MARK: - Properties
	var actionsArray: [[[String: String]]]? = nil {
		didSet {
			collectionView.reloadData()
		}
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		collectionView.selfSizingDelegate = self
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		return collectionView.frame.size
	}

	// MARK: - Functions
	@objc func invalidateCollectionViewLayout() {
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension VerticalCollectionTableViewCell: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let actionsArrayCount = actionsArray?.count else { return 0 }
		return actionsArrayCount
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actionsArraySectionCount = actionsArray?[section].count else { return 0 }
		return actionsArraySectionCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let identifier = VerticalCollectionCellStyle(rawValue: indexPath.section)?.reuseIdentifier {
			if let actionListExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ActionBaseExploreCollectionViewCell {
				return actionListExploreCollectionViewCell
			}
		}

		return UICollectionViewCell()
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let actionBaseExploreCollectionViewCell = cell as? ActionBaseExploreCollectionViewCell {
			actionBaseExploreCollectionViewCell.actionItem = actionsArray?[indexPath.section][indexPath.row]
		}
	}
}

// MARK: - UICollectionViewDelegate
extension VerticalCollectionTableViewCell: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDelegateFlowLayout
extension VerticalCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var width = self.frame.width - 60
		let actionsArrayCount = actionsArray?[indexPath.section].count ?? 0

		if UIDevice.isPad {
			if UIDevice.isLandscape {
				if actionsArrayCount <= 2 {
					width /= 2
				} else {
					width /= 3
					width -= 20
				}
			} else {
				width /= 2
			}
		} else if UIDevice.isPhone {
			width /= UIDevice.isLandscape ? 2 : 1
		}

		if width < 284, self.frame.width < 284 * 2 {
			width = self.frame.width - 40
		}

		return CGSize(width: width, height: 45)
	}
}

// MARK: - SelfSizingCollectionViewDelegate
extension VerticalCollectionTableViewCell: SelfSizingCollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didChageContentSizeFrom oldSize: CGSize, to newSize: CGSize) {
		if let indexPath = indexPath {
			tableView?.reloadRows(at: [indexPath], with: .none)
		} else {
			tableView?.reloadData()
		}
	}
}
