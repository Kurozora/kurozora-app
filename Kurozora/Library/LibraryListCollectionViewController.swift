//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwiftTheme

protocol LibraryListViewControllerDelegate: class {
	func updateChangeLayoutButton(with cellStyle: Library.CellStyle)
	func updateSortTypeButton(with sortType: Library.SortType)
}

class LibraryListCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	private let refreshControl = UIRefreshControl()

	var showDetailsElements: [ShowDetailsElement]? {
		didSet {
			collectionView.reloadData {
				DispatchQueue.main.async {
					self.refreshControl.endRefreshing()
					self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.sectionTitle.lowercased()) list.", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
				}
			}
		}
	}
	var sectionTitle: String = ""
	var sectionIndex: Int?
	var librarySortType: Library.SortType = .none {
		didSet {
			self.delegate?.updateSortTypeButton(with: librarySortType)
			self.savePreferredSortType()
		}
	}
	var libraryCellStyle: Library.CellStyle = .detailed
	weak var delegate: LibraryListViewControllerDelegate?

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .libraryPage)

		// Update change layout button to reflect user settings
		delegate?.updateChangeLayoutButton(with: libraryCellStyle)

		// Update sort type button to reflect user settings
		delegate?.updateSortTypeButton(with: librarySortType)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		collectionView.collectionViewLayout = createLayout()

		// Setup library view controller delegate
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self

		// Add Refresh Control to Collection View
		collectionView.refreshControl = refreshControl
		refreshControl.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle.lowercased()) list.", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)

		// Observe NotificationCenter for an update
		NotificationCenter.default.addObserver(self, selector: #selector(fetchLibrary), name: Notification.Name("Update\(sectionTitle)Section"), object: nil)

		// Fetch library if user is signed in
		if User.isSignedIn {
			fetchLibrary()
		}

        // Setup empty data view
		setupEmptyDataView()
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}

	// MARK: - Functions
	/// Setup empty data view data.
	func setupEmptyDataView() {
		collectionView.emptyDataSetView { (view) in
			let detailLabelString = User.isSignedIn ? "Add a show to your \(self.sectionTitle.lowercased()) list and it will show up here." : "Library is only available to registered Kurozora users."
			view.titleLabelString(NSAttributedString(string: "No Shows", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_library"))
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)

			// Not signed in
			if !User.isSignedIn {
				view.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue]), for: .normal)
					.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue.darken()]), for: .highlighted)
					.isScrollAllowed(false)
					.didTapDataButton {
						if let signInTableViewController = SignInTableViewController.instantiateFromStoryboard() as? SignInTableViewController {
							let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
							self.present(kNavigationController)
						}
					}
			}
		}
	}

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		collectionView.reloadData()
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		refreshControl.isEnabled = User.isSignedIn
	}

	/// Reload the data on the view.
	@objc private func reloadData() {
		enableActions()
		fetchLibrary()
	}

	/// Fetch the library items for the current user.
	@objc private func fetchLibrary() {
		if User.isSignedIn {
			refreshControl.attributedTitle = NSAttributedString(string: "Refreshing your \(sectionTitle.lowercased()) list...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])

			KService.shared.getLibrary(forStatus: sectionTitle, withSortType: librarySortType.rawValue, withSuccess: { (showDetailsElements) in
				DispatchQueue.main.async {
					self.showDetailsElements = showDetailsElements
				}
			})
		} else {
			self.showDetailsElements = nil
			collectionView.reloadData()
		}
	}

	/**
		Reutrns the number of columns the collection view should present.

		Number of columns is calculated by deviding the max width of the cell with the total width of the collection view.

		- Parameter width: The width of the collection view used to calculate the number of columns.

		- Returns: the number of columns the collection view should present.
	*/
	func columnCount(for width: CGFloat) -> Int {
		switch libraryCellStyle {
		case .compact:
			var columnCount = (width / 125).int
			if columnCount < 0 {
				columnCount = 3
			} else if columnCount > 10 {
				columnCount = 10
			}
			return columnCount
		case .detailed, .list:
			var columnCount = (width / 374).int
			if columnCount < 0 {
				columnCount = 1
			} else if columnCount > 5 {
				columnCount = 5
			}
			return columnCount
		}
	}

	/**
		Returns the CGFloat value of the collection view group height fraction.

		When the width of the cell is longer than the height, the fractional height is calculated by deviding the fractional height for one column with the number of columns the collection view is currenlty presenting.

		- Parameter column: The number of columns used to determin the fractional height value.

		- Returns: the CGFloat value of the collection view group height fraction.
	*/
	func groupHeightFraction(for column: Int) -> CGFloat {
		switch libraryCellStyle {
		case .compact:
			return (1.44 / column.double).cgFloat
		case .detailed, .list:
			return (0.60 / column.double).cgFloat
		}
	}

	/**
		Returns the layout that should be used for the collection view.

		- Returns: the layout that should be used for the collection view.
	*/
	func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

			let heightFraction = self.groupHeightFraction(for: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .fractionalWidth(heightFraction))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
			return section
		}
		return layout
	}

	/// Returns a ShowDetailsElemenet for the selected show at the given index path.
	func selectedShow(at indexPath: IndexPath) -> ShowDetailsElement? {
		return showDetailsElements?[indexPath.row]
    }

	fileprivate func savePreferredSortType() {
		let librarySortTypes = UserSettings.librarySortTypes
		var newLibrarySortTypes = librarySortTypes
		newLibrarySortTypes[sectionTitle] = librarySortType.rawValue
		UserSettings.set(newLibrarySortTypes, forKey: .librarySortTypes)
	}

	/// Builds and presents the sort types in an action sheet.
	func populateSortActions(_ sender: UIBarButtonItem) {
		let action = UIAlertController.actionSheetWithItems(items: Library.SortType.alertControllerItems) { (_, value) in
			self.librarySortType = value
			self.fetchLibrary()
		}

		if librarySortType != .none {
			// Report thread action
			let stopSortingAction = UIAlertAction.init(title: "Stop sorting", style: .destructive, handler: { (_) in
				self.librarySortType = .none
				self.fetchLibrary()
			})
			stopSortingAction.setValue(#imageLiteral(resourceName: "Symbols/xmark_circle_fill"), forKey: "image")
			stopSortingAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(stopSortingAction)
		}

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(action, animated: true, completion: nil)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? LibraryBaseCollectionViewCell, let showDetailViewController = segue.destination as? ShowDetailViewController {
			showDetailViewController.libraryBaseCollectionViewCell = currentCell
			showDetailViewController.showDetailsElement = currentCell.showDetailsElement
			showDetailViewController.delegate = self
		}
	}
}

