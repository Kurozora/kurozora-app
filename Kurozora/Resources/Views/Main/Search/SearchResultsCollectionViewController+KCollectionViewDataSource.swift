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
			self.appendCurrentTypeSection()
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

	/// Appends only the currently selected type's section.
	private func appendCurrentTypeSection() {
		let selectedType: SearchType
		switch self.currentScope {
		case .kurozora:
			selectedType = self.searchTypes[safe: self.currentIndex] ?? .shows
		case .library:
			let candidate = self.searchTypes[safe: self.currentIndex] ?? .shows
			selectedType = [.shows, .literatures, .games].contains(candidate) ? candidate : .shows
		}
		self.appendSection(for: selectedType)
	}

	/// Appends a section containing identities for the given search type, if any are loaded.
	private func appendSection(for searchType: SearchType) {
		switch searchType {
		case .shows:
			guard !self.showIdentities.isEmpty else { return }
			self.snapshot.appendSections([.shows])
			self.snapshot.appendItems(self.showIdentities.map { .showIdentity($0) }, toSection: .shows)
		case .literatures:
			guard !self.literatureIdentities.isEmpty else { return }
			self.snapshot.appendSections([.literatures])
			self.snapshot.appendItems(self.literatureIdentities.map { .literatureIdentity($0) }, toSection: .literatures)
		case .games:
			guard !self.gameIdentities.isEmpty else { return }
			self.snapshot.appendSections([.games])
			self.snapshot.appendItems(self.gameIdentities.map { .gameIdentity($0) }, toSection: .games)
		case .episodes:
			guard !self.episodeIdentities.isEmpty else { return }
			self.snapshot.appendSections([.episodes])
			self.snapshot.appendItems(self.episodeIdentities.map { .episodeIdentity($0) }, toSection: .episodes)
		case .characters:
			guard !self.characterIdentities.isEmpty else { return }
			self.snapshot.appendSections([.characters])
			self.snapshot.appendItems(self.characterIdentities.map { .characterIdentity($0) }, toSection: .characters)
		case .people:
			guard !self.personIdentities.isEmpty else { return }
			self.snapshot.appendSections([.people])
			self.snapshot.appendItems(self.personIdentities.map { .personIdentity($0) }, toSection: .people)
		case .songs:
			guard !self.songIdentities.isEmpty else { return }
			self.snapshot.appendSections([.songs])
			self.snapshot.appendItems(self.songIdentities.map { .songIdentity($0) }, toSection: .songs)
		case .studios:
			guard !self.studioIdentities.isEmpty else { return }
			self.snapshot.appendSections([.studios])
			self.snapshot.appendItems(self.studioIdentities.map { .studioIdentity($0) }, toSection: .studios)
		case .users:
			guard !self.userIdentities.isEmpty else { return }
			self.snapshot.appendSections([.users])
			self.snapshot.appendItems(self.userIdentities.map { .userIdentity($0) }, toSection: .users)
		}
	}
}

extension SearchResultsCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, SearchResults.Item>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
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

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, SearchResults.Item> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, SearchResults.Item>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
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
				let song: Song? = self.fetchModel(at: indexPath)
				let resolvedSong = song?.attributes.amID.flatMap { self.resolvedSongs[$0] }
				musicLockupCollectionViewCell.configure(using: song, at: indexPath, resolvedSong: resolvedSong)

				if let song = song {
					self.resolveMusicSong(song)
				}
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
