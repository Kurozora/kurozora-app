//
//  ReviewsListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension UserReviewsListCollectionViewController {
	override func configureDataSource() {
		let episodeReviewCell = self.getConfiguredEpisodeReviewCell()
		let gameReviewCell = self.getConfiguredGameReviewCell()
		let musicReviewCell = self.getConfiguredMusicReviewCell()
		let personReviewCell = self.getConfiguredPersonReviewCell()
		let baseReviewCell = self.getConfiguredBaseReviewCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let review = itemKind.review else { return nil }

			if review.relationships?.literatures != nil {
				return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.characters != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.people != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.episodes != nil {
				return collectionView.dequeueConfiguredReusableCell(using: episodeReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.games != nil {
				return collectionView.dequeueConfiguredReusableCell(using: gameReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.shows != nil {
				return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.songs != nil {
				return collectionView.dequeueConfiguredReusableCell(using: musicReviewCell, for: indexPath, item: itemKind)
			} else if review.relationships?.studios != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: itemKind)
			}

			return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let reviewItems: [ItemKind] = self.reviews.map { review in
			.review(review)
		}
		self.snapshot.appendItems(reviewItems, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}
}

extension UserReviewsListCollectionViewController {
	func getConfiguredGameReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind>(cellNib: GameReviewLockupCollectionViewCell.nib) { [weak self] baseReviewLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			guard let review = itemKind.review else { return }

			let game: Game? = self.fetchModel(at: indexPath)

			if game == nil {
				Task {
					await self.fetchReviewSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			baseReviewLockupCollectionViewCell.configure(using: review, for: game)
		}
	}

	func getConfiguredBaseReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind>(cellNib: BaseReviewLockupCollectionViewCell.nib) { [weak self] baseReviewLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			guard let review = itemKind.review else { return }

			if review.relationships?.shows != nil {
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil {
					Task {
						await self.fetchReviewSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: show)
			} else if review.relationships?.literatures != nil {
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil {
					Task {
						await self.fetchReviewSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: literature)
			}
		}
	}

	func getConfiguredMusicReviewCell() -> UICollectionView.CellRegistration<MusicReviewLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicReviewLockupCollectionViewCell, ItemKind>(cellNib: MusicReviewLockupCollectionViewCell.nib) { [weak self] musicReviewLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			guard let review = itemKind.review else { return }

			musicReviewLockupCollectionViewCell.delegate = self
			musicReviewLockupCollectionViewCell.indexPath = indexPath

			let song: Song? = self.fetchModel(at: indexPath)

			if song == nil {
				Task {
					await self.fetchReviewSectionIfNeeded(ResourceCollection<Song>.self, SongIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			musicReviewLockupCollectionViewCell.configure(using: review, for: song)
		}
	}

	func getConfiguredEpisodeReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind>(cellNib: EpisodeReviewLockupCollectionViewCell.nib) { [weak self] episodeReviewLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			guard let review = itemKind.review else { return }

			let episode: Episode? = self.fetchModel(at: indexPath)

			if episode == nil {
				Task {
					await self.fetchReviewSectionIfNeeded(ResourceCollection<Episode>.self, EpisodeIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			episodeReviewLockupCollectionViewCell.configure(using: review, for: episode)
		}
	}

	func getConfiguredPersonReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, ItemKind>(cellNib: PersonReviewLockupCollectionViewCell.nib) { [weak self] baseReviewLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			guard let review = itemKind.review else { return }

			if review.relationships?.characters != nil {
				let character: Character? = self.fetchModel(at: indexPath)

				if character == nil {
					Task {
						await self.fetchReviewSectionIfNeeded(ResourceCollection<Character>.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: character)
			} else if review.relationships?.people != nil {
				let person: Person? = self.fetchModel(at: indexPath)

				if person == nil {
					Task {
						await self.fetchReviewSectionIfNeeded(ResourceCollection<Person>.self, PersonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: person)
			} else if review.relationships?.studios != nil {
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil {
					Task {
						await self.fetchReviewSectionIfNeeded(ResourceCollection<Studio>.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: studio)
			}
		}
	}
}
