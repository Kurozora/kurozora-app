//
//  ReCapCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation

class ReCapCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var year: Int = 0
	var recapItems: [RecapItem] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

	/// Show properties.
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []

	/// Literature properties.
	var literatures: [IndexPath: Literature] = [:]
	var literatureIdentities: [LiteratureIdentity] = []

	/// Game properties.
	var games: [IndexPath: Game] = [:]
	var gameIdentities: [GameIdentity] = []

	/// Genre properties.
	var genres: [IndexPath: Genre] = [:]
	var genreIdentities: [GenreIdentity] = []

	/// Theme properties.
	var themes: [IndexPath: Theme] = [:]
	var themeIdentities: [ThemeIdentity] = []

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.title = "\(Trans.reCAP)’\(self.year % 100)"

		self.configureDataSource()

		// Fetch ReCap details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	func fetchDetails() async {
		do {
			let recapResponse = try await KService.getRecap(for: "\(self.year)").value
			self.recapItems = recapResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}
}

// MARK: - SectionLayoutKind
extension ReCapCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a top shows section layout type.
		case topShows(_: RecapItem)

		/// Indicates a top literatures section layout type.
		case topLiteratures(_: RecapItem)

		/// Indicates a top games section layout type.
		case topGames(_: RecapItem)

		/// Indicates a top genres section layout type.
		case topGenres(_: RecapItem)

		/// Indicates a top themes section layout type.
		case topThemes(_: RecapItem)

		/// Indicates a milestones section layout type.
		case milestones(_: RecapItem)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .topShows(let recapItem):
				hasher.combine(recapItem)
			case .topLiteratures(let recapItem):
				hasher.combine(recapItem)
			case .topGames(let recapItem):
				hasher.combine(recapItem)
			case .topGenres(let recapItem):
				hasher.combine(recapItem)
			case .topThemes(let recapItem):
				hasher.combine(recapItem)
			case .milestones(let recapItem):
				hasher.combine(recapItem)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.topShows(let recapItem1), .topShows(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topLiteratures(let recapItem1), .topLiteratures(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topGames(let recapItem1), .topGames(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topGenres(let recapItem1), .topGenres(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topThemes(let recapItem1), .topThemes(let recapItem2)):
				return recapItem1 == recapItem2
			case (.milestones(let recapItem1), .milestones(let recapItem2)):
				return recapItem1 == recapItem2
			default: return false
			}
		}
	}
}

// MARK: - ItemKind
extension ReCapCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GenreIdentity` object.
		case genreIdentity(_: GenreIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ThemeIdentity` object.
		case themeIdentity(_: ThemeIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			case .genreIdentity(let genreIdentity, let id):
				hasher.combine(genreIdentity)
				hasher.combine(id)
			case .themeIdentity(let themeIdentity, let id):
				hasher.combine(themeIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			case (.genreIdentity(let genreIdentity1, let id1), .genreIdentity(let genreIdentity2, let id2)):
				return genreIdentity1 == genreIdentity2 && id1 == id2
			case (.themeIdentity(let themeIdentity1, let id1), .themeIdentity(let themeIdentity2, let id2)):
				return themeIdentity1 == themeIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
