//
//  HomeCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension HomeCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			BannerLockupCollectionViewCell.self,
			SmallLockupCollectionViewCell.self,
			MediumLockupCollectionViewCell.self,
			LargeLockupCollectionViewCell.self,
			VideoLockupCollectionViewCell.self,
			PersonLockupCollectionViewCell.self,
			CharacterLockupCollectionViewCell.self,
			MusicLockupCollectionViewCell.self,
			LegalCollectionViewCell.self,
			UpcomingLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			if indexPath.section < self.exploreCategories.count {
				// Get a cell of the desired kind.
				let exploreCategorySize = indexPath.section != 0 ? self.exploreCategories[indexPath.section].attributes.exploreCategorySize : .banner

				// Populate the cell with our item description.
				switch item {
				case .show(let show, _):
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCategorySize.identifierString, for: indexPath) as? BaseLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(exploreCategorySize.identifierString)") }
					baseLockupCollectionViewCell.delegate = self
					baseLockupCollectionViewCell.configure(using: show)
					return baseLockupCollectionViewCell
				case .showSong(let showSong, _):
					let reuseIdentifier = R.reuseIdentifier.musicLockupCollectionViewCell.identifier
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MusicLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(reuseIdentifier)") }
					baseLockupCollectionViewCell.delegate = self
					baseLockupCollectionViewCell.configure(using: showSong, at: indexPath, showEpisodes: false, showShow: true)
					return baseLockupCollectionViewCell
				case .genre(let genre, _):
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCategorySize.identifierString, for: indexPath) as? MediumLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(exploreCategorySize.identifierString)") }
					baseLockupCollectionViewCell.configure(using: genre)
					return baseLockupCollectionViewCell
				case .theme(let theme, _):
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCategorySize.identifierString, for: indexPath) as? MediumLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(exploreCategorySize.identifierString)") }
					baseLockupCollectionViewCell.configure(using: theme)
					return baseLockupCollectionViewCell
				case .character(let character, _):
					let reuseIdentifier = R.reuseIdentifier.characterLockupCollectionViewCell.identifier
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CharacterLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(reuseIdentifier)") }
					baseLockupCollectionViewCell.configure(using: character)
					return baseLockupCollectionViewCell
				case .person(let person, _):
					let reuseIdentifier = R.reuseIdentifier.personLockupCollectionViewCell.identifier
					guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PersonLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(reuseIdentifier)") }
					baseLockupCollectionViewCell.configure(using: person)
					return baseLockupCollectionViewCell
				default: break
				}

				// Return the cell.
				return nil
			}

			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			var actionsArray = self.actionsArray.first

			switch indexPath.section {
			case let section where section == collectionView.numberOfSections - 1: // If last section
				return self.createExploreCell(with: .legal, for: indexPath)
			case let section where section == collectionView.numberOfSections - 2: // If before last section
				verticalCollectionCellStyle = .actionButton
				actionsArray = self.actionsArray[1]
			default: break
			}

			let actionBaseExploreCollectionViewCell = self.createExploreCell(with: verticalCollectionCellStyle, for: indexPath) as? ActionBaseExploreCollectionViewCell
			actionBaseExploreCollectionViewCell?.actionItem = actionsArray?[indexPath.item]
			return actionBaseExploreCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let exploreCategoriesCount = self.exploreCategories.count

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.delegate = self

			if indexPath.section < exploreCategoriesCount {
				let exploreCategory = self.exploreCategories[indexPath.section]
				var segueID = ""

				switch exploreCategory.attributes.exploreCategoryType {
				case .shows, .mostPopularShows, .upcomingShows:
					segueID = R.segue.homeCollectionViewController.showsListSegue.identifier
				case .songs:
					segueID = R.segue.homeCollectionViewController.showSongsListSegue.identifier
				case .genres:
					segueID = R.segue.homeCollectionViewController.genresSegue.identifier
				case .themes:
					segueID = R.segue.homeCollectionViewController.themesSegue.identifier
				case .characters:
					segueID = R.segue.homeCollectionViewController.charactersListSegue.identifier
				case .people:
					segueID = R.segue.homeCollectionViewController.peopleListSegue.identifier
				}

				exploreSectionTitleCell.configure(withTitle: exploreCategory.attributes.title, exploreCategory.attributes.description, indexPath: indexPath, segueID: segueID)
			} else {
				exploreSectionTitleCell.configure(withTitle: "Quick Links", indexPath: indexPath)
			}
			// Return the view.
			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		let numberOfSections: Int = exploreCategories.count + 2

		// Initialize data
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		var identifierOffset = 0
		var itemsPerSection = 0

		for section in 0...numberOfSections {
			let sectionHeader = SectionLayoutKind.header()
			snapshot.appendSections([sectionHeader])

			if section < exploreCategories.count {
				let exploreCategoriesSection = exploreCategories[section]

				switch exploreCategories[section].attributes.exploreCategoryType {
				case .shows, .upcomingShows, .mostPopularShows:
					if let shows = exploreCategoriesSection.relationships.shows?.data {
						let showItems: [ItemKind] = shows.map { show in
							return .show(show)
						}
						snapshot.appendItems(showItems, toSection: sectionHeader)
					}
				case .songs:
					if let showSongs = exploreCategoriesSection.relationships.showSongs?.data {
						let showSongsItems: [ItemKind] = showSongs.map { showSong in
							return .showSong(showSong)
						}
						snapshot.appendItems(showSongsItems, toSection: sectionHeader)
					}
				case .genres:
					if let genres = exploreCategoriesSection.relationships.genres?.data {
						let genreItems: [ItemKind] = genres.map { genre in
							return .genre(genre)
						}
						snapshot.appendItems(genreItems, toSection: sectionHeader)
					}
				case .themes:
					if let themes = exploreCategoriesSection.relationships.themes?.data {
						let themeItems: [ItemKind] = themes.map { theme in
							return .theme(theme)
						}
						snapshot.appendItems(themeItems, toSection: sectionHeader)
					}
				case .characters:
					if let characters = exploreCategoriesSection.relationships.characters?.data {
						let characterItems: [ItemKind] = characters.map { character in
							return .character(character)
						}
						snapshot.appendItems(characterItems, toSection: sectionHeader)
					}
				case .people:
					if let people = exploreCategoriesSection.relationships.people?.data {
						let personItems: [ItemKind] = people.map { person in
							return .person(person)
						}
						snapshot.appendItems(personItems, toSection: sectionHeader)
					}
				}
			} else {
				// Get number of items per section
				if section == numberOfSections - 2 {
					itemsPerSection = actionsArray.first?.count ?? itemsPerSection
				} else if section == numberOfSections - 1 {
					itemsPerSection = actionsArray[1].count
				} else {
					itemsPerSection = 1
				}

				// Get max identifier
				let maxIdentifier = identifierOffset + itemsPerSection

				// Append items to section
				let otherItems: [ItemKind] = (identifierOffset..<maxIdentifier).map { index in
					return .other(index)
				}
				snapshot.appendItems(otherItems, toSection: sectionHeader)

				// Update identifier offset
				identifierOffset += itemsPerSection
			}
		}

		self.dataSource.apply(self.snapshot)
	}
}
