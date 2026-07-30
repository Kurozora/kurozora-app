//
//  KotodamaStatsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension KotodamaStatsCollectionViewController {
	override func configureDataSource() {
		let statCellRegistration = UICollectionView.CellRegistration<KotodamaStatCollectionViewCell, KotodamaStat> { cell, _, stat in
			cell.configure(using: stat)
		}

		let distributionCellRegistration = UICollectionView.CellRegistration<KotodamaDistributionCollectionViewCell, KotodamaDistributionBar> { cell, _, bar in
			cell.configure(using: bar)
		}

		let headingCellRegistration = UICollectionView.CellRegistration<KotodamaHeadingCollectionViewCell, KotodamaHeading> { cell, _, heading in
			cell.configure(using: heading)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
			collectionView: self.collectionView
		) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .stat(let stat):
				return collectionView.dequeueConfiguredReusableCell(
					using: statCellRegistration,
					for: indexPath,
					item: stat
				)
			case .distribution(let bar):
				return collectionView.dequeueConfiguredReusableCell(
					using: distributionCellRegistration,
					for: indexPath,
					item: bar
				)
			case .heading(let heading):
				return collectionView.dequeueConfiguredReusableCell(
					using: headingCellRegistration,
					for: indexPath,
					item: heading
				)
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if let attributes = self.stats?.attributes {
			let winRate = NumberFormatter.localizedString(
				from: NSNumber(value: attributes.winRate),
				number: .percent
			)
			let averageGuesses = NumberFormatter.localizedString(
				from: NSNumber(value: attributes.averageGuesses),
				number: .decimal
			)

			snapshot.appendSections([.summary, .distributionTitle, .distribution, .average])
			snapshot.appendItems([
				.stat(KotodamaStat(title: L10n.kotodamaGamesPlayed, value: "\(attributes.gamesPlayed)")),
				.stat(KotodamaStat(title: L10n.kotodamaWinRate, value: winRate)),
				.stat(KotodamaStat(title: L10n.kotodamaCurrentStreak, value: "\(attributes.currentStreak)")),
				.stat(KotodamaStat(title: L10n.kotodamaBestStreak, value: "\(attributes.maxStreak)"))
			], toSection: .summary)
			snapshot.appendItems([
				.heading(KotodamaHeading(text: L10n.kotodamaGuessDistribution, isProminent: true))
			], toSection: .distributionTitle)
			snapshot.appendItems(self.distribution.map { ItemKind.distribution($0) }, toSection: .distribution)
			snapshot.appendItems([
				.heading(KotodamaHeading(
					text: String(format: L10n.kotodamaAverageGuessesValue, averageGuesses),
					isProminent: false
				))
			], toSection: .average)
		}

		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}

// MARK: - SectionLayoutKind
extension KotodamaStatsCollectionViewController {
	/// The set of available sections.
	enum SectionLayoutKind: Int, CaseIterable {
		/// The headline values of the record.
		case summary

		/// The heading above the guess distribution.
		case distributionTitle

		/// The buckets of the guess distribution.
		case distribution

		/// The average number of guesses.
		case average
	}
}

// MARK: - ItemKind
extension KotodamaStatsCollectionViewController {
	/// The set of available items.
	enum ItemKind: Hashable {
		/// A headline value.
		case stat(KotodamaStat)

		/// A bucket of the guess distribution.
		case distribution(KotodamaDistributionBar)

		/// A line of text between sections.
		case heading(KotodamaHeading)
	}
}
