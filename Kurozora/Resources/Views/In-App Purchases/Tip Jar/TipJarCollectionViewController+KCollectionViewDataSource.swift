//
//  TipJarCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension TipJarCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			PurchaseHeaderCollectionViewCell.self,
			PurchaseButtonCollectionViewCell.self,
			PurchaseFeatureCollectionViewCell.self,
			PurchaseFooterCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let tipJarSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch tipJarSection {
			case .header:
				let purchaseHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.purchaseHeaderCollectionViewCell, for: indexPath)
				purchaseHeaderCollectionViewCell?.configureCell(using: "Kurozora Tip Jar", secondaryText: """
					The Kurozora app is built by a small team—me and my little sister! We may be small, but we're mighty, and we pour our hearts into making this app as useful and delightful as possible.

					We rely on your support to develop Kurozora. If you find it to be useful to you, please consider supporting us by leaving a tip in the Kurozora Tip Jar. We would like to keep working on and improving Kurozora, so any amount is incredibly appreciated. Please know that even if you don't tip we're still grateful that you use this app.

					Any amount unlocks Pro 🚀
				""")
				return purchaseHeaderCollectionViewCell
			case .products:
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
				case .productFeature(let productFeature, _):
					purchaseFeatureCollectionViewCell?.configureCell(using: productFeature)
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
			case .products:
				let itemKinds: [ItemKind] = self.products.map { product in
						return .product(product)
				}
				self.snapshot.appendSections([sectionLayoutKind])
				self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
			case .features:
				let itemKinds: [ItemKind] = self.productFeatures.map { productFeature in
					return .productFeature(productFeature)
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
