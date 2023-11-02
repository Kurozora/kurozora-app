//
//  SkeletonDisplayable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SkeletonDisplayable: AnyObject {
	/// Adds and shows the skeleton view.
	func showSkeleton()

	/// Hides the skeleton view.
	func hideSkeleton()
}

extension SkeletonDisplayable {
	/// The tag by which the skeleton view is identifie in the view hierarchy.
	private var skeletonViewTag: Int {
		return 1000000
	}
}

// MARK: - UICollectionViewCell
extension SkeletonDisplayable where Self: UICollectionViewCell {
	func showSkeleton() {
		self.hideSkeleton()

		let skeletonView = UIView()
		skeletonView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		skeletonView.isUserInteractionEnabled = false
		skeletonView.layerCornerRadius = 10.0
		skeletonView.tag = self.skeletonViewTag
		self.contentView.addSubview(skeletonView)
		self.contentView.layerCornerRadius = 10.0
		skeletonView.fillToSuperview()
	}

	func hideSkeleton() {
		self.contentView.viewWithTag(self.skeletonViewTag)?.removeFromSuperview()
		self.contentView.layerCornerRadius = 0.0
		self.contentView.layer.masksToBounds = false
	}
}

// MARK: - UITableViewCell
extension SkeletonDisplayable where Self: UITableViewCell {
	func showSkeleton() {
		self.hideSkeleton()

		let skeletonView = UIView()
		skeletonView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		skeletonView.isUserInteractionEnabled = false
		skeletonView.layerCornerRadius = 10.0
		skeletonView.tag = self.skeletonViewTag
		self.contentView.addSubview(skeletonView)
		self.contentView.layerCornerRadius = 10.0
		skeletonView.fillToSuperview()
	}

	func hideSkeleton() {
		self.contentView.viewWithTag(self.skeletonViewTag)?.removeFromSuperview()
		self.contentView.layerCornerRadius = 0.0
		self.contentView.layer.masksToBounds = false
	}
}
