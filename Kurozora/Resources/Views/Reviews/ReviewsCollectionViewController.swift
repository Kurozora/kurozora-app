//
//  ReviewsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum ReviewsListType {
	case show(_ show: Show)
	case literature(_ literature: Literature)
	case game(_ game: Game)
	case character(_ character: Character)
	case person(_ person: Person)
	case studio(_ studio: Studio)
	case song(_ song: Song)
	case episode(_ episode: Episode)
}

class ReviewsCollectionViewController: KCollectionViewController, RatingAlertPresentable {
	// MARK: - Properties
	var listType: ReviewsListType?
	var reviews: [Review] = []
	var nextPageURL: String?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.collectionView.contentInset.top = 20
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchReviews()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh reviews!")
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteReview(_:)), name: .KReviewDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchReviews()
		}
	}

	override func configureEmptyDataView() {
		let detailString = "Be the first to place a review!"

		self.emptyBackgroundView.configureImageView(image: .Empty.reminders)
		self.emptyBackgroundView.configureLabels(title: "No Reviews", detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the user's reminder list.
	var fetchInProgress: Bool = false
	@objc func fetchReviews() async {
		guard let listType = self.listType else { return }

		if self.fetchInProgress {
			return
		}
		self.fetchInProgress = true

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.collectionView.backgroundView?.alpha = 0

			self._prefersActivityIndicatorHidden = false

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing reviews...")
			#endif
		}

		do {
			let reviewsResponse: ReviewResponse

			switch listType {
			case .character(let character):
				let identity = CharacterIdentity(id: character.id)
				reviewsResponse = try await KService.getReviews(forCharacter: identity, next: self.nextPageURL).value
			case .episode(let episode):
				let identity = EpisodeIdentity(id: episode.id)
				reviewsResponse = try await KService.getReviews(forEpisode: identity, next: self.nextPageURL).value
			case .game(let game):
				let identity = GameIdentity(id: game.id)
				reviewsResponse = try await KService.getReviews(forGame: identity, next: self.nextPageURL).value
			case .literature(let literature):
				let identity = LiteratureIdentity(id: literature.id)
				reviewsResponse = try await KService.getReviews(forLiterature: identity, next: self.nextPageURL).value
			case .person(let person):
				let identity = PersonIdentity(id: person.id)
				reviewsResponse = try await KService.getReviews(forPerson: identity, next: self.nextPageURL).value
			case .show(let show):
				let identity = ShowIdentity(id: show.id)
				reviewsResponse = try await KService.getReviews(forShow: identity, next: self.nextPageURL).value
			case .song(let song):
				let identity = SongIdentity(id: song.id)
				reviewsResponse = try await KService.getReviews(forSong: identity, next: self.nextPageURL).value
			case .studio(let studio):
				let identity = StudioIdentity(id: studio.id)
				reviewsResponse = try await KService.getReviews(forStudio: identity, next: self.nextPageURL).value
			}

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.reviews = []
			}

			// Save next page url and append new data
			self.nextPageURL = reviewsResponse.next
			self.reviews.append(contentsOf: reviewsResponse.data)
		} catch {
			print("-----", error.localizedDescription)
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh reviews!")
		#endif

		self.fetchInProgress = false
	}

	/// Deletes the review with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteReview(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				// Start delete process
				self.reviews.remove(at: indexPath.item)
			}

			switch self.listType {
			case .character(let character):
				character.attributes.givenRating = nil
				character.attributes.givenReview = nil
			case .episode(let episode):
				episode.attributes.givenRating = nil
				episode.attributes.givenReview = nil
			case .game(let game):
				game.attributes.library?.rating = nil
				game.attributes.library?.review = nil
			case .literature(let literature):
				literature.attributes.library?.rating = nil
				literature.attributes.library?.review = nil
			case .person(let person):
				person.attributes.givenRating = nil
				person.attributes.givenReview = nil
			case .show(let show):
				show.attributes.library?.rating = nil
				show.attributes.library?.review = nil
			case .song(let song):
				song.attributes.library?.rating = nil
				song.attributes.library?.review = nil
			case .studio(let studio):
				studio.attributes.library?.rating = nil
				studio.attributes.library?.review = nil
			case .none: break
			}

			self.updateDataSource()
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.remindersCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.remindersCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.remindersCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		default: break
		}
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension ReviewsCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		self.reviews[indexPath.item].visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge
			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}
}

