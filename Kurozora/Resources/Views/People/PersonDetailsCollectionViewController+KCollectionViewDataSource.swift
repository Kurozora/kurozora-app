//
//  PersonDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension PersonDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			InformationCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()
		let gameCellRegistration = self.getConfiguredGameCell()
		let characterCellRegistration = self.getConfiguredCharacterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let personDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch personDetailSection {
			case .header:
				let personHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonHeaderCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .person(let person, _):
					personHeaderCollectionViewCell?.person = person
				default: break
				}
				return personHeaderCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.reuseID, for: indexPath) as? TextViewCollectionViewCell
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				switch itemKind {
				case .person(let person, _):
					textViewCollectionViewCell?.textViewContent = person.attributes.about
				default: break
				}
				return textViewCollectionViewCell
			case .rating:
				let personDetailRating = PersonDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: personDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .person(let person, _):
					if let stats = person.attributes.stats {
						switch personDetailRating {
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
				let personDetailRateAndReview = PersonDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: personDetailRateAndReview.identifierString, for: indexPath)

				switch personDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .person(let person, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: person.attributes.givenRating)
					default: break
					}
				case .writeAReview:
					(rateAndReviewCollectionViewCell as? WriteAReviewCollectionViewCell)?.delegate = self
				}
				return rateAndReviewCollectionViewCell
			case .reviews:
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.reviewCollectionViewCell, for: indexPath)
				switch itemKind {
				case .review(let review, _):
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review)
				default: break
				}
				return reviewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .person(let person, _):
					informationCollectionViewCell?.configure(using: person, for: PersonDetail.Information(rawValue: indexPath.item) ?? .aliases)
				default: break
				}
				return informationCollectionViewCell
			case .characters:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
			case .shows, .literatures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .games:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let personDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: personDetailSection.stringValue, indexPath: indexPath, segueID: personDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { personDetailSection in
			switch personDetailSection {
			case .header:
				self.snapshot.appendSections([personDetailSection])
				self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
			case .about:
				if let about = self.person.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([personDetailSection])
				PersonDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([personDetailSection])
				PersonDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: personDetailSection)
				}
			case .information:
				self.snapshot.appendSections([personDetailSection])
				PersonDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .characters:
				if !self.characterIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let characterIdentityItems: [ItemKind] = self.characterIdentities.map { characterIdentity in
						.characterIdentity(characterIdentity)
					}
					self.snapshot.appendItems(characterIdentityItems, toSection: personDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: personDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						.literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: personDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						.gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: personDetailSection)
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
