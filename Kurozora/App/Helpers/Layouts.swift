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

	/// Returns the width of a single item laid out by the standard section builders.
	///
	/// Horizontal groups size their fraction against the full container width, while
	/// vertical groups size against the container inset by the section margins.
	private static func itemWidth(for layoutEnvironment: NSCollectionLayoutEnvironment, columns: Int, isHorizontal: Bool) -> CGFloat {
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let groupWidth = isHorizontal ? containerWidth * 0.90 : containerWidth - 20.0
		return (groupWidth - CGFloat(columns - 1) * 20.0) / CGFloat(columns)
	}

	/// Returns the line height of the given text style in the layout environment's size category.
	private static func lineHeight(_ textStyle: UIFont.TextStyle, for layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		return UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: layoutEnvironment.traitCollection).lineHeight
	}

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

		// Heights mirror ProfileLockupCollectionViewCell.xib.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth + 10.0 + Self.lineHeight(.body, for: layoutEnvironment) * 2.0 + Self.lineHeight(.subheadline, for: layoutEnvironment)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror ProfileLockupCollectionViewCell.xib.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth + 10.0 + Self.lineHeight(.body, for: layoutEnvironment) * 2.0 + Self.lineHeight(.subheadline, for: layoutEnvironment)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror MusicLockupCollectionViewCell.xib. The extra 8 covers the width
		// rounding UIKit applies per item, which the square album inherits.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth + 16.0 + Self.lineHeight(.body, for: layoutEnvironment) + Self.lineHeight(.subheadline, for: layoutEnvironment) + 24.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror SmallLockupCollectionViewCell.xib. The poster cap wins until the
		// text column outgrows it at larger content size categories.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		var textColumnHeight = Self.lineHeight(.body, for: layoutEnvironment) * 2.0 + Self.lineHeight(.subheadline, for: layoutEnvironment) + 16.0 + 8.0 + 30.0
		if !isHorizontal {
			textColumnHeight += Self.lineHeight(.footnote, for: layoutEnvironment) * 2.0
		}
		let itemHeight = max(150.0, textColumnHeight)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

	static func gameSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Heights mirror GameLockupCollectionViewCell.xib. The poster cap wins until the
		// text column outgrows it at larger content size categories.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		var textColumnHeight = Self.lineHeight(.body, for: layoutEnvironment) + Self.lineHeight(.subheadline, for: layoutEnvironment) + 16.0 + 8.0 + 30.0
		if !isHorizontal {
			textColumnHeight += Self.lineHeight(.footnote, for: layoutEnvironment) * 2.0
		}
		let itemHeight = max(100.0, textColumnHeight)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

	static func recapSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Heights mirror RecapLockupCollectionViewCell.xib, which is a square card.
		let itemHeight = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

	static func reviewSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment, isHorizontal: Bool = true) -> NSCollectionLayoutSection {
		let widthDimension: NSCollectionLayoutDimension = isHorizontal ? .fractionalWidth(0.90) : .fractionalWidth(1.0)
		let bottomInset: CGFloat = isHorizontal ? 40.0 : 20.0

		// Heights mirror ReviewCollectionViewCell.xib. The text block reserves the six line
		// collapsed cap plus one metadata line, and the reaction row sits pinned at the bottom.
		let textBlockHeight = Self.lineHeight(.body, for: layoutEnvironment) * 6.0 + Self.lineHeight(.caption1, for: layoutEnvironment)
		let itemHeight = 8.0 + Self.lineHeight(.headline, for: layoutEnvironment) + 16.0 + 8.0 + textBlockHeight + 8.0 + 23.0 + 8.0
		let heightDimension: NSCollectionLayoutDimension
		if isHorizontal {
			heightDimension = .absolute(itemHeight)
		} else if #available(iOS 17.0, *) {
			heightDimension = .uniformAcrossSiblings(estimate: itemHeight)
		} else {
			heightDimension = .estimated(itemHeight)
		}

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: isHorizontal ? .absolute(itemHeight) : .estimated(itemHeight))
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

		// Heights mirror UpcomingLockupCollectionViewCell.xib.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth * 4.0 / 3.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror MediumLockupCollectionViewCell.xib. The extra 8 covers per item
		// width rounding, which the gradient banner inherits through its aspect ratio.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth * 9.0 / 16.0 + 16.0 + Self.lineHeight(.title3, for: layoutEnvironment)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror LargeLockupCollectionViewCell.xib.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = itemWidth * 9.0 / 16.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror BannerLockupCollectionViewCell.xib.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let itemHeight = 21.0 + itemWidth * 9.0 / 16.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror VideoLockupCollectionViewCell.xib. The tagline block is always
		// reserved so every item in the section shares one deterministic height.
		let contentWidth = layoutEnvironment.container.effectiveContentSize.width - 20.0
		let groupWidth = contentWidth * (isHorizontal ? 0.90 : 1.0)
		let itemWidth = (groupWidth - CGFloat(columns - 1) * 20.0) / CGFloat(columns)
		let bannerHeight = itemWidth * 9.0 / 16.0
		let taglineHeight = UIFont.preferredFont(forTextStyle: .callout, compatibleWith: layoutEnvironment.traitCollection).lineHeight * 2.0
		let itemHeight = bannerHeight + 8.0 + 150.0 + 16.0 + taglineHeight

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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

		// Heights mirror EpisodeLockupCollectionViewCell.xib. The stack reserves the
		// episode pill, a two line title, the show link, the date line and the watched
		// button with its spacing, plus a small tolerance for button insets.
		let itemWidth = Self.itemWidth(for: layoutEnvironment, columns: columns, isHorizontal: isHorizontal)
		let stackHeight = Self.lineHeight(.callout, for: layoutEnvironment) + Self.lineHeight(.body, for: layoutEnvironment) + Self.lineHeight(.subheadline, for: layoutEnvironment) * 2.0 + 30.0 + 16.0
		let itemHeight = itemWidth * 9.0 / 16.0 + 8.0 + stackHeight

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .absolute(itemHeight))
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
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 40, trailing: 10)
		return layoutSection
	}

	static func quickActionSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// The buttons keep their designed width and stay centered as a pair, shrinking
		// only when the window cannot fit them.
		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let itemWidth = min(310.0, (containerWidth - 40.0 - CGFloat(columns - 1) * 20.0) / CGFloat(columns))
		let groupWidth = itemWidth * CGFloat(columns) + CGFloat(columns - 1) * 20.0
		let sideInset = max((containerWidth - groupWidth) / 2.0, 20.0)

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .estimated(45.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth), heightDimension: .estimated(45.0))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: 40.0, trailing: sideInset)
		return layoutSection
	}

	static func backgroundDecoration(extendsToBottom: Bool, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDecorationItem {
		let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		let containerSize = layoutEnvironment.container.contentSize

		backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -containerSize.width, bottom: extendsToBottom ? -containerSize.height : 0, trailing: -containerSize.width)

		return backgroundDecoration
	}

	static func legalSection(_ section: Int, columns: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		// Heights mirror LegalCollectionViewCell.xib.
		let itemHeight = Self.lineHeight(.subheadline, for: layoutEnvironment) + 20.0

		// Add layout item.
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		// Add layout group.
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
		layoutGroup.interItemSpacing = .fixed(20)

		// Add layout section.
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.interGroupSpacing = 20.0
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		return layoutSection
	}
}
