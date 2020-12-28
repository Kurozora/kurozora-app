//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol LibraryListViewControllerDelegate: class {
	func updateChangeLayoutButton(with cellStyle: KKLibrary.CellStyle)
	func updateSortTypeButton(with sortType: KKLibrary.SortType)
}

class LibraryListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.libraryStatus.stringValue.lowercased()) list.")
			#endif
		}
	}
	var libraryStatus: KKLibrary.Status = .planning
	var sectionIndex: Int?
	var librarySortType: KKLibrary.SortType = .none
	var librarySortTypeOption: KKLibrary.SortType.Options = .none {
		didSet {
			self.delegate?.updateSortTypeButton(with: librarySortType)
		}
	}
	var libraryCellStyle: KKLibrary.CellStyle = .detailed
	weak var delegate: LibraryListViewControllerDelegate?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Show>! = nil

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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .libraryPage)

		// Setup library view controller delegate
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self

		// Update change layout button to reflect user settings
		delegate?.updateChangeLayoutButton(with: libraryCellStyle)

		// Update sort type button to reflect user settings
		delegate?.updateSortTypeButton(with: librarySortType)
	}

	override func viewWillReload() {
		super.viewWillReload()

		self.enableRefreshControl()
		self.handleRefreshControl()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(addToLibrary(_:)), name: Notification.Name("AddTo\(self.libraryStatus.sectionValue)Section"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(removeFromLibrary(_:)), name: Notification.Name("RemoveFrom\(self.libraryStatus.sectionValue)Section"), object: nil)

		// Add bottom inset to avoid the tabbar obscuring the view
		self.collectionView.contentInset.bottom = 50

		// Setup collection view.
		self.collectionView.collectionViewLayout = self.createLayout()

		// Hide activity indicator if user is not signed in.
		if !User.isSignedIn {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		// Add Refresh Control to Collection View
		enableRefreshControl()
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(libraryStatus.stringValue.lowercased()) list.")
		#endif

		self.configureDataSource()

		// Fetch library if user is signed in
		if User.isSignedIn {
			DispatchQueue.global(qos: .background).async {
				self.fetchLibrary()
			}
		}
    }

	// MARK: - Functions
	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 || !User.isSignedIn {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	override func handleRefreshControl() {
		DispatchQueue.global(qos: .background).async {
			self.fetchLibrary()
		}
	}

	override func configureEmptyDataView() {
		var detailString: String
		var buttonTitle: String = ""
		var buttonAction: (() -> Void)? = nil

		if User.isSignedIn {
			detailString = "Add a show to your \(self.libraryStatus.stringValue.lowercased()) list and it will show up here."
		} else {
			detailString = "Library is currently available to registered Kurozora users only."
			buttonTitle = "Sign In"
			buttonAction = {
				if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
					let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
					self.present(kNavigationController, animated: true)
				}
			}
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.library()!)
		emptyBackgroundView.configureLabels(title: "No Shows", detail: detailString)
		emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		collectionView.backgroundView?.alpha = 0
	}

	/// Enables and disables the refresh control according to the user sign in state.
	private func enableRefreshControl() {
		self._prefersRefreshControlDisabled = !User.isSignedIn
	}

	/// Fetch the library items for the current user.
	private func fetchLibrary() {
		if User.isSignedIn {
			DispatchQueue.main.async {
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your \(self.libraryStatus.stringValue.lowercased()) list...")
				#endif
			}

			KService.getLibrary(withLibraryStatus: self.libraryStatus, withSortType: librarySortType, withSortOption: librarySortTypeOption) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let shows):
					self.shows = shows
				case .failure: break
				}
			}
		} else {
			self.shows.removeAll()
			collectionView.reloadData {
				self.toggleEmptyDataView()
			}
		}
	}

	/**
		Add the given show to the library.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc func addToLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .background).async {
			self.fetchLibrary()
		}
	}

	/**
		Removes the given show from the library.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc func removeFromLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .background).async {
			self.fetchLibrary()
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? LibraryBaseCollectionViewCell, let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
			showDetailCollectionViewController.showID = currentCell.show.id
		}
	}
}

// MARK: - UICollectionViewDelegate
extension LibraryListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 0.2,
					   options: [.beginFromCurrentState],
					   animations: {
						cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}, completion: nil)
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.4,
					   initialSpringVelocity: 0.2,
					   options: [.beginFromCurrentState],
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let libraryBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryBaseCollectionViewCell
		performSegue(withIdentifier: R.segue.libraryListCollectionViewController.showDetailsSegue, sender: libraryBaseCollectionViewCell)
	}
}

// MARK: - KCollectionViewDataSource
extension LibraryListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return []
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Show>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Show) -> UICollectionViewCell? in
			if let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.libraryCellStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell {
				libraryBaseCollectionViewCell.show = item
				return libraryBaseCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Show>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.shows)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension LibraryListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		switch libraryCellStyle {
		case .compact:
			var columnCount = (width / 105).rounded().int
			if columnCount < 0 {
				columnCount = 3
			} else if columnCount > 8 {
				columnCount = 8
			} else {
				columnCount = abs(columnCount.double/1.5).rounded().int
			}
			return columnCount
		case .detailed, .list:
			var columnCount = (width / 374).rounded().int
			if columnCount < 0 {
				columnCount = 1
			} else if columnCount > 5 {
				columnCount = 5
			}
			return columnCount
		}
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = 10.0
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - UICollectionViewDragDelegate
extension LibraryListCollectionViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let libraryBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryBaseCollectionViewCell else { return [UIDragItem]() }
		let selectedShow = self.shows[indexPath.row]
		let userActivity = selectedShow.openDetailUserActivity
		let itemProvider = NSItemProvider(object: (libraryBaseCollectionViewCell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image ?? libraryBaseCollectionViewCell.posterImageView.image ?? R.image.placeholders.showPoster()!)
		itemProvider.suggestedName = libraryBaseCollectionViewCell.titleLabel.text
		itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = selectedShow

        return [dragItem]
    }
}

// MARK: - LibraryViewControllerDelegate
extension LibraryListCollectionViewController: LibraryViewControllerDelegate {
	func sortLibrary(by sortType: KKLibrary.SortType, option: KKLibrary.SortType.Options) {
		librarySortType = sortType
		librarySortTypeOption = option

//		switch (librarySortType, librarySortTypeOption) {
//		case (.alphabetically, .ascending):
//			self.shows.sort { $0.attributes.title < $1.attributes.title }
//			self.updateDataSource()
//		case (.alphabetically, .descending):
//			self.shows.sort { $0.attributes.title > $1.attributes.title }
//			self.updateDataSource()
//		default: break
//		}

		DispatchQueue.global(qos: .background).async {
			self.fetchLibrary()
		}
	}

	func sortValue() -> KKLibrary.SortType {
		return librarySortType
	}

	func sortOptionValue() -> KKLibrary.SortType.Options {
		return librarySortTypeOption
	}
}

// MARK: - SectionLayoutKind
extension LibraryListCollectionViewController {
	/**
		List of cast section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
