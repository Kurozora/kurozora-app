//
//  SearchResultsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension SearchResultsCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let characterCellConfiguration = self.getConfiguredCharacterCell()
		let episodeCellConfiguration = self.getConfiguredEpisodeCell()
		let personCellConfiguration = self.getConfiguredPersonCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()
		let showCellConfiguration = self.getConfiguredShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let userCellConfiguration = self.getConfiguredUserCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			switch itemKind {
			case .show:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .literature:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .characterIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .episodeIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
			case .personIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: personCellConfiguration, for: indexPath, item: itemKind)
			case .songIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
			case .showIdentity, .literatureIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: showCellConfiguration, for: indexPath, item: itemKind)
			case .studioIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .userIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: userCellConfiguration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			var segueID: String = ""
			let sectionLayoutKind = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.delegate = self

			switch sectionLayoutKind {
			case .searchHistory: break
			case .characters:
				segueID = R.segue.searchResultsCollectionViewController.charactersListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.characters, indexPath: indexPath, segueID: segueID)
			case .episodes:
				segueID = R.segue.searchResultsCollectionViewController.episodesListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.episodes, indexPath: indexPath, segueID: segueID)
			case .literatures:
				segueID = R.segue.searchResultsCollectionViewController.literaturesListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.literatures, indexPath: indexPath, segueID: segueID)
			case .people:
				segueID = R.segue.searchResultsCollectionViewController.peopleListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.people, indexPath: indexPath, segueID: segueID)
			case .songs:
				segueID = R.segue.searchResultsCollectionViewController.songsListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.songs, indexPath: indexPath, segueID: segueID)
			case .shows:
				segueID = R.segue.searchResultsCollectionViewController.showsListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.shows, indexPath: indexPath, segueID: segueID)
			case .studios:
				segueID = R.segue.searchResultsCollectionViewController.studiosListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.studios, indexPath: indexPath, segueID: segueID)
			case .users:
				segueID = R.segue.searchResultsCollectionViewController.usersListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.users, indexPath: indexPath, segueID: segueID)
			}

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
	}

	func fetchEpisode(at indexPath: IndexPath) -> Episode? {
		guard let episode = self.episodes[indexPath] else { return nil }
		return episode
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
		guard let showSongs = self.songs[indexPath] else { return nil }
		return showSongs
	}

	func fetchStudio(at indexPath: IndexPath) -> Studio? {
		guard let studio = self.studios[indexPath] else { return nil }
		return studio
	}

	func fetchUser(at indexPath: IndexPath) -> User? {
		guard let user = self.users[indexPath] else { return nil }
		return user
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		switch self.currentScope {
		case .kurozora:
			if let showSearchResults = self.searchResults?.shows?.data, !showSearchResults.isEmpty {
				let showItems: [ItemKind] = showSearchResults.map { showIdentity in
					return .showIdentity(showIdentity)
				}

				snapshot.appendSections([.shows])
				snapshot.appendItems(showItems, toSection: .shows)
			}

			if let literatureSearchResults = self.searchResults?.literatures?.data, !literatureSearchResults.isEmpty {
				let literatureItems: [ItemKind] = literatureSearchResults.map { literatureIdentity in
					return .literatureIdentity(literatureIdentity)
				}

				snapshot.appendSections([.literatures])
				snapshot.appendItems(literatureItems, toSection: .literatures)
			}

			if let episodeSearchResults = self.searchResults?.episodes?.data, !episodeSearchResults.isEmpty {
				let episodeItems: [ItemKind] = episodeSearchResults.map { episodeIdentity in
					return .episodeIdentity(episodeIdentity)
				}

				snapshot.appendSections([.episodes])
				snapshot.appendItems(episodeItems, toSection: .episodes)
			}

			if let characterSearchResults = self.searchResults?.characters?.data, !characterSearchResults.isEmpty {
				let characterItems: [ItemKind] = characterSearchResults.map { characterIdentity in
					return .characterIdentity(characterIdentity)
				}

				snapshot.appendSections([.characters])
				snapshot.appendItems(characterItems, toSection: .characters)
			}

			if let peopleSearchResults = self.searchResults?.people?.data, !peopleSearchResults.isEmpty {
				let peopleItems: [ItemKind] = peopleSearchResults.map { personIdentity in
					return .personIdentity(personIdentity)
				}

				snapshot.appendSections([.people])
				snapshot.appendItems(peopleItems, toSection: .people)
			}

			if let songSearchResults = self.searchResults?.songs?.data, !songSearchResults.isEmpty {
				let songItems: [ItemKind] = songSearchResults.map { songIdentity in
					return .songIdentity(songIdentity)
				}

				snapshot.appendSections([.songs])
				snapshot.appendItems(songItems, toSection: .songs)
			}

			if let studioSearchResults = self.searchResults?.studios?.data, !studioSearchResults.isEmpty {
				let studioItems: [ItemKind] = studioSearchResults.map { studioIdentity in
					return .studioIdentity(studioIdentity)
				}

				snapshot.appendSections([.studios])
				snapshot.appendItems(studioItems, toSection: .studios)
			}

			if let userSearchResults = self.searchResults?.users?.data, !userSearchResults.isEmpty {
				let userItems: [ItemKind] = userSearchResults.map { userIdentity in
					return .userIdentity(userIdentity)
				}

				snapshot.appendSections([.users])
				snapshot.appendItems(userItems, toSection: .users)
			}
		case .library:
			if let showSearchResults = self.searchResults?.shows?.data,
			   !showSearchResults.isEmpty {
				let showItems: [ItemKind] = showSearchResults.map { showIdentity in
					return .showIdentity(showIdentity)
				}

				snapshot.appendSections([.shows])
				snapshot.appendItems(showItems, toSection: .shows)
			}

			if let literatureSearchResults = self.searchResults?.literatures?.data,
			   !literatureSearchResults.isEmpty {
				let literatureItems: [ItemKind] = literatureSearchResults.map { literatureIdentity in
					return .literatureIdentity(literatureIdentity)
				}

				snapshot.appendSections([.literatures])
				snapshot.appendItems(literatureItems, toSection: .literatures)
			}
		}

		if snapshot.numberOfSections == 0 {
//			let showItems: [ItemKind] = self.suggestionElements.map { show in
//				return .show(show)
//			}
			snapshot.appendSections([.searchHistory])
			snapshot.appendItems([], toSection: .searchHistory)
		}

		self.dataSource.apply(snapshot)
	}
}

