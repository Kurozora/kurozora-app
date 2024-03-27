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
		let baseReviewCell = self.getConfiguredBaseReviewCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Review>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, reviewIdentity: Review) -> UICollectionViewCell? in
			if reviewIdentity.relationships?.literatures != nil {
				return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.characters != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.people != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.episodes != nil {
				return collectionView.dequeueConfiguredReusableCell(using: episodeReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.games != nil {
				return collectionView.dequeueConfiguredReusableCell(using: gameReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.shows != nil {
				return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.songs != nil {
				return collectionView.dequeueConfiguredReusableCell(using: musicReviewCell, for: indexPath, item: reviewIdentity)
			} else if reviewIdentity.relationships?.studios != nil {
				return collectionView.dequeueConfiguredReusableCell(using: personReviewCell, for: indexPath, item: reviewIdentity)
			}

			return collectionView.dequeueConfiguredReusableCell(using: baseReviewCell, for: indexPath, item: reviewIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Review>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.reviews, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
	}

	func fetchEpisode(at indexPath: IndexPath) -> Episode? {
		guard let episode = self.episodes[indexPath] else { return nil }
		return episode
	}

	func fetchGame(at indexPath: IndexPath) -> Game? {
		guard let game = self.games[indexPath] else { return nil }
		return game
	}

	func fetchLiterature(at indexPath: IndexPath) -> Literature? {
		guard let literature = self.literatures[indexPath] else { return nil }
		return literature
	}

	func fetchPerson(at indexPath: IndexPath) -> Person? {
		guard let person = self.people[indexPath] else { return nil }
		return person
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func fetchSong(at indexPath: IndexPath) -> Song? {
		guard let song = self.songs[indexPath] else { return nil }
		return song
	}

	func fetchStudio(at indexPath: IndexPath) -> Studio? {
		guard let studio = self.studios[indexPath] else { return nil }
		return studio
	}

	func setUserNeedsUpdate(_ review: Review) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(review) != nil else { return }
		snapshot.reconfigureItems([review])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension ReviewsListCollectionViewController {
	func getConfiguredGameReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.gameReviewLockupCollectionViewCell)) { [weak self] baseReviewLockupCollectionViewCell, indexPath, review in
			guard let self = self else { return }
			let gameIdentity = review.relationships?.games?.data.first
			let game = self.fetchGame(at: indexPath)

			if game == nil, let gameIdentity = gameIdentity {
				Task {
					do {
						let reviewResponse = try await KService.getDetails(forGame: gameIdentity).value

						self.games[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(review)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			baseReviewLockupCollectionViewCell.configure(using: review, for: game)
		}
	}

	func getConfiguredBaseReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.baseReviewLockupCollectionViewCell)) { [weak self] baseReviewLockupCollectionViewCell, indexPath, review in
			guard let self = self else { return }

			if let showIdentity = review.relationships?.shows?.data.first {
				let show = self.fetchShow(at: indexPath)

				if show == nil {
					Task {
						do {
							let reviewResponse = try await KService.getDetails(forShow: showIdentity).value

							self.shows[indexPath] = reviewResponse.data.first
							self.setUserNeedsUpdate(review)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: show)
			} else if let literatureIdentity = review.relationships?.literatures?.data.first {
				let literature = self.fetchLiterature(at: indexPath)

				if literature == nil {
					Task {
						do {
							let reviewResponse = try await KService.getDetails(forLiterature: literatureIdentity).value

							self.literatures[indexPath] = reviewResponse.data.first
							self.setUserNeedsUpdate(review)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: literature)
			}
		}
	}

	func getConfiguredMusicReviewCell() -> UICollectionView.CellRegistration<MusicReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<MusicReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.musicReviewLockupCollectionViewCell)) { [weak self] baseReviewLockupCollectionViewCell, indexPath, review in
			guard let self = self else { return }
			let songIdentity = review.relationships?.songs?.data.first
			let song = self.fetchSong(at: indexPath)

			if song == nil, let songIdentity = songIdentity {
				Task {
					do {
						let reviewResponse = try await KService.getDetails(forSong: songIdentity).value

						self.songs[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(review)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			baseReviewLockupCollectionViewCell.delegate = self
			baseReviewLockupCollectionViewCell.configure(using: review, for: song)
		}
	}

	func getConfiguredEpisodeReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.episodeReviewLockupCollectionViewCell)) { [weak self] baseReviewLockupCollectionViewCell, indexPath, review in
			guard let self = self else { return }
			let episodeIdentity = review.relationships?.episodes?.data.first
			let episode = self.fetchEpisode(at: indexPath)

			if episode == nil, let episodeIdentity = episodeIdentity {
				Task {
					do {
						let reviewResponse = try await KService.getDetails(forEpisode: episodeIdentity).value

						self.episodes[indexPath] = reviewResponse.data.first
						self.setUserNeedsUpdate(review)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			baseReviewLockupCollectionViewCell.configure(using: review, for: episode)
		}
	}

	func getConfiguredPersonReviewCell() -> UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review> {
		return UICollectionView.CellRegistration<BaseReviewLockupCollectionViewCell, Review>(cellNib: UINib(resource: R.nib.personReviewLockupCollectionViewCell)) { [weak self] baseReviewLockupCollectionViewCell, indexPath, review in
			guard let self = self else { return }

			if let characterIdentity = review.relationships?.characters?.data.first {
				let character = self.fetchCharacter(at: indexPath)

				if character == nil {
					Task {
						do {
							let reviewResponse = try await KService.getDetails(forCharacter: characterIdentity).value

							self.characters[indexPath] = reviewResponse.data.first
							self.setUserNeedsUpdate(review)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: character)
			} else if let personIdentity = review.relationships?.people?.data.first {
				let person = self.fetchPerson(at: indexPath)

				if person == nil {
					Task {
						do {
							let reviewResponse = try await KService.getDetails(forPerson: personIdentity).value

							self.people[indexPath] = reviewResponse.data.first
							self.setUserNeedsUpdate(review)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: person)
			} else if let studioIdentity = review.relationships?.studios?.data.first {
				let studio = self.fetchStudio(at: indexPath)

				if studio == nil {
					Task {
						do {
							let reviewResponse = try await KService.getDetails(forStudio: studioIdentity).value

							self.studios[indexPath] = reviewResponse.data.first
							self.setUserNeedsUpdate(review)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				baseReviewLockupCollectionViewCell.configure(using: review, for: studio)
			}
		}
	}
}
