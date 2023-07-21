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
		let gameCellConfiguration = self.getConfiguredGameCell()
		let personCellConfiguration = self.getConfiguredPersonCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()
		let showCellConfiguration = self.getConfiguredShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let userCellConfiguration = self.getConfiguredUserCell()
		let discoverSuggestionCellConfiguration = UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.actionLinkExploreCollectionViewCell)) { [weak self] actionLinkExploreCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .discoverSuggestion(let discoverSuggestion):
				let quickLink = QuickLink(title: discoverSuggestion, url: "")
				actionLinkExploreCollectionViewCell.delegate = self
				actionLinkExploreCollectionViewCell.configure(using: quickLink)
			default: break
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SearchResults.Section, SearchResults.Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: SearchResults.Item) -> UICollectionViewCell? in
			switch itemKind {
			case .show:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .literature:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
			case .game:
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
			case .gameIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
			case .studioIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .userIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: userCellConfiguration, for: indexPath, item: itemKind)
			case .discoverSuggestion:
				return collectionView.dequeueConfiguredReusableCell(using: discoverSuggestionCellConfiguration, for: indexPath, item: itemKind)
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
			case .episodes:
				segueID = R.segue.searchResultsCollectionViewController.episodesListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.episodes, indexPath: indexPath, segueID: segueID)
			case .games:
				segueID = R.segue.searchResultsCollectionViewController.gamesListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: Trans.games, indexPath: indexPath, segueID: segueID)
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
			case .discover:
				exploreSectionTitleCell.configure(withTitle: Trans.discover, indexPath: indexPath, segueID: segueID)
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

	func setItemKindNeedsUpdate(_ itemKind: SearchResults.Item) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>()

		if !self.searchTypes.isEmpty {
			switch self.currentScope {
			case .kurozora:
				switch self.searchTypes[self.currentIndex] {
				case .shows:
					if !self.showIdentities.isEmpty {
						let showItems: [SearchResults.Item] = self.showIdentities.map { showIdentity in
							return .showIdentity(showIdentity)
						}

						snapshot.appendSections([.shows])
						snapshot.appendItems(showItems, toSection: .shows)
					}
				case .literatures:
					if !self.literatureIdentities.isEmpty {
						let literatureItems: [SearchResults.Item] = self.literatureIdentities.map { literatureIdentity in
							return .literatureIdentity(literatureIdentity)
						}

						snapshot.appendSections([.literatures])
						snapshot.appendItems(literatureItems, toSection: .literatures)
					}
				case .games:
					if !self.gameIdentities.isEmpty {
						let gameItems: [SearchResults.Item] = self.gameIdentities.map { gameIdentity in
							return .gameIdentity(gameIdentity)
						}

						snapshot.appendSections([.games])
						snapshot.appendItems(gameItems, toSection: .games)
					}
				case .episodes:
					if !self.episodeIdentities.isEmpty {
						let episodeItems: [SearchResults.Item] = self.episodeIdentities.map { episodeIdentity in
							return .episodeIdentity(episodeIdentity)
						}

						snapshot.appendSections([.episodes])
						snapshot.appendItems(episodeItems, toSection: .episodes)
					}
				case .characters:
					if !self.characterIdentities.isEmpty {
						let characterItems: [SearchResults.Item] = self.characterIdentities.map { characterIdentity in
							return .characterIdentity(characterIdentity)
						}

						snapshot.appendSections([.characters])
						snapshot.appendItems(characterItems, toSection: .characters)
					}
				case .people:
					if !self.personIdentities.isEmpty {
						let peopleItems: [SearchResults.Item] = self.personIdentities.map { personIdentity in
							return .personIdentity(personIdentity)
						}

						snapshot.appendSections([.people])
						snapshot.appendItems(peopleItems, toSection: .people)
					}
				case .songs:
					if !self.songIdentities.isEmpty {
						let songItems: [SearchResults.Item] = self.songIdentities.map { songIdentity in
							return .songIdentity(songIdentity)
						}

						snapshot.appendSections([.songs])
						snapshot.appendItems(songItems, toSection: .songs)
					}
				case .studios:
					if !self.studioIdentities.isEmpty {
						let studioItems: [SearchResults.Item] = self.studioIdentities.map { studioIdentity in
							return .studioIdentity(studioIdentity)
						}

						snapshot.appendSections([.studios])
						snapshot.appendItems(studioItems, toSection: .studios)
					}
				case .users:
					if !self.userIdentities.isEmpty {
						let userItems: [SearchResults.Item] = self.userIdentities.map { userIdentity in
							return .userIdentity(userIdentity)
						}

						snapshot.appendSections([.users])
						snapshot.appendItems(userItems, toSection: .users)
					}
				}
			case .library:
				switch self.searchTypes[self.currentIndex] {
				case .shows:
					if !self.showIdentities.isEmpty {
						let showItems: [SearchResults.Item] = self.showIdentities.map { showIdentity in
							return .showIdentity(showIdentity)
						}

						snapshot.appendSections([.shows])
						snapshot.appendItems(showItems, toSection: .shows)
					}
				case .literatures:
					if !self.literatureIdentities.isEmpty {
						let literatureItems: [SearchResults.Item] = self.literatureIdentities.map { literatureIdentity in
							return .literatureIdentity(literatureIdentity)
						}

						snapshot.appendSections([.literatures])
						snapshot.appendItems(literatureItems, toSection: .literatures)
					}
				case .games:
					if !self.gameIdentities.isEmpty {
						let gameItems: [SearchResults.Item] = self.gameIdentities.map { gameIdentity in
							return .gameIdentity(gameIdentity)
						}

						snapshot.appendSections([.games])
						snapshot.appendItems(gameItems, toSection: .games)
					}
				default: break
				}
			}
		}

		if snapshot.numberOfSections == 0 {
			let discoverSuggestionItems: [SearchResults.Item] = self.discoverSuggestions.map { discoverSuggestions in
				return .discoverSuggestion(discoverSuggestions)
			}
			snapshot.appendSections([.discover])
			snapshot.appendItems(discoverSuggestionItems, toSection: .discover)
		}

		self.dataSource.apply(snapshot)
	}
}

