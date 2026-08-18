//
//  ReviewEditorCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

// MARK: - KCollectionViewDelegateLayout
extension ReviewEditorCollectionViewController {
	/// The horizontal inset of every section.
	private static var horizontalInset: CGFloat {
		return 20.0
	}

	/// The vertical inset above and below a rating category.
	private static var categoryInset: CGFloat {
		return 12.0
	}

	/// The space below the tap to rate row.
	private static var rateSpacing: CGFloat {
		return 8.0
	}

	/// The space below a text input.
	private static var inputSpacing: CGFloat {
		return 20.0
	}

	/// The estimated height of the tap to rate row and its separator.
	private static var rateEstimatedHeight: CGFloat {
		return Layouts.rateAndReviewRowHeight + 9.0
	}

	/// The estimated height of a self sizing input.
	private static var inputEstimatedHeight: CGFloat {
		return 200.0
	}

	/// The smallest height a text input is given, below which it scrolls instead of shrinking.
	private static var inputMinimumHeight: CGFloat {
		return 160.0
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let sectionLayoutKind = self.sections[safe: section] else { return nil }

			return self.layoutSection(for: sectionLayoutKind, layoutEnvironment: layoutEnvironment)
		}
	}

	/// Returns the layout of the given section.
	///
	/// - Parameters:
	///    - sectionLayoutKind: The section being laid out.
	///    - layoutEnvironment: The layout environment of the section.
	private func layoutSection(for sectionLayoutKind: SectionLayoutKind, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let heightDimension: NSCollectionLayoutDimension
		var contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self.horizontalInset, bottom: 0, trailing: Self.horizontalInset)

		switch sectionLayoutKind {
		case .rate:
			heightDimension = .estimated(Self.rateEstimatedHeight)
			contentInsets.bottom = Self.rateSpacing
		case .review:
			heightDimension = .absolute(self.inputHeight(for: layoutEnvironment))
			contentInsets.bottom = Self.inputSpacing
		case .category:
			heightDimension = .estimated(Self.inputEstimatedHeight)
			contentInsets.top = Self.categoryInset
			contentInsets.bottom = Self.categoryInset
		case .privateNote:
			if self.isDetailed {
				heightDimension = .estimated(Self.inputEstimatedHeight)
				contentInsets.top = Self.categoryInset
				contentInsets.bottom = Self.categoryInset
			} else {
				heightDimension = .absolute(self.inputHeight(for: layoutEnvironment))
				contentInsets.bottom = Self.inputSpacing
			}
		}

		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = contentInsets
		return layoutSection
	}

	/// Returns the height each text input takes so the two of them fill the sheet.
	///
	/// - Parameter layoutEnvironment: The layout environment of the section.
	private func inputHeight(for layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		let chromeHeight = Self.rateEstimatedHeight + Self.rateSpacing + Self.inputSpacing * 2
		let availableHeight = layoutEnvironment.container.contentSize.height - chromeHeight

		return max(availableHeight / 2, Self.inputMinimumHeight)
	}
}
