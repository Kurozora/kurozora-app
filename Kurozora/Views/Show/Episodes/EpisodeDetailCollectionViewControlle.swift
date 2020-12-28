//
//  EpisodeDetailCollectionViewControlle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodeDetailCollectionViewControlle: KCollectionViewController {
	// MARK: - Properties
	var episodeID = 0
	var episode: Episode! {
		didSet {
			self.title = self.episode.attributes.title
			self._prefersActivityIndicatorHidden = true
			self.collectionView.reloadData {
				self.toggleEmptyDataView()
			}
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch cast
		DispatchQueue.global(qos: .background).async {
			self.fetchEpisodeDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchEpisodeDetails()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.episodes()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This episode doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetch details for the current episode.
	fileprivate func fetchEpisodeDetails() {
		KService.getDetails(forEpisodeID: self.episodeID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let episode):
				DispatchQueue.main.async {
					self.episode = episode.first
				}
			case .failure: break
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension EpisodeDetailCollectionViewControlle {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.episode != nil ? EpisodeDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var itemsPerSection = 0

		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			itemsPerSection = 1
		case .synopsis:
			if let overview = self.episode.attributes.overview, !overview.isEmpty {
				itemsPerSection = 1
			}
		case .rating:
			itemsPerSection = 1
		case .information:
			itemsPerSection = EpisodeDetail.Information.allCases.count
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let episodeDetailSection = EpisodeDetail.Section(rawValue: indexPath.section) else { fatalError("Can't determine cellForItemAt indexPath: \(indexPath)") }

		switch episodeDetailSection {
		case .header:
			let episodeLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! EpisodeLockupCollectionViewCell
			return episodeLockupCollectionViewCell
		case .synopsis:
			let synopsisCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! TextViewCollectionViewCell
			return synopsisCollectionViewCell
		case .rating:
			let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! RatingCollectionViewCell
			return ratingCollectionViewCell
		case .information:
			let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! InformationCollectionViewCell
			return informationCollectionViewCell
		}
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		return supplementaryView
	}
}

// MARK: - UICollectionViewDelegate
extension EpisodeDetailCollectionViewControlle {
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch EpisodeDetail.Section(rawValue: indexPath.section) {
		case .header:
			let episodeLockupCollectionViewCell = cell as? EpisodeLockupCollectionViewCell
			episodeLockupCollectionViewCell?.simpleModeEnabled = true
			episodeLockupCollectionViewCell?.episode = self.episode
		case .synopsis:
			let textViewCollectionViewCell = cell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell?.textViewContent = self.episode.attributes.overview
//		case .rating:
//			let ratingCollectionViewCell = cell as? RatingCollectionViewCell
//			ratingCollectionViewCell?.showDetailsElement = showDetailsElement
		case .information:
			let informationCollectionViewCell = cell as? InformationCollectionViewCell
			informationCollectionViewCell?.episodeDetailInformation = EpisodeDetail.Information(rawValue: indexPath.item) ?? .number
			informationCollectionViewCell?.episode = episode
		default: break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		guard let sectionHeaderReusableView = view as? TitleHeaderCollectionReusableView else { return }
		guard let Section = EpisodeDetail.Section(rawValue: indexPath.section) else { return }

		sectionHeaderReusableView.title = Section.stringValue
		sectionHeaderReusableView.indexPath = indexPath
	}
}

// MARK: - KCollectionViewDataSource
extension EpisodeDetailCollectionViewControlle {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [EpisodeLockupCollectionViewCell.self,
				TextViewCollectionViewCell.self,
				RatingCollectionViewCell.self,
				InformationCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}
}

// MARK: - KCollectionViewDelegateLayout
extension EpisodeDetailCollectionViewControlle {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch EpisodeDetail.Section(rawValue: section) {
		case .header, .synopsis:
			return 1
		case .rating:
			if width > 828 {
				let columnCount = (width / 374).rounded().int
				if columnCount >= 3 {
					return 3
				} else if columnCount > 0 {
					return columnCount
				}
			}
			return 1
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			let width = layoutEnvironment.container.effectiveContentSize.width
			let height = (9 / 16) * width
			return .absolute(height)
		case .synopsis:
			return .absolute(110)
		case .rating:
			return .absolute(88)
		case .information:
			return .estimated(55)
		default:
			let groupHeight = groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(groupHeight)
		}
	}

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			return .zero
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
		}
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let episodeSection = EpisodeDetail.Section(rawValue: section) else { fatalError("Episode section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch episodeSection {
			case .header:
				let headerSection = self.headerSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .synopsis:
				if let overview = self.episode.attributes.overview, !overview.isEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasSectionHeader = true
				}
			case .rating:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
				hasSectionHeader = true
			case .information:
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

	func headerSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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

	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90),
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
															 subitem: item, count: columns)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
