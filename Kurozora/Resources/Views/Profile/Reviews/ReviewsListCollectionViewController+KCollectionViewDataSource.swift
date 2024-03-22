//
//  ReviewsListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ReviewsListCollectionViewController {
	override func configureDataSource() {
		let episodeReviewCell = self.getConfiguredEpisodeReviewCell()
		let gameReviewCell = self.getConfiguredGameReviewCell()
		let musicReviewCell = self.getConfiguredMusicReviewCell()
		let personReviewCell = self.getConfiguredPersonReviewCell()
		let smallReviewCell = self.getConfiguredSmallReviewCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Review>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, reviewIdentity: Review) -> UICollectionViewCell? in
			if reviewIdentity.relationships?.literatures != nil {
				return collectionView.dequeueConfiguredReusableCell(using: smallReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.characters != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.people != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.episodes != nil {
				return collectionView.dequeueConfiguredReusableCell(using: episodeReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.games != nil {
				return collectionView.dequeueConfiguredReusableCell(using: gameReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.shows != nil {
				return collectionView.dequeueConfiguredReusableCell(using: smallReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.songs != nil {
				return collectionView.dequeueConfiguredReusableCell(using: musicReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.studios != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			}

			return collectionView.dequeueConfiguredReusableCell(using: smallReviewCell, for: indexPath, item: reviewIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Review>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.reviewIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchReview(at indexPath: IndexPath) -> Review? {
		guard let review = self.reviews[indexPath] else { return nil }
		return review
	}

	func setUserNeedsUpdate(_ review: Review) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(review) != nil else { return }
		snapshot.reconfigureItems([review])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension ReviewsListCollectionViewController {
	func getConfiguredGameReviewCell() -> UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.gameReviewLockupCollectionViewCell)) { [weak self] smallReviewLockupCollectionViewCell, indexPath, reviewIdentity in
			guard let self = self else { return }
			self.reviews[indexPath] = reviewIdentity
			let review = self.fetchReview(at: indexPath)

			if review == nil {
				Task {
					do {
//						let reviewResponse = try await KService.getReview(reviewID: review).value
//
//						self.reviews[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(reviewIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			smallReviewLockupCollectionViewCell.configure(using: review)
		}
	}

	func getConfiguredSmallReviewCell() -> UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.smallReviewLockupCollectionViewCell)) { [weak self] smallReviewLockupCollectionViewCell, indexPath, reviewIdentity in
			guard let self = self else { return }
			self.reviews[indexPath] = reviewIdentity
			let review = self.fetchReview(at: indexPath)

			if review == nil {
				Task {
					do {
//						let reviewResponse = try await KService.getReview(reviewID: review).value
//
//						self.reviews[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(reviewIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			smallReviewLockupCollectionViewCell.configure(using: review)
		}
	}

	func getConfiguredMusicReviewCell() -> UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.musicReviewLockupCollectionViewCell)) { [weak self] smallReviewLockupCollectionViewCell, indexPath, reviewIdentity in
			guard let self = self else { return }
			self.reviews[indexPath] = reviewIdentity
			let review = self.fetchReview(at: indexPath)

			if review == nil {
				Task {
					do {
//						let reviewResponse = try await KService.getReview(reviewID: review).value
//
//						self.reviews[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(reviewIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			smallReviewLockupCollectionViewCell.configure(using: review)
		}
	}

	func getConfiguredEpisodeReviewCell() -> UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.episodeReviewLockupCollectionViewCell)) { [weak self] smallReviewLockupCollectionViewCell, indexPath, reviewIdentity in
			guard let self = self else { return }
			self.reviews[indexPath] = reviewIdentity
			let review = self.fetchReview(at: indexPath)

			if review == nil {
				Task {
					do {
//						let reviewResponse = try await KService.getReview(reviewID: review).value
//
//						self.reviews[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(reviewIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			smallReviewLockupCollectionViewCell.configure(using: review)
		}
	}

	func getConfiguredPersonReviewCell() -> UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<SmallReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.personReviewLockupCollectionViewCell)) { [weak self] smallReviewLockupCollectionViewCell, indexPath, reviewIdentity in
			guard let self = self else { return }
			self.reviews[indexPath] = reviewIdentity
			let review = self.fetchReview(at: indexPath)

			if review == nil {
				Task {
					do {
//						let reviewResponse = try await KService.getReview(reviewID: review).value
//
//						self.reviews[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(reviewIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			smallReviewLockupCollectionViewCell.configure(using: review)
		}
	}
}
