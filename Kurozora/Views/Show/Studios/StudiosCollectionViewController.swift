//
//  StudiosCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudiosCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioID: Int = 0
	var studioElement: StudioElement? = nil {
		didSet {
			_prefersActivityIndicatorHidden = true
			configureDataSource()
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<StudioSection, Int>! = nil

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

		DispatchQueue.global(qos: .background).async {
			self.fetchStudios()
		}
	}

	// MARK: - Functions
	func fetchStudios() {
		KService.getDetails(forStudioID: studioID, includesShows: true) { result in
			switch result {
			case .success(let studioElement):
				DispatchQueue.main.async {
					self.studioElement = studioElement
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.studiosCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
				if let selectedCell = sender as? BaseLockupCollectionViewCell {
					showDetailCollectionViewController.showDetailsElement = selectedCell.showDetailsElement
				} else if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		}
	}
}

// MARK: - KCollectionViewDataSource
extension StudiosCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			SynopsisCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<StudioSection, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			let studioSection = StudioSection(rawValue: indexPath.section) ?? .main
			let reuseIdentifier = studioSection.identifierString(for: indexPath.item)
			let studioCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch studioSection {
			case .main:
				(studioCollectionViewCell as? StudioHeaderCollectionViewCell)?.studioElement = self.studioElement
			case .about:
				(studioCollectionViewCell as? SynopsisCollectionViewCell)?.synopsisText = self.studioElement?.about
			case .information:
				if let informationCollectionViewCell = studioCollectionViewCell as? InformationCollectionViewCell {
					informationCollectionViewCell.studioInformationSection = StudioInformationSection(rawValue: indexPath.item) ?? .founded
					informationCollectionViewCell.studioElement = self.studioElement
				} else if let informationButtonCollectionViewCell = studioCollectionViewCell as? InformationButtonCollectionViewCell {
					informationButtonCollectionViewCell.studioInformationSection = StudioInformationSection(rawValue: indexPath.item)
					informationButtonCollectionViewCell.studioElement = self.studioElement
				}
			case .shows:
				(studioCollectionViewCell as? SmallLockupCollectionViewCell)?.showDetailsElement = self.studioElement?.shows?[indexPath.item]
			}

			return studioCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let studioSection = StudioSection(rawValue: indexPath.section) ?? .main
			let titleHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderReusableView.self, for: indexPath)
			titleHeaderReusableView.title = studioSection.stringValue
			titleHeaderReusableView.indexPath = indexPath
			return titleHeaderReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<StudioSection, Int>()
		StudioSection.allCases.forEach {
			snapshot.appendSections([$0])
			let rowCount = $0 == .shows ? studioElement?.shows?.count ?? $0.rowCount : $0.rowCount
			let itemOffset = $0.rawValue * rowCount
			let itemUpperbound = itemOffset + rowCount
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension StudiosCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch StudioSection(rawValue: section) {
		case .main, .about:
			return 1
		case .shows:
			if width >= 414 {
				return (width / 384).rounded().int
			} else {
				return (width / 284).rounded().int
			}
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch StudioSection(rawValue: section) {
		case .main:
			return .estimated(230)
		case .about:
			return .absolute(110)
		case .information:
			return .estimated(55)
		case .shows:
			return .estimated(230)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch StudioSection(rawValue: section) {
		case .main:
			return .zero
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch StudioSection(rawValue: section) {
		case .main:
			return  NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let studioSection = StudioSection(rawValue: section) else { fatalError("Studio section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch studioSection {
			case .main:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .about:
				if let about = self.studioElement?.about, !about.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .information:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			case .shows:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			}

			if hasSectionHeader {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(50))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				sectionLayout?.boundarySupplementaryItems = [sectionHeader]
			}

			return sectionLayout
		}
		return layout
	}

	func fullSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func listSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
															 subitem: item, count: columns)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}
}
