//
//  HomeCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension HomeCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			LegalCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let bannerCellConfiguration = self.getConfiguredBannerCell()
		let characterCellConfiguration = self.getConfiguredCharacterCell()
		let episodeCellConfiguration = self.getConfiguredEpisodeCell()
		let gameCellConfiguration = self.getConfiguredGameCell()
		let largeCellConfiguration = self.getConfiguredLargeCell()
		let mediumCellConfiguration = self.getConfiguredMediumCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()
		let personCellConfiguration = self.getConfiguredPersonCell()
		let smallCellConfiguration = self.getConfiguredSmallCell()
		let upcomingCellConfiguration = self.getConfiguredUpcomingCell()
		let videoCellConfiguration = self.getConfiguredVideoCell()
		let actionLinkCellConfiguration = self.getConfiguredActionLinkCell()
		let actionButtonCellConfiguration = self.getConfiguredActionButtonCell()
		let recapCellConfiguration = self.getConfiguredRecapCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let showDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch showDetailSection {
			case .banner:
				return collectionView.dequeueConfiguredReusableCell(using: bannerCellConfiguration, for: indexPath, item: itemKind)
			case .small:
				switch itemKind {
				case .gameIdentity:
					return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
				case .episodeIdentity:
					return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
				case .recap:
					return collectionView.dequeueConfiguredReusableCell(using: recapCellConfiguration, for: indexPath, item: itemKind)
				default:
					return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
				}
			case .medium:
				return collectionView.dequeueConfiguredReusableCell(using: mediumCellConfiguration, for: indexPath, item: itemKind)
			case .large:
				return collectionView.dequeueConfiguredReusableCell(using: largeCellConfiguration, for: indexPath, item: itemKind)
			case .video:
				return collectionView.dequeueConfiguredReusableCell(using: videoCellConfiguration, for: indexPath, item: itemKind)
			case .upcoming:
				return collectionView.dequeueConfiguredReusableCell(using: upcomingCellConfiguration, for: indexPath, item: itemKind)
			case .profile:
				switch itemKind {
				case .characterIdentity:
					return collectionView.dequeueConfiguredReusableCell(using: characterCellConfiguration, for: indexPath, item: itemKind)
				case .personIdentity:
					return collectionView.dequeueConfiguredReusableCell(using: personCellConfiguration, for: indexPath, item: itemKind)
				default: return nil
				}
			case .episode:
				return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
			case .music:
				return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
			case .quickLinks:
				return collectionView.dequeueConfiguredReusableCell(using: actionLinkCellConfiguration, for: indexPath, item: itemKind)
			case .quickActions:
				return collectionView.dequeueConfiguredReusableCell(using: actionButtonCellConfiguration, for: indexPath, item: itemKind)
			case .legal:
				let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: LegalCollectionViewCell.self, for: indexPath)
				return legalExploreCollectionViewCell
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			var segueID: SegueIdentifiers?
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.delegate = self

			switch sectionLayoutKind {
			case .banner(let exploreCategory), .video(let exploreCategory), .upcoming(let exploreCategory), .small(let exploreCategory), .large(let exploreCategory):
				switch exploreCategory.attributes.exploreCategoryType {
				case .literatures, .mostPopularLiteratures, .upcomingLiteratures, .newLiteratures:
					segueID = .literaturesListSegue
				case .games, .mostPopularGames, .upcomingGames, .newGames:
					segueID = .gamesListSegue
				case .recap:
					break
				default:
					segueID = .showsListSegue
				}
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .medium(let exploreCategory):
				switch exploreCategory.attributes.exploreCategoryType {
				case .genres:
					segueID = .genresSegue
				case .themes:
					segueID = .themesSegue
				default: break
				}
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .profile(let exploreCategory):
				switch exploreCategory.attributes.exploreCategoryType {
				case .characters:
					segueID = .charactersListSegue
				case .people:
					segueID = .peopleListSegue
				default: break
				}
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .episode(let exploreCategory):
				segueID = .episodesListSegue
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .music(let exploreCategory):
				segueID = .songsListSegue
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .quickLinks:
				exploreSectionTitleCell.configure(withTitle: "Quick Links", indexPath: indexPath)
			case .quickActions: break
			case .legal: break
			}

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		let previousSnapshot = self.dataSource?.snapshot() ?? NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		var previousItemsByKey: [PreviousItemKey: ItemKind] = [:]

		for section in previousSnapshot.sectionIdentifiers {
			for item in previousSnapshot.itemIdentifiers(inSection: section) {
				guard let id = self.identityID(from: item) else { continue }
				previousItemsByKey[PreviousItemKey(section: section, identityID: id)] = item
			}
		}

		var previousModelsByIdentityID: [KurozoraItemID: KurozoraItem] = [:]

		for model in self.cache.values {
			previousModelsByIdentityID[model.id] = model
		}

		self.cache = [:]
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		for exploreCategory in self.exploreCategories {
			let section = self.sectionHeader(for: exploreCategory)
			let freshItems = self.items(for: exploreCategory)
			let stableItems: [ItemKind] = freshItems.map { fresh in
				guard let id = self.identityID(from: fresh) else { return fresh }
				return previousItemsByKey[PreviousItemKey(section: section, identityID: id)] ?? fresh
			}

			self.snapshot.appendSections([section])
			self.snapshot.appendItems(stableItems, toSection: section)
		}

		self.appendQuickLinksSection()
		self.appendQuickActionsSection()
		self.appendLegalSection()

		for (sectionIndex, section) in self.snapshot.sectionIdentifiers.enumerated() {
			for (itemIndex, item) in self.snapshot.itemIdentifiers(inSection: section).enumerated() {
				guard
					let id = self.identityID(from: item),
					let model = previousModelsByIdentityID[id]
				else { continue }
				self.cache[IndexPath(item: itemIndex, section: sectionIndex)] = model
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	/// Composite key pairing a section with an identity id, used to carry forward ``ItemKind`` UUIDs across rebuilds.
	private struct PreviousItemKey: Hashable {
		let section: SectionLayoutKind
		let identityID: KurozoraItemID
	}

	/// Returns the section layout kind for the given explore category, honoring its configured display size.
	///
	/// - Parameter category: The explore category whose section header is being resolved.
	///
	/// - Returns: The matching ``SectionLayoutKind`` case embedding `category`.
	private func sectionHeader(for category: ExploreCategory) -> SectionLayoutKind {
		switch category.attributes.exploreCategoryType {
		case .mostPopularShows, .mostPopularLiteratures, .mostPopularGames:
			return .banner(category)
		case .upcomingShows, .upcomingLiteratures, .upcomingGames:
			return .upcoming(category)
		case .shows, .newShows, .literatures, .newLiteratures, .games, .newGames:
			switch category.attributes.exploreCategorySize {
			case .banner: return .banner(category)
			case .large: return .large(category)
			case .medium: return .medium(category)
			case .small: return .small(category)
			case .upcoming: return .upcoming(category)
			case .video: return .video(category)
			}
		case .episodes, .upNextEpisodes: return .episode(category)
		case .songs: return .music(category)
		case .characters, .people: return .profile(category)
		case .genres, .themes: return .medium(category)
		case .recap: return .small(category)
		}
	}

	/// Returns the item kinds for the given explore category, respecting the per-category item limit.
	///
	/// - Parameter category: The explore category whose items are being resolved.
	///
	/// - Returns: The array of ``ItemKind`` values to append to the category's section.
	private func items(for category: ExploreCategory) -> [ItemKind] {
		switch category.attributes.exploreCategoryType {
		case .mostPopularShows:
			return (category.relationships.shows?.data ?? []).map { .showIdentity($0) }
		case .mostPopularLiteratures:
			return (category.relationships.literatures?.data ?? []).map { .literatureIdentity($0) }
		case .mostPopularGames:
			return (category.relationships.games?.data ?? []).map { .gameIdentity($0) }
		case .upcomingShows, .shows, .newShows:
			return (category.relationships.shows?.data ?? []).prefix(10).map { .showIdentity($0) }
		case .upcomingLiteratures, .literatures, .newLiteratures:
			return (category.relationships.literatures?.data ?? []).prefix(10).map { .literatureIdentity($0) }
		case .upcomingGames, .games, .newGames:
			return (category.relationships.games?.data ?? []).prefix(10).map { .gameIdentity($0) }
		case .episodes, .upNextEpisodes:
			return (category.relationships.episodes?.data ?? []).prefix(10).map { .episodeIdentity($0) }
		case .songs:
			return (category.relationships.showSongs?.data ?? []).prefix(10).map { .showSong($0) }
		case .characters:
			return (category.relationships.characters?.data ?? []).prefix(10).map { .characterIdentity($0) }
		case .people:
			return (category.relationships.people?.data ?? []).prefix(10).map { .personIdentity($0) }
		case .genres:
			return (category.relationships.genres?.data ?? []).prefix(10).map { .genreIdentity($0) }
		case .themes:
			return (category.relationships.themes?.data ?? []).prefix(10).map { .themeIdentity($0) }
		case .recap:
			return (category.relationships.recaps?.data ?? []).prefix(10).map { .recap($0) }
		}
	}

	/// Appends the quick links section and its items to the current snapshot.
	private func appendQuickLinksSection() {
		let section = SectionLayoutKind.quickLinks(id: self.quickLinksSectionID)
		self.snapshot.appendSections([section])
		self.snapshot.appendItems(self.quickLinkItemKinds, toSection: section)
	}

	/// Appends the quick actions section and its items to the current snapshot.
	private func appendQuickActionsSection() {
		let section = SectionLayoutKind.quickActions(id: self.quickActionsSectionID)
		let items: [ItemKind] = self.quickActions.map { .quickAction($0) }
		self.snapshot.appendSections([section])
		self.snapshot.appendItems(items, toSection: section)
	}

	/// Appends the legal section to the current snapshot.
	private func appendLegalSection() {
		let section = SectionLayoutKind.legal(id: self.legalSectionID)
		self.snapshot.appendSections([section])
		self.snapshot.appendItems([.legal(id: self.legalItemID)], toSection: section)
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

// MARK: - Cell Configuration
extension HomeCollectionViewController {
	func getConfiguredActionLinkCell() -> UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, ItemKind>(cellNib: ActionLinkExploreCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .quickLink(let quickLink, _) = itemKind else { return }
			let totalCount = self.quickLinks.count
			let columns = self.collectionView.columnCount(inSection: indexPath.section)

			cell.delegate = self
			cell.separatorIsHidden = indexPath.item + columns >= totalCount
			cell.configure(using: quickLink)
		}
	}

	func getConfiguredActionButtonCell() -> UICollectionView.CellRegistration<ActionButtonExploreCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ActionButtonExploreCollectionViewCell, ItemKind>(cellNib: ActionButtonExploreCollectionViewCell.nib) { [weak self] cell, _, itemKind in
			guard let self = self, case .quickAction(let quickAction, _) = itemKind else { return }

			cell.delegate = self
			cell.configure(using: quickAction)
		}
	}

	func getConfiguredBannerCell() -> UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind>(cellNib: BannerLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showIdentity = itemKind else { return }
			let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)

			cell.delegate = self
			cell.configure(using: show)
		}
	}

	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)
				cell.delegate = self
				cell.configure(using: show)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Literature>.self, identity: LiteratureIdentity.self)
				cell.delegate = self
				cell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .episodeIdentity = itemKind else { return }
			let episode: Episode? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Episode>.self, identity: EpisodeIdentity.self)

			cell.delegate = self
			cell.configure(using: episode)
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .gameIdentity = itemKind else { return }
			let game: Game? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Game>.self, identity: GameIdentity.self)

			cell.delegate = self
			cell.configure(using: game)
		}
	}

	func getConfiguredMediumCell() -> UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind>(cellNib: MediumLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .genreIdentity:
				let genre: Genre? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Genre>.self, identity: GenreIdentity.self)
				cell.configure(using: genre)
			case .themeIdentity:
				let theme: Theme? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Theme>.self, identity: ThemeIdentity.self)
				cell.configure(using: theme)
			default: break
			}
		}
	}

	func getConfiguredLargeCell() -> UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind>(cellNib: LargeLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showIdentity = itemKind else { return }
			let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)

			cell.delegate = self
			cell.configure(using: show)
		}
	}

	func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showIdentity = itemKind else { return }
			let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)

			cell.delegate = self
			cell.configure(using: show)
		}
	}

	func getConfiguredVideoCell() -> UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind>(cellNib: VideoLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showIdentity = itemKind else { return }
			let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)

			cell.delegate = self
			cell.configure(using: show)
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showSong(let showSong, _) = itemKind else { return }
			self.cache[indexPath] = showSong

			cell.delegate = self
			cell.configure(using: showSong, at: indexPath, showEpisodes: false, showShow: true)
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: PersonLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .personIdentity = itemKind else { return }
			let person: Person? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Person>.self, identity: PersonIdentity.self)

			cell.configure(using: person)
		}
	}

	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .characterIdentity = itemKind else { return }
			let character: Character? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Character>.self, identity: CharacterIdentity.self)

			cell.configure(using: character)
		}
	}

	func getConfiguredRecapCell() -> UICollectionView.CellRegistration<RecapLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<RecapLockupCollectionViewCell, ItemKind>(cellNib: RecapLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .recap(let recap, _) = itemKind else { return }
			self.cache[indexPath] = recap

			cell.configure(using: recap)
		}
	}
}
