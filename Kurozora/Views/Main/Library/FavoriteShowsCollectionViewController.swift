//
//  FavoriteShowsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FavoriteShowsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showDetailsElements: [ShowDetailsElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.configureDataSource()
		}
	}
	var _userProfile: UserProfile? = User.current
	var userProfile: UserProfile? {
		get {
			return _userProfile
		}
		set {
			self._userProfile = newValue
		}
	}
	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if dismissButtonIsEnabled {
				enableDismissButton()
			}
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

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
		// Observe NotificationCenter for an update.
		if userProfile?.id == User.current?.id {
			NotificationCenter.default.addObserver(self, selector: #selector(fetchFavoritesList), name: .KFavoriteShowsListDidChange, object: nil)
		}

		DispatchQueue.global(qos: .background).async {
			self.fetchFavoritesList()
		}
	}

	// MARK: - Functions
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
			let detailLabel = self.userProfile?.id == User.current?.id ? "Favorited shows will show up on this page!" : "\(self.userProfile?.username ?? "This user") hasn't favorited shows yet."
			view.titleLabelString(NSAttributedString(string: "No Favorites", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabel, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.favorites()!)
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetches the user's favorite list.
	@objc fileprivate func fetchFavoritesList() {
		guard let userID = self.userProfile?.id else { return }
		KService.getFavourites(forUserID: userID) { result in
			switch result {
			case .success(let showDetailsElements):
				DispatchQueue.main.async {
					self.showDetailsElements = showDetailsElements
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? SmallLockupCollectionViewCell, let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
			showDetailCollectionViewController.showDetailsElement = currentCell.showDetailsElement
		}
	}
}

// MARK: - UICollectionViewDelegate
extension FavoriteShowsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell
			performSegue(withIdentifier: R.segue.favoriteShowsCollectionViewController.showDetailsSegue, sender: smallLockupCollectionViewCell)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension FavoriteShowsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			if indexPath.section == 0 {
				if let libraryStatisticsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.libraryStatisticsCollectionViewCell, for: indexPath) {
					libraryStatisticsCollectionViewCell.showDetailsElements = self.showDetailsElements
					return libraryStatisticsCollectionViewCell
				} else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.libraryStatisticsCollectionViewCell.identifier)")
				}
			}

			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
			smallLockupCollectionViewCell.showDetailsElement = self.showDetailsElements?[indexPath.row]
			return smallLockupCollectionViewCell
		}

		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			let itemsPerSection = $0 == .statistics ? 1: showDetailsElements?.count ?? 0

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

// MARK: - SectionLayoutKind
extension FavoriteShowsCollectionViewController {
	/**
		List of cast section layout kind.

		```
		case statistics = 0
		case main = 1
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case statistics = 0
		case main = 1
	}
}
