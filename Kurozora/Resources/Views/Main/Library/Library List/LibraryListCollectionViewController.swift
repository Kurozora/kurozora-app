//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}
	var nextPageURL: String?
	var libraryStatus: KKLibrary.Status = .planning
	var sectionIndex: Int?
	var librarySortType: KKLibrary.SortType = .none
	var librarySortTypeOption: KKLibrary.SortType.Options = .none {
		didSet {
			self.nextPageURL = nil
			self.delegate?.libraryListViewController(updateSortWith: librarySortType)
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
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchLibrary()
			}
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .libraryPage)

		// Setup library view controller delegate
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self

		// Update change layout button to reflect user settings
		delegate?.libraryListViewController(updateLayoutWith: libraryCellStyle)

		// Update sort type button to reflect user settings
		delegate?.libraryListViewController(updateSortWith: librarySortType)
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
		self.nextPageURL = nil
		DispatchQueue.global(qos: .userInteractive).async {
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
	func fetchLibrary() {
		if User.isSignedIn {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your \(self.libraryStatus.stringValue.lowercased()) list...")
				#endif
			}

			KService.getLibrary(withLibraryStatus: self.libraryStatus, withSortType: self.librarySortType, withSortOption: librarySortTypeOption, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let showResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.shows = []
					}

					// Save next page url and append new data
					self.nextPageURL = showResponse.next
					self.shows.append(contentsOf: showResponse.data)

					// Reset refresh controller title
					#if !targetEnvironment(macCatalyst)
					self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.libraryStatus.stringValue.lowercased()) list.")
					#endif
				case .failure: break
				}
			}
		} else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.shows.removeAll()
				self.collectionView.reloadData {
					self.toggleEmptyDataView()
				}
			}
		}
	}

	/// Add the given show to the library.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func addToLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchLibrary()
		}
	}

	/// Removes the given show from the library.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func removeFromLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchLibrary()
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? LibraryBaseCollectionViewCell, let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
			showDetailCollectionViewController.show = currentCell.show
		}
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

		DispatchQueue.global(qos: .userInteractive).async {
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

// MARK: - UIScrollViewDelegate
extension LibraryListCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if let parent = self.parent?.parent as? LibraryViewController {
			parent.scrollView.contentSize = scrollView.contentSize
			parent.scrollView.contentInset = scrollView.contentInset
			parent.scrollView.contentOffset = scrollView.contentOffset
			parent.scrollView.decelerationRate = scrollView.decelerationRate
			parent.scrollView.panGestureRecognizer.state = scrollView.panGestureRecognizer.state
			parent.scrollView.directionalPressGestureRecognizer.state = scrollView.directionalPressGestureRecognizer.state
		}
	}
}

// MARK: - SectionLayoutKind
extension LibraryListCollectionViewController {
	/// List of cast section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
