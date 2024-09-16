//
//  StudioDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension StudioDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			BadgeCollectionViewCell.self,
			RatingBadgeCollectionViewCell.self,
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()
		let gameCellRegistration = self.getConfiguredGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let studioDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch studioDetailSection {
			case .header:
				let studioHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.studioHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .studio(let studio, _):
					studioHeaderCollectionViewCell?.configure(using: studio)
				default: break
				}
				return studioHeaderCollectionViewCell
			case .badges:
				let studioDetailBadge = StudioDetail.Badge(rawValue: indexPath.item) ?? .tvRating
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailBadge.identifierString, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .studio(let studio, _):
					badgeCollectionViewCell?.configureCell(with: studio, studioDetailBadge: studioDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				switch itemKind {
				case .studio(let studio, _):
					textViewCollectionViewCell?.textViewContent = studio.attributes.about
				default: break
				}
				return textViewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .studio(let studio, _):
					informationCollectionViewCell?.configure(using: studio, for: StudioDetail.Information(rawValue: indexPath.item) ?? .websites)
				default: break
				}
				return informationCollectionViewCell
			case .shows, .literatures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .games:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let studioDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: studioDetailSection.stringValue, indexPath: indexPath, segueID: studioDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] studioDetailSection in
			guard let self = self else { return }

			switch studioDetailSection {
			case .header:
				self.snapshot.appendSections([studioDetailSection])
				self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
			case .badges:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.Badge.allCases.forEach { studioDetailBadge in
					switch studioDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
					}
				}
			case .about:
				if let about = self.studio.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .information:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						return .showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: studioDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						return .literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: studioDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						return .gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: studioDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func fetchLiterature(at indexPath: IndexPath) -> Literature? {
		guard let literature = self.literatures[indexPath] else { return nil }
		return literature
	}

	func fetchGame(at indexPath: IndexPath) -> Game? {
		guard let game = self.games[indexPath] else { return nil }
		return game
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension StudioDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
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

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
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
}
