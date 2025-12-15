//
//  SongDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SongDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			SosumiCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let songDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch songDetailSection {
			case .header:
				let songHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SongHeaderCollectionViewCell.self, for: indexPath)
				songHeaderCollectionViewCell?.delegate = self
				switch itemKind {
				case .song(let song, _):
					songHeaderCollectionViewCell?.configure(using: song)
				default: break
				}
				return songHeaderCollectionViewCell
			case .lyrics:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .lyrics
				textViewCollectionViewCell?.textViewContent = self.song.attributes.originalLyrics
				return textViewCollectionViewCell
			case .rating:
				let songDetailRating = SongDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: songDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .song(let song, _):
					if let stats = song.attributes.stats {
						switch songDetailRating {
						case .average:
							(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: stats)
						case .sentiment:
							(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
						case .bar:
							(ratingCollectionViewCell as? RatingBarCollectionViewCell)?.configure(using: stats)
						}
					}
				default: break
				}
				return ratingCollectionViewCell
			case .rateAndReview:
				let songDetailRateAndReview = SongDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: songDetailRateAndReview.identifierString, for: indexPath)

				switch songDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .song(let song, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: song.attributes.library?.rating)
					default: break
					}
				case .writeAReview:
					(rateAndReviewCollectionViewCell as? WriteAReviewCollectionViewCell)?.delegate = self
				}
				return rateAndReviewCollectionViewCell
			case .reviews:
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .review(let review, _):
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review)
				default: break
				}
				return reviewCollectionViewCell
			case .shows:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .song(let song, _):
					sosumiCollectionViewCell?.copyrightText = song.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let songDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: songDetailSection.stringValue, indexPath: indexPath, segueID: songDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] songDetailSection in
			guard let self = self else { return }

			switch songDetailSection {
			case .header:
				self.snapshot.appendSections([songDetailSection])
				self.snapshot.appendItems([.song(self.song)], toSection: songDetailSection)
			case .lyrics:
				if let synopsis = self.song.attributes.originalLyrics, !synopsis.isEmpty {
					self.snapshot.appendSections([songDetailSection])
					self.snapshot.appendItems([.song(self.song)], toSection: songDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([songDetailSection])
				SongDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.song(self.song)], toSection: songDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([songDetailSection])
				SongDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.song(self.song)], toSection: songDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([songDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: songDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([songDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: songDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.song.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([songDetailSection])
					self.snapshot.appendItems([.song(self.song)], toSection: songDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		return self.cache[indexPath] as? M
	}

	func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfSection(section) != nil else { return }
		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
