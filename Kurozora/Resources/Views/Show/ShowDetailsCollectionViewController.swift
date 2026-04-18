//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class ShowDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable {
	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var show: Show! {
		didSet {
			self.title = self.show.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.show.attributes.title
			self.showIdentity = ShowIdentity(id: self.show.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var seasonIdentities: [SeasonIdentity] = []
	var relatedShows: [RelatedShow] = []
	var relatedLiteratures: [RelatedLiterature] = []
	var relatedGames: [RelatedGame] = []
	var castIdentities: [CastIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var studioShowIdentities: [ShowIdentity] = []
	var showSongs: [ShowSong] = []

	/// The player that controls song playback.
	var player: AVPlayer?

	/// The index path of the song that is currently playing.
	var currentPlayerIndexPath: IndexPath?

	private var firstCellSize: CGSize = .zero

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var favoriteTarget: (any Libraryable)? { self.show }

	override var reminderTarget: (any Libraryable)? { self.show }

	override var emptyStateImage: UIImage { .Empty.animeLibrary }

	override var emptyStateDetail: String { "This show doesn't have details yet. Please check back again later." }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let show = self.show else { return [] }
		var items: [MediaItem] = []
		if let posterURL = URL(string: show.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: show.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with showID: KurozoraItemID) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.showIdentity = ShowIdentity(id: showID)
		return showDetailsCollectionViewController
	}

	func callAsFunction(with show: Show) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.show = show
		return showDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureDataSource()
		self.configureNavigationItems()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake, self.show?.attributes.title.lowercased().contains("log horizon") == true {
			if let url = URL.livingInTheDatabase {
				UIApplication.shared.kOpen(url)
			}
		}
	}

	// MARK: - Functions
	override func fetchDetails() async {
		guard let showIdentity = self.showIdentity else { return }

		if self.show == nil {
			do {
				let showResponse = try await KService.getDetails(forShow: showIdentity)
				self.show = showResponse.data.first

				// Donate suggestion to Siri.
				self.userActivity = self.show.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri.
			self.userActivity = self.show.openDetailUserActivity

			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forShow: showIdentity, next: nil, limit: 10)
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let seasonIdentityResponse = try await KService.getSeasons(forShow: showIdentity, reversed: true, next: nil, limit: 10)
			self.seasonIdentities = seasonIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forShow: showIdentity, limit: 10)
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showSongResponse = try await KService.getSongs(forShow: showIdentity, limit: 10)
			self.showSongs = showSongResponse.data

			let appleMusicIDs = self.showSongs.compactMap { $0.song.attributes.amID }
			_ = await MusicManager.shared.getSongs(for: appleMusicIDs)

			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forShow: showIdentity, limit: 10)
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getMoreByStudio(forShow: showIdentity, limit: 10)
			self.studioShowIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forShow: showIdentity, limit: 10)
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteraturesResponse = try await KService.getRelatedLiteratures(forShow: showIdentity, limit: 10)
			self.relatedLiteratures = relatedLiteraturesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGamesResponse = try await KService.getRelatedGames(forShow: showIdentity, limit: 10)
			self.relatedGames = relatedGamesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.show?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard let show = self.show else { return nil }
		return try await show.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? {
		guard let show = self.show else { return nil }
		return (.show(show), show.attributes.library?.rating, show.attributes.library?.review)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: KKLibrary.Kind) -> (any Libraryable)? {
		switch kind {
		case .shows:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio: return self.cache[indexPath] as? Show
			case .relatedShows: return self.relatedShows[safe: indexPath.item]?.show
			default: return nil
			}
		case .literatures:
			return self.relatedLiteratures[safe: indexPath.item]?.literature
		case .games:
			return self.relatedGames[safe: indexPath.item]?.game
		}
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.show?.attributes.library?.rating = nil
		self.show?.attributes.library?.review = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }
		return self.makeDestinationVC(for: identifier)
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }
		self.prepareDestination(for: identifier, destination: destination, sender: sender)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(SegueIdentifiers.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.show.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}
}
