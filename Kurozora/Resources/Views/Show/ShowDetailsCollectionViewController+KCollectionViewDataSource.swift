//
//  ShowDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

extension ShowDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			InformationCollectionViewCell.self,
			MusicLockupCollectionViewCell.self,
			SosumiShowCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let seasonCellConfiguration = self.getConfiguredSeasonCell()
		let castCellConfiguration = self.getConfiguredCastCell()
		let studioShowCellConfiguration = self.getConfiguredStudioShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let showDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch showDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.showDetailHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .show(let show, _):
					showDetailHeaderCollectionViewCell?.show = show
				default: break
				}
				return showDetailHeaderCollectionViewCell
			case .badge:
				let showDetailBadge = ShowDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = showDetailBadge == ShowDetail.Badge.rating ? R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier : R.reuseIdentifier.badgeCollectionViewCell.identifier
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.showDetailBage = showDetailBadge
				switch itemKind {
				case .show(let show, _):
					badgeCollectionViewCell?.show = show
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.ratingCollectionViewCell, for: indexPath)
				ratingCollectionViewCell?.delegate = self
				switch itemKind {
				case .show(let show, _):
					ratingCollectionViewCell?.configure(using: show)
				default: break
				}
				return ratingCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .show(let show, _):
					informationCollectionViewCell?.configure(using: show, for: ShowDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .seasons:
				return collectionView.dequeueConfiguredReusableCell(using: seasonCellConfiguration, for: indexPath, item: itemKind)
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .songs:
				let musicLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.musicLockupCollectionViewCell, for: indexPath)
				musicLockupCollectionViewCell?.delegate = self
				switch itemKind {
				case .showSong(let showSong, _):
					musicLockupCollectionViewCell?.configure(using: showSong, at: indexPath)
				default: break
				}
				return musicLockupCollectionViewCell
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShows:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiShowCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.sosumiShowCollectionViewCell, for: indexPath)
				switch itemKind {
				case .show(let show, _):
					sosumiShowCollectionViewCell?.copyrightText = show.attributes.copyright
				default: break
				}
				return sosumiShowCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let showDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = showDetailSection != .moreByStudio ? showDetailSection.stringValue : "\(showDetailSection.stringValue) \(self.studio.attributes.name)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: showDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] showDetailSection in
			guard let self = self else { return }
			switch showDetailSection {
			case .header:
				self.snapshot.appendSections([showDetailSection])
				self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
			case .badge:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.Badge.allCases.forEach { _ in
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .synopsis:
				if let synopsis = self.show.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([showDetailSection])
				self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
			case .information:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .seasons:
				if !self.seasonIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let seasonIdentityItems: [ItemKind] = self.seasonIdentities.map { seasonIdentity in
						return .seasonIdentity(seasonIdentity)
					}
					self.snapshot.appendItems(seasonIdentityItems, toSection: showDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						return .castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: showDetailSection)
				}
			case .songs:
				if !self.showSongs.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let showSongItems: [ItemKind] = self.showSongs.map { showSong in
						return .showSong(showSong)
					}
					self.snapshot.appendItems(showSongItems, toSection: showDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						return .studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: showDetailSection)
				}
			case .moreByStudio:
				if !self.studioShowIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let studioShowIdentyItems: [ItemKind] = self.studioShowIdentities.map { studioShowIdentity in
						return .showIdentity(studioShowIdentity)
					}
					self.snapshot.appendItems(studioShowIdentyItems, toSection: showDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						return .relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: showDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.show.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([showDetailSection])
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchStudioShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.studioShows[indexPath] else { return nil }
		return show
	}

	func fetchCast(at indexPath: IndexPath) -> Cast? {
		guard let cast = self.cast[indexPath] else { return nil }
		return cast
	}

	func fetchSeason(at indexPath: IndexPath) -> Season? {
		guard let season = self.seasons[indexPath] else { return nil }
		return season
	}

	func fetchStudio(at indexPath: IndexPath) -> Studio? {
		guard let studio = self.studios[indexPath] else { return nil }
		return studio
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension ShowDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.castCollectionViewCell)) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity(let castIdentitiy, _):
				let cast = self.fetchCast(at: indexPath)

				if cast == nil {
					Task {
						do {
							let castResponse = try await KService.getDetails(forCast: castIdentitiy).value
							self.cast[indexPath] = castResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				castCollectionViewCell.delegate = self
				castCollectionViewCell.configure(using: cast)
			default: return
			}
		}
	}

	func getConfiguredStudioShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchStudioShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.studioShows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.configure(using: show)
			default: return
			}
		}
	}

	func getConfiguredSeasonCell() -> UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.seasonLockupCollectionViewCell)) { [weak self] seasonLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .seasonIdentity(let seasonIdentity, _):
				let season = self.fetchSeason(at: indexPath)

				if season == nil {
					Task {
						do {
							let seasonResponse = try await KService.getDetails(forSeason: seasonIdentity).value

							self.seasons[indexPath] = seasonResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				seasonLockupCollectionViewCell.configure(using: season)
			default: return
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.studioLockupCollectionViewCell)) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity(let studioIdentity, _):
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

	func getConfiguredRelatedShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { smallLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			default: return
			}
		}
	}
}
