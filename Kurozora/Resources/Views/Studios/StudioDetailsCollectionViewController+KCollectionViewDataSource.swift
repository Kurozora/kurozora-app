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
					informationCollectionViewCell?.configure(using: studio, for: StudioInformation(rawValue: indexPath.item) ?? .website)
				default: break
				}
				return informationCollectionViewCell
			case .shows:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
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
			case .about:
				if let about = self.studio.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .information:
				self.snapshot.appendSections([studioDetailSection])
				StudioInformation.allCases.forEach { _ in
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
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
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
			let show = self.fetchShow(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

			if dataRequest == nil && show == nil {
				switch itemKind {
				case .showIdentity(let showIdentity, _):
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				default: break
				}
			}

			smallLockupCollectionViewCell.dataRequest = dataRequest
			smallLockupCollectionViewCell.delegate = self
			smallLockupCollectionViewCell.configure(using: show)
		}
	}
}
