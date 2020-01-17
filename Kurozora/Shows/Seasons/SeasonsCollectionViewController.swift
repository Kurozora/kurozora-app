//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class SeasonsCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	var showID: Int?
	var seasons: [SeasonsElement]? {
		didSet {
			self.collectionView?.reloadData()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		collectionView.collectionViewLayout = createLayout()
		collectionView.register(nibWithCellClass: LockupCollectionViewCell.self)

		// Fetch seasons
		if seasons == nil {
			fetchSeasons()
		}

		// Setup empty data view
		setupEmptyDataView()
    }

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "details", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "SeasonsCollectionViewController")
	}

	/// Sets up the empty data view.
	func setupEmptyDataView() {
		collectionView?.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Seasons", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "This show doesn't have seasons yet. Please check back again later.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_seasons"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		collectionView.reloadData()
	}

	/// Fetch seasons for the current show.
    fileprivate func fetchSeasons() {
        KService.shared.getSeasonsFor(showID, withSuccess: { (seasons) in
			DispatchQueue.main.async {
				self.seasons = seasons
			}
        })
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodeSegue", let lockupCollectionViewCell = sender as? LockupCollectionViewCell {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController, let indexPath = collectionView.indexPath(for: lockupCollectionViewCell) {
				episodesCollectionViewController.seasonID = seasons?[indexPath.item].id
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let seasonsCount = seasons?.count else { return 0 }
		return seasonsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let lockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LockupCollectionViewCell", for: indexPath) as! LockupCollectionViewCell
		return lockupCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegate
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		self.performSegue(withIdentifier: "EpisodeSegue", sender: collectionViewCell)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let lockupCollectionViewCell = cell as? LockupCollectionViewCell {
			lockupCollectionViewCell.seasonsElement = seasons?[indexPath.row]

			if collectionView.indexPathForLastItem == indexPath {
				lockupCollectionViewCell.separatorView.isHidden = true
			} else {
				lockupCollectionViewCell.separatorView.isHidden = false
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SeasonsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 374).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		return (0.50 / columnsCount.double).cgFloat
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

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
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
