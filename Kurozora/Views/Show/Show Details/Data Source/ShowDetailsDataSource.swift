//
//  ShowDetailsDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVFoundation

/// - Tag: ShowDetailsDataSource
class ShowDetailsDataSource: NSObject {
	// MARK: Properties
	weak var viewController: ShowDetailsCollectionViewController?
	var show: Show! {
		didSet {
			self.viewController?.navigationTitleLabel.text = self.show.attributes.title
			self.viewController?.showID = self.show.id
		}
	}

	// Season properties
	var seasons: [Season] = []
	var seasonIdentities: [SeasonIdentity] = [] {
		didSet {
			self.seasonIdentities.forEachInParallel({ seasonIdentity in
				self.fetchDetails(using: seasonIdentity)
			})
		}
	}

	// Cast properties
	var cast: [Cast] = []
	var castIdentities: [CastIdentity] = [] {
		didSet {
			self.castIdentities.forEachInParallel({ castIdentity in
				self.fetchDetails(using: castIdentity)
			})
		}
	}

	// Songs properties
	var showSongs: [ShowSong] = []
//	{
//		didSet {
//			self.showSongs.forEachInParallel({ showSong in
//				self.fetchDetails(using: showSong)
//			})
//		}
//	}

	var relatedShows: [RelatedShow] = [] {
		didSet {
			self.viewController?._prefersActivityIndicatorHidden = true
			self.viewController?.collectionView.reloadData {
				self.viewController?.toggleEmptyDataView()
			}
			#if targetEnvironment(macCatalyst)
			self.viewController?.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.viewController?.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	// Studio properties
	var studio: Studio! {
		didSet {
			self.studio?.relationships?.shows?.data.forEachInParallel({ showIdentity in
				self.fetchDetails(using: showIdentity)
			})
		}
	}
	var studioShows: [Show] = []

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// Fetch details for a season.
	///
	/// - Parameter seasonIdentity: A `SeasonIdentity` object that identifies which season's details to fetch.
	private func fetchDetails(using seasonIdentity: SeasonIdentity) {
		KService.getDetails(forSeasonID: seasonIdentity.id) { [weak self] result in
			switch result {
			case .success(let seasons):
				// Save data
				self?.seasons.append(contentsOf: seasons)

				if (self?.seasons.count ?? 0) == (self?.seasonIdentities.count ?? 0) {
					self?.seasons.sort { season1, season2 in
						season1.attributes.number > season2.attributes.number
					}
				}
			case .failure:
				break
			}
		}
	}

	/// Fetch details for a cast.
	///
	/// - Parameter castIdentity: A `CastIdentity` object that identifies which cast's details to fetch.
	private func fetchDetails(using castIdentity: CastIdentity) {
		KService.getDetails(forCast: castIdentity.id) { [weak self] result in
			switch result {
			case .success(let cast):
				// Save data
				self?.cast.append(contentsOf: cast)
			case .failure:
				break
			}
		}
	}

	/// Fetch details for a show song.
	///
	/// - Parameter showSong: A `ShowSong` object that identifies which show song's details to fetch.
	private func fetchDetails(using showSong: ShowSong) {	}

	/// Fetch details for a show.
	///
	/// - Parameter showIdentity: A `ShowIdentity` object that identifies which show's details to fetch.
	private func fetchDetails(using showIdentity: ShowIdentity) {
		KService.getDetails(forShowID: showIdentity.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let shows):
				// Save data
				self.studioShows.append(contentsOf: shows)
			case .failure: break
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ShowDetailsDataSource: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.show != nil ? ShowDetail.Section.allCases.count : 0
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let showDetailSection = ShowDetail.Section(rawValue: section) ?? .header
		var itemsPerSection = self.show != nil ? showDetailSection.rowCount : 0

		if self.show != nil {
			switch showDetailSection {
			case .synopsis:
				let synopsis = self.show.attributes.synopsis ?? ""
				if synopsis.isEmpty {
					itemsPerSection = 0
				}
			case .seasons:
				itemsPerSection = self.seasonIdentities.count
			case .cast:
				itemsPerSection = self.castIdentities.count
			case .songs:
				itemsPerSection = self.showSongs.count
			case .moreByStudio:
				if let studioShowsCount = self.studio?.relationships?.shows?.data.count {
					itemsPerSection = studioShowsCount
				}
			case .relatedShows:
				itemsPerSection = self.relatedShows.count
			case .sosumi:
				let copyright = self.show.attributes.copyright ?? ""
				if copyright.isEmpty {
					itemsPerSection = 0
				}
			default: break
			}
		}

		return itemsPerSection
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
		let reuseIdentifier = showDetailSection.identifierString(for: indexPath.item)
		let showDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch showDetailSection {
		case .header:
			let showDetailHeaderCollectionViewCell = showDetailCollectionViewCell as? ShowDetailHeaderCollectionViewCell
			showDetailHeaderCollectionViewCell?.show = self.show
		case .badge:
			let badgeCollectionViewCell = showDetailCollectionViewCell as? BadgeCollectionViewCell
			badgeCollectionViewCell?.showDetailBage = ShowDetail.Badge(rawValue: indexPath.item) ?? .rating
			badgeCollectionViewCell?.show = self.show
		case .synopsis:
			let textViewCollectionViewCell = showDetailCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self.viewController
			textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
		case .rating:
			let ratingCollectionViewCell = showDetailCollectionViewCell as? RatingCollectionViewCell
			ratingCollectionViewCell?.show = self.show
		case .information:
			let informationCollectionViewCell = showDetailCollectionViewCell as? InformationCollectionViewCell
			informationCollectionViewCell?.showDetailInformation = ShowDetail.Information(rawValue: indexPath.item) ?? .type
			informationCollectionViewCell?.show = self.show
		case .seasons:
			let posterLockupCollectionViewCell = showDetailCollectionViewCell as? PosterLockupCollectionViewCell
			posterLockupCollectionViewCell?.configure(with: self.seasons[indexPath.item])
//			let season = self.seasonIdentities[indexPath.item]
//			let seasonIdentifier = season.id
//			posterLockupCollectionViewCell?.representedIdentifier = seasonIdentifier
//
//			// Check if the `asyncFetcher` has already fetched data for the specified identifier.
//			if let seasonData = seasonAsyncFetcher.fetchedData(for: seasonIdentifier) {
//				// The data has already been fetched and cached; use it to configure the cell.
//				posterLockupCollectionViewCell?.configure(with: seasonData)
//			} else {
//				// There is no data available; clear the cell until we've fetched data.
////				posterLockupCollectionViewCell.configure(with: nil)
//
//				// Ask the `asyncFetcher` to fetch data for the specified identifier.
//				seasonAsyncFetcher.fetchAsync(seasonIdentifier) { fetchedData in
//					DispatchQueue.main.async {
//						/*
//						 The `asyncFetcher` has fetched data for the identifier. Before
//						 updating the cell, check if it has been recycled by the
//						 collection view to represent other data.
//						 */
//						guard posterLockupCollectionViewCell?.representedIdentifier == seasonIdentifier else { return }
//
//						// Configure the cell with the fetched image.
//						posterLockupCollectionViewCell?.configure(with: fetchedData)
//					}
//				}
//			}
		case .cast:
			let castCollectionViewCell = showDetailCollectionViewCell as? CastCollectionViewCell
			castCollectionViewCell?.delegate = self.viewController
			castCollectionViewCell?.cast = self.cast[indexPath.item]
		case .songs:
			let musicLockupCollectionViewCell = showDetailCollectionViewCell as? MusicLockupCollectionViewCell
			musicLockupCollectionViewCell?.delegate = self
			musicLockupCollectionViewCell?.configureCell(with: self.showSongs[indexPath.item], at: indexPath)
		case .moreByStudio:
			let smallLockupCollectionViewCell = showDetailCollectionViewCell as? SmallLockupCollectionViewCell
			smallLockupCollectionViewCell?.configureCell(with: self.studioShows[indexPath.item])
		case .relatedShows:
			let smallLockupCollectionViewCell = showDetailCollectionViewCell as? SmallLockupCollectionViewCell
			smallLockupCollectionViewCell?.configureCell(with: self.relatedShows[indexPath.item])
		case .sosumi:
			let sosumiShowCollectionViewCell = showDetailCollectionViewCell as? SosumiShowCollectionViewCell
			sosumiShowCollectionViewCell?.copyrightText = self.show.attributes.copyright
		}

		return showDetailCollectionViewCell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
		let sectionTitle = showDetailSection != .moreByStudio ? showDetailSection.stringValue : showDetailSection.stringValue + self.studio.attributes.name

		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self.viewController
		titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: showDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - UICollectionViewDataSourcePrefetching
extension ShowDetailsDataSource: UICollectionViewDataSourcePrefetching {
	/// - Tag: Prefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//		// Begin asynchronously fetching data for the requested index paths.
//		for indexPath in indexPaths {
//			guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { fatalError("ShowDetail section not supported") }
//
//			switch showDetailSection {
//			case .seasons:
////				let seasonIdentity = self.seasonIdentities[indexPath.item]
////				seasonAsyncFetcher.fetchAsync(seasonIdentity.id)
//				let seasonIdentity = self.seasonIdentities[indexPath.item]
//				self.fetchDetails(using: seasonIdentity, at: indexPath)
//			default: break
//			}
//		}
	}

	/// - Tag: CancelPrefetching
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//		// Cancel any in-flight requests for data for the specified index paths.
//		for indexPath in indexPaths {
//			guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { fatalError("ShowDetail section not supported") }
//			switch showDetailSection {
//			case .seasons:
////				let seasonIdentity = self.seasonIdentities[indexPath.item]
////				seasonAsyncFetcher.cancelFetch(seasonIdentity.id)
//				self.operations[indexPath]?.cancelRequest()
//			default: break
//			}
//		}
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowDetailsDataSource: MusicLockupCollectionViewCellDelegate {
	func playButtonPressed(_ sender: UIButton, cell: MusicLockupCollectionViewCell) {
		guard let song = cell.song else { return }

		if let songURL = song.previewAssets?.first?.url {
			let playerItem = AVPlayerItem(url: songURL)

			if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
				switch self.player?.timeControlStatus {
				case .playing:
					cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
					self.player?.pause()
				case .paused:
					cell.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
				if let indexPath = self.currentPlayerIndexPath {
					if let cell = self.viewController?.collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell {
						cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
					}
				}

				self.currentPlayerIndexPath = cell.indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					self?.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
				})
			}
		}
	}

	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}
}
