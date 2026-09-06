//
//  Layouts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

enum Layouts {
	/// The height of a row in the rate and review section.
	static let rateAndReviewRowHeight: CGFloat = EmojiRatingView.buttonSize

	/// The max width constraint of `ActionButtonExploreCollectionViewCell`.
	static let quickActionButtonMaxWidth: CGFloat = 300.0

	/// The fraction of a section's width one orthogonally scrolling page occupies.
	private static let groupWidthFraction: CGFloat = 0.90

	/// The space between two items in a row.
	private static let interItemSpacing: CGFloat = 20.0

	/// The space between a section and its container's edges.
	private static let horizontalInset: CGFloat = 10.0

	static func badgeSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var item: NSCollectionLayoutItem!
		var layoutGroup: NSCollectionLayoutGroup!

		if width > 828 {
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
			layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		} else {
			let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .estimated(50.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .estimated(50.0))
			layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		}

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: 40.0, trailing: Self.horizontalInset)
		return layoutSection
	}

	static func profileHeaderSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = .fractionalWidth(1.0)
		let heightDimension: NSCollectionLayoutDimension = .absolute(384.0)
		let bottomInset: CGFloat = 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: bottomInset, trailing: 0)
		return layoutSection
	}

	static func headerSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = .fractionalWidth(1.0)
		let bottomInset: CGFloat = 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(0.65))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: bottomInset, trailing: 0)

		if #available(iOS 26.0, *) {
			layoutSection.contentInsetsReference = .none
		}

		return layoutSection
	}

	static func fullSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = .fractionalWidth(1.0)
		let bottomInset: CGFloat = 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		return layoutSection
	}

	static func gridSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = .fractionalWidth(1.0)
		let bottomInset: CGFloat = 20.0
		let heightDimension: NSCollectionLayoutDimension = if #available(iOS 17.0, *) {
			.uniformAcrossSiblings(estimate: 140.0)
		} else {
			.estimated(140.0)
		}

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(140.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		return layoutSection
	}

	static func ratingSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, itemCount: Int = 3) -> NSCollectionLayoutSection {
		let layoutGroup: NSCollectionLayoutGroup
		let bottomInset: CGFloat = 20.0

		if columns < 3 {
			let topItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0)))
			topItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
			let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0)), subitem: topItem, count: max(itemCount - 1, 1))

			let bottomItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0)))
			bottomItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
			layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomItem])
			layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)
		} else {
			// Create item an equal fraction of the row width
			let fractionalWidthItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(max(itemCount, 1))), heightDimension: .estimated(1.0))
			let fractionalWidthItem = NSCollectionLayoutItem(layoutSize: fractionalWidthItemSize)

			// Add layout group.
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
			layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [fractionalWidthItem])
		}

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		return layoutSection
	}

	static func charactersSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func peopleSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func castSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func musicSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true, maximumHeight: ((CGFloat) -> CGFloat?)? = nil) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0
		let heightDimensions = Self.heightDimensions(columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: isHorizontal, estimate: 180.0, maximumHeight: maximumHeight)

		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimensions.item)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimensions.group)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func smallSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	/// Returns the width a single item is given in a section laid out by `heightDimensions`.
	///
	/// - Parameters:
	///    - columns: The number of items in a row.
	///    - layoutEnvironment: The environment the section is laid out in.
	///    - isHorizontal: Whether the section scrolls orthogonally.
	///
	/// - Returns: The width of one item.
	private static func itemWidth(columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool) -> CGFloat {
		let columnCount = CGFloat(max(columns, 1))
		let sectionWidth = layoutEnvironment.container.effectiveContentSize.width - (Self.horizontalInset * 2.0)
		let groupWidth = isHorizontal ? sectionWidth * Self.groupWidthFraction : sectionWidth
		let spacing = Self.interItemSpacing * (columnCount - 1.0)

		return max((groupWidth - spacing) / columnCount, 0.0)
	}

	/// Returns the item and group heights that keep a section's cells level with each other.
	///
	/// - Parameters:
	///    - columns: The number of items in a row.
	///    - layoutEnvironment: The environment the section is laid out in.
	///    - isHorizontal: Whether the section scrolls orthogonally, holding one height for its whole length.
	///    - estimate: The height a row starts out at.
	///    - maximumHeight: Returns the height of the tallest cell in the section at the given item width.
	///
	/// - Returns: The item and group height dimensions.
	private static func heightDimensions(columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool, estimate: CGFloat, maximumHeight: ((CGFloat) -> CGFloat?)?) -> (item: NSCollectionLayoutDimension, group: NSCollectionLayoutDimension) {
		if isHorizontal {
			let itemWidth = Self.itemWidth(columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: isHorizontal)

			if let height = maximumHeight?(itemWidth) {
				return (.fractionalHeight(1.0), .absolute(height))
			}

			return (.estimated(estimate), .estimated(estimate))
		}

		if #available(iOS 17.0, macCatalyst 17.0, *) {
			return (.uniformAcrossSiblings(estimate: estimate), .estimated(estimate))
		}

		return (.estimated(estimate), .estimated(estimate))
	}

	static func reviewsSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true, maximumHeight: ((CGFloat) -> CGFloat?)? = nil) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0
		let heightDimensions = Self.heightDimensions(columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: isHorizontal, estimate: 180.0, maximumHeight: maximumHeight)

		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimensions.item)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimensions.group)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func upcomingSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func mediumSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func largeSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func bannerSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func videoSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
