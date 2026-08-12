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

	/// The authenticated user's library state for the song.
	var libraryAttributes: LibraryAttributes?

	/// The entity tag of the last applied favorites overlay.
	var favoritesOverlayETag: String?

	/// The entity tag of the last applied reviews overlay.
	var reviewsOverlayETag: String?

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

	/// The synced lyrics of the song.
	var syncedLyrics: Lyrics?

	/// Original lyrics derived from the synced lyrics.
	var plainLyrics: String? {
		guard let lines = self.syncedLyrics?.attributes.lines, !lines.isEmpty else { return nil }
		let text = lines.map(\.text).joined(separator: "\n")
		return text.isEmpty ? nil : text
	}

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage? { .Symbols.musicNoteCircleFill }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.song.lowercased(with: .current)) }

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

		#if DEBUG
		self.installLyricsCaptureButton()
		#endif

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

		await self.fetchUserOverlays()

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

		do {
			let lyricsResponse = try await KService.lyrics(for: songIdentity).response()
			self.syncedLyrics = lyricsResponse.data.first
		} catch {
			print(error.localizedDescription)
		}

		self.updateDataSource()
	}

	/// Fetches the auth user's favorite and review overlays for the current song.
	private func fetchUserOverlays() async {
		guard
			let songID = self.song?.id,
			let userID = User.current?.id
		else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let overlayResult = try await KService
				.favoritesOverlay(forUser: userIdentity, kind: .songs, itemIDs: [songID])
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
				.reviewsOverlay(forUser: userIdentity, kind: .songs, itemIDs: [songID])
				.response(ifNoneMatch: self.reviewsOverlayETag)

			if case .modified(let response, let etag) = overlayResult {
				let reviewEntry = response.data.first?.attributes
				var libraryAttributes = self.libraryAttributes ?? LibraryAttributes()
				libraryAttributes.rating = reviewEntry?.score
				libraryAttributes.review = reviewEntry?.description
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
		return self.song?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let song = self.song else { return nil }
		return try await song.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewKind, rating: Double?, review: String?)? {
		guard let song = self.song else { return nil }
		return (.song(song), self.libraryAttributes?.rating, self.libraryAttributes?.review)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		return self.cache[indexPath] as? any Libraryable
	}

	override func reminderTarget(at indexPath: IndexPath) -> Show? {
		return self.cache[indexPath] as? Show
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
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
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
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
		guard let syncedLyrics = self.syncedLyrics, let songID = self.song?.id else { return }

		let lyricsViewController = LyricsViewController(songID: songID, lyrics: syncedLyrics)
		let kNavigationController = KNavigationController(rootViewController: lyricsViewController)
		kNavigationController.modalPresentationStyle = .pageSheet
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

#if DEBUG
extension SongDetailsCollectionViewController {
	func installLyricsCaptureButton() {
		let captureAction = UIAction(title: "Capture Lyrics", image: UIImage(systemName: "captions.bubble")) { [weak self] _ in
			self?.captureLyrics()
		}
		let tokenAction = UIAction(title: "Replace Privileged Token…", image: UIImage(systemName: "key.horizontal")) { [weak self] _ in
			self?.promptForPrivilegedToken { _ in }
		}

		let captureButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "captions.bubble"), primaryAction: nil, menu: UIMenu(children: [captureAction, tokenAction]))
		self.navigationItem.rightBarButtonItems = [self.moreBarButtonItem, captureButton]
	}

	private func captureLyrics() {
		guard let song = self.song else { return }

		Task { [weak self] in
			await self?.runCapture(for: song)
		}
	}

	/// Resolves the song's Apple Music identifier and captures its raw syllable lyrics.
	///
	/// - Parameter song: The song to capture lyrics for.
	private func runCapture(for song: KKSong) async {
		guard !UserSettings.appleMusicPrivilegedToken.isEmpty else {
			self.promptForPrivilegedToken { [weak self] saved in
				guard saved else { return }
				Task { await self?.runCapture(for: song) }
			}
			return
		}

		let appleMusicID: Int
		if let existing = song.attributes.amID {
			appleMusicID = existing
		} else if let resolved = await self.resolveAppleMusicID(for: song) {
			appleMusicID = resolved
		} else {
			return
		}

		let outcome = await LyricsCaptureManager.shared.capture(
			appleMusicID: appleMusicID,
			title: song.attributes.title,
			artist: song.attributes.artist,
			kkSongID: "\(song.id)"
		)
		self.presentCaptureOutcome(outcome)
	}

	/// Presents the reconcile picker and persists the confirmed identifier.
	///
	/// - Parameter song: The song to resolve.
	///
	/// - Returns: The confirmed Apple Music identifier.
	private func resolveAppleMusicID(for song: KKSong) async -> Int? {
		let selected: Int? = await withCheckedContinuation { continuation in
			let reconcileViewController = AMIDReconcileViewController(
				songTitle: song.attributes.title,
				songArtist: song.attributes.artist
			) { appleMusicID in
				continuation.resume(returning: appleMusicID)
			}
			let navigationController = KNavigationController(rootViewController: reconcileViewController)
			navigationController.modalPresentationStyle = .formSheet
			navigationController.presentationController?.delegate = reconcileViewController
			self.present(navigationController, animated: true)
		}

		guard let selected = selected else { return nil }

		let saved = await AppleMusicIDUpdater.save(appleMusicID: selected, forSongID: "\(song.id)")
		print("----- LyricsCapture: amID \(selected) saved to backend:", saved)

		return selected
	}

	/// Prompts user to paste the privileged Apple Music developer token.
	///
	/// - Parameter completion: The handler invoked with whether a token was saved.
	private func promptForPrivilegedToken(completion: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(
			title: "Privileged Token",
			message: "Paste the Apple Music web player developer token (Authorization: Bearer …).",
			preferredStyle: .alert
		)
		alertController.addTextField { textField in
			textField.placeholder = "eyJhbGciOi…"
			textField.text = UserSettings.appleMusicPrivilegedToken
			textField.clearButtonMode = .whileEditing
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
			completion(false)
		})
		alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
			let token = alertController.textFields?.first?.text ?? ""
			UserSettings.set(token, forKey: .appleMusicPrivilegedToken)
			completion(!token.isEmpty)
		})
		self.present(alertController, animated: true)
	}

	/// Presents a summary of the capture outcome.
	///
	/// - Parameter outcome: The outcome to summarize.
	private func presentCaptureOutcome(_ outcome: LyricsCaptureManager.CaptureOutcome) {
		let message: String
		switch outcome {
		case .success(let appleMusicID, let jsonBytes, let ttmlBytes):
			message = "Captured \(appleMusicID).\nJSON: \(jsonBytes) bytes · TTML: \(ttmlBytes) bytes\n\(LyricsCaptureManager.shared.captureDirectoryURL.path)"
		case .missingToken:
			message = "No privileged token configured."
		case .empty:
			message = "Apple returned an empty response."
		case .forbidden(let statusCode, _):
			message = "Rejected (\(statusCode)). The token likely lacks the lyrics entitlement, or the account isn't an active Apple Music subscriber."
		case .failed(let reason):
			message = "Failed: \(reason)"
		}

		let alertController = UIAlertController(title: "Lyrics Capture", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: L10n.okay, style: .default))
		self.present(alertController, animated: true)
	}
}
#endif
