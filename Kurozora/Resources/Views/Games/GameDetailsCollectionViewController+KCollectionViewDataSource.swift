//
//  GameDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

extension GameDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
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
		let studioGameCellConfiguration = self.getConfiguredStudioGameCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let gameDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch gameDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.showDetailHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .game(let game, _):
					showDetailHeaderCollectionViewCell?.configure(using: game)
				default: break
				}
				return showDetailHeaderCollectionViewCell
			case .badge:
				let gameDetailBadge = GameDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = gameDetailBadge == GameDetail.Badge.rating ? R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier : R.reuseIdentifier.badgeCollectionViewCell.identifier
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .game(let game, _):
					badgeCollectionViewCell?.configureCell(with: game, gameDetailBadge: gameDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.game.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.ratingCollectionViewCell, for: indexPath)
				ratingCollectionViewCell?.delegate = self
				switch itemKind {
				case .game(let game, _):
					ratingCollectionViewCell?.configure(using: game)
				default: break
				}
				return ratingCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .game(let game, _):
					informationCollectionViewCell?.configure(using: game, for: GameDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGames:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShows, .relatedLiteratures:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.sosumiCollectionViewCell, for: indexPath)
				switch itemKind {
				case .game(let game, _):
					sosumiCollectionViewCell?.copyrightText = game.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let gameDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = gameDetailSection != .moreByStudio ? gameDetailSection.stringValue : "\(gameDetailSection.stringValue) \(self.game.attributes.studio ?? Trans.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: gameDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] gameDetailSection in
			guard let self = self else { return }
			switch gameDetailSection {
			case .header:
				self.snapshot.appendSections([gameDetailSection])
				self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
			case .badge:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.Badge.allCases.forEach { gameDetailBadge in
					switch gameDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.game.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([gameDetailSection])
				self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
			case .information:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						return .castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: gameDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						return .studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: gameDetailSection)
				}
			case .moreByStudio:
				if !self.studioGameIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let studioGameIdentyItems: [ItemKind] = self.studioGameIdentities.map { studioGameIdentity in
						return .gameIdentity(studioGameIdentity)
					}
					self.snapshot.appendItems(studioGameIdentyItems, toSection: gameDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						return .relatedGame(relatedGame)
					}
					self.snapshot.appendItems(relatedGameItems, toSection: gameDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						return .relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: gameDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						return .relatedLiterature(relatedLiterature)
					}
					self.snapshot.appendItems(relatedLiteratureItems, toSection: gameDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.game.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([gameDetailSection])
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchStudioGame(at indexPath: IndexPath) -> Game? {
		guard let game = self.studioGames[indexPath] else { return nil }
		return game
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

extension GameDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.castCollectionViewCell)) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity(let castIdentitiy, _):
				let cast = self.fetchCast(at: indexPath)

				if cast == nil {
					Task {
						do {
							let castResponse = try await KService.getDetails(forGameCast: castIdentitiy).value
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

	func getConfiguredStudioGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity(let gameIdentity, _):
				let game = self.fetchStudioGame(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? gameLockupCollectionViewCell.dataRequest

				if dataRequest == nil && game == nil {
					dataRequest = KService.getDetails(forGame: gameIdentity) { result in
						switch result {
						case .success(let games):
							self.studioGames[indexPath] = games.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				gameLockupCollectionViewCell.dataRequest = dataRequest
				gameLockupCollectionViewCell.configure(using: game)
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

	func getConfiguredRelatedShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { smallLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			case .relatedLiterature(let relatedLiterature, _):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			default: return
			}
		}
	}

	func getConfiguredRelatedGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { gameLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .relatedGame(let relatedGame, _):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
