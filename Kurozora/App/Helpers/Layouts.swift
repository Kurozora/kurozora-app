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
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40.0, trailing: 10)
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
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
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
		layoutGroup.interItemSpacing = .fixed(20.0)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
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
			layoutGroup.interItemSpacing = .fixed(20.0)
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
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: bottomInset, trailing: 10)
		return layoutSection
	}

	static func charactersSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func castSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	/// The width from which the trailer queue is listed beside the hero.
	static let trailerQueueWidth: CGFloat = 1024.0

	/// The share of the width the hero trailer takes when the queue sits beside it.
	static let trailerHeroFraction: CGFloat = 0.75

	/// The vertical gap between two queued trailers.
	static let trailerQueueSpacing: CGFloat = 12.0

	/// The minimum height of a queued trailer.
	static let trailerQueueRowHeight: CGFloat = 64.0

	/// Returns the number of queued trailers that fit beside the hero at the given width.
	///
	/// - Parameter width: The width of the collection.
	///
	/// - Returns: the number of queued trailers that fit beside the hero.
	static func trailerQueueCount(forWidth width: CGFloat) -> Int {
		let heroHeight = width * trailerHeroFraction * 9.0 / 16.0
		let queueCount = Int((heroHeight + trailerQueueSpacing) / (trailerQueueRowHeight + trailerQueueSpacing))
		return min(max(queueCount, 2), 9)
	}

	/// Returns the section the hero trailer and the queue behind it are laid out in.
	///
	/// - Parameters:
	///    - section: The index of the section.
	///    - layoutEnvironment: The layout environment of the section.
	///    - queueCount: The number of trailers listed beside the hero.
	///    - listsQueue: Whether there is room to list the queue beside the hero.
	///
	/// - Returns: the section the hero trailer and the queue behind it are laid out in.
	static func trailerHeroSection(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment, queueCount: Int, listsQueue: Bool) -> NSCollectionLayoutSection {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let captionHeight: CGFloat = 96.0

		guard listsQueue, queueCount > 0 else {
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupWidth = (width - 20.0) * 0.90
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(groupWidth * 9.0 / 16.0 + captionHeight))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

			// Add layout section.
			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = 20.0
			layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
			#if targetEnvironment(macCatalyst)
			layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			#else
			layoutSection.orthogonalScrollingBehavior = .groupPaging
			#endif
			return layoutSection
		}

		// Add the hero item.
		let heroFraction = Layouts.trailerHeroFraction
		let heroItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(heroFraction), heightDimension: .fractionalHeight(1.0)))

		// Add the queue group.
		let queueHeight = width * heroFraction * 9.0 / 16.0
		let rowHeight = (queueHeight - Layouts.trailerQueueSpacing * CGFloat(queueCount - 1)) / CGFloat(queueCount)
		let queueItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(rowHeight)))
		let queueGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 - heroFraction), heightDimension: .fractionalHeight(1.0)), subitem: queueItem, count: queueCount)
		queueGroup.interItemSpacing = .fixed(Layouts.trailerQueueSpacing)
		queueGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: captionHeight, trailing: 0)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute((width * heroFraction) * 9.0 / 16.0 + captionHeight))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [heroItem, queueGroup])

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
		return layoutSection
	}

	static func videoSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func seasonsSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func episodesSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func studiosSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func podiumSection(_ section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let horizontalInset: CGFloat = 10.0
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
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1.0))
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

	static func quickLinkSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
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
		let maxInset = max(leadingInset, trailingInset)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: maxInset, bottom: 40.0, trailing: maxInset)
		return layoutSection
	}

	static func legalSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		return layoutSection
	}
}
