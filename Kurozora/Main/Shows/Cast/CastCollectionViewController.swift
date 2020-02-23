//
//  CastCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class CastCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showID: Int?
	var actorsElements: [ActorsElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.collectionView?.reloadData()
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

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

		// Stop activity indicator in case user doesn't need to fetch actors details.
		if actorsElements != nil {
			_prefersActivityIndicatorHidden = true
		}

		// Setup collection view.
		collectionView.collectionViewLayout = createLayout()
		collectionView.register(nibWithCellClass: CastCollectionViewCell.self)

		// Fetch actors
		if actorsElements == nil {
			DispatchQueue.global(qos: .background).async {
				self.fetchActors()
			}
		}
    }

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		collectionView.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Actors", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get actors list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.actor())
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetch actors for the current show.
	fileprivate func fetchActors() {
		KService.shared.getCastFor(showID, withSuccess: { (actors) in
			DispatchQueue.main.async {
				self.actorsElements = actors
			}
		})
	}
}

// MARK: - UICollectionViewDataSource
extension CastCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actorsCount = actorsElements?.count else { return 0 }
		return actorsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let castCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.castCollectionViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
		}
		return castCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegate
extension CastCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let castCollectionViewCell = cell as? CastCollectionViewCell {
			castCollectionViewCell.actorElement = actorsElements?[indexPath.row]

			if collectionView.indexPathForLastItem == indexPath {
				castCollectionViewCell.separatorView.isHidden = true
			} else {
				castCollectionViewCell.separatorView.isHidden = false
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CastCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 374).rounded().int
		if columnCount > 5 {
			return 5
		}
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		return (0.52 / columnsCount.double).cgFloat
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
