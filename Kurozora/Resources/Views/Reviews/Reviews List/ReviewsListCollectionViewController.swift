//
//  ReviewsListCollectionViewController.swift
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

class ReviewsListCollectionViewController: KCollectionViewController, RatingAlertPresentable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var listType: ReviewsListType?

	/// The authenticated user's rating for the reviewed item.
	var givenRating: Double?

	/// The authenticated user's review text for the reviewed item.
	var givenReview: String?
	var reviews: [Review] = []
	var nextPageCursor: PageCursor?

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

		self.title = L10n.reviews

		self.collectionView.contentInset.top = 20
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchReviews()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteReview(_:)), name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateReviewTranslation(_:)), name: .KTranslationDidUpdate, object: nil)
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
		let detailString = L10n.beFirstToReview

		self.emptyBackgroundView.configureImageView(image: .Empty.bellCircle)
		self.emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.reviews), detail: detailString)

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
	/// Re-renders the reviews whose translation state changed.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateReviewTranslation(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// Re-applying the snapshot alone changes nothing: the item identifiers are
			// unchanged, so the diff is empty and no cell is ever reconfigured.
			var snapshot = self.dataSource.snapshot()
			snapshot.reconfigureItems(snapshot.itemIdentifiers)
			self.dataSource.apply(snapshot, animatingDifferences: false)
		}
	}

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
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.reviews.lowercased(with: Locale.current)))
			#endif
		}

		do {
			let reviewsResponse: ResourceCollection<Review>

			switch listType {
			case .character(let character):
				let identity = CharacterIdentity(id: character.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .episode(let episode):
				let identity = EpisodeIdentity(id: episode.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .game(let game):
				let identity = GameIdentity(id: game.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .literature(let literature):
				let identity = LiteratureIdentity(id: literature.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .person(let person):
				let identity = PersonIdentity(id: person.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .show(let show):
				let identity = ShowIdentity(id: show.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .song(let song):
				let identity = SongIdentity(id: song.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			case .studio(let studio):
				let identity = StudioIdentity(id: studio.id)
				reviewsResponse = try await KService.reviews(for: identity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()
			}

			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.reviews = []
			}

			// Save next page url and append new data
			self.nextPageCursor = reviewsResponse.nextCursor
			self.reviews.append(contentsOf: reviewsResponse.data)

			if #available(iOS 26.4, macCatalyst 26.4, *) {
				TranslationService.shared.prefetch(reviewsResponse.data)
			}
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
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

			self.givenRating = nil
			self.givenReview = nil

			self.updateDataSource()
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .reviewDetailsSegue:
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		}
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension ReviewsListCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }
		review.visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressMoreButton button: UIButton) {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }
		self.present(.reviewDetailsSegue, sender: review)
	}

	func reviewCollectionViewCellDidTapTranslation(_ cell: ReviewCollectionViewCell) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }

		TranslationService.shared.toggleTranslation(for: review)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapTranslationSettings button: UIButton) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }

		TranslationSettingsViewController.present(for: review, from: button, in: self)
	}
}

// MARK: - TapToRateCollectionViewCellDelegate
extension ReviewsListCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		if rating == 0 {
			self.handleTapToRateDeletion(on: cell)
			return
		}

		Task { [weak self] in
			guard let self = self else { return }
			let newRating: Double?

			do throws(APIError) {
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

	private func handleTapToRateDeletion(on cell: TapToRateCollectionViewCell) {
		guard let kind = self.currentReviewKind() else {
			cell.configure(using: nil)
			return
		}
		let previousRating = self.currentGivenRating()

		self.confirmDeleteRating(onConfirm: { [weak self, weak cell] in
			guard let self = self, let cell = cell else { return }
			Task {
				do throws(APIError) {
					let didDelete = try await kind.deleteRating()
					if didDelete {
						cell.configure(using: nil)
					} else {
						cell.configure(using: previousRating)
						self.presentAlertController(title: L10n.ratingFailed, message: L10n.notAvailableForType)
					}
				} catch {
					cell.configure(using: previousRating)
					self.showRatingFailureAlert(message: error.message)
				}
			}
		}, onCancel: { [weak cell] in
			cell?.configure(using: previousRating)
		})
	}

	private func currentReviewKind() -> ReviewKind? {
		switch self.listType {
		case .character(let character): return .character(character)
		case .episode(let episode): return .episode(episode)
		case .game(let game): return .game(game)
		case .literature(let literature): return .literature(literature)
		case .person(let person): return .person(person)
		case .show(let show): return .show(show)
		case .song(let song): return .song(song)
		case .studio(let studio): return .studio(studio)
		case .none: return nil
		}
	}

	private func currentGivenRating() -> Double? {
		return self.givenRating
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension ReviewsListCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		switch self.listType {
		case .character(let character):
			reviewTextEditorViewController.kind = .character(character)
			reviewTextEditorViewController.rating = self.givenRating
		case .episode(let episode):
			reviewTextEditorViewController.kind = .episode(episode)
			reviewTextEditorViewController.rating = self.givenRating
		case .game(let game):
			reviewTextEditorViewController.kind = .game(game)
			reviewTextEditorViewController.rating = self.givenRating
		case .literature(let literature):
			reviewTextEditorViewController.kind = .literature(literature)
			reviewTextEditorViewController.rating = self.givenRating
		case .person(let person):
			reviewTextEditorViewController.kind = .person(person)
			reviewTextEditorViewController.rating = self.givenRating
		case .show(let show):
			reviewTextEditorViewController.kind = .show(show)
			reviewTextEditorViewController.rating = self.givenRating
		case .song(let song):
			reviewTextEditorViewController.kind = .song(song)
			reviewTextEditorViewController.rating = self.givenRating
		case .studio(let studio):
			reviewTextEditorViewController.kind = .studio(studio)
			reviewTextEditorViewController.rating = self.givenRating
		case .none:
			reviewTextEditorViewController.kind = nil
			reviewTextEditorViewController.rating = nil
		}
		reviewTextEditorViewController.review = nil

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension ReviewsListCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}

	func reviewTextEditorViewControllerDidDeleteReview() {
		self.collectionView.reloadData()
	}
}

// MARK: - SectionLayoutKind
extension ReviewsListCollectionViewController {
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
				return L10n.ratingsAndReviews
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