// MARK: - TapToRateCollectionViewCellDelegate
extension ReviewsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }
			let newRating: Double?

			do throws(KKAPIError) {
				switch self.listType {
				case .character(let character):
					newRating = try await character.rate(using: rating, description: nil)
				case .episode(let episode):
					newRating = try await episode.rate(using: rating, description: nil)
				case .game(let game):
					newRating = try await game.rate(using: rating, description: nil)
				case .literature(let literature):
					newRating = try await literature.rate(using: rating, description: nil)
				case .person(let person):
					newRating = try await person.rate(using: rating, description: nil)
				case .show(let show):
					newRating = try await show.rate(using: rating, description: nil)
				case .song(let song):
					newRating = try await song.rate(using: rating, description: nil)
				case .studio(let studio):
					newRating = try await studio.rate(using: rating, description: nil)
				case .none:
					newRating = nil
				}

				cell.configure(using: newRating)

				if newRating != nil {
					self.showRatingSuccessAlert()
				}
			} catch {
				print(error.localizedDescription)
				self.showRatingFailureAlert(message: error.message)
			}
		}
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension ReviewsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		switch self.listType {
		case .character(let character):
			reviewTextEditorViewController.router?.dataStore?.kind = .character(character)
			reviewTextEditorViewController.router?.dataStore?.rating = character.attributes.givenRating
		case .episode(let episode):
			reviewTextEditorViewController.router?.dataStore?.kind = .episode(episode)
			reviewTextEditorViewController.router?.dataStore?.rating = episode.attributes.givenRating
		case .game(let game):
			reviewTextEditorViewController.router?.dataStore?.kind = .game(game)
			reviewTextEditorViewController.router?.dataStore?.rating = game.attributes.library?.rating
		case .literature(let literature):
			reviewTextEditorViewController.router?.dataStore?.kind = .literature(literature)
			reviewTextEditorViewController.router?.dataStore?.rating = literature.attributes.library?.rating
		case .person(let person):
			reviewTextEditorViewController.router?.dataStore?.kind = .person(person)
			reviewTextEditorViewController.router?.dataStore?.rating = person.attributes.givenRating
		case .show(let show):
			reviewTextEditorViewController.router?.dataStore?.kind = .show(show)
			reviewTextEditorViewController.router?.dataStore?.rating = show.attributes.library?.rating
		case .song(let song):
			reviewTextEditorViewController.router?.dataStore?.kind = .song(song)
			reviewTextEditorViewController.router?.dataStore?.rating = song.attributes.library?.rating
		case .studio(let studio):
			reviewTextEditorViewController.router?.dataStore?.kind = .studio(studio)
			reviewTextEditorViewController.router?.dataStore?.rating = studio.attributes.library?.rating
		case .none:
			reviewTextEditorViewController.router?.dataStore?.kind = nil
			reviewTextEditorViewController.router?.dataStore?.rating = nil
		}
		reviewTextEditorViewController.router?.dataStore?.review = nil

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension ReviewsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

// MARK: - SectionLayoutKind
extension ReviewsCollectionViewController {
	/// List of  review section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		case rating = 0
		case rateAndReview
		case reviews

		// MARK: - Properties
		/// The string value of a review section type.
		var stringValue: String {
			switch self {
			case .rating:
				return Trans.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a rating.
		case rateAndReview(_: RateAndReview, currentRating: Double?)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `Character` object.
		case character(_ character: Character, id: UUID = UUID())

		/// Indicates the item kind contains a `Episode` object.
		case episode(_ episode: Episode, id: UUID = UUID())

		/// Indicates the item kind contains a `Game` object.
		case game(_ game: Game, id: UUID = UUID())

		/// Indicates the item kind contains a `Literature` object.
		case literature(_ literature: Literature, id: UUID = UUID())

		/// Indicates the item kind contains a `Person` object.
		case person(_ person: Person, id: UUID = UUID())

		/// Indicates the item kind contains a `Show` object.
		case show(_ show: Show, id: UUID = UUID())

		/// Indicates the item kind contains a `Song` object.
		case song(_ song: Song, id: UUID = UUID())

		/// Indicates the item kind contains a `Studio` object.
		case studio(_ studio: Studio, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .rateAndReview(let rateAndReview, let currentRating):
				hasher.combine(rateAndReview)
				hasher.combine(currentRating)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .character(let character, let id):
				hasher.combine(character)
				hasher.combine(id)
			case .episode(let episode, let id):
				hasher.combine(episode)
				hasher.combine(id)
			case .game(let game, let id):
				hasher.combine(game)
				hasher.combine(id)
			case .literature(let literature, let id):
				hasher.combine(literature)
				hasher.combine(id)
			case .person(let person, let id):
				hasher.combine(person)
				hasher.combine(id)
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .song(let song, let id):
				hasher.combine(song)
				hasher.combine(id)
			case .studio(let studio, let id):
				hasher.combine(studio)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.rateAndReview(let rateAndReview1, let currentRating1), .rateAndReview(let rateAndReview2, let currentRating2)):
				return rateAndReview1 == rateAndReview2 && currentRating1 == currentRating2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.character(let character1, let id1), .character(let character2, let id2)):
				return character1 == character2 && id1 == id2
			case (.episode(let episode1, let id1), .episode(let episode2, let id2)):
				return episode1 == episode2 && id1 == id2
			case (.game(let game1, let id1), .game(let game2, let id2)):
				return game1 == game2 && id1 == id2
			case (.literature(let literature1, let id1), .literature(let literature2, let id2)):
				return literature1 == literature2 && id1 == id2
			case (.person(let person1, let id1), .person(let person2, let id2)):
				return person1 == person2 && id1 == id2
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1 == show2 && id1 == id2
			case (.song(let song1, let id1), .song(let song2, let id2)):
				return song1 == song2 && id1 == id2
			case (.studio(let studio1, let id1), .studio(let studio2, let id2)):
				return studio1 == studio2 && id1 == id2
			default:
				return false
			}
		}
	}
}
