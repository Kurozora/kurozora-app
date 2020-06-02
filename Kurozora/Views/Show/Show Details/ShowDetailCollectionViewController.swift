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
			if #available(iOS 12.0, *) {
				userActivity?.suggestedInvocationPhrase = title
				userActivity?.isEligibleForPrediction = true
			}
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
		case .related: break
		default: break
		}

		return numberOfRows
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { fatalError("Can't determine cellForItemAt indexPath: \(indexPath)") }

		switch showDetailSection {
		case .header:
			let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! ShowDetailHeaderCollectionViewCell
			return showDetailHeaderCollectionViewCell
		case .badge:
			let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! BadgeCollectionViewCell
			return badgeCollectionViewCell
		case .synopsis:
			let synopsisCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! SynopsisCollectionViewCell
			return synopsisCollectionViewCell
		case .rating:
			let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! RatingCollectionViewCell
			return ratingCollectionViewCell
		case .information:
			let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! InformationCollectionViewCell
			return informationCollectionViewCell
		case .seasons:
			let lockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! LockupCollectionViewCell
			return lockupCollectionViewCell
		case .cast:
			let castCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! CastCollectionViewCell
			return castCollectionViewCell
		case .related:
			let relatedShowCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailSection.identifierString, for: indexPath) as! RelatedShowCollectionViewCell
			return relatedShowCollectionViewCell
		}
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let showSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderReusableView.self, for: indexPath)
		titleHeaderReusableView.segueID = showSection.segueIdentifier
		titleHeaderReusableView.title = showSection.stringValue
		titleHeaderReusableView.indexPath = indexPath
		return titleHeaderReusableView
	}
}

// MARK: - UICollectionViewDelegate
extension ShowDetailCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		var segueIdentifier = ""

		switch ShowDetail.Section(rawValue: indexPath.section) {
		case .seasons:
			segueIdentifier = R.segue.showDetailCollectionViewController.episodeSegue.identifier
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
			let synopsisCollectionViewCell = cell as? SynopsisCollectionViewCell
			synopsisCollectionViewCell?.synopsisText = showDetailsElement?.synopsis
		case .rating:
			let ratingCollectionViewCell = cell as? RatingCollectionViewCell
			ratingCollectionViewCell?.showDetailsElement = showDetailsElement
		case .information:
			let informationCollectionViewCell = cell as? InformationCollectionViewCell
			informationCollectionViewCell?.showDetailsElement = showDetailsElement
		case .seasons:
			let lockupCollectionViewCell = cell as? LockupCollectionViewCell
			lockupCollectionViewCell?.seasonsElement = seasons?[indexPath.item]
		case .cast:
			let castCollectionViewCell = cell as? CastCollectionViewCell
			castCollectionViewCell?.actorElement = actors?[indexPath.item]
		case .related: break
//			let relatedShowCollectionViewCell = cell as? RelatedShowCollectionViewCell
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowDetailCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SynopsisCollectionViewCell.self,
				RatingCollectionViewCell.self,
				InformationCollectionViewCell.self,
				LockupCollectionViewCell.self,
				CastCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderReusableView.self]
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
		case .seasons, .cast, .related:
			let columnCount = (width / 374).rounded().int
			if columnCount > 5 {
				return 5
			}
			return columnCount > 0 ? columnCount : 1
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
			return .absolute(80)
		case .synopsis:
			return .absolute(110)
		case .rating:
			return .absolute(88)
		case .information:
			return .estimated(55)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons:
			if let seasonsCount = seasons?.count, seasonsCount != 0 {
				return (0.50 / columnsCount.double).cgFloat
			}
		case .cast:
			if let actorsCount = actors?.count, actorsCount != 0 {
				return (0.50 / columnsCount.double).cgFloat
			}
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
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
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
