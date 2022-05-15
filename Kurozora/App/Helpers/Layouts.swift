//
//  Layouts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

enum Layouts {
	static func charactersSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.50) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(50.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
		if isHorizontal {
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
		}
		return layoutSection
	}

	static func musicSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.50) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(100.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(100.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.50) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(50.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(150.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(460.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: bottomInset, trailing: 10)
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(200.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: bottomInset, trailing: 10)
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

	static func quickLinkSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(55))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		return layoutSection
	}

	static func quickActionSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, collectionView: UICollectionView) -> NSCollectionLayoutSection {
		let leadingInset = collectionView.directionalLayoutMargins.leading
		let trailingInset = collectionView.directionalLayoutMargins.trailing

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: leadingInset, bottom: 40.0, trailing: trailingInset)
		return layoutSection
	}

	static func legalSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(55))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		return layoutSection
	}
}
