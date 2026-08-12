//
//  KotodamaStatsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaStatsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The player's record.
	var stats: KotodamaUserStats?

	/// The buckets of the player's guess distribution.
	var distribution: [KotodamaDistributionBar] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	private var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.kotodamaStats
		self.configureDataSource()

		Task { [weak self] in
			await self?.fetchStats()
		}
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		self.collectionView.backgroundView?.alpha = 0

		if let image = UIImage(systemName: "chart.bar.doc.horizontal") {
			self.emptyBackgroundView.configureImageView(image: image)
		}
		self.emptyBackgroundView.configureLabels(
			title: L10n.kotodamaNoStats,
			detail: L10n.kotodamaNoStatsDescription
		)
	}

	override func handleRefreshControl() {
		Task { [weak self] in
			await self?.fetchStats()
		}
	}

	/// Fades the empty data view in or out according to the number of items.
	func toggleEmptyDataView() {
		if self.stats == nil {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the player's record.
	private func fetchStats() async {
		do {
			let response = try await KService.myKotodamaStats().response()
			self.stats = response.data.first
		} catch {
			self.stats = nil
		}

		self.distribution = Self.buildDistribution(from: self.stats?.attributes.guessDistribution ?? [:])
		self._prefersActivityIndicatorHidden = true
		self.configureEmptyDataView()
		self.updateDataSource()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	/// Returns one bucket per guess count, measured against the busiest bucket.
	///
	/// - Parameter guessDistribution: The number of wins per guess count.
	///
	/// - Returns: The buckets to draw.
	private static func buildDistribution(from guessDistribution: [String: Int]) -> [KotodamaDistributionBar] {
		let busiest = guessDistribution.values.max() ?? 0
		let highestBucket = guessDistribution.keys.compactMap(Int.init).max() ?? Kotodama.maxGuesses

		return (1...max(highestBucket, Kotodama.maxGuesses)).map { guessCount in
			KotodamaDistributionBar(
				guessCount: guessCount,
				wins: guessDistribution["\(guessCount)"] ?? 0,
				busiest: busiest
			)
		}
	}
}
