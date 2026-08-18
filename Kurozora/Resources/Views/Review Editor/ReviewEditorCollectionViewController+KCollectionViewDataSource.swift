//
//  ReviewEditorCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

// MARK: - SectionLayoutKind
extension ReviewEditorCollectionViewController {
	/// The sections of the review editor.
	enum SectionLayoutKind {
		/// Indicates the section holds the tap to rate row.
		case rate

		/// Indicates the section holds the review text.
		case review

		/// Indicates the section holds the rating category at the given index.
		case category(index: Int)

		/// Indicates the section holds the spoiler toggle.
		case spoiler

		/// Indicates the section holds the private note.
		case privateNote
	}

	/// The sections shown for the user's rating style.
	var sections: [SectionLayoutKind] {
		guard self.isDetailed else {
			return [.rate, .review, .spoiler, .privateNote]
		}

		return self.ratingCategories.indices.map { .category(index: $0) } + [.spoiler, .privateNote]
	}
}

// MARK: - KCollectionViewDataSource
extension ReviewEditorCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			RateCollectionViewCell.self,
			RatingCategoryCollectionViewCell.self,
			ReviewInputCollectionViewCell.self,
			SpoilerToggleCollectionViewCell.self
		]
	}
}

// MARK: - UICollectionViewDataSource
extension ReviewEditorCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.sections.count
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch self.sections[safe: indexPath.section] {
		case .rate:
			let rateCollectionViewCell = collectionView.dequeueReusableCell(withClass: RateCollectionViewCell.self, for: indexPath)
			let existingRating = self.rating ?? 0.0

			rateCollectionViewCell.delegate = self
			rateCollectionViewCell.configure(using: existingRating > 0 ? existingRating : Self.defaultRating)

			return rateCollectionViewCell
		case .category(let index):
			let ratingCategoryCollectionViewCell = collectionView.dequeueReusableCell(withClass: RatingCategoryCollectionViewCell.self, for: indexPath)
			ratingCategoryCollectionViewCell.delegate = self

			if let ratingCategory = self.ratingCategories[safe: index] {
				ratingCategoryCollectionViewCell.configure(using: ratingCategory)
			}

			return ratingCategoryCollectionViewCell
		case .spoiler:
			let spoilerToggleCollectionViewCell = collectionView.dequeueReusableCell(withClass: SpoilerToggleCollectionViewCell.self, for: indexPath)
			spoilerToggleCollectionViewCell.configure(isOn: self.isSpoiler, delegate: self)

			return spoilerToggleCollectionViewCell
		case .privateNote:
			let reviewInputCollectionViewCell = collectionView.dequeueReusableCell(withClass: ReviewInputCollectionViewCell.self, for: indexPath)
			reviewInputCollectionViewCell.delegate = self
			reviewInputCollectionViewCell.configure(title: L10n.privateNotes, text: self.note, showsSeparator: true)

			return reviewInputCollectionViewCell
		default:
			let reviewInputCollectionViewCell = collectionView.dequeueReusableCell(withClass: ReviewInputCollectionViewCell.self, for: indexPath)
			reviewInputCollectionViewCell.delegate = self
			reviewInputCollectionViewCell.configure(title: L10n.review, text: self.review, showsSeparator: false)

			return reviewInputCollectionViewCell
		}
	}
}
