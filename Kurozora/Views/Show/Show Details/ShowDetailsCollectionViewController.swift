//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Intents
import IntentsUI

protocol ShowDetailsCollectionViewControllerDelegate: class {
	func updateShowInLibrary(for cell: LibraryBaseCollectionViewCell?)
}

class ShowDetailsCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var showID: Int = 0
	private var show: Show! {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.navigationTitleLabel.text = show.attributes.title
			self.showID = show.id
		}
	}
	var seasons: [Season] = []
	var cast: [Cast] = []
	var relatedShows: [RelatedShow] = []
	var moreByStudio: Studio!
	var dataSource: UICollectionViewDiffableDataSource<ShowDetail.Section, Int>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Properties
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Make the navigation bar background clear
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationController?.navigationBar.shadowImage = UIImage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationTitleLabel.alpha = 0

		// Fetch show details.
		DispatchQueue.global(qos: .background).async {
			self.fetchDetails()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Restore the navigation bar to default
		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		navigationController?.navigationBar.shadowImage = nil
	}

	// MARK: - Functions
	/// Fetches details for the currently viewed show.
	func fetchDetails() {
		// If the air status is empty then the details are incomplete and should be fetched anew.
		KService.getDetails(forShowID: self.showID, including: ["genres", "seasons", "cast", "studios", "related-shows"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let shows):
				self.show = shows.first
				self.seasons = shows.first?.relationships?.seasons?.data ?? []
				self.cast = shows.first?.relationships?.cast?.data ?? []
				self.moreByStudio = shows.first?.relationships?.studios?.data.randomElement()
				self.relatedShows = shows.first?.relationships?.relatedShows?.data ?? []
				self.configureDataSource()

				// Donate suggestion to Siri
				self.userActivity = self.show.openDetailUserActivity
			case .failure: break
			}
		}
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		let shareText = "https://kurozora.app/anime/\(show.id)\nYou should watch \"\(show.attributes.title)\" via @KurozoraApp"
		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		self.present(activityViewController, animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.showDetailsCollectionViewController.seasonSegue.identifier {
			if let seasonsCollectionViewController = segue.destination as? SeasonsCollectionViewController {
				seasonsCollectionViewController.seasons = seasons
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.castSegue.identifier {
			if let castCollectionViewController = segue.destination as? CastCollectionViewController {
				castCollectionViewController.showID = self.show.id
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.episodeSegue.identifier {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController {
				if let lockupCollectionViewCell = sender as? LockupCollectionViewCell {
					episodesCollectionViewController.seasonID = lockupCollectionViewCell.season.id
				}
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailsCollectionViewController.showID = show.id
				} else if let relatedShow = (sender as? LockupCollectionViewCell)?.relatedShow {
					showDetailsCollectionViewController.showID = relatedShow.show.id
				}
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.studioSegue.identifier {
			if let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController {
				studioDetailsCollectionViewController.studioID = self.moreByStudio.id
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.title = "Related"
				showsListCollectionViewController.showID = self.show.id
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) else { return }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		var segueIdentifier = ""

		switch showDetailSection {
		case .seasons:
			segueIdentifier = R.segue.showDetailsCollectionViewController.episodeSegue.identifier
		case .moreByStudio, .relatedShows:
			segueIdentifier = R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier
		default: return
		}

		self.performSegue(withIdentifier: segueIdentifier, sender: collectionViewCell)
	}
}

// MARK: - KCollectionViewDataSource
extension ShowDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [TextViewCollectionViewCell.self,
				RatingCollectionViewCell.self,
				InformationCollectionViewCell.self,
				LockupCollectionViewCell.self,
				SmallLockupCollectionViewCell.self,
				CastCollectionViewCell.self,
				SosumiShowCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<ShowDetail.Section, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
			let reuseIdentifier = showDetailSection.identifierString(for: indexPath.item)
			let showDetailCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch showDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = showDetailCollectionViewCell as? ShowDetailHeaderCollectionViewCell
				showDetailHeaderCollectionViewCell?.show = self.show
			case .badge:
				let badgeCollectionViewCell = showDetailCollectionViewCell as? BadgeCollectionViewCell
				badgeCollectionViewCell?.collectionView = collectionView
				badgeCollectionViewCell?.show = self.show
			case .synopsis:
				let textViewCollectionViewCell = showDetailCollectionViewCell as? TextViewCollectionViewCell
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
			case .rating:
				let ratingCollectionViewCell = showDetailCollectionViewCell as? RatingCollectionViewCell
				ratingCollectionViewCell?.show = self.show
			case .information:
				let informationCollectionViewCell = showDetailCollectionViewCell as? InformationCollectionViewCell
				informationCollectionViewCell?.showDetailInformation = ShowDetail.Information(rawValue: indexPath.item) ?? .studio
				informationCollectionViewCell?.show = self.show
			case .seasons:
				let lockupCollectionViewCell = showDetailCollectionViewCell as? LockupCollectionViewCell
				lockupCollectionViewCell?.season = self.seasons[indexPath.item]
			case .cast:
				let castCollectionViewCell = showDetailCollectionViewCell as? CastCollectionViewCell
				castCollectionViewCell?.cast = self.cast[indexPath.item]
			case .moreByStudio:
				let smallLockupCollectionViewCell = showDetailCollectionViewCell as? SmallLockupCollectionViewCell
				smallLockupCollectionViewCell?.show = self.moreByStudio.relationships?.shows?.data[indexPath.item]
			case .relatedShows:
				let lockupCollectionViewCell = showDetailCollectionViewCell as? LockupCollectionViewCell
				lockupCollectionViewCell?.relatedShow = self.relatedShows[indexPath.item]
			case .sosumi:
				let sosumiShowCollectionViewCell = showDetailCollectionViewCell as? SosumiShowCollectionViewCell
				sosumiShowCollectionViewCell?.copyrightText = self.show.attributes.copyright
			}

			return showDetailCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.segueID = showDetailSection.segueIdentifier
			titleHeaderCollectionReusableView.indexPath = indexPath
			titleHeaderCollectionReusableView.title = showDetailSection != .moreByStudio ? showDetailSection.stringValue : showDetailSection.stringValue + self.moreByStudio.attributes.name
			return titleHeaderCollectionReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<ShowDetail.Section, Int>()
		ShowDetail.Section.allCases.forEach {
			snapshot.appendSections([$0])
			var itemsPerSection = self.show != nil ? $0.rowCount : 0

			if self.show != nil {
				switch $0 {
				case .synopsis:
					if let synopsis = self.show.attributes.synopsis, synopsis.isEmpty {
						itemsPerSection = 0
					}
				case .seasons:
					itemsPerSection = self.seasons.count
				case .cast:
					itemsPerSection = self.cast.count
				case .moreByStudio:
					if let studioShowsCount = self.moreByStudio?.relationships?.shows?.data.count {
						itemsPerSection = studioShowsCount
					}
				case .relatedShows:
					itemsPerSection = self.relatedShows.count
				case .sosumi:
					if let copyright = self.show.attributes.copyright, copyright.isEmpty {
						itemsPerSection = 0
					}
				default: break
				}
			}

			snapshot.appendItems(Array(0..<itemsPerSection), toSection: $0)
		}
		dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowDetailsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width

		switch ShowDetail.Section(rawValue: section) {
		case .header, .badge, .synopsis, .sosumi:
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
		case .seasons, .cast, .moreByStudio, .relatedShows:
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
		default:
			let columnCount = (width / 374).rounded().int
			return columnCount > 0 ? columnCount : 1
		}
	}

	func verticalColumnCount(for section: Int) -> Int {
		guard let showDetailSection = ShowDetail.Section(rawValue: section) else { return 1 }
		var itemsCount = 0
		switch showDetailSection {
		case .seasons:
			let seasonsCount = seasons.count
			if seasonsCount != 0 {
				itemsCount = seasonsCount
			}
		case .cast:
			let castCount = cast.count
			if castCount != 0 {
				itemsCount = castCount
			}
		case .moreByStudio:
			if let studioShowsCount = self.moreByStudio.relationships?.shows?.data.count, studioShowsCount != 0 {
				itemsCount = studioShowsCount
			}
		case .relatedShows:
			let relatedShowsCount = relatedShows.count
			if relatedShowsCount != 0 {
				itemsCount = relatedShowsCount
			}
		default: break
		}
		return itemsCount > 5 ? 2 : 1
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
		case .seasons, .cast, .moreByStudio, .relatedShows:
			let verticalColumnCount = self.verticalColumnCount(for: section)
			return verticalColumnCount == 2 ? .estimated(400) : .estimated(200)
		case .sosumi:
			return .estimated(50)
		default:
			let heightFraction = self.groupHeightFraction(forSection: section, with: columnsCount, layout: layoutEnvironment)
			return .fractionalWidth(heightFraction)
		}
	}

	func widthDimension(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutDimension {
		switch ShowDetail.Section(rawValue: section) {
		case .seasons, .cast, .moreByStudio, .relatedShows:
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
			if seasons.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .cast:
			if cast.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .moreByStudio:
			if let showsCount = self.moreByStudio.relationships?.shows?.data.count, showsCount != 0 {
				return (0.90 / columnsCount.double).cgFloat
			}
		case .relatedShows:
			if relatedShows.count != 0 {
				return (0.90 / columnsCount.double).cgFloat
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
			return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			guard let showDetailSection = ShowDetail.Section(rawValue: section) else { fatalError("ShowDetail section not supported") }
			var sectionLayout: NSCollectionLayoutSection? = nil
			var hasSectionHeader = false
			var hasBackgroundDecoration = false

			switch showDetailSection {
			case .header:
				let headerSection = self.headerSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = headerSection
			case .badge:
				let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
				sectionLayout = fullSection
			case .synopsis:
				if let synopsis = self.show.attributes.synopsis, !synopsis.isEmpty {
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
				let seasonsCount = self.seasons.count
				if seasonsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .cast:
				let castCount = self.cast.count
				if castCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
				}
			case .moreByStudio:
				if let studioShowsCount = self.moreByStudio?.relationships?.shows?.data.count {
					if studioShowsCount != 0 {
						let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
						sectionLayout = gridSection
						hasSectionHeader = true
						hasBackgroundDecoration = true
					}
				}
			case .relatedShows:
				let relatedShowsCount = self.relatedShows.count
				if relatedShowsCount != 0 {
					let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = gridSection
					hasSectionHeader = true
					hasBackgroundDecoration = true
				}
			case .sosumi:
				if let copyrightIsEmpty = self.show.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					let fullSection = self.fullSection(for: section, layoutEnvironment: layoutEnvironment)
					sectionLayout = fullSection
					hasBackgroundDecoration = true
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

			if hasBackgroundDecoration {
				let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
				sectionLayout?.decorationItems = [sectionBackgroundDecoration]
			}

			return sectionLayout
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
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

// MARK: - UIScrollViewDelegate
extension ShowDetailsCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let navigationBar = self.navigationController?.navigationBar
		let firstCell = self.collectionView.cellForItem(at: [0, 0])

		let globalNavigationBarPositionY = navigationBar?.superview?.convert(navigationBar?.frame.origin ?? CGPoint(x: 0, y: 0), to: nil).y ?? .zero
		let offset = scrollView.contentOffset.y
		let firstCellHeight = firstCell?.frame.size.height ?? .zero

		let percentage = offset / (firstCellHeight - globalNavigationBarPositionY)

		if percentage.isFinite, percentage >= 0 {
			self.navigationTitleLabel.alpha = percentage
		}
	}
}
