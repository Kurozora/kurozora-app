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
	#if !targetEnvironment(macCatalyst)
	private let refreshControl = UIRefreshControl()
	#endif

	var shows: [Show] = [] {
		didSet {
			self.configureDataSource()
			#if !targetEnvironment(macCatalyst)
			self.refreshControl.endRefreshing()
			self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(self.libraryStatus.stringValue.lowercased()) list.", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
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
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

	override var prefersActivityIndicatorHidden: Bool {
		return true
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

		#if !targetEnvironment(macCatalyst)
		self.enableActions()
		#endif
		self.fetchLibrary()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Add bottom inset to avoid the tabbar obscuring the view
		collectionView.contentInset.bottom = 50

		// Setup collection view.
		collectionView.collectionViewLayout = createLayout()

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		collectionView.refreshControl = refreshControl
		refreshControl.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(libraryStatus.stringValue.lowercased()) list.", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshControl.addTarget(self, action: #selector(viewWillReload), for: .valueChanged)
		#endif

		// Observe NotificationCenter for an update
		NotificationCenter.default.addObserver(self, selector: #selector(fetchLibrary), name: Notification.Name("Update\(libraryStatus.sectionValue)Section"), object: nil)

		// Fetch library if user is signed in
		if User.isSignedIn {
			DispatchQueue.global(qos: .background).async {
				self.fetchLibrary()
			}
		}
    }

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		collectionView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }
			let detailLabelString = User.isSignedIn ? "Add a show to your \(self.libraryStatus.stringValue.lowercased()) list and it will show up here." : "Library is only available to registered Kurozora users."
			view.titleLabelString(NSAttributedString(string: "No Shows", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.library())

			// Not signed in
			if !User.isSignedIn {
				view.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue]), for: .normal)
					.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue.darken()]), for: .highlighted)
					.isScrollAllowed(false)
					.didTapDataButton {
						if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
							let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
							self.present(kNavigationController, animated: true)
						}
					}
			} else {
				view.verticalOffset(-50)
					.verticalSpace(5)
					.isScrollAllowed(true)
			}
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	#if !targetEnvironment(macCatalyst)
	private func enableActions() {
		refreshControl.isEnabled = User.isSignedIn
	}
	#endif

	/// Fetch the library items for the current user.
	@objc private func fetchLibrary() {
		if User.isSignedIn {
			DispatchQueue.main.async {
				#if !targetEnvironment(macCatalyst)
				self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing your \(self.libraryStatus.stringValue.lowercased()) list...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
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
			self.shows = []
			collectionView.reloadData()
		}
	}

	/// Returns a ShowDetailsElemenet for the selected show at the given index path.
	func selectedShow(at indexPath: IndexPath) -> Show? {
		return shows[indexPath.row]
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
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			if let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.libraryCellStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell {
				libraryBaseCollectionViewCell.show = self.shows[indexPath.item]
				return libraryBaseCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
			}
		}

		let itemsPerSection = shows.count
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			snapshot.appendSections([$0])
			let itemOffset = $0.rawValue * itemsPerSection
			let itemUpperbound = itemOffset + itemsPerSection
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
		collectionView.reloadEmptyDataSet()
	}
}

// MARK: - KCollectionViewDelegateLayout
extension LibraryListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		switch libraryCellStyle {
		case .compact:
			var columnCount = (width / 125).rounded().int
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

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		switch libraryCellStyle {
		case .compact:
			return (1.44 / columnsCount.double).cgFloat
		case .detailed, .list:
			return (0.60 / columnsCount.double).cgFloat
		}
	}

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns, layout: layoutEnvironment)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
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
		let selectedShow = self.selectedShow(at: indexPath)

		guard let userActivity = selectedShow?.openDetailUserActivity else { return [UIDragItem]() }
		let itemProvider = NSItemProvider(object: (libraryBaseCollectionViewCell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image ?? libraryBaseCollectionViewCell.posterImageView.image ?? R.image.placeholders.showPoster()!)
		itemProvider.suggestedName = libraryBaseCollectionViewCell.titleLabel.text
		itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = selectedShow

        return [dragItem]
    }
}

// MARK: - ShowDetailsCollectionViewControllerDelegate
extension LibraryListCollectionViewController: ShowDetailsCollectionViewControllerDelegate {
	func updateShowInLibrary(for libraryCell: LibraryBaseCollectionViewCell?) {
		guard let libraryCell = libraryCell else { return }
		guard let indexPath = collectionView.indexPath(for: libraryCell) else { return }

		collectionView.performBatchUpdates({
			shows.remove(at: indexPath.item)
			collectionView.deleteItems(at: [indexPath])
		})

		collectionView.reloadData()
	}
}

// MARK: - LibraryViewControllerDelegate
extension LibraryListCollectionViewController: LibraryViewControllerDelegate {
	func sortLibrary(by sortType: KKLibrary.SortType, option: KKLibrary.SortType.Options) {
		librarySortType = sortType
		librarySortTypeOption = option
		self.fetchLibrary()
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
