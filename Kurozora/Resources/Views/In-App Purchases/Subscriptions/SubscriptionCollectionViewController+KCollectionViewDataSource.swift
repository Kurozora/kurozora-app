//
//  SubscriptionCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension SubscriptionCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			PurchaseHeaderCollectionViewCell.self,
			PurchaseStatusCollectionViewCell.self,
			PurchaseButtonCollectionViewCell.self,
			PurchaseFeatureCollectionViewCell.self,
			PurchaseFooterCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let subscriptionSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch subscriptionSection {
			case .header:
				let purchaseHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseHeaderCollectionViewCell, for: indexPath)
				purchaseHeaderCollectionViewCell?.configureCell(using: "Elevate your anime tracking with Kurozora+", secondaryText: "Take your anime tracking to the next level with Kurozora+. Get access to exclusive features like gif profile images, premium app icons, customizable themes, and iCal reminders to never miss an episode. Upgrade to Kurozora+ and get the ultimate anime experience.")
				return purchaseHeaderCollectionViewCell
			case .currentSubscription:
				switch indexPath.item {
				case 0:
					let purchaseButtonCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseButtonCollectionViewCell, for: indexPath)
					purchaseButtonCollectionViewCell?.delegate = self
					switch itemKind {
					case .product(let product, _):
						purchaseButtonCollectionViewCell?.configureCell(using: product, isPurchased: true)
					default:
						break
					}
					return purchaseButtonCollectionViewCell
				default:
					let purchaseStatusCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseStatusCollectionViewCell, for: indexPath)
					switch itemKind {
					case .product(let product, _):
						purchaseStatusCollectionViewCell?.configureCell(using: product, status: self.status)
					default:
						break
					}
					return purchaseStatusCollectionViewCell
				}
			case .subscriptions:
				let purchaseButtonCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseButtonCollectionViewCell, for: indexPath)
				purchaseButtonCollectionViewCell?.delegate = self
				switch itemKind {
				case .product(let product, _):
					purchaseButtonCollectionViewCell?.configureCell(using: product)
				default:
					break
				}
				return purchaseButtonCollectionViewCell
			case .features:
				let purchaseFeatureCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseFeatureCollectionViewCell, for: indexPath)
				switch itemKind {
				case .subscriptionFeature(let subscriptionFeature, _):
					purchaseFeatureCollectionViewCell?.configureCell(using: subscriptionFeature)
				default:
					break
				}
				return purchaseFeatureCollectionViewCell
			case .footer:
				let purchaseFooterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseFooterCollectionViewCell, for: indexPath)
				purchaseFooterCollectionViewCell?.delegate = self
				purchaseFooterCollectionViewCell?.configureCell(using: Trans.subscriptionFooter, termsOfUseButtonText: Trans.termsOfUse, privacyButtonText: Trans.privacyPolicy, restorePurchaseButtonText: Trans.restorePurchase)
				return purchaseFooterCollectionViewCell
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] sectionLayoutKind in
			guard let self = self else { return }

			switch sectionLayoutKind {
			case .header:
				self.snapshot.appendSections([sectionLayoutKind])
				self.snapshot.appendItems([.other()], toSection: sectionLayoutKind)
			case .currentSubscription:
				if let currentSubscription = self.currentSubscription {
					let itemKinds: [ItemKind] = [
						.product(currentSubscription),
						.product(currentSubscription)
					]
					self.snapshot.appendSections([sectionLayoutKind])
					self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
				}
			case .subscriptions:
				let itemKinds: [ItemKind] = self.products.map { product in
						return .product(product)
				}
				self.snapshot.appendSections([sectionLayoutKind])
				self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
			case .features:
				let itemKinds: [ItemKind] = self.subscriptionFeatures.map { subscriptionFeature in
					return .subscriptionFeature(subscriptionFeature)
				}
				self.snapshot.appendSections([sectionLayoutKind])
				self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
			case .footer:
				self.snapshot.appendSections([sectionLayoutKind])
				self.snapshot.appendItems([.other()], toSection: sectionLayoutKind)
			}
		}

		self.dataSource.apply(self.snapshot)
	}
}
