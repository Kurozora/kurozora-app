//
//  FavoriteShowsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FavoriteShowsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showDetailsElements: [ShowDetailsElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.collectionView.reloadData()
		}
	}
	var userID: Int? = nil
	var username: String?
	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if dismissButtonIsEnabled {
				enableDismissButton()
			}
		}
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

	// MARK: - Views
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		// Create colelction view layout
		collectionView.collectionViewLayout = createLayout()
		collectionView.register(nib: UINib(nibName: "SectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: SectionHeaderReusableView.self)
		collectionView.register(nibWithCellClass: SmallLockupCollectionViewCell.self)

		// Observe NotificationCenter for an update
		if userID == nil {
			NotificationCenter.default.addObserver(self, selector: #selector(fetchFavoritesList), name: .KFavoriteShowsListDidChange, object: nil)
		}

		DispatchQueue.global(qos: .background).async {
			self.fetchFavoritesList()
		}
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "library", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "FavoriteShowsCollectionViewController")
	}

	/// Enable and show the dismiss button.
	func enableDismissButton() {
		let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissButtonPressed))
		self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
	}

	/// Dismiss the view. Used by the dismiss button when viewing other users' profile.
	@objc fileprivate func dismissButtonPressed() {
		dismiss(animated: true, completion: nil)
	}

	override func setupEmptyDataSetView() {
		collectionView.emptyDataSetView { view in
			let detailLabel = self.userID == nil ? "Favorited shows will show up on this page!" : "\(self.username ?? "This user") hasn't favorited shows yet."
			view.titleLabelString(NSAttributedString(string: "No Favorites", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabel, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_favorites"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetches the user's favorite list.
	@objc fileprivate func fetchFavoritesList() {
		KService.shared.getFavourites(forUser: userID) { (showDetailsElements) in
			DispatchQueue.main.async {
				self.showDetailsElements = showDetailsElements
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? SmallLockupCollectionViewCell, let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
			showDetailCollectionViewController.baseLockupCollectionViewCell = currentCell
			showDetailCollectionViewController.showDetailsElement = currentCell.showDetailsElement
		}
	}
}

// MARK: - UICollectionViewDataSource
extension FavoriteShowsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let showDetailsElements = showDetailsElements else { return 0 }
		if showDetailsElements.isEmpty {
			return 0
		} else {
			return 2
		}
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
		guard let showDetailsElementsCount = showDetailsElements?.count else { return 0 }
		return showDetailsElementsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.section == 0 {
			let libraryStatisticsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryStatisticsCollectionViewCell", for: indexPath)
			return libraryStatisticsCollectionViewCell
		}
		let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
		return smallLockupCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegate
extension FavoriteShowsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let libraryStatisticsCollectionViewCell = cell as? LibraryStatisticsCollectionViewCell {
			libraryStatisticsCollectionViewCell.showDetailsElements = showDetailsElements
		} else if let smallLockupCollectionViewCell = cell as? SmallLockupCollectionViewCell {
			smallLockupCollectionViewCell.showDetailsElement = showDetailsElements?[indexPath.row]
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell
			performSegue(withIdentifier: "ShowDetailsSegue", sender: smallLockupCollectionViewCell)
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension FavoriteShowsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		if section == 0 {
			return 1
		}

		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = (width / 374).rounded().int
		if columnCount < 0 {
			columnCount = 1
		} else if columnCount > 5 {
			columnCount = 5
		}
		return columnCount
	}

	func heightDimension(forSection section: Int, with columnsCount: Int) -> NSCollectionLayoutDimension {
		if section == 0 {
			return .absolute(80)
		}

		let heightFraction = (0.60 / columnsCount.double).cgFloat
		return .fractionalWidth(heightFraction)
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightDimension = self.heightDimension(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: heightDimension)
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)

			return layoutSection
		}
		return layout
	}
}
