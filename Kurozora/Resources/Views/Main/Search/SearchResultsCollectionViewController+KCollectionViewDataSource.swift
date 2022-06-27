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
		let personCellConfiguration = self.getConfiguredPersonCell()
		let songCellConfiguration = self.getConfiguredSongCell()
		let showCellConfiguration = self.getConfiguredShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let userCellConfiguration = self.getConfiguredUserCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			switch itemKind {
			case .characterIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .personIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: personCellConfiguration, for: indexPath, item: itemKind)
			case .songIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: songCellConfiguration, for: indexPath, item: itemKind)
			case .showIdentity:
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
			case .characters:
				segueID = R.segue.searchResultsCollectionViewController.charactersListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.characters, indexPath: indexPath, segueID: segueID)
			case .people:
				segueID = R.segue.searchResultsCollectionViewController.peopleListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.people, indexPath: indexPath, segueID: segueID)
			case .songs:
				segueID = R.segue.searchResultsCollectionViewController.songsListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.shows, indexPath: indexPath, segueID: segueID)
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

	func fetchPerson(at indexPath: IndexPath) -> Person? {
		guard let person = self.people[indexPath] else { return nil }
		return person
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
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

			if let showSearchResults = self.searchResults?.shows?.data, !showSearchResults.isEmpty {
				let showItems: [ItemKind] = showSearchResults.map { showIdentity in
					return .showIdentity(showIdentity)
				}

				snapshot.appendSections([.shows])
				snapshot.appendItems(showItems, toSection: .shows)
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
			let showItems: [ItemKind] = self.showIdentities.map { showIdentity in
				return .showIdentity(showIdentity)
			}
			snapshot.appendSections([.shows])
			snapshot.appendItems(showItems, toSection: .shows)
		}

		self.dataSource.apply(snapshot)
	}
}

extension SearchResultsCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity(let characterIdentity):
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

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity(let personIdentity):
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

	func getConfiguredSongCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.musicLockupCollectionViewCell)) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .songIdentity(let songIdentity):
				let song = self.fetchSong(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? musicLockupCollectionViewCell.dataRequest

				if dataRequest == nil && song == nil {
					dataRequest = KService.getDetails(forSong: songIdentity) { result in
						switch result {
						case .success(let song):
							self.songs[indexPath] = song.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

//				musicLockupCollectionViewCell.delegate = self
//				musicLockupCollectionViewCell.dataRequest = dataRequest
//				musicLockupCollectionViewCell.configure(using: song, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity): // ):
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
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.studioLockupCollectionViewCell)) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity(let studioIdentity):
				let studio = self.fetchStudio(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? studioLockupCollectionViewCell.dataRequest

				if dataRequest == nil && studio == nil {
					dataRequest = KService.getDetails(forStudio: studioIdentity) { result in
						switch result {
						case .success(let studios):
							self.studios[indexPath] = studios.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				studioLockupCollectionViewCell.dataRequest = dataRequest
				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.userLockupCollectionViewCell)) { [weak self] userLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity(let userIdentity):
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
