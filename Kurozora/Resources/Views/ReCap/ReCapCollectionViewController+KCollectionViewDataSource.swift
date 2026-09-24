//
//  ReCapCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	/// The milestones of the recap items.
	var milestones: [(recapItem: RecapItem, kind: MilestoneKind)] {
		var milestones: [(recapItem: RecapItem, kind: MilestoneKind)] = []

		for recapItem in self.recapItems {
			let hasDuration = recapItem.attributes.totalPartsDuration > 0
			let hasParts = recapItem.attributes.totalPartsCount > 0

			switch recapItem.attributes.recapItemType {
			case .shows:
				if hasDuration {
					milestones.append((recapItem, .minuetsWatched))
				}

				if hasParts {
					milestones.append((recapItem, .episodesWatched))
				}
			case .literatures:
				if hasDuration {
					milestones.append((recapItem, .minuetsRead))
				}

				if hasParts {
					milestones.append((recapItem, .chaptersRead))
				}
			case .games:
				if hasDuration {
					milestones.append((recapItem, .minutesPlayed))
				}

				if hasParts {
					milestones.append((recapItem, .gamesPlayed))
				}
			case .genres, .themes, .studios, .characters, .voices, .creators:
				break
			}
		}

		return milestones
	}

	/// The recap with the best top percentile of the period.
	var topPercentileRecapItem: RecapItem? {
		return self.recapItems
			.filter { [.shows, .literatures, .games].contains($0.attributes.recapItemType) && $0.attributes.topPercentile > 0.0 }
			.min { $0.attributes.topPercentile < $1.attributes.topPercentile }
	}

	/// The top titles of the period paired with those of the year before.
	var comparisons: [RecapItemType: ReCapComparison] {
		guard self.selectedMonth == 0 else { return [:] }

		var comparisons: [RecapItemType: ReCapComparison] = [:]

		for recapItem in self.recapItems {
			let recapItemType = recapItem.attributes.recapItemType
			let title: String

			switch recapItemType {
			case .shows: title = L10n.recapTopAnimeComparison
			case .literatures: title = L10n.recapTopMangaComparison
			case .games: title = L10n.recapTopGameComparison
			default: continue
			}

			guard
				let previousRecapItem = self.previousRecapItems.first(where: { $0.attributes.recapItemType == recapItemType }),
				let currentEntry = self.recapEntries(of: recapItem).first,
				let previousEntry = self.recapEntries(of: previousRecapItem).first,
				let currentModel = self.models.model(for: currentEntry),
				let previousModel = self.models.model(for: previousEntry)
			else { continue }

			comparisons[recapItemType] = ReCapComparison(title: title, entries: [
				ReCapComparison.Entry(year: self.year, model: currentModel, detail: self.detail(for: currentEntry, of: recapItemType)),
				ReCapComparison.Entry(year: self.year - 1, model: previousModel, detail: self.detail(for: previousEntry, of: recapItemType)),
			])
		}

		return comparisons
	}

	/// Returns the milestone of the given kind.
	///
	/// - Parameters:
	///    - recapItem: The recap the milestone is drawn from.
	///    - milestoneKind: The kind of the milestone.
	///
	/// - Returns: The milestone.
	func milestone(for recapItem: RecapItem, milestoneKind: MilestoneKind) -> ReCapMilestone {
		let models = self.recapEntries(of: recapItem).compactMap { self.models.model(for: $0) }
		return ReCapMilestone(recapItem: recapItem, milestoneKind: milestoneKind, models: models)
	}

	/// Returns the title of the section that shows the given recap item.
	///
	/// - Parameter recapItem: The recap item the section shows.
	///
	/// - Returns: The title of the section.
	func sectionTitle(for recapItem: RecapItem) -> String {
		let year: String? = self.selectedMonth == 0 ? String(self.year) : nil

		switch recapItem.attributes.recapItemType {
		case .shows: return L10n.recapTopAnime(of: year)
		case .literatures: return L10n.recapTopManga(of: year)
		case .games: return L10n.recapTopGames(of: year)
		case .genres: return L10n.recapTopGenres(of: year)
		case .themes: return L10n.recapTopThemes(of: year)
		case .studios: return L10n.recapTopStudios(of: year)
		case .characters: return L10n.recapTopCharacters(of: year)
		case .voices: return L10n.recapTopVoices(of: year)
		case .creators: return L10n.recapTopCreators(of: year)
		}
	}

	/// Returns the ranked entries of the given recap item.
	///
	/// - Parameter recapItem: The recap item whose entries to return.
	///
	/// - Returns: The entries sorted by position.
	func recapEntries(of recapItem: RecapItem) -> [RecapEntry] {
		return (recapItem.relationships?.items?.data ?? []).sorted { $0.attributes.position < $1.attributes.position }
	}

	/// Returns the measure shown under the given recap entry.
	///
	/// - Parameters:
	///    - recapEntry: The entry to measure.
	///    - recapItemType: The type of the recap the entry belongs to.
	///
	/// - Returns: The measure of the entry.
	func detail(for recapEntry: RecapEntry, of recapItemType: RecapItemType) -> String? {
		let minutes = Int(recapEntry.attributes.partsDuration.rounded())
		let count = recapEntry.attributes.partsCount

		guard minutes > 0 || count > 0 else { return nil }

		switch recapItemType {
		case .shows:
			return minutes > 0 ? L10n.recapMinutes(minutes) : L10n.recapEpisodes(count)
		case .literatures:
			return count > 0 ? L10n.recapChapters(count) : nil
		case .games, .studios, .genres, .themes:
			return minutes > 0 ? L10n.recapMinutes(minutes) : nil
		case .voices:
			return count > 0 ? L10n.recapCharacters(count) : nil
		case .creators:
			let titles: String? = count > 0 ? L10n.recapTitles(count) : nil
			let detail = [recapEntry.attributes.role, titles].compactMap { $0 }.joined(separator: " · ")
			return detail.isEmpty ? nil : detail
		case .characters:
			return nil
		}
	}

	/// Returns the top genres or themes of the given recap.
	///
	/// - Parameter recapItem: The recap of genres or themes.
	///
	/// - Returns: The top models of the recap.
	func genreCardModels(for recapItem: RecapItem) -> [KurozoraItem] {
		return self.recapEntries(of: recapItem)
			.prefix(ReCapGenreLockupCollectionViewCell.maximumNameCount)
			.compactMap { self.models.model(for: $0) }
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let headerCellConfiguration = self.getConfiguredHeaderCell()
		let titleCellConfiguration = self.getConfiguredTitleCell()
		let genreCellConfiguration = self.getConfiguredGenreCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let profileCellConfiguration = self.getConfiguredProfileCell()
		let statCellConfiguration = self.getConfiguredStatCell()
		let comparisonCellConfiguration = self.getConfiguredComparisonCell()
		let milestoneCellConfiguration = self.getConfiguredMilestoneCell()
		let keepTrackingCellConfiguration = self.getConfiguredKeepTrackingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let recapSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch recapSection {
			case .header:
				return collectionView.dequeueConfiguredReusableCell(using: headerCellConfiguration, for: indexPath, item: itemKind)
			case .topShows, .topLiteratures, .topGames, .topByMonth:
				return collectionView.dequeueConfiguredReusableCell(using: titleCellConfiguration, for: indexPath, item: itemKind)
			case .topGenres, .topThemes:
				return collectionView.dequeueConfiguredReusableCell(using: genreCellConfiguration, for: indexPath, item: itemKind)
			case .topStudios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .topCharacters, .topVoices, .topCreators:
				return collectionView.dequeueConfiguredReusableCell(using: profileCellConfiguration, for: indexPath, item: itemKind)
			case .stats:
				return collectionView.dequeueConfiguredReusableCell(using: statCellConfiguration, for: indexPath, item: itemKind)
			case .comparisons:
				return collectionView.dequeueConfiguredReusableCell(using: comparisonCellConfiguration, for: indexPath, item: itemKind)
			case .milestones:
				return collectionView.dequeueConfiguredReusableCell(using: milestoneCellConfiguration, for: indexPath, item: itemKind)
			case .keepTracking:
				return collectionView.dequeueConfiguredReusableCell(using: keepTrackingCellConfiguration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			let title: String?
			let subtitle: String?

			switch sectionLayoutKind {
			case .header, .milestones, .keepTracking:
				return nil
			case .topByMonth(let recapItemType):
				title = self.byMonthSectionTitle(for: recapItemType)
				subtitle = nil
			case .topShows(let recap), .topGames(let recap), .topLiteratures(let recap):
				title = self.sectionTitle(for: recap)
				subtitle = L10n.totalSeries(recap.attributes.totalSeriesCount)
			case .topGenres(let recap), .topThemes(let recap),
			     .topStudios(let recap), .topCharacters(let recap), .topVoices(let recap), .topCreators(let recap):
				title = self.sectionTitle(for: recap)
				subtitle = nil
			case .stats(let group):
				title = group.title
				subtitle = nil
			case .comparisons:
				title = L10n.recapRememberLastYear
				subtitle = nil
			}

			titleHeaderCollectionReusableView.configure(withTitle: title, subtitle, segueID: nil, separatorIsHidden: true)

			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.cache = [:]
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.recapItems.isEmpty {
			let now = Date.now.components

			if self.year == now.year, self.selectedMonth == now.month {
				let title: String

				if let month = Month(rawValue: self.selectedMonth) {
					title = L10n.recapInProgressMonth(month.name, month.next.name)
				} else {
					title = L10n.recapInProgressGeneric
				}

				self.appendHeader(title, rollingText: nil)
				self.snapshot.appendSections([.keepTracking])
				self.snapshot.appendItems([.keepTracking], toSection: .keepTracking)
			}
		} else {
			let periodName = self.periodName
			self.appendHeader(L10n.recapDefiningSeries(periodName), rollingText: periodName)

			for recapItem in self.recapItems {
				self.appendSection(for: recapItem)
			}

			for recapItemType in [RecapItemType.shows, .literatures, .games] {
				self.appendByMonthSection(for: recapItemType)
			}

			for group in ReCapStatCard.Group.allCases {
				guard let statCards = self.statCards[group], !statCards.isEmpty else { continue }
				self.snapshot.appendSections([.stats(group)])
				self.snapshot.appendItems(statCards.map { .statCard($0) }, toSection: .stats(group))
			}

			let comparisons = self.comparisons
			let comparisonTypes = self.recapItems.map(\.attributes.recapItemType).filter { comparisons[$0] != nil }

			if !comparisonTypes.isEmpty {
				self.snapshot.appendSections([.comparisons])
				self.snapshot.appendItems(comparisonTypes.map { .comparison($0) }, toSection: .comparisons)
			}

			self.appendHeader(L10n.recapFinaleMilestones, rollingText: nil)

			let milestoneItems: [ItemKind] = self.milestones.map { .recapItem($0.recapItem, milestoneKind: $0.kind) }

			if !milestoneItems.isEmpty {
				self.snapshot.appendSections([.milestones(false)])
				self.snapshot.appendItems(milestoneItems, toSection: .milestones(false))
			}

			if let recapItem = self.topPercentileRecapItem {
				self.snapshot.appendSections([.milestones(true)])
				self.snapshot.appendItems([.recapItem(recapItem, milestoneKind: .topPercentile)], toSection: .milestones(true))
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}

	/// Appends a header section with the given title.
	///
	/// - Parameters:
	///    - title: The title of the header.
	///    - rollingText: The part of the title that rolls into place.
	private func appendHeader(_ title: String, rollingText: String?) {
		let section = SectionLayoutKind.header(title, rollingText: rollingText)
		self.snapshot.appendSections([section])
		self.snapshot.appendItems([.string(title, section: section)], toSection: section)
	}

	/// Returns the title of the section that shows the top titles of each month.
	///
	/// - Parameter recapItemType: The type of the titles.
	///
	/// - Returns: The title of the section.
	func byMonthSectionTitle(for recapItemType: RecapItemType) -> String {
		switch recapItemType {
		case .literatures: return L10n.recapTopMangaByMonth
		case .games: return L10n.recapTopGamesByMonth
		default: return L10n.recapTopAnimeByMonth
		}
	}

	/// Appends the section that shows the top titles of each month of the given type.
	///
	/// - Parameter recapItemType: The type of the titles.
	private func appendByMonthSection(for recapItemType: RecapItemType) {
		let section = SectionLayoutKind.topByMonth(recapItemType)
		var itemKinds: [ItemKind] = []

		for (month, recapEntry) in self.monthlyTopEntries[recapItemType] ?? [] {
			guard let model = self.models.model(for: recapEntry) else { continue }

			let itemKind = ItemKind.monthlyTitle(recapItemType, month: month, id: model.id)
			self.cache[itemKind] = model
			itemKinds.append(itemKind)
		}

		guard !itemKinds.isEmpty else { return }

		self.snapshot.appendSections([section])
		self.snapshot.appendItems(itemKinds, toSection: section)
	}

	/// Appends the section that shows the given recap item.
	///
	/// - Parameter recapItem: The recap item to show.
	private func appendSection(for recapItem: RecapItem) {
		let recapItemType = recapItem.attributes.recapItemType
		let recapEntries = self.recapEntries(of: recapItem)
		let section: SectionLayoutKind
		var itemKinds: [ItemKind] = []

		switch recapItemType {
		case .shows:
			section = .topShows(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.shows?.data.first else { continue }
				let itemKind = ItemKind.showIdentity(identity, detail: self.detail(for: recapEntry, of: recapItemType), section: section)
				self.cache[itemKind] = self.models.shows[identity.id]
				itemKinds.append(itemKind)
			}
		case .literatures:
			section = .topLiteratures(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.literatures?.data.first else { continue }
				let itemKind = ItemKind.literatureIdentity(identity, detail: self.detail(for: recapEntry, of: recapItemType), section: section)
				self.cache[itemKind] = self.models.literatures[identity.id]
				itemKinds.append(itemKind)
			}
		case .games:
			section = .topGames(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.games?.data.first else { continue }
				let itemKind = ItemKind.gameIdentity(identity, detail: self.detail(for: recapEntry, of: recapItemType), section: section)
				self.cache[itemKind] = self.models.games[identity.id]
				itemKinds.append(itemKind)
			}
		case .genres, .themes:
			section = recapItemType == .genres ? .topGenres(recapItem) : .topThemes(recapItem)
			if !self.genreCardModels(for: recapItem).isEmpty {
				itemKinds = [.genreCard(recapItem)]
			}
		case .studios:
			section = .topStudios(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.studios?.data.first else { continue }
				let itemKind = ItemKind.studioIdentity(identity, detail: self.detail(for: recapEntry, of: recapItemType), section: section)
				self.cache[itemKind] = self.models.studios[identity.id]
				itemKinds.append(itemKind)
			}
		case .characters:
			section = .topCharacters(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.characters?.data.first else { continue }
				let itemKind = ItemKind.characterIdentity(identity, section: section)
				self.cache[itemKind] = self.models.characters[identity.id]
				itemKinds.append(itemKind)
			}
		case .voices, .creators:
			section = recapItemType == .voices ? .topVoices(recapItem) : .topCreators(recapItem)
			for recapEntry in recapEntries {
				guard let identity = recapEntry.relationships?.people?.data.first else { continue }
				let itemKind = ItemKind.personIdentity(identity, detail: self.detail(for: recapEntry, of: recapItemType), section: section)
				self.cache[itemKind] = self.models.people[identity.id]
				itemKinds.append(itemKind)
			}
		}

		guard !itemKinds.isEmpty else { return }

		self.snapshot.appendSections([section])
		self.snapshot.appendItems(itemKinds, toSection: section)
	}
}

// MARK: - Cell Configuration
extension ReCapCollectionViewController {
	func getConfiguredHeaderCell() -> UICollectionView.CellRegistration<ReCapHeaderCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapHeaderCollectionViewCell, ItemKind> { reCapHeaderCollectionViewCell, _, itemKind in
			switch itemKind {
			case .string(let title, let section):
				guard case .header(_, let rollingText) = section else { return }
				reCapHeaderCollectionViewCell.configure(using: title, rollingText: rollingText)
			default: break
			}
		}
	}

	func getConfiguredTitleCell() -> UICollectionView.CellRegistration<ReCapTitleLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapTitleLockupCollectionViewCell, ItemKind> { [weak self] titleLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			let rank = indexPath.item + 1
			let showsSeparator = indexPath.item % 2 == 1

			switch itemKind {
			case .showIdentity(_, let detail, _):
				let show: Show? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)
				titleLockupCollectionViewCell.configure(using: show, rank: rank, detail: detail, showsSeparator: showsSeparator)
			case .literatureIdentity(_, let detail, _):
				let literature: Literature? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Literature>.self, identity: LiteratureIdentity.self)
				titleLockupCollectionViewCell.configure(using: literature, rank: rank, detail: detail, showsSeparator: showsSeparator)
			case .gameIdentity(_, let detail, _):
				let game: Game? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Game>.self, identity: GameIdentity.self)
				titleLockupCollectionViewCell.configure(using: game, rank: rank, detail: detail, showsSeparator: showsSeparator)
			case .monthlyTitle(_, let month, _):
				let eyebrow = Month(rawValue: month)?.name
				switch self.cache[itemKind] {
				case let show as Show:
					titleLockupCollectionViewCell.configure(using: show, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: showsSeparator)
				case let literature as Literature:
					titleLockupCollectionViewCell.configure(using: literature, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: showsSeparator)
				case let game as Game:
					titleLockupCollectionViewCell.configure(using: game, rank: nil, eyebrow: eyebrow, detail: nil, showsSeparator: showsSeparator)
				default:
					break
				}
			default: break
			}
		}
	}

	func getConfiguredKeepTrackingCell() -> UICollectionView.CellRegistration<ReCapKeepTrackingCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapKeepTrackingCollectionViewCell, ItemKind> { [weak self] keepTrackingCollectionViewCell, _, _ in
			keepTrackingCollectionViewCell.buttonPressedHandler = { [weak self] in
				self?.keepTrackingButtonPressed()
			}
		}
	}

	func getConfiguredGenreCell() -> UICollectionView.CellRegistration<ReCapGenreLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapGenreLockupCollectionViewCell, ItemKind> { [weak self] genreLockupCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .genreCard(let recapItem):
				let models = self.genreCardModels(for: recapItem)
				let names = models.compactMap { model -> String? in
					switch model {
					case let genre as Genre: return genre.attributes.name
					case let theme as Theme: return theme.attributes.name
					default: return nil
					}
				}

				genreLockupCollectionViewCell.configure(using: names, colors: self.recapColors)
				genreLockupCollectionViewCell.nameSelectedHandler = { [weak self] index in
					guard let model = models[safe: index] else { return }
					self?.showDetails(of: model)
				}
				genreLockupCollectionViewCell.shareButton.shareHandler = { [weak self] shareButton in
					guard let self = self else { return }
					self.share(self.genreShareCard(for: recapItem), button: shareButton)
				}
				self.configure(genreLockupCollectionViewCell.contextMenuHandler, for: models)
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity(_, let detail, _):
				let studio: Studio? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Studio>.self, identity: StudioIdentity.self)
				studioLockupCollectionViewCell.configure(using: studio, rank: indexPath.item + 1, detail: detail)
			default: break
			}
		}
	}

	func getConfiguredProfileCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] profileLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Character>.self, identity: CharacterIdentity.self)
				profileLockupCollectionViewCell.configure(using: character, rank: indexPath.item + 1)
			case .personIdentity(_, let detail, _):
				let person: Person? = self.fetchModelOrTriggerSectionFetch(for: itemKind, response: ResourceCollection<Person>.self, identity: PersonIdentity.self)
				profileLockupCollectionViewCell.configure(using: person, detail: detail, rank: indexPath.item + 1)
			default: break
			}
		}
	}

	func getConfiguredStatCell() -> UICollectionView.CellRegistration<ReCapStatLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapStatLockupCollectionViewCell, ItemKind> { statLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .statCard(let statCard):
				statLockupCollectionViewCell.configure(using: statCard)
			default: break
			}
		}
	}

	func getConfiguredComparisonCell() -> UICollectionView.CellRegistration<ReCapComparisonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapComparisonLockupCollectionViewCell, ItemKind> { [weak self] comparisonLockupCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .comparison(let recapItemType):
				guard let comparison = self.comparisons[recapItemType] else { return }
				comparisonLockupCollectionViewCell.configure(using: comparison, colors: self.recapColors)
				comparisonLockupCollectionViewCell.entrySelectedHandler = { [weak self] index in
					guard let entry = comparison.entries[safe: index] else { return }
					self?.showDetails(of: entry.model)
				}
				comparisonLockupCollectionViewCell.shareButton.shareHandler = { [weak self] shareButton in
					guard let self = self else { return }
					self.share(self.comparisonShareCard(for: recapItemType), button: shareButton)
				}
				self.configure(comparisonLockupCollectionViewCell.contextMenuHandler, for: comparison.entries.map(\.model))
			default: break
			}
		}
	}

	func getConfiguredMilestoneCell() -> UICollectionView.CellRegistration<ReCapMilestoneCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapMilestoneCollectionViewCell, ItemKind> { [weak self] reCapMilestoneCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .recapItem(let recapItem, let milestoneKind):
				let milestone = self.milestone(for: recapItem, milestoneKind: milestoneKind)
				let models = milestone.artworks.map(\.model)
				reCapMilestoneCollectionViewCell.configure(using: milestone)
				reCapMilestoneCollectionViewCell.artworkSelectedHandler = { [weak self] index in
					guard let model = models[safe: index] else { return }
					self?.showDetails(of: model)
				}
				self.configure(reCapMilestoneCollectionViewCell.contextMenuHandler, for: models)
			default: break
			}
		}
	}
}