// MARK: - UICollectionViewDataSource
extension LibraryListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let showDetailsElementsCount = showDetailsElements?.count else { return 0 }
		return showDetailsElementsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: libraryCellStyle.identifierString, for: indexPath) as! LibraryBaseCollectionViewCell
		libraryBaseCollectionViewCell.showDetailsElement = showDetailsElements?[indexPath.item]
		return libraryBaseCollectionViewCell
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
					   options: .beginFromCurrentState,
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
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}
}

// MARK: - UICollectionViewDragDelegate
extension LibraryListCollectionViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let libraryBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryBaseCollectionViewCell else { return [UIDragItem]() }
		let selectedShow = self.selectedShow(at: indexPath)

		guard let userActivity = selectedShow?.openDetailUserActivity else { return [UIDragItem]() }
		let itemProvider = NSItemProvider(object: (libraryBaseCollectionViewCell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image ?? libraryBaseCollectionViewCell.posterImageView.image ?? #imageLiteral(resourceName: "placeholder_poster_image"))
		itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = selectedShow

        return [dragItem]
    }
}

// MARK: - ShowDetailViewControllerDelegate
extension LibraryListCollectionViewController: ShowDetailViewControllerDelegate {
	func updateShowInLibrary(for libraryCell: LibraryBaseCollectionViewCell?) {
		guard let libraryCell = libraryCell else { return }
		guard let indexPath = collectionView.indexPath(for: libraryCell) else { return }

		collectionView.performBatchUpdates({
			showDetailsElements?.remove(at: indexPath.item)
			collectionView.deleteItems(at: [indexPath])
		})

		collectionView.reloadData()
	}
}

// MARK: - LibraryViewControllerDelegate
extension LibraryListCollectionViewController: LibraryViewControllerDelegate {
	func sortTypeBarButtonItemPressed(_ sender: UIBarButtonItem) {
		populateSortActions(sender)
	}
}

//    func updateSortType(sortType: SortType) {
//
//        currentSortType = sortType
//
//        switch self.currentSortType {
//        case .Rating:
//            animeList.sortInPlace({ $0.rank < $1.rank && $0.rank != 0 })
//        case .Popularity:
//            animeList.sortInPlace({ $0.popularityRank < $1.popularityRank })
//        case .Title:
//            animeList.sortInPlace({ $0.title < $1.title })
//        case .NextAiringEpisode:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
//                let startDate2 = anime2.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
//                return startDate1.compare(startDate2) == .OrderedAscending
//            })
//        case .Newest:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.startDate ?? NSDate()
//                let startDate2 = anime2.startDate ?? NSDate()
//                return startDate1.compare(startDate2) == .OrderedDescending
//            })
//        case .Oldest:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.startDate ?? NSDate()
//                let startDate2 = anime2.startDate ?? NSDate()
//                return startDate1.compare(startDate2) == .OrderedAscending
//
//            })
//        case .MyRating:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let score1 = anime1.progress!.score ?? 0
//                let score2 = anime2.progress!.score ?? 0
//                return score1 > score2
//            })
//        case .NextEpisodeToWatch:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//                let nextDate1 = anime1.progress!.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
//                let nextDate2 = anime2.progress!.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
//                return nextDate1.compare(nextDate2) == .OrderedAscending
//            })
//            break
//        default:
//            break
//        }
//
//        if isViewLoaded {
//            collectionView.reloadData()
//        }
//    }
//}
