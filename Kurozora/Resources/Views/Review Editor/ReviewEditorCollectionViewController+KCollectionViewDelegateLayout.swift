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
	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard self.sections[safe: section] != nil else { return nil }

			return self.layoutSection(for: layoutEnvironment)
		}
	}

	/// Returns the layout of a section.
	///
	/// - Parameter layoutEnvironment: The layout environment of the section.
	private func layoutSection(for layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(self.estimatedRowHeight(for: layoutEnvironment)))
		let item = NSCollectionLayoutItem(layoutSize: layoutSize)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsetsReference = .layoutMargins
		layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: self.rowSpacing(for: layoutEnvironment), trailing: 0)
		return layoutSection
	}

	/// Returns the space below a row at the reader's text size.
	///
	/// - Parameter layoutEnvironment: The layout environment of the section.
	private func rowSpacing(for layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		return UIFontMetrics(forTextStyle: .body).scaledValue(for: 12.0, compatibleWith: layoutEnvironment.traitCollection)
	}

	/// Returns the height a row is expected to take at the reader's text size.
	///
	/// - Parameter layoutEnvironment: The layout environment of the section.
	private func estimatedRowHeight(for layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		let font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: layoutEnvironment.traitCollection)

		return font.lineHeight * 3.0
	}
}
