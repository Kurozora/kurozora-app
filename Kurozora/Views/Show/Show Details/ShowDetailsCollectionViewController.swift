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
	var dataSource: UICollectionViewDiffableDataSource<ShowDetail.Section, Int>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<ShowDetail.Section, Int>! = nil
	var showID: Int = 0
	var show: Show! {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.navigationTitleLabel.text = show.attributes.title
			self.showID = show.id
			#if !targetEnvironment(macCatalyst)
			#if DEBUG
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var seasons: [Season] = []
	var cast: [Cast] = []
	var relatedShows: [RelatedShow] = []
	var moreByStudio: Studio!

	#if !targetEnvironment(macCatalyst)
	#if DEBUG
	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return _prefersRefreshControlDisabled
	}
	#endif
	#endif

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

		// Add refresh control
		#if !targetEnvironment(macCatalyst)
		#if DEBUG
		_prefersRefreshControlDisabled = false
		#else
		_prefersRefreshControlDisabled = true
		#endif
		#endif

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
				self.collectionView.reloadData()

				// Donate suggestion to Siri
				self.userActivity = self.show.openDetailUserActivity
			case .failure: break
			}
		}
	}

	#if DEBUG
	override func handleRefreshControl() {
		self.fetchDetails()
	}
	#endif

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		show.openShareSheet(on: self, barButtonItem: sender)
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

// MARK: - UICollectionViewDataSource
extension ShowDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.show != nil ? ShowDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let showDetailSection = ShowDetail.Section(rawValue: section) ?? .header
		var itemsPerSection = self.show != nil ? showDetailSection.rowCount : 0

		if self.show != nil {
			switch showDetailSection {
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

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let showDetailSection = ShowDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.segueID = showDetailSection.segueIdentifier
		titleHeaderCollectionReusableView.indexPath = indexPath
		titleHeaderCollectionReusableView.title = showDetailSection != .moreByStudio ? showDetailSection.stringValue : showDetailSection.stringValue + self.moreByStudio.attributes.name
		return titleHeaderCollectionReusableView
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
		return [
			TextViewCollectionViewCell.self,
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
