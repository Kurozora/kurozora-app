//
//  ShowDetailCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Intents
import IntentsUI

protocol ShowDetailCollectionViewControllerDelegate: class {
	func updateShowInLibrary(for cell: LibraryBaseCollectionViewCell?)
}

class ShowDetailCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showID: Int = 0
	var showDetailsElement: ShowDetailsElement? = nil {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.title = showDetailsElement?.title
			self.showID = showDetailsElement?.id ?? self.showID
		}
	}
	var seasons: [SeasonElement]?
	var actors: [ActorElement]?
	var studioElement: StudioElement?

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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Setup navigation controller with special settings
		navigationController?.navigationBar.prefersLargeTitles = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Donate suggestion to Siri
		userActivity = NSUserActivity(activityType: "OpenAnimeIntent")
		if let title = showDetailsElement?.title {
			let title = "Open \(title)"
			userActivity?.title = title
			userActivity?.userInfo = ["showID": self.showID]
			userActivity?.suggestedInvocationPhrase = title
			userActivity?.isEligibleForPrediction = true
			userActivity?.isEligibleForSearch = true
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator in case user doesn't need to fetch show details.
		if showDetailsElement != nil {
			_prefersActivityIndicatorHidden = true
		}

		// Fetch show details.
		DispatchQueue.global(qos: .background).async {
			self.fetchDetails()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Reset the navigation bar
		self.navigationController?.navigationBar.alpha = 1.0
		navigationController?.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
	}

	// MARK: - Functions
	/// Fetches details for the currently viewed show.
	func fetchDetails() {
		// If the air status is empty then the details are incomplete and should be fetched anew.
		if showDetailsElement?.airStatus == "" {
			KService.getDetails(forShowID: self.showID) { result in
				switch result {
				case .success(let showDetailsElement):
					DispatchQueue.main.async {
						self.showDetailsElement = showDetailsElement
						self.collectionView.reloadData()
						self.fetchStudio()
					}
				case .failure: break
				}
			}
		}

		if seasons == nil {
			KService.getSeasons(forShowID: self.showID) { result in
				switch result {
				case .success(let seasons):
					DispatchQueue.main.async {
						self.seasons = seasons
						self.collectionView.reloadData()
					}
				case .failure: break
				}
			}
		}

		if actors == nil {
			KService.getCast(forShowID: self.showID) { result in
				switch result {
				case .success(let actors):
					DispatchQueue.main.async {
						self.actors = actors
						self.collectionView.reloadData()
					}
				case .failure: break
				}
			}
		}

		if showDetailsElement?.airStatus != "" {
			self.fetchStudio()
		}
	}

	/// Fetches studio details for the currently viewed show.
	func fetchStudio() {
		if studioElement == nil, let studioID = self.showDetailsElement?.studio?.id, studioID != 0 {
			KService.getDetails(forStudioID: studioID, includesShows: true, limit: 10) { result in
				switch result {
				case .success(let studioElement):
					DispatchQueue.main.async {
						self.studioElement = studioElement
						self.collectionView.reloadData()
					}
				case .failure: break
				}
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.showDetailCollectionViewController.seasonSegue.identifier {
			if let seasonsCollectionViewController = segue.destination as? SeasonsCollectionViewController {
				seasonsCollectionViewController.seasonsElements = seasons
			}
		} else if segue.identifier == R.segue.showDetailCollectionViewController.castSegue.identifier {
			if let castCollectionViewController = segue.destination as? CastCollectionViewController {
				castCollectionViewController.actorElements = actors
			}
		} else if segue.identifier == R.segue.showDetailCollectionViewController.episodeSegue.identifier {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController {
				if let lockupCollectionViewCell = sender as? LockupCollectionViewCell, let seasonID = lockupCollectionViewCell.seasonsElement?.id {
					episodesCollectionViewController.seasonID = seasonID
				}
			}
		} else if segue.identifier == R.segue.showDetailCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
				if let selectedCell = sender as? BaseLockupCollectionViewCell {
					showDetailCollectionViewController.showDetailsElement = selectedCell.showDetailsElement
				} else if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		} else if segue.identifier == R.segue.showDetailCollectionViewController.studioSegue.identifier {
			if let studiosCollectionViewController = segue.destination as? StudiosCollectionViewController {
				if let studioID = studioElement?.id {
					studiosCollectionViewController.studioID = studioID
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ShowDetailCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return showDetailsElement != nil ? ShowDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numberOfRows = 0

		switch ShowDetail.Section(rawValue: section) {
		case .header:
			numberOfRows = 1
		case .badge:
			numberOfRows = 1
		case .synopsis:
			if let synopsis = showDetailsElement?.synopsis, !synopsis.isEmpty {
				numberOfRows = 1
			}
		case .rating:
			numberOfRows = 1
		case .information:
			numberOfRows = ShowDetail.Information.allCases.count
//			if !User.isAdmin {
//				numberOfRows -= 1
//			}
		case .seasons:
			if let seasonsCount = seasons?.count {
				numberOfRows = seasonsCount >= 10 ? 10 : seasonsCount
			}
		case .cast:
			if let actorsCount = actors?.count {
				numberOfRows = actorsCount >= 10 ? 10 : actorsCount
			}
		case .moreByStudio:
			if let studioShowsCount = studioElement?.shows?.count {
				numberOfRows = studioShowsCount
			}
		case .related: break
		default: break
		}

		return numberOfRows
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { fatalError("Can't determine cellForItemAt indexPath: \(indexPath)") }
		let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath)
		return collectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let showSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.segueID = showSection.segueIdentifier
		titleHeaderCollectionReusableView.title = showSection != .moreByStudio ? showSection.stringValue : showSection.stringValue + (studioElement?.name ?? "this Studio")
		titleHeaderCollectionReusableView.indexPath = indexPath
		return titleHeaderCollectionReusableView
	}
}

// MARK: - UICollectionViewDelegate
extension ShowDetailCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		var segueIdentifier = ""

		switch showDetailSection {
		case .seasons:
			segueIdentifier = R.segue.showDetailCollectionViewController.episodeSegue.identifier
		case .moreByStudio:
			segueIdentifier = R.segue.showDetailCollectionViewController.showDetailsSegue.identifier
		default: return
		}

		self.performSegue(withIdentifier: segueIdentifier, sender: collectionViewCell)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return }
		switch showDetailSection {
		case .header:
			let showDetailHeaderCollectionViewCell = cell as? ShowDetailHeaderCollectionViewCell
			showDetailHeaderCollectionViewCell?.showDetailsElement = showDetailsElement
		case .badge:
			let badgeCollectionViewCell = cell as? BadgeCollectionViewCell
			badgeCollectionViewCell?.showDetailsElement = showDetailsElement
		case .synopsis:
			let textViewCollectionViewCell = cell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell?.textViewContent = showDetailsElement?.synopsis
		case .rating:
			let ratingCollectionViewCell = cell as? RatingCollectionViewCell
			ratingCollectionViewCell?.showDetailsElement = showDetailsElement
		case .information:
			let informationCollectionViewCell = cell as? InformationCollectionViewCell
			informationCollectionViewCell?.showDetailInformation = ShowDetail.Information(rawValue: indexPath.item) ?? .id
			informationCollectionViewCell?.showDetailsElement = showDetailsElement
		case .seasons:
			let lockupCollectionViewCell = cell as? LockupCollectionViewCell
			lockupCollectionViewCell?.seasonsElement = seasons?[indexPath.item]
		case .cast:
			let castCollectionViewCell = cell as? CastCollectionViewCell
			castCollectionViewCell?.actorElement = actors?[indexPath.item]
		case .moreByStudio:
			let smallLockupCollectionViewCell = cell as? SmallLockupCollectionViewCell
			smallLockupCollectionViewCell?.showDetailsElement = studioElement?.shows?[indexPath.item]
		case .related: break
//			let relatedShowCollectionViewCell = cell as? RelatedShowCollectionViewCell
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowDetailCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [TextViewCollectionViewCell.self,
				RatingCollectionViewCell.self,
				InformationCollectionViewCell.self,
				LockupCollectionViewCell.self,
				SmallLockupCollectionViewCell.self,
				CastCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowDetailCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch ShowDetail.Section(rawValue: section) {
		case .header, .badge, .synopsis:
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
		case .seasons, .cast, .moreByStudio:
			var columnCount = 1
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
			if columnCount > 5 {
				return 5
			}
			return columnCount
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func heightDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return .fractionalHeight(0.90)
		case .badge:
			return .estimated(50)
		case .synopsis:
			return .estimated(100)
		case .rating:
			return .absolute(88)
		case .information:
			return .estimated(55)
		case .seasons, .cast, .moreByStudio:
			return .absolute(440)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	func widthDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons, .cast, .moreByStudio, .related:
			let columnsCount = columnsCount <= 1 ? columnsCount : columnsCount - 1
			let widthFraction = self.groupWidthFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(widthFraction)
		default:
			return .fractionalWidth(1.0)
		}
	}

	func groupWidthFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons:
			if let seasonsCount = seasons?.count, seasonsCount != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .cast:
			if let castCount = actors?.count, castCount != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .moreByStudio:
			if let showsCount = studioElement?.shows?.count, showsCount != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .related: break
		default: break
		}
		return .zero
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return .zero
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
		}
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		switch ShowDetail.Section(rawValue: section) {
		case .header:
			return  NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let showSections = ShowDetail.Section(rawValue: section) else { fatalError("ShowDetail section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false

			switch showSections {
			case .header:
				let headerSection = self.headerSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .synopsis:
				if let synopsis = self.showDetailsElement?.synopsis, !synopsis.isEmpty {
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
			case .seasons:
				if let seasonsCount = self.seasons?.count, seasonsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .cast:
				if let actorsCount = self.actors?.count, actorsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .moreByStudio:
				if let studioShowCount = self.studioElement?.shows?.count, studioShowCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .related: break
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
											  heightDimension: .fractionalHeight(0.5))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightDimension = self.heightDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let widthDimension = self.widthDimension(forSection: section, with: columns, layout: layoutEnvironment)
		let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension,
											   heightDimension: heightDimension)
		let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
														   subitem: item, count: 2)
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

// MARK: - UIScrollViewDelegate
extension ShowDetailCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		#if !targetEnvironment(macCatalyst)
		if scrollView.contentOffset.y >= scrollView.contentSize.height / 5 { // If user scrolled to 1/5 of the total scroll height
			UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.navigationController?.navigationBar.alpha = 1.0
			}, completion: nil)
		} else {
			UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.navigationController?.navigationBar.alpha = 0.0
			}, completion: nil)
		}
		#endif
	}
}
