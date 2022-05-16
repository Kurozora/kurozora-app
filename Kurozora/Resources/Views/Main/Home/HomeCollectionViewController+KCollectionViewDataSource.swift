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
			MusicLockupCollectionViewCell.self,
			LegalCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let bannerCellConfiguration = self.getConfiguredBannerCell()
		let largeCellConfiguration = self.getConfiguredLargeCell()
		let mediumCellConfiguration = self.getConfiguredMediumCell()
		let smallShowCellConfiguration = self.getConfiguredSmallCell()
		let upcomingCellConfiguration = self.getConfiguredUpcomingCell()
		let videoCellConfiguration = self.getConfiguredVideoCell()
		let personCellConfiguration = self.getConfiguredPersonCell()
		let characterCellConfiguration = self.getConfiguredCharacterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let showDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch showDetailSection {
			case .banner:
				return collectionView.dequeueConfiguredReusableCell(using: bannerCellConfiguration, for: indexPath, item: itemKind)
			case .small:
				return collectionView.dequeueConfiguredReusableCell(using: smallShowCellConfiguration, for: indexPath, item: itemKind)
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
			case .music:
				switch itemKind {
				case .showSong(let showSong, _):
					let musicLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.musicLockupCollectionViewCell, for: indexPath)
					musicLockupCollectionViewCell?.delegate = self
					musicLockupCollectionViewCell?.configure(using: showSong, at: indexPath, showEpisodes: false, showShow: true)
					return musicLockupCollectionViewCell
				default: return nil
				}
			case .quickLinks:
				switch itemKind {
				case .quickLink(let quickLink, _):
					let actionLinkExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.actionLinkExploreCollectionViewCell, for: indexPath)
					actionLinkExploreCollectionViewCell?.delegate = self
					actionLinkExploreCollectionViewCell?.configure(using: quickLink)
					return actionLinkExploreCollectionViewCell
				default: return nil
				}
			case .quickActions:
				switch itemKind {
				case .quickAction(let quickAction, _):
					let actionButtonExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.actionButtonExploreCollectionViewCell, for: indexPath)
					actionButtonExploreCollectionViewCell?.delegate = self
					actionButtonExploreCollectionViewCell?.configure(using: quickAction)
					return actionButtonExploreCollectionViewCell
				default: return nil
				}
			case .legal:
				let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.legalCollectionViewCell, for: indexPath)
				return legalExploreCollectionViewCell
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			var segueID: String = ""
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.delegate = self

			switch sectionLayoutKind {
			case .banner(let exploreCategory), .video(let exploreCategory), .upcoming(let exploreCategory), .small(let exploreCategory), .large(let exploreCategory):
				segueID = R.segue.homeCollectionViewController.showsListSegue.identifier
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .medium(let exploreCategory):
				switch exploreCategory.attributes.exploreCategoryType {
				case .genres:
					segueID = R.segue.homeCollectionViewController.genresSegue.identifier
				case .themes:
					segueID = R.segue.homeCollectionViewController.themesSegue.identifier
				default: break
				}
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .profile(let exploreCategory):
				switch exploreCategory.attributes.exploreCategoryType {
				case .characters:
					segueID = R.segue.homeCollectionViewController.charactersListSegue.identifier
				case .people:
					segueID = R.segue.homeCollectionViewController.peopleListSegue.identifier
				default: break
				}
				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			case .music(let exploreCategory):
				segueID = R.segue.homeCollectionViewController.showSongsListSegue.identifier
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
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		// Add explore categories
		self.exploreCategories.forEach { exploreCategory in
			var sectionHeader: SectionLayoutKind
			var itemKinds: [ItemKind] = []

			switch exploreCategory.attributes.exploreCategoryType {
			case .mostPopularShows:
				sectionHeader = .banner(exploreCategory)
				if let shows = exploreCategory.relationships.shows?.data {
					itemKinds = shows.map { showIdentity in
						return .showIdentity(showIdentity)
					}
				}
			case .upcomingShows:
				sectionHeader = .upcoming(exploreCategory)
				if let shows = exploreCategory.relationships.shows?.data {
					itemKinds = shows.prefix(10).map { showIdentity in
						return .showIdentity(showIdentity)
					}
				}
			case .shows:
				switch exploreCategory.attributes.exploreCategorySize {
				case .banner:
					sectionHeader = .banner(exploreCategory)
				case .large:
					sectionHeader = .large(exploreCategory)
				case .medium:
					sectionHeader = .medium(exploreCategory)
				case .small:
					sectionHeader = .small(exploreCategory)
				case .upcoming:
					sectionHeader = .upcoming(exploreCategory)
				case .video:
					sectionHeader = .video(exploreCategory)
				}
				if let shows = exploreCategory.relationships.shows?.data {
					itemKinds = shows.prefix(10).map { showIdentity in
						return .showIdentity(showIdentity)
					}
				}
			case .songs:
				sectionHeader = .music(exploreCategory)
				if let showSongs = exploreCategory.relationships.showSongs?.data {
					itemKinds = showSongs.prefix(10).map { showSong in
						return .showSong(showSong)
					}
				}
			case .characters:
				sectionHeader = .profile(exploreCategory)
				if let characters = exploreCategory.relationships.characters?.data {
					itemKinds = characters.prefix(10).map { character in
						return .characterIdentity(character)
					}
				}
			case .people:
				sectionHeader = .profile(exploreCategory)
				if let people = exploreCategory.relationships.people?.data {
					itemKinds = people.prefix(10).map { person in
						return .personIdentity(person)
					}
				}
			case .genres:
				sectionHeader = .medium(exploreCategory)
				if let genres = exploreCategory.relationships.genres?.data {
					itemKinds = genres.prefix(10).map { genre in
						return .genreIdentity(genre)
					}
				}
			case .themes:
				sectionHeader = .medium(exploreCategory)
				if let themes = exploreCategory.relationships.themes?.data {
					itemKinds = themes.prefix(10).map { theme in
						return .themeIdentity(theme)
					}
				}
			}

			self.snapshot.appendSections([sectionHeader])
			self.snapshot.appendItems(itemKinds, toSection: sectionHeader)
		}

		// Add quick links
		let quickLinksSectionHeader = SectionLayoutKind.quickLinks()
		let quickLinkItemKinds: [ItemKind] = self.quickLinks.map { quickLink in
			return .quickLink(quickLink)
		}
		self.snapshot.appendSections([quickLinksSectionHeader])
		self.snapshot.appendItems(quickLinkItemKinds, toSection: quickLinksSectionHeader)

		// Add quick actions
		let quickActionsSectionHeader = SectionLayoutKind.quickActions()
		let quickActionItemKinds: [ItemKind] = self.quickActions.map { quickAction in
			return .quickAction(quickAction)
		}
		self.snapshot.appendSections([quickActionsSectionHeader])
		self.snapshot.appendItems(quickActionItemKinds, toSection: quickActionsSectionHeader)

		// Add legal section
		let legalSectionHeader = SectionLayoutKind.legal()
		self.snapshot.appendSections([legalSectionHeader])
		self.snapshot.appendItems([.legal()], toSection: legalSectionHeader)

		self.dataSource.apply(self.snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func fetchGenre(at indexPath: IndexPath) -> Genre? {
		guard let genre = self.genres[indexPath] else { return nil }
		return genre
	}

	func fetchTheme(at indexPath: IndexPath) -> Theme? {
		guard let theme = self.themes[indexPath] else { return nil }
		return theme
	}

	func fetchPerson(at indexPath: IndexPath) -> Person? {
		guard let person = self.people[indexPath] else { return nil }
		return person
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