extension SearchResultsCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity(let characterIdentity, _):
				let character = self.fetchCharacter(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? characterLockupCollectionViewCell.dataRequest

				if dataRequest == nil && character == nil {
					dataRequest = KService.getDetails(forCharacter: characterIdentity) { result in
						switch result {
						case .success(let characters):
							self.characters[indexPath] = characters.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				characterLockupCollectionViewCell.dataRequest = dataRequest
				characterLockupCollectionViewCell.configure(using: character)
			default: return
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.episodeLockupCollectionViewCell)) { [weak self] episodeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episodeIdentity(let episodeIdentity, _):
				let episode = self.fetchEpisode(at: indexPath)

				if episode == nil {
					Task {
						do {
							let episodeResponse = try await KService.getDetails(forEpisode: episodeIdentity).value
							self.episodes[indexPath] = episodeResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: episode)
			default: return
			}
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity(let personIdentity, _):
				let person = self.fetchPerson(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? personLockupCollectionViewCell.dataRequest

				if dataRequest == nil && person == nil {
					dataRequest = KService.getDetails(forPerson: personIdentity) { result in
						switch result {
						case .success(let persons):
							self.people[indexPath] = persons.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				personLockupCollectionViewCell.dataRequest = dataRequest
				personLockupCollectionViewCell.configure(using: person)
			default: return
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.musicLockupCollectionViewCell)) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .songIdentity(let songIdentity, _):
				let song = self.fetchSong(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? musicLockupCollectionViewCell.dataRequest

				if dataRequest == nil && song == nil {
					dataRequest = KService.getDetails(forSong: songIdentity) { result in
						switch result {
						case .success(let song):
							self.songs[indexPath] = song.data.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.dataRequest = dataRequest
				musicLockupCollectionViewCell.configure(using: song, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity(let literatureIdentity, _):
				let literature = self.fetchLiterature(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && literature == nil {
					dataRequest = KService.getDetails(forLiterature: literatureIdentity) { result in
						switch result {
						case .success(let literatures):
							self.literatures[indexPath] = literatures.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.studioLockupCollectionViewCell)) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity(let studioIdentity, _):
				let studio = self.fetchStudio(at: indexPath)

				if studio == nil {
					Task {
						do {
							let studioResponse = try await KService.getDetails(forStudio: studioIdentity).value
							self.studios[indexPath] = studioResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.userLockupCollectionViewCell)) { [weak self] userLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity(let userIdentity, _):
				let user = self.fetchUser(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? userLockupCollectionViewCell.dataRequest

				if dataRequest == nil && user == nil {
					dataRequest = KService.getDetails(forUser: userIdentity) { result in
						switch result {
						case .success(let users):
							self.users[indexPath] = users.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				userLockupCollectionViewCell.delegate = self
				userLockupCollectionViewCell.dataRequest = dataRequest
				userLockupCollectionViewCell.configure(using: user)
			default: break
			}
		}
	}
}
