//
//  ShowDetailsCollectionViewController+Cells.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ShowDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: CastCollectionViewCell.nib) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CastResponse.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				castCollectionViewCell.delegate = self
				castCollectionViewCell.configure(using: cast)
			default: return
			}
		}
	}

	func getConfiguredStudioShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			default: return
			}
		}
	}

	func getConfiguredSeasonCell() -> UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind>(cellNib: SeasonLockupCollectionViewCell.nib) { [weak self] seasonLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .seasonIdentity:
				let season: Season? = self.fetchModel(at: indexPath)

				if season == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(SeasonResponse.self, SeasonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				seasonLockupCollectionViewCell.configure(using: season)
			default: return
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(StudioResponse.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { musicLockupCollectionViewCell, indexPath, itemKind in
			switch itemKind {
			case .showSong(let showSong, _):
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredRelatedShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

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
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			gameLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedGame(let relatedGame, _):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
