//
//  ShowsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ShowsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var actorID: Int! {
		didSet {
			KService.getShows(forActorID: actorID) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let shows):
					self.shows = shows
				case .failure: break
				}
			}
		}
	}
	var characterID: Int! {
		didSet {
			KService.getShows(forCharacterID: characterID) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let shows):
					self.shows = shows
				case .failure: break
				}
			}
		}
	}
	var showID: Int! {
		didSet {
			KService.getRelatedShows(forShowID: showID) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let relatedShows):
					self.shows = relatedShows.compactMap({ relatedShow -> Show? in
						return relatedShow.show
					})
				case .failure: break
				}
			}
		}
	}
	var studioID: Int! {
		didSet {
			KService.getShows(forStudioID: studioID) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let shows):
					self.shows = shows
				case .failure: break
				}
			}
		}
	}
	var shows: [Show] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.configureDataSource()
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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.showListCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
				if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			self.performSegue(withIdentifier: R.segue.showListCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell.show?.id)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
			smallLockupCollectionViewCell.show = self.shows[indexPath.row]
			return smallLockupCollectionViewCell
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
extension ShowsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		return (0.55 / columnsCount.double).cgFloat
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

// MARK: - SectionLayoutKind
extension ShowsListCollectionViewController {
	/**
	List of section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
