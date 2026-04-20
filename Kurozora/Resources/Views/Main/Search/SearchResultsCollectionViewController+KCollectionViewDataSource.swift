//
//  SearchResultsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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
		let discoverSuggestionCellConfiguration = self.getConfiguredActionLinkCell()
		let browseCellConfiguration = self.getConfiguredBrowseCell()

		self.dataSource = UICollectionViewDiffableDataSource<SearchResults.Section, SearchResults.Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: SearchResults.Item) -> UICollectionViewCell? in
			switch itemKind {
			case .discoverSuggestion:
				return collectionView.dequeueConfiguredReusableCell(using: discoverSuggestionCellConfiguration, for: indexPath, item: itemKind)
			case .browseCategory:
				return collectionView.dequeueConfiguredReusableCell(using: browseCellConfiguration, for: indexPath, item: itemKind)
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
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			var segueID: SegueIdentifiers?
			let sectionLayoutKind = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.delegate = self

			switch sectionLayoutKind {
			case .discover:
				exploreSectionTitleCell.configure(withTitle: L10n.discover, indexPath: indexPath, segueID: segueID)
			case .browse:
				exploreSectionTitleCell.configure(withTitle: L10n.browse, indexPath: indexPath, segueID: segueID)
			case .characters:
				segueID = .charactersListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.characters, indexPath: indexPath, segueID: segueID)
			case .episodes:
				segueID = .episodesListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.episodes, indexPath: indexPath, segueID: segueID)
			case .games:
				segueID = .gamesListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.games, indexPath: indexPath, segueID: segueID)
			case .literatures:
				segueID = .literaturesListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.literatures, indexPath: indexPath, segueID: segueID)
			case .people:
				segueID = .peopleListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.people, indexPath: indexPath, segueID: segueID)
			case .songs:
				segueID = .songsListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.songs, indexPath: indexPath, segueID: segueID)
			case .shows:
				segueID = .showsListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.shows, indexPath: indexPath, segueID: segueID)
			case .studios:
				segueID = .studiosListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.studios, indexPath: indexPath, segueID: segueID)
			case .users:
				segueID = .usersListSegue
				exploreSectionTitleCell.configure(withTitle: L10n.users, indexPath: indexPath, segueID: segueID)
			}

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	/// Returns the identity contained in the given item.
	///
	/// - Parameter item: The item to inspect.
	///
	/// - Returns: The identity of type `Element`, or `nil` if the item does not contain one.
	func extractIdentity<Element: KurozoraItem>(from item: SearchResults.Item) -> Element? {
		switch item {
		case .characterIdentity(let identity):  return identity as? Element
		case .episodeIdentity(let identity):    return identity as? Element
		case .gameIdentity(let identity):       return identity as? Element
		case .literatureIdentity(let identity): return identity as? Element
		case .personIdentity(let identity):     return identity as? Element
		case .showIdentity(let identity):       return identity as? Element
		case .songIdentity(let identity):       return identity as? Element
		case .studioIdentity(let identity):     return identity as? Element
		case .userIdentity(let identity):       return identity as? Element
		case .discoverSuggestion, .browseCategory, .show, .literature, .game:
			return nil
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>()

		if !self.searchTypes.isEmpty {
			switch self.currentScope {
			case .kurozora:
				switch self.searchTypes[safe: self.currentIndex] ?? .shows {
				case .shows:
					if !self.showIdentities.isEmpty {
						let showItems: [SearchResults.Item] = self.showIdentities.map { showIdentity in
							.showIdentity(showIdentity)
						}

						self.snapshot.appendSections([.shows])
						self.snapshot.appendItems(showItems, toSection: .shows)
					}
				case .literatures:
					if !self.literatureIdentities.isEmpty {
						let literatureItems: [SearchResults.Item] = self.literatureIdentities.map { literatureIdentity in
							.literatureIdentity(literatureIdentity)
						}

						self.snapshot.appendSections([.literatures])
						self.snapshot.appendItems(literatureItems, toSection: .literatures)
					}
				case .games:
					if !self.gameIdentities.isEmpty {
						let gameItems: [SearchResults.Item] = self.gameIdentities.map { gameIdentity in
							.gameIdentity(gameIdentity)
						}

						self.snapshot.appendSections([.games])
						self.snapshot.appendItems(gameItems, toSection: .games)
					}
				case .episodes:
					if !self.episodeIdentities.isEmpty {
						let episodeItems: [SearchResults.Item] = self.episodeIdentities.map { episodeIdentity in
							.episodeIdentity(episodeIdentity)
						}

						self.snapshot.appendSections([.episodes])
						self.snapshot.appendItems(episodeItems, toSection: .episodes)
					}
				case .characters:
					if !self.characterIdentities.isEmpty {
						let characterItems: [SearchResults.Item] = self.characterIdentities.map { characterIdentity in
							.characterIdentity(characterIdentity)
						}

						self.snapshot.appendSections([.characters])
						self.snapshot.appendItems(characterItems, toSection: .characters)
					}
				case .people:
					if !self.personIdentities.isEmpty {
						let peopleItems: [SearchResults.Item] = self.personIdentities.map { personIdentity in
							.personIdentity(personIdentity)
						}

						self.snapshot.appendSections([.people])
						self.snapshot.appendItems(peopleItems, toSection: .people)
					}
				case .songs:
					if !self.songIdentities.isEmpty {
						let songItems: [SearchResults.Item] = self.songIdentities.map { songIdentity in
							.songIdentity(songIdentity)
						}

						self.snapshot.appendSections([.songs])
						self.snapshot.appendItems(songItems, toSection: .songs)
					}
				case .studios:
					if !self.studioIdentities.isEmpty {
						let studioItems: [SearchResults.Item] = self.studioIdentities.map { studioIdentity in
							.studioIdentity(studioIdentity)
						}

						self.snapshot.appendSections([.studios])
						self.snapshot.appendItems(studioItems, toSection: .studios)
					}
				case .users:
					if !self.userIdentities.isEmpty {
						let userItems: [SearchResults.Item] = self.userIdentities.map { userIdentity in
							.userIdentity(userIdentity)
						}

						self.snapshot.appendSections([.users])
						self.snapshot.appendItems(userItems, toSection: .users)
					}
				}
			case .library:
				switch self.searchTypes[safe: self.currentIndex] ?? .shows {
				case .shows:
					if !self.showIdentities.isEmpty {
						let showItems: [SearchResults.Item] = self.showIdentities.map { showIdentity in
							.showIdentity(showIdentity)
						}

						self.snapshot.appendSections([.shows])
						self.snapshot.appendItems(showItems, toSection: .shows)
					}
				case .literatures:
					if !self.literatureIdentities.isEmpty {
						let literatureItems: [SearchResults.Item] = self.literatureIdentities.map { literatureIdentity in
							.literatureIdentity(literatureIdentity)
						}

						self.snapshot.appendSections([.literatures])
						self.snapshot.appendItems(literatureItems, toSection: .literatures)
					}
				case .games:
					if !self.gameIdentities.isEmpty {
						let gameItems: [SearchResults.Item] = self.gameIdentities.map { gameIdentity in
							.gameIdentity(gameIdentity)
						}

						self.snapshot.appendSections([.games])
						self.snapshot.appendItems(gameItems, toSection: .games)
					}
				default: break
				}
			}
		}

		switch self.searchViewKind {
		case .single, .library:
			break
		case .multiple:
			if self.snapshot.numberOfSections == 0 {
				if self.discoverSuggestions.count != 0 {
					let discoverSuggestionItems: [SearchResults.Item] = self.discoverSuggestions.map { discoverSuggestion in
						.discoverSuggestion(discoverSuggestion)
					}
					self.snapshot.appendSections([.discover])
					self.snapshot.appendItems(discoverSuggestionItems, toSection: .discover)
				}

				if self.browseCategories.count != 0 {
					let browseCategoryItems: [SearchResults.Item] = self.browseCategories.map { browseCategory in
						.browseCategory(browseCategory)
					}
					self.snapshot.appendSections([.browse])
					self.snapshot.appendItems(browseCategoryItems, toSection: .browse)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}
}

extension SearchResultsCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, SearchResults.Item>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .characterIdentity:
				characterLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Character?)
			default: return
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, SearchResults.Item>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] episodeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .episodeIdentity:
				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Episode?)
			default: return
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, SearchResults.Item>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .gameIdentity:
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Game?)
			default: break
			}
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, SearchResults.Item>(cellNib: PersonLockupCollectionViewCell.nib) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .personIdentity:
				personLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Person?)
			default: return
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, SearchResults.Item>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .songIdentity:
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Song?, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, SearchResults.Item>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .showIdentity:
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Show?)
			case .literatureIdentity:
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Literature?)
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, SearchResults.Item>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .studioIdentity:
				studioLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as Studio?)
			default: break
			}
		}
	}

	func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, SearchResults.Item>(cellNib: UserLockupCollectionViewCell.nib) { [weak self] userLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			switch itemKind {
			case .userIdentity:
				userLockupCollectionViewCell.delegate = self
				userLockupCollectionViewCell.configure(using: self.fetchModel(at: indexPath) as User?)
			default: break
			}
		}
	}

	func getConfiguredActionLinkCell() -> UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, SearchResults.Item>(cellNib: ActionLinkExploreCollectionViewCell.nib) { [weak self] actionLinkExploreCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .discoverSuggestion(let quickLink):
				actionLinkExploreCollectionViewCell.delegate = self
				let totalCount = self.discoverSuggestions.count
				let columns = self.collectionView.columnCount(inSection: indexPath.section)
				actionLinkExploreCollectionViewCell.separatorIsHidden = indexPath.item + columns >= totalCount
				actionLinkExploreCollectionViewCell.configure(using: quickLink)
			default: break
			}
		}
	}

	func getConfiguredBrowseCell() -> UICollectionView.CellRegistration<BrowseCategoryLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<BrowseCategoryLockupCollectionViewCell, SearchResults.Item>(cellNib: BrowseCategoryLockupCollectionViewCell.nib) { browseCategoryLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .browseCategory(let browseCategory):
				browseCategoryLockupCollectionViewCell.configure(using: browseCategory)
			default: break
			}
		}
	}
}
