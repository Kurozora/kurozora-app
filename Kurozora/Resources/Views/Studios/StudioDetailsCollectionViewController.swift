//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable {
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
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var studioIdentity: StudioIdentity?
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

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage { .Empty.cast }

	override var emptyStateDetail: String { "This studio doesn't have details yet. Please check back again later." }

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
				let studioResponse = try await KService.getDetails(forStudio: studioIdentity)
				self.studio = studioResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forStudio: studioIdentity, next: nil, limit: 10)
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forStudio: studioIdentity, limit: 10)
			self.showIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.getLiteratures(forStudio: studioIdentity, limit: 10)
			self.literatureIdentities = literatureIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getGames(forStudio: studioIdentity, limit: 10)
			self.gameIdentities = gameIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.studio?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard let studio = self.studio else { return nil }
		return try await studio.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? {
		guard let studio = self.studio else { return nil }
		return (.studio(studio), studio.attributes.library?.rating, studio.attributes.library?.review)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: KKLibrary.Kind) -> (any Libraryable)? {
		return self.cache[indexPath] as? any Libraryable
	}

	override func reminderTarget(at indexPath: IndexPath) -> Show? {
		return self.cache[indexPath] as? Show
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.studio?.attributes.library?.rating = nil
		self.studio?.attributes.library?.review = nil
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
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .studio(self.studio)
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
		case .studioDetailsSegue: return
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
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
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
						await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}
}
