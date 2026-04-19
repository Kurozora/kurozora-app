//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibraryListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = []
	var literatures: [Literature] = []
	var games: [Game] = []
	var nextPageURL: String?
	var sectionIndex: Int?
	var totalLibraryItemsCount: Int = 0
	var libraryKind: KKLibrary.Kind = UserSettings.libraryKind
	var libraryStatus: KKLibrary.Status = .none
	var librarySortType: KKLibrary.SortType = .none
	var librarySortTypeOption: KKLibrary.SortType.Option = .none {
		didSet {
			self.nextPageURL = nil
			self.delegate?.libraryListViewController(updateSortWith: self.librarySortType, sortOption: self.librarySortTypeOption)
		}
	}

	var libraryCellStyle: KKLibrary.CellStyle = .detailed
	var libraryColumnPreferences: KKLibrary.ColumnPreferences = .defaultShared

	private var lastEffectiveCellStyle: KKLibrary.CellStyle?

	weak var delegate: LibraryListViewControllerDelegate?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	var user: User?
	var viewedUser: User? {
		return self.user ?? User.current
	}

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
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.enableRefreshControl()
		}

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.viewedUser == User.current {
			NotificationCenter.default.addObserver(self, selector: #selector(addToLibrary(_:)), name: Notification.Name("AddTo\(self.libraryStatus.sectionValue)Section"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(removeFromLibrary(_:)), name: Notification.Name("RemoveFrom\(self.libraryStatus.sectionValue)Section"), object: nil)
		}

		// Add bottom inset to avoid the tabbar obscuring the view
		self.collectionView.contentInset.top = 50
		self.collectionView.contentInset.bottom = 60
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
		self.collectionView.allowsMultipleSelectionDuringEditing = true

		if self.viewedUser == nil {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		self.enableRefreshControl()

		#if !targetEnvironment(macCatalyst)
		let libraryStatus: String

		switch UserSettings.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
		}

		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshLibrary(libraryStatus.lowercased()))
		#endif

		if let (sortType, sortOption) = UserSettings.librarySortTypes[self.libraryKind]?[self.libraryStatus] {
			self.librarySortType = sortType
			self.librarySortTypeOption = sortOption
		}

		self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: self.libraryKind, status: self.libraryStatus)

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		UserSettings.set(self.sectionIndex, forKey: .libraryPage)

		self.configureEmptyDataView()
		self.toggleEmptyDataView()

		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDataSource = self

		if let index = self.sectionIndex {
			self.delegate?.libraryListViewController(willScrollTo: index)
		}

		self.delegate?.libraryListViewController(updateSortWith: self.librarySortType, sortOption: self.librarySortTypeOption)
		self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)

		if self.libraryKind != UserSettings.libraryKind {
			self.libraryKind = UserSettings.libraryKind
			self.nextPageURL = nil
			self.libraryCellStyle = UserSettings.libraryCellStyle(for: self.libraryKind, status: self.libraryStatus)
			self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: self.libraryKind, status: self.libraryStatus)
			self.shows = []
			self.literatures = []
			self.games = []
			self.updateDataSource()

			Task { [weak self] in
				guard let self = self else {
					return
				}

				await self.fetchLibrary()
			}
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard self.dataSource != nil else {
			return
		}

		let newEffective = self.effectiveCellStyleForCurrentEnvironment()
		guard newEffective != self.lastEffectiveCellStyle else {
			return
		}

		self.lastEffectiveCellStyle = newEffective

		DispatchQueue.main.async { [weak self] in
			self?.collectionView.reloadData()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else {
			return nil
		}

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else {
			return
		}

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
		}
	}
}
