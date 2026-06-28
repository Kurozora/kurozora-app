//
//  DigestCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension DigestCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let bannerCellConfiguration = self.getConfiguredBannerCell()
		let showCellConfiguration = self.getConfiguredShowCell()
		let gameCellConfiguration = self.getConfiguredGameCell()
		let episodeCellConfiguration = self.getConfiguredEpisodeCell()
		let personCellConfiguration = self.getConfiguredPersonCell()
		let momentumCellConfiguration = self.getConfiguredMomentumCell()
		let textCellConfiguration = self.getConfiguredTextCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let section = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch section {
			case .hero:
				switch itemKind {
				case .showIdentity:
					return collectionView.dequeueConfiguredReusableCell(using: bannerCellConfiguration, for: indexPath, item: itemKind)
				default:
					return collectionView.dequeueConfiguredReusableCell(using: textCellConfiguration, for: indexPath, item: itemKind)
				}
			case .becauseYouWatched, .dropIn, .rescueOnHold, .rescuePlanning, .premiering:
				return collectionView.dequeueConfiguredReusableCell(using: showCellConfiguration, for: indexPath, item: itemKind)
			case .newReleases, .releasing:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
			case .newEpisodes, .finales, .trending:
				return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
			case .birthdays:
				return collectionView.dequeueConfiguredReusableCell(using: personCellConfiguration, for: indexPath, item: itemKind)
			case .momentum:
				return collectionView.dequeueConfiguredReusableCell(using: momentumCellConfiguration, for: indexPath, item: itemKind)
			case .growth:
				return collectionView.dequeueConfiguredReusableCell(using: textCellConfiguration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let section = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)

			titleHeaderCollectionReusableView.configure(withTitle: self.title(for: section), self.subtitle(for: section), segueID: nil, separatorIsHidden: true)

			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.cache = [:]
		self.sectionHeaders = [:]
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		guard let digest = self.digest else {
			self.dataSource.apply(self.snapshot)
			return
		}

		let sections = digest.sections.sorted { $0.attributes.position < $1.attributes.position }
		for section in sections {
			guard let layoutKind = SectionLayoutKind(rawValue: section.attributes.kind) else { continue }
			let items = self.items(for: section, layoutKind: layoutKind)
			guard !items.isEmpty else { continue }

			self.sectionHeaders[layoutKind] = (section.attributes.title, section.attributes.subtitle)
			self.snapshot.appendSections([layoutKind])
			self.snapshot.appendItems(items, toSection: layoutKind)
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		return self.cache[indexPath] as? M
	}

	// MARK: - Snapshot helpers
	/// The items to render for the given section.
	private func items(for section: WeeklyDigestSection, layoutKind: SectionLayoutKind) -> [ItemKind] {
		let relationships = section.relationships

		switch layoutKind {
		case .hero:
			guard let hero = relationships?.shows?.data.first else { return [] }
			var items: [ItemKind] = [.showIdentity(hero, section: .hero)]
			if let caption = section.attributes.subtitle, !caption.isEmpty {
				items.append(.text(caption, section: .hero))
			}
			return items
		case .becauseYouWatched, .dropIn, .rescueOnHold, .rescuePlanning, .premiering:
			return (relationships?.shows?.data ?? []).map { .showIdentity($0, section: layoutKind) }
		case .newReleases, .releasing:
			return (relationships?.games?.data ?? []).map { .gameIdentity($0, section: layoutKind) }
		case .newEpisodes, .finales, .trending:
			return (relationships?.episodes?.data ?? []).map { .episodeIdentity($0, section: layoutKind) }
		case .birthdays:
			return (relationships?.people?.data ?? []).map { .personIdentity($0, section: layoutKind) }
		case .momentum:
			return section.attributes.momentum != nil ? [.momentum] : []
		case .growth:
			guard let caption = section.attributes.subtitle, !caption.isEmpty else { return [] }
			return [.text(caption, section: .growth)]
		}
	}

	// MARK: - Header text
	/// The server-provided header title for the given section.
	func title(for section: SectionLayoutKind) -> String? {
		return self.sectionHeaders[section]?.title
	}

	/// The server-provided header subtitle for the given section.
	func subtitle(for section: SectionLayoutKind) -> String? {
		return self.sectionHeaders[section]?.subtitle
	}

	/// Whether the given section renders a title header.
	func hasHeader(for section: SectionLayoutKind) -> Bool {
		return self.title(for: section) != nil
	}

	// MARK: - Momentum text
	/// The primary big-number momentum stats, each a value paired with its label.
	func momentumStats(for momentum: WeeklyDigest.Momentum) -> [(value: String, label: String)] {
		var stats: [(value: String, label: String)] = []

		if momentum.episodesWatched > 0 {
			stats.append((momentum.episodesWatched.formatted(), L10n.digestMomentumEpisodesLabel))

			if momentum.secondsWatched > 0 {
				stats.append((self.durationString(fromSeconds: momentum.secondsWatched), L10n.digestMomentumTimeLabel))
			}
		}
		if momentum.finishedCount > 0 {
			stats.append((momentum.finishedCount.formatted(), L10n.digestMomentumFinishedLabel))
		}

		return stats
	}

	/// The supporting momentum lines, such as the milestone and streak.
	func momentumNotes(for momentum: WeeklyDigest.Momentum) -> [String] {
		var notes: [String] = []

		if momentum.lifetimeEpisodes > 0 {
			notes.append(L10n.digestMilestone(momentum.episodesToMilestone, momentum.nextMilestone))
		}
		if momentum.weekStreak >= 2 {
			notes.append(L10n.digestWeekStreak(momentum.weekStreak))
		}

		return notes
	}

	/// A short, abbreviated duration string for the given number of seconds.
	private func durationString(fromSeconds seconds: Int) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute]
		formatter.unitsStyle = .abbreviated
		formatter.maximumUnitCount = 2
		return formatter.string(from: TimeInterval(seconds)) ?? ""
	}
}
