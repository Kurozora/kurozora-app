//
//  SkeletonDisplayable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SkeletonDisplayable: AnyObject {
	func showSkeleton()
	func hideSkeleton()
}

extension SkeletonDisplayable where Self: UICollectionViewCell {
	private var skeletonViewTag: Int {
		return 1000000
	}

	func showSkeleton() {
		self.hideSkeleton()

		let skeletonView = UIView()
		skeletonView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		skeletonView.isUserInteractionEnabled = false
		skeletonView.cornerRadius = 10.0
		skeletonView.tag = self.skeletonViewTag
		self.contentView.addSubview(skeletonView)
		self.contentView.cornerRadius = 10.0
		skeletonView.fillToSuperview()
	}

	func hideSkeleton() {
		self.contentView.viewWithTag(self.skeletonViewTag)?.removeFromSuperview()
		self.contentView.cornerRadius = 0.0
		self.contentView.layer.masksToBounds = false
	}
}
