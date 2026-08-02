//
//  TopChartsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension TopChartsCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellConfiguration = self.getConfiguredSmallCell()
		let gameCellConfiguration = self.getConfiguredGameCell()
		let profileCellConfiguration = self.getConfiguredProfileCell()
		let episodeCellConfiguration = self.getConfiguredEpisodeCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let sectionLayoutKind = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch sectionLayoutKind {
			case .chart(let chartKind):
				switch chartKind {
				case .shows, .literatures:
					return collectionView.dequeueConfiguredReusableCell(using: smallCellConfiguration, for: indexPath, item: itemKind)
				case .games:
					return collectionView.dequeueConfiguredReusableCell(using: gameCellConfiguration, for: indexPath, item: itemKind)
				case .characters, .people:
					return collectionView.dequeueConfiguredReusableCell(using: profileCellConfiguration, for: indexPath, item: itemKind)
				case .episodes:
					return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
				case .songs:
					return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
				case .studios:
					return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
				}
			}
		}
		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let sectionLayoutKind = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self

			switch sectionLayoutKind {
			case .chart(let chartKind):
				titleHeaderCollectionReusableView.configure(withTitle: L10n.xTopCharts(self.name(for: chartKind)), indexPath: indexPath, segueID: self.listSegueIdentifier(for: chartKind))
			}

			return titleHeaderCollectionReusableView
		}

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	}

	override func updateDataSource() {
		guard !self.settledChartKinds.isEmpty else { return }

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		for chartKind in ChartKind.allCases {
			let sectionLayoutKind: SectionLayoutKind = .chart(chartKind)
			self.snapshot.appendSections([sectionLayoutKind])
			self.snapshot.appendItems(self.items(for: chartKind), toSection: sectionLayoutKind)
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
		self.toggleEmptyDataView()
	}

	/// Returns the items of the given chart's section.
	///
	/// - Parameter chartKind: The chart whose items are resolved.
	///
	/// - Returns: The chart's entries, or skeleton placeholders while its request is in flight.
	private func items(for chartKind: ChartKind) -> [ItemKind] {
		guard self.settledChartKinds.contains(chartKind) else {
			return (0 ..< Self.entryLimit).map { index in
				.pending(chartKind: chartKind, index: index)
			}
		}

		switch chartKind {
		case .shows:
			return self.showIdentities.map { .showIdentity($0) }
		case .characters:
			return self.characterIdentities.map { .characterIdentity($0) }
		case .episodes:
			return self.episodeIdentities.map { .episodeIdentity($0) }
		case .games:
			return self.gameIdentities.map { .gameIdentity($0) }
		case .literatures:
			return self.literatureIdentities.map { .literatureIdentity($0) }
		case .people:
			return self.personIdentities.map { .personIdentity($0) }
		case .songs:
			return self.songIdentities.map { .songIdentity($0) }
		case .studios:
			return self.studioIdentities.map { .studioIdentity($0) }
		}
	}
}

// MARK: - Cell Configuration
extension TopChartsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			cell.delegate = self

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)
				cell.configure(using: show, rank: indexPath.item + 1)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Literature>.self, identity: LiteratureIdentity.self)
				cell.configure(using: literature, rank: indexPath.item + 1)
			case .pending(let chartKind, _):
				switch chartKind {
				case .literatures:
					let literature: Literature? = nil
					cell.configure(using: literature)
				default:
					let show: Show? = nil
					cell.configure(using: show)
				}
			default: break
			}

			cell.setDimmed(false)
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			cell.delegate = self

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Game>.self, identity: GameIdentity.self)
				cell.configure(using: game, rank: indexPath.item + 1)
			case .pending:
				let game: Game? = nil
				cell.configure(using: game)
			default: break
			}

			cell.setDimmed(false)
		}
	}

	func getConfiguredProfileCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Character>.self, identity: CharacterIdentity.self)
				cell.configure(using: character, rank: indexPath.item + 1)
			case .personIdentity:
				let person: Person? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Person>.self, identity: PersonIdentity.self)
				cell.configure(using: person, rank: indexPath.item + 1)
			case .pending(let chartKind, _):
				switch chartKind {
				case .people:
					let person: Person? = nil
					cell.configure(using: person)
				default:
					let character: Character? = nil
					cell.configure(using: character)
				}
			default: break
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			cell.delegate = self

			switch itemKind {
			case .episodeIdentity:
				let episode: Episode? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Episode>.self, identity: EpisodeIdentity.self)
				cell.configure(using: episode, rank: indexPath.item + 1)
			case .pending:
				let episode: Episode? = nil
				cell.configure(using: episode)
			default: break
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			cell.delegate = self

			switch itemKind {
			case .songIdentity:
				let song: Song? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Song>.self, identity: SongIdentity.self)
				let resolvedSong = song?.attributes.amID.flatMap { self.resolvedSongs[$0] }
				cell.configure(using: song, at: indexPath, rank: indexPath.item + 1, resolvedSong: resolvedSong)

				if let song = song {
					self.resolveMusicSong(song)
				}
			case .pending:
				let song: Song? = nil
				cell.configure(using: song, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Studio>.self, identity: StudioIdentity.self)
				cell.configure(using: studio, rank: indexPath.item + 1)
			case .pending:
				let studio: Studio? = nil
				cell.configure(using: studio)
			default: break
			}
		}
	}
}
