//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case showDetailsSegue
		case showsListSegue
		case literatureDetailsSegue
		case literaturesListSegue
		case gameDetailsSegue
		case gamesListSegue
		case studioDetailsSegue
		case topChartsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var studioIdentity: StudioIdentity?

	/// The authenticated user's library state for the studio.
	var libraryAttributes: LibraryAttributes?

	/// The entity tag of the last applied favorites overlay.
	var favoritesOverlayETag: String?

	/// The entity tag of the last applied reviews overlay.
	var reviewsOverlayETag: String?

	var studio: Studio! {
		didSet {
			self.title = self.studio.attributes.name
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.studio.attributes.name
			self.studioIdentity = StudioIdentity(id: self.studio.id)
			self.configureNavBarButtons()

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var showIdentities: [ShowIdentity] = []
	var literatureIdentities: [LiteratureIdentity] = []
	var gameIdentities: [GameIdentity] = []

	/// The badges shown for the current studio.
	var badges: [StudioDetail.Badge] {
		guard let studio = self.studio else { return [] }
		return StudioDetail.Badge.cases(for: studio)
	}

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage? { UIImage(systemName: "building.2.crop.circle.fill") }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.studio.lowercased(with: .current)) }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let studio = self.studio else { return [] }
		var items: [MediaItem] = []
		let profileURL = URL(string: studio.attributes.profile?.url ?? "")
		let logoURL = URL(string: studio.attributes.logo?.url ?? "")
		if let primaryURL = profileURL ?? logoURL {
			items.append(MediaItem(
				url: primaryURL,
				type: .image,
				title: studio.attributes.name,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}
		if let bannerURL = URL(string: studio.attributes.banner?.url ?? "") {
			items.append(MediaItem(
				url: bannerURL,
				type: .image,
				title: studio.attributes.name,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with studioID: KurozoraItemID) -> StudioDetailsCollectionViewController {
		let studioDetailsCollectionViewController = StudioDetailsCollectionViewController()
		studioDetailsCollectionViewController.studioIdentity = StudioIdentity(id: studioID)
		return studioDetailsCollectionViewController
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

	// MARK: - Functions
	override func fetchDetails() async {
		guard let studioIdentity = self.studioIdentity else { return }

		if self.studio == nil {
			do {
				let studioResponse = try await KService.detail(studioIdentity).response()
				self.studio = studioResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		}

		await self.fetchUserOverlays()

		do {
			let reviewIdentityResponse = try await KService.reviews(for: studioIdentity).cursor(nil).limit(10).response()
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.shows(for: studioIdentity).limit(10).response()
			self.showIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.literatures(for: studioIdentity).limit(10).response()
			self.literatureIdentities = literatureIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.games(for: studioIdentity).limit(10).response()
			self.gameIdentities = gameIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Fetches the auth user's favorite and review overlays for the current studio.
	private func fetchUserOverlays() async {
		guard
			let studioID = self.studio?.id,
			let userID = User.current?.id
		else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let overlayResult = try await KService
				.favoritesOverlay(forUser: userIdentity, kind: .studios, itemIDs: [studioID])
				.response(ifNoneMatch: self.favoritesOverlayETag)

			if case .modified(let response, let etag) = overlayResult {
				var libraryAttributes = self.libraryAttributes ?? LibraryAttributes()
				libraryAttributes.isFavorited = !response.data.isEmpty
				self.libraryAttributes = libraryAttributes
				self.favoritesOverlayETag = etag
			}
		} catch {
			print("favoritesOverlay fetch failed: \(error.localizedDescription)")
		}

		do {
			let overlayResult = try await KService
				.reviewsOverlay(forUser: userIdentity, kind: .studios, itemIDs: [studioID])
				.response(ifNoneMatch: self.reviewsOverlayETag)

			if case .modified(let response, let etag) = overlayResult {
				let reviewEntry = response.data.first?.attributes
				var libraryAttributes = self.libraryAttributes ?? LibraryAttributes()
				libraryAttributes.rating = reviewEntry?.score
				libraryAttributes.review = reviewEntry?.description
				libraryAttributes.note = try? await KService
					.notesOverlay(forUser: userIdentity, kind: .studios, itemIDs: [studioID])
					.response().data.first?.attributes.body
				libraryAttributes.isSpoiler = reviewEntry?.isSpoiler
				libraryAttributes.recommendation = reviewEntry?.recommendation
				self.libraryAttributes = libraryAttributes
				self.reviewsOverlayETag = etag
			}
		} catch {
			print("reviewsOverlay fetch failed: \(error.localizedDescription)")
		}

		await MainActor.run { [weak self] in
			self?.updateDataSource()
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.studio?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let studio = self.studio else { return nil }
		return try await studio.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> ReviewEditorContext? {
		guard let studio = self.studio else { return nil }
		return ReviewEditorContext(kind: .studio(studio), rating: self.libraryAttributes?.rating, review: self.libraryAttributes?.review, note: self.libraryAttributes?.note, isSpoiler: self.libraryAttributes?.isSpoiler ?? false, recommendation: self.libraryAttributes?.recommendation)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		return self.cache[indexPath] as? any Libraryable
	}

	override func reminderTarget(at indexPath: IndexPath) -> Show? {
		return self.cache[indexPath] as? Show
	}

	override func didDeleteReview() {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .topChartsSegue: return StudiosListCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .studio(self.studio)
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
			reviewsCollectionViewController.givenNote = self.libraryAttributes?.note
			reviewsCollectionViewController.givenIsSpoiler = self.libraryAttributes?.isSpoiler ?? false
			reviewsCollectionViewController.givenRecommendation = self.libraryAttributes?.recommendation
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .showsListSegue:
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.studioIdentity = self.studioIdentity
			showsListCollectionViewController.showsListFetchType = .studio
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .literaturesListSegue:
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.studioIdentity = self.studioIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .studio
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .gamesListSegue:
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.studioIdentity = self.studioIdentity
			gamesListCollectionViewController.gamesListFetchType = .studio
		case .studioDetailsSegue:
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studioIdentity = sender as? StudioIdentity else { return }
			studioDetailsCollectionViewController.studioIdentity = studioIdentity
		case .topChartsSegue:
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.studiosListFetchType = .charts
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

// MARK: - UICollectionViewDataSource
extension StudioDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let studioDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: studioDetailSection.stringValue, indexPath: indexPath, segueID: studioDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.studio.attributes.about

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - Cell Configuration
extension StudioDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}
}
