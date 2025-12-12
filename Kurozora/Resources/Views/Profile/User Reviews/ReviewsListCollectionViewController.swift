//
//  ReviewsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVFoundation

class ReviewsListCollectionViewController: KCollectionViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
		case episodeDetailsSegue
		case gameDetailsSegue
		case literatureDetailsSegue
		case personDetailsSegue
		case showDetailsSegue
		case songDetailsSegue
		case studioDetailsSegue
	}

	// MARK: - Properties
	var user: User?
	var characters: [IndexPath: Character] = [:]
	var episodes: [IndexPath: Episode] = [:]
	var games: [IndexPath: Game] = [:]
	var literatures: [IndexPath: Literature] = [:]
	var people: [IndexPath: Person] = [:]
	var shows: [IndexPath: Show] = [:]
	var songs: [IndexPath: Song] = [:]
	var studios: [IndexPath: Studio] = [:]
	var reviews: [Review] = []
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Review>! = nil

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the reviews.")
		#endif

		self.configureDataSource()

		// Fetch follow list.
		if !self.reviews.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.user != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func configureEmptyDataView() {
		let username = self.user?.attributes.username
		let titleString: String = "No Reviews"
		let detailString: String = if self.user?.id == User.current?.id {
			"Ratings and reviews you submit will appear here. "
		} else {
			"\(username ?? "") has not submitted any reviews yet. Check back later."
		}

		self.emptyBackgroundView.configureImageView(image: .Empty.follow)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	/// Fetch the reviews list for the currently viewed profile.
	func fetchReviews() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing reviews...")
		#endif

		guard let user = self.user else { return }
		let userIdentity = UserIdentity(id: user.id)

		do {
			let reviewResponse = try await KService.getReviewsList(forUser: userIdentity, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.reviews = []
			}

			// Save next page url and append new data
			self.nextPageURL = reviewResponse.next
			self.reviews.append(contentsOf: reviewResponse.data)
			self.reviews.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the reviews.")
		#endif
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		}
	}
}

// MARK: - SectionLayoutKind
extension ReviewsListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
