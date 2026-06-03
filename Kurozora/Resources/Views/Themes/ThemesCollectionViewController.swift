//
//  ThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2022.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ThemesCollectionViewController: KCollectionViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case exploreSegue
	}

	// MARK: - Properties
	var themes: [Theme] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.themes.lowercased(with: Locale.current)))
			#endif
			#endif
		}
	}

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Theme>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Theme>!

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

		self.title = L10n.browseThemes

		#if DEBUG
		// Setup refresh control
		self._prefersRefreshControlDisabled = false
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.themes.lowercased(with: Locale.current)))
		#endif
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchThemes()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchThemes()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.genres)
		emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.themes), detail: L10n.cantGetListDetail(L10n.themes.lowercased(with: Locale.current)))

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

	/// Fetches themes from the server.
	func fetchThemes() async {
		DispatchQueue.main.async {
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.themes.lowercased(with: Locale.current)))
			#endif
			#endif
		}

		do {
			let identityResponse = try await KService.themes().response()
			let detailedResponse = try await KService.details(identityResponse.data).response()
			self.themes = detailedResponse.data
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
				let theme = sender as? Theme
			else { return }
			homeCollectionViewController.theme = theme
		}
	}
}

// MARK: - SectionLayoutKind
extension ThemesCollectionViewController {
	/// List of  themes section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - Cell Configuration
extension ThemesCollectionViewController {
	func getConfiguredGenreCell() -> UICollectionView.CellRegistration<GenreLockupCollectionViewCell, Theme> {
		return UICollectionView.CellRegistration<GenreLockupCollectionViewCell, Theme>(cellNib: GenreLockupCollectionViewCell.nib) { genreLockupCollectionViewCell, _, itemKind in
			genreLockupCollectionViewCell.configure(using: itemKind)
		}
	}
}
