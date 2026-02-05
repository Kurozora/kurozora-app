//
//  GenresCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class GenresCollectionViewController: KCollectionViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case exploreSegue
	}

	// MARK: - Properties
	var genres: [Genre] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh genres list!")
			#endif
			#endif
		}
	}

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Genre>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Genre>!

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

		self.title = Trans.browseGenres

		#if DEBUG
		// Setup refresh control
		self._prefersRefreshControlDisabled = false
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh genres list!")
		#endif
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchGenres()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchGenres()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.genres)
		emptyBackgroundView.configureLabels(title: "No Genres", detail: "Can't get genres list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of .
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches genres from the server.
	func fetchGenres() async {
		DispatchQueue.main.async {
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing genres list...")
			#endif
			#endif
		}

		do {
			let genreResponse = try await KService.getGenres().value
			self.genres = genreResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .exploreSegue: return HomeCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .exploreSegue:
			guard
				let homeCollectionViewController = destination as? HomeCollectionViewController,
				let genre = sender as? Genre
			else { return }
			homeCollectionViewController.genre = genre
		}
	}
}

// MARK: - SectionLayoutKind
extension GenresCollectionViewController {
	/// List of  genres section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - Cell Configuration
extension GenresCollectionViewController {
	func getConfiguredGenreCell() -> UICollectionView.CellRegistration<GenreLockupCollectionViewCell, Genre> {
		return UICollectionView.CellRegistration<GenreLockupCollectionViewCell, Genre>(cellNib: GenreLockupCollectionViewCell.nib) { genreLockupCollectionViewCell, _, itemKind in
			genreLockupCollectionViewCell.configure(using: itemKind)
		}
	}
}
