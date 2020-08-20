//
//  CharacterDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterID: Int = 0
	var character: Character! {
		didSet {
			_prefersActivityIndicatorHidden = true
		}
	}
	var actors: [Actor] = []
	var shows: [Show] = []
	var dataSource: UICollectionViewDiffableDataSource<CharacterSection, Int>! = nil

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
			self.fetchcharacters()
		}
	}

	// MARK: - Functions
	func fetchcharacters() {
		KService.getDetails(forCharacterID: characterID, including: ["shows", "actors"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let characters):
				self.character = characters.first
				self.actors = characters.first?.relationships?.actors?.data ?? []
				self.shows = characters.first?.relationships?.shows?.data ?? []
				self.configureDataSource()
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.characterDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.characterID = self.character.id
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.actorsListSegue.identifier {
			if let actorsListCollectionViewController = segue.destination as? ActorsListCollectionViewController {
				actorsListCollectionViewController.characterID = self.character.id
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.actorDetailsSegue.identifier {
			if let actorDetailsCollectionViewController = segue.destination as? ActorDetailsCollectionViewController {
				if let actor = (sender as? ActorLockupCollectionViewCell)?.actor {
					actorDetailsCollectionViewController.actorID = actor.id
				}
			}
		}
	}
}

// MARK: - UICollectionViewController
extension CharacterDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		} else if let actorLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ActorLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.actorDetailsSegue, sender: actorLockupCollectionViewCell)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension CharacterDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ActorLockupCollectionViewCell.self,
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<CharacterSection, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let characterSection = CharacterSection(rawValue: indexPath.section) ?? .main
			let reuseIdentifier = characterSection.identifierString(for: indexPath.item)
			let characterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch characterSection {
			case .main:
				(characterCollectionViewCell as? CharacterHeaderCollectionViewCell)?.character = self.character
			case .about:
				let textViewCollectionViewCell = characterCollectionViewCell as? TextViewCollectionViewCell
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				textViewCollectionViewCell?.textViewContent = self.character.attributes.about
			case .information:
				if let informationCollectionViewCell = characterCollectionViewCell as? InformationCollectionViewCell {
					informationCollectionViewCell.characterInformationSection = CharacterInformationSection(rawValue: indexPath.item) ?? .debut
					informationCollectionViewCell.character = self.character
				}
			case .shows:
				if self.shows.count != 0 {
					(characterCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
				}
			case .actors:
				if self.actors.count != 0 {
					(characterCollectionViewCell as? ActorLockupCollectionViewCell)?.actor = self.actors[indexPath.item]
				}
			}

			return characterCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let characterSection = CharacterSection(rawValue: indexPath.section) ?? .main
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.segueID = characterSection.segueIdentifier
			titleHeaderCollectionReusableView.indexPath = indexPath
			titleHeaderCollectionReusableView.title = characterSection.stringValue
			return titleHeaderCollectionReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<CharacterSection, Int>()
		CharacterSection.allCases.forEach {
			snapshot.appendSections([$0])
			var itemsPerSection = $0.rowCount

			switch $0 {
			case .shows:
				itemsPerSection = self.shows.count
			case .actors:
				itemsPerSection = self.actors.count
			default: break
			}

			snapshot.appendItems(Array(0..<itemsPerSection), toSection: $0)
		}
		dataSource.apply(snapshot)
	}

	override func updateDataSource() {
		// Grab the current state of the UI from the data source.
		var updatedSnapshot = dataSource.snapshot()

		// Delete and append items for each section.
		updatedSnapshot.deleteAllItems()
		updatedSnapshot.sectionIdentifiers.forEach {
			var itemsPerSection = $0.rowCount

			switch $0 {
			case .shows:
				itemsPerSection = self.shows.count
			case .actors:
				itemsPerSection = self.actors.count
			default: break
			}

			updatedSnapshot.appendItems(Array(0..<itemsPerSection), toSection: $0)
		}

		self.dataSource.apply(updatedSnapshot)
		collectionView.reloadEmptyDataSet()
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CharacterDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch CharacterSection(rawValue: section) {
		case .main, .about:
			return 1
		case .shows:
			var columnCount = 1
			if width >= 414 {
				columnCount = (width / 414).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
			if columnCount > 5 {
				return 5
			}
			return columnCount
		case .actors:
			let columnCount = (width / 200).rounded().int
			if columnCount > 5 {
				return 5
			}
			return columnCount
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func verticalColumnCount(for section: Int) -> Int {
		guard let characterSection = CharacterSection(rawValue: section) else { return 1 }
		var itemsCount = 0
		switch characterSection {
		case .shows:
			let showsCount = self.shows.count
			if showsCount != 0 {
				itemsCount = showsCount
			}
		case .actors:
			let actorsCount = self.actors.count
			if actorsCount != 0 {
				itemsCount = actorsCount
			}
		default: break
		}
		return itemsCount > 5 ? 2 : 1
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch CharacterSection(rawValue: section) {
		case .main:
			return .estimated(230)
		case .about:
			return .estimated(20)
		case .information:
			return .estimated(55)
		case .shows:
			let verticalColumnCount = self.verticalColumnCount(for: section)
			return verticalColumnCount == 2 ? .estimated(460) : .estimated(230)
		case .actors:
			let verticalColumnCount = self.verticalColumnCount(for: section)
			return verticalColumnCount == 2 ? .estimated(400) : .estimated(200)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	func widthDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch CharacterSection(rawValue: section) {
		case .shows:
			let columnsCount = columnsCount <= 1 ? columnsCount : columnsCount - 1
			let widthFraction = self.groupWidthFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(widthFraction)
		case .actors:
			return .estimated(200)
		default:
			return .fractionalWidth(1.0)
		}
	}

	func groupWidthFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		switch CharacterSection(rawValue: section) {
		case .shows:
			if self.shows.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		default: break
		}
		return .zero
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch CharacterSection(rawValue: section) {
		case .main:
			return .zero
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch CharacterSection(rawValue: section) {
		case .main:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let characterSection = CharacterSection(rawValue: section) else { fatalError("character section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch characterSection {
			case .main:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .about:
				if let about = self.character.attributes.about, !about.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .information:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = listSection
				hasSectionHeader = true
			case .shows:
				if self.shows.count != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .actors:
				if self.actors.count != 0 {
					let responsiveGridSection = self.responsiveGridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = responsiveGridSection
					hasSectionHeader = true
				}
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
		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												heightDimension: heightDimension)

		let item = NSCollectionLayoutItem(layoutSize: layoutSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitem: item, count: columns)

		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func responsiveGridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let widthDimension = self.widthDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension,
											  heightDimension: .fractionalHeight(0.5))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension,
											   heightDimension: heightDimension)
		let verticalColumnCount = self.verticalColumnCount(for: section)
		let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
														   subitem: item, count: verticalColumnCount)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(0.5))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let widthDimension = self.widthDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension,
											   heightDimension: heightDimension)
		let verticalColumnCount = self.verticalColumnCount(for: section)
		let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
														   subitem: item, count: verticalColumnCount)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		#if targetEnvironment(macCatalyst)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		#else
		layoutSection.orthogonalScrollingBehavior = .groupPaging
		#endif
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
