//
//  ThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2022.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - SectionLayoutKind
extension ThemesCollectionViewController {
	/// List of  themes section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

class ThemesCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var themes: [Theme] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh themes list!")
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Theme>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Theme>! = nil

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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		// Setup refresh control
		self._prefersRefreshControlDisabled = false
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh themes list!")
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
		emptyBackgroundView.configureImageView(image: R.image.empty.genres()!)
		emptyBackgroundView.configureLabels(title: "No Themes", detail: "Can't get themes list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of .
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
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
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing themes list...")
			#endif
			#endif
		}

		do {
			let themeResponse = try await KService.getThemes().value
			self.themes = themeResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.themesCollectionViewController.exploreSegue.identifier:
			guard let homeCollectionViewController = segue.destination as? HomeCollectionViewController else { return }
			guard let theme = sender as? Theme else { return }
			homeCollectionViewController.theme = theme
		default: break
		}
	}
}
