//
//  SongDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit

class SongDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case showDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var songIdentity: SongIdentity?
	var song: KKSong! {
		didSet {
			self.title = self.song.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.song.attributes.title
			self.songIdentity = SongIdentity(id: self.song.id)

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var showIdentities: [ShowIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage { .Empty.cast }

	override var emptyStateDetail: String { "This song doesn't have details yet. Please check back again later." }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let song = self.song,
		      let artworkURL = URL(string: song.attributes.artwork?.url ?? "") else { return [] }
		return [MediaItem(url: artworkURL, type: .image, title: song.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil)]
	}

	// MARK: - Initializers
	func callAsFunction(with songID: KurozoraItemID) -> SongDetailsCollectionViewController {
		let songDetailsCollectionViewController = SongDetailsCollectionViewController()
		songDetailsCollectionViewController.songIdentity = SongIdentity(id: songID)
		return songDetailsCollectionViewController
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
		guard let songIdentity = self.songIdentity else { return }

		if self.song == nil {
			do {
				let songResponse = try await KService.detail(songIdentity).response()
				self.song = songResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		} else {
			self.updateDataSource()
		}

		self.configureNavBarButtons()

		do {
			let showIdentityResponse = try await KService.shows(for: songIdentity).limit(10).response()
			self.showIdentities = showIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let reviewIdentityResponse = try await KService.reviews(for: songIdentity).cursor(nil).limit(10).response()
			self.reviews = reviewIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		self.updateDataSource()
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.song?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let song = self.song else { return nil }
		return try await song.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewKind, rating: Double?, review: String?)? {
		guard let song = self.song else { return nil }
		return (.song(song), song.attributes.library?.rating, song.attributes.library?.review)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		return self.cache[indexPath] as? any Libraryable
	}

	override func reminderTarget(at indexPath: IndexPath) -> Show? {
		return self.cache[indexPath] as? Show
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.song?.attributes.library?.rating = nil
		self.song?.attributes.library?.review = nil
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .showIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .song(self.song)
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
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
extension SongDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let songDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: songDetailSection.stringValue, indexPath: indexPath, segueID: songDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension SongDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.song.attributes.originalLyrics

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - SongHeaderCollectionViewCellDelegate
extension SongDetailsCollectionViewController: SongHeaderCollectionViewCellDelegate {
	func playStateChanged(_ song: MKSong?) {
		self.updateMenu(with: song)
	}

	private func updateMenu(with song: MKSong?) {
		guard let song = song else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.moreBarButtonItem.menu = self.song?.makeContextMenu(in: self, userInfo: [
				"song": song
			], sourceView: nil, barButtonItem: self.moreBarButtonItem)
		}
	}
}

extension SongDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// A header section layout type.
		case header = 0

		/// A lyrics section layout type.
		case lyrics

		/// A rating section layout type.
		case rating

		/// A rate and review section layout type.
		case rateAndReview

		/// A reviews section layout type.
		case reviews

		/// A shows section layout type.
		case shows

		/// A copyright section layout type.
		case sosumi

		// MARK: - Properties
		/// The string value of a song section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .lyrics:
				return L10n.lyrics
			case .rating:
				return L10n.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .shows:
				return L10n.asHeardOn
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a song section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .lyrics, .rateAndReview, .reviews, .shows, .sosumi:
				return nil
			case .rating:
				return .reviewsListSegue
			}
		}
	}

	/// List of available item kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// An item kind that contains a `KKSong` object.
		case song(_: KKSong, id: UUID = UUID())

		/// An item kind that contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// An item kind that contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .song(let song, let id):
				hasher.combine(song)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.song(let song1, let id1), .song(let song2, let id2)):
				return song1 == song2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension SongDetailsCollectionViewController {
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
			default: break
			}
		}
	}
}