extension SearchResultsCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity(let characterIdentity, _):
				let character = self.fetchCharacter(at: indexPath)

				if character == nil {
					Task {
						do {
							let characterResponse = try await KService.getDetails(forCharacter: characterIdentity).value

							self.characters[indexPath] = characterResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				characterLockupCollectionViewCell.configure(using: character)
			default: return
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.episodeLockupCollectionViewCell)) { [weak self] episodeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episodeIdentity(let episodeIdentity, _):
				let episode = self.fetchEpisode(at: indexPath)

				if episode == nil {
					Task {
						do {
							let episodeResponse = try await KService.getDetails(forEpisode: episodeIdentity, including: ["show", "season"]).value
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

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity(let gameIdentity, _):
				let game = self.fetchGame(at: indexPath)

				if game == nil {
					Task {
						do {
							let gameResponse = try await KService.getDetails(forGame: gameIdentity).value

							self.games[indexPath] = gameResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}
	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity(let personIdentity, _):
				let person = self.fetchPerson(at: indexPath)

				if person == nil {
					Task {
						do {
							let personResponse = try await KService.getDetails(forPerson: personIdentity).value

							self.people[indexPath] = personResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				personLockupCollectionViewCell.configure(using: person)
			default: return
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.musicLockupCollectionViewCell)) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .songIdentity(let songIdentity, _):
				let song = self.fetchSong(at: indexPath)

				if song == nil {
					Task {
						do {
							let songResponse = try await KService.getDetails(forSong: songIdentity).value

							self.songs[indexPath] = songResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: song, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)

				if show == nil {
					Task {
						do {
							let showResponse = try await KService.getDetails(forShow: showIdentity).value

							self.shows[indexPath] = showResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity(let literatureIdentity, _):
				let literature = self.fetchLiterature(at: indexPath)

				if literature == nil {
					Task {
						do {
							let literatureResponse = try await KService.getDetails(forLiterature: literatureIdentity).value

							self.literatures[indexPath] = literatureResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.studioLockupCollectionViewCell)) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
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

	func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, SearchResults.Item>(cellNib: UINib(resource: R.nib.userLockupCollectionViewCell)) { [weak self] userLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity(let userIdentity, _):
				let user = self.fetchUser(at: indexPath)

				if user == nil {
					Task {
						do {
							let userResponse = try await KService.getDetails(forUser: userIdentity).value

							self.users[indexPath] = userResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				userLockupCollectionViewCell.delegate = self
				userLockupCollectionViewCell.configure(using: user)
			default: break
			}
		}
	}
}
