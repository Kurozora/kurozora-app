//
//  MusicResolving.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that resolves the Apple Music entries of the songs a collection view renders.
@MainActor
protocol MusicResolving: UICollectionViewController {
	// MARK: - Properties
	/// The Apple Music songs resolved so far.
	var resolvedSongs: [Int: MKSong] { get set }

	// MARK: - Methods
	/// Returns the song rendered at the given index path.
	///
	/// - Parameter indexPath: The index path of the song.
	///
	/// - Returns: The song at the index path.
	func song(at indexPath: IndexPath) -> KKSong?
}

extension MusicResolving {
	/// Resolves the Apple Music entry of the given song.
	///
	/// - Parameter song: The song to resolve.
	func resolveMusicSong(_ song: KKSong) {
		guard let appleMusicID = song.attributes.amID, self.resolvedSongs[appleMusicID] == nil else { return }

		Task { [weak self] in
			self?.resolvedSongs[appleMusicID] = await MusicManager.shared.getSong(for: appleMusicID)
			self?.refreshVisibleMusicCells()
		}
	}

	/// Refreshes the play button glyph and artwork of every visible song cell.
	func refreshVisibleMusicCells() {
		for case let cell as MusicLockupCollectionViewCell in self.collectionView.visibleCells {
			guard
				let indexPath = self.collectionView.indexPath(for: cell),
				let song = self.song(at: indexPath)
			else { continue }

			cell.updatePlayButton(for: song)
			cell.updateArtwork(for: song, resolvedSong: song.attributes.amID.flatMap { self.resolvedSongs[$0] })
		}
	}

	/// Plays the songs the given index path's section renders.
	///
	/// - Parameter indexPath: The index path of the song to start at.
	func playSongs(startingAt indexPath: IndexPath) {
		let itemCount = self.collectionView.numberOfItems(inSection: indexPath.section)
		let kkSongs: [KKSong?] = (0 ..< itemCount).map { item in
			self.song(at: IndexPath(item: item, section: indexPath.section))
		}

		MusicManager.shared.play(kkSongs: kkSongs, startingAt: indexPath.item)
	}
}
