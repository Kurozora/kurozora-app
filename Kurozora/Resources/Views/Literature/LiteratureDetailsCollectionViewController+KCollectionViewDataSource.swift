//
//  LiteratureDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

extension LiteratureDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			InformationCollectionViewCell.self,
			MusicLockupCollectionViewCell.self,
			SosumiCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let castCellConfiguration = self.getConfiguredCastCell()
		let studioLiteratureCellConfiguration = self.getConfiguredStudioLiteratureCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedLiteratureCellConfiguration = self.getConfiguredRelatedLiteratureCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let literatureDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch literatureDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.showDetailHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .literature(let literature, _):
					showDetailHeaderCollectionViewCell?.configure(using: literature)
				default: break
				}
				return showDetailHeaderCollectionViewCell
			case .badge:
				let literatureDetailBadge = LiteratureDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = literatureDetailBadge == LiteratureDetail.Badge.rating ? R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier : R.reuseIdentifier.badgeCollectionViewCell.identifier
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .literature(let literature, _):
					badgeCollectionViewCell?.configureCell(with: literature, literatureDetailBadge: literatureDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.literature.attributes.synopsis
				return textViewCollectionViewCell
			case .rating, .reviews:
				let literatureDetailRating = LiteratureDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: literatureDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .literature(let literature, _):
					if let stats = literature.attributes.stats {
						switch literatureDetailRating {
						case .average:
							(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: literature)
						case .sentiment:
							(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
						case .bar:
							(ratingCollectionViewCell as? RatingBarCollectionViewCell)?.configure(using: stats)
						}
					}
				default: break
				}
				return ratingCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .literature(let literature, _):
					informationCollectionViewCell?.configure(using: literature, for: LiteratureDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedLiteratures, .relatedShows:
				return collectionView.dequeueConfiguredReusableCell(using: relatedLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGames:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.sosumiCollectionViewCell, for: indexPath)
				switch itemKind {
				case .literature(let literature, _):
					sosumiCollectionViewCell?.copyrightText = literature.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let literatureDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = literatureDetailSection != .moreByStudio ? literatureDetailSection.stringValue : "\(literatureDetailSection.stringValue) \(self.literature.attributes.studio ?? Trans.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: literatureDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] literatureDetailSection in
			guard let self = self else { return }
			switch literatureDetailSection {
			case .header:
				self.snapshot.appendSections([literatureDetailSection])
				self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
			case .badge:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Badge.allCases.forEach { literatureDetailBadge in
					switch literatureDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.literature.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .reviews: break
			case .information:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						return .castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: literatureDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						return .studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: literatureDetailSection)
				}
			case .moreByStudio:
				if !self.studioLiteratureIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let studioLiteratureIdentyItems: [ItemKind] = self.studioLiteratureIdentities.map { studioLiteratureIdentity in
						return .literatureIdentity(studioLiteratureIdentity)
					}
					self.snapshot.appendItems(studioLiteratureIdentyItems, toSection: literatureDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						return .relatedLiterature(relatedLiterature)
					}
					self.snapshot.appendItems(relatedLiteratureItems, toSection: literatureDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						return .relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: literatureDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						return .relatedGame(relatedGame)
					}
					self.snapshot.appendItems(relatedGameItems, toSection: literatureDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.literature.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchStudioLiterature(at indexPath: IndexPath) -> Literature? {
		guard let literature = self.studioLiteratures[indexPath] else { return nil }
		return literature
	}

	func fetchCast(at indexPath: IndexPath) -> Cast? {
		guard let cast = self.cast[indexPath] else { return nil }
		return cast
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

extension LiteratureDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity(let castIdentitiy, _):
				let cast = self.fetchCast(at: indexPath)

				if cast == nil {
					Task {
						do {
							let castResponse = try await KService.getDetails(forLiteratureCast: castIdentitiy).value
							self.cast[indexPath] = castResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				characterLockupCollectionViewCell.configure(using: cast?.relationships.characters.data.first, role: cast?.attributes.role)
			default: return
			}
		}
	}

	func getConfiguredStudioLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity(let literatureIdentity, _):
				let literature = self.fetchStudioLiterature(at: indexPath)

				if literature == nil {
					Task {
						do {
							let literatureResponse = try await KService.getDetails(forLiterature: literatureIdentity).value

							self.studioLiteratures[indexPath] = literatureResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
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

				if studio == nil {
					Task {
						do {
							let studioReponse = try await KService.getDetails(forStudio: studioIdentity).value
							self.studios[indexPath] = studioReponse.data.first
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

	func getConfiguredRelatedLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedLiterature(let relatedLiterature, _):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			default: return
			}
		}
	}

	func getConfiguredRelatedGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { gameLockupCollectionViewCell, _, itemKind in
			gameLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedGame(let relatedGame, _):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