//		layoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
//			guard let self = self else { return }
//			visibleItems.forEach { item in
//				guard let cell = self.collectionView.cellForItem(at: item.indexPath) as? VideoLockupCollectionViewCell else { return }
//
//				if cell.avQueuePlayer.items().count > 0 {
//					let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
//
//					if distanceFromCenter / environment.container.contentSize.width < 0.6 {
//						cell.avQueuePlayer.play()
//					} else {
//						cell.avQueuePlayer.pause()
//					}
//				}
//			}
//		}
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func seasonsSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func episodesSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true, maximumHeight: ((CGFloat) -> CGFloat?)? = nil) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0
		let heightDimensions = Self.heightDimensions(columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: isHorizontal, estimate: 180.0, maximumHeight: maximumHeight)

		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimensions.item)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimensions.group)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func studiosSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func podiumSection(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let horizontalInset = Self.horizontalInset
		let groupHeight: CGFloat = 240.0
		let interItemSpacing: CGFloat = 12.0

		// Width fractions of the available space.
		let rank1WidthFraction: CGFloat = 0.36
		let rank2WidthFraction: CGFloat = 0.30
		let rank3WidthFraction: CGFloat = 0.24

		// Maximum widths.
		let rank1MaxWidth: CGFloat = 140.0
		let rank2MaxWidth: CGFloat = 110.0
		let rank3MaxWidth: CGFloat = 95.0

		// Vertical drop applied to side columns.
		let rank2Elevation: CGFloat = 18.0
		let rank3Elevation: CGFloat = 36.0

		let availableWidth = max(containerWidth - (horizontalInset * 2), 0)
		let rank1Width = min(availableWidth * rank1WidthFraction, rank1MaxWidth)
		let rank2Width = min(availableWidth * rank2WidthFraction, rank2MaxWidth)
		let rank3Width = min(availableWidth * rank3WidthFraction, rank3MaxWidth)

		// Center the cells horizontally when the available width exceeds the content
		// width plus the two fixed inter-column gaps.
		let podiumWidth = rank1Width + rank2Width + rank3Width + (interItemSpacing * 2)
		let leadingPadding = max((availableWidth - podiumWidth) / 2.0, 0)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(groupHeight)
		)
		let layoutGroup = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { _ in
			var frames: [NSCollectionLayoutGroupCustomItem] = []

			// Index 0: rank 2
			let leftFrame = CGRect(
				x: leadingPadding,
				y: rank2Elevation,
				width: rank2Width,
				height: groupHeight - rank2Elevation
			)
			frames.append(NSCollectionLayoutGroupCustomItem(frame: leftFrame))

			// Index 1: rank 1
			let centerX = leadingPadding + rank2Width + interItemSpacing
			let centerFrame = CGRect(
				x: centerX,
				y: 0,
				width: rank1Width,
				height: groupHeight
			)
			frames.append(NSCollectionLayoutGroupCustomItem(frame: centerFrame))

			// Index 2: rank 3
			let rightX = centerX + rank1Width + interItemSpacing
			let rightFrame = CGRect(
				x: rightX,
				y: rank3Elevation,
				width: rank3Width,
				height: groupHeight - rank3Elevation
			)
			frames.append(NSCollectionLayoutGroupCustomItem(frame: rightFrame))

			return frames
		}

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: horizontalInset, bottom: 24, trailing: horizontalInset)
		return layoutSection
	}

	static func usersSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(Self.groupWidthFraction) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: bottomInset, trailing: Self.horizontalInset)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func quickLinkSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: 40, trailing: Self.horizontalInset)
		return layoutSection
	}

	static func quickActionSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let totalSpacing = Self.interItemSpacing * CGFloat(columns - 1)
		let widestFittingItem = (containerWidth - Self.horizontalInset * 2 - totalSpacing) / CGFloat(columns)
		let itemWidth = min(self.quickActionButtonMaxWidth, widestFittingItem)
		let sideInset = (containerWidth - itemWidth * CGFloat(columns) - totalSpacing) / 2

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: Array(repeating: item, count: columns))
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: 40.0, trailing: sideInset)
		return layoutSection
	}

	/// Returns a background decoration that extends past the section's horizontal edges.
	///
	/// - Parameters:
	///    - extendsToBottom: Whether the decoration also extends past the section's bottom edge.
	///    - layoutEnvironment: The layout environment of the section.
	///
	/// - Returns: A background decoration for a section.
	static func backgroundDecoration(extendsToBottom: Bool, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDecorationItem {
		let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		let containerSize = layoutEnvironment.container.contentSize

		backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -containerSize.width, bottom: extendsToBottom ? -containerSize.height : 0, trailing: -containerSize.width)

		return backgroundDecoration
	}

	static func legalSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(Self.interItemSpacing)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: 0, trailing: Self.horizontalInset)
		return layoutSection
	}
}
