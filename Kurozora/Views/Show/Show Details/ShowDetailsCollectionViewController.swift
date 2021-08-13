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
			self.navigationTitleLabel.text = show.attributes.title
			self.showID = show.id
		}
	}
	var seasons: [Season] = []
	var cast: [Cast] = []
	var relatedShows: [RelatedShow] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.collectionView.reloadData {
				self.toggleEmptyDataView()
			}
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var studio: Studio! {
		didSet {
			if studio != nil {
				studio.relationships?.shows?.data.forEachInParallel({ show in
					self.fetchDetails(for: show.id)
				})
			}
		}
	}
	var studioShows: [Show] = []

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleShowIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleShowIsRemindedTouchBarItem: NSButtonTouchBarItem?
	#endif

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/**
		Initialize a new instance of ShowDetailsCollectionViewController with the given show id.

		- Parameter showID: The show id to use when initializing the view.

		- Returns: an initialized instance of ShowDetailsCollectionViewController.
	*/
	static func `init`(with showID: Int) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.showID = showID
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given show id.")
	}

	/**
		Initialize a new instance of ShowDetailsCollectionViewController with the given show object.

		- Parameter show: The `Show` object to use when initializing the view controller.

		- Returns: an initialized instance of ShowDetailsCollectionViewController.
	*/
	static func `init`(with show: Show) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.show = show
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given Show object.")
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Make the navigation bar background clear
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KShowFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KShowReminderIsToggled, object: nil)

		self.navigationTitleLabel.alpha = 0

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch show details.
		if show == nil {
			DispatchQueue.global(qos: .background).async {
				self.fetchDetails()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Restore the navigation bar to default
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchDetails()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.library()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This show doesn't have details yet. Please check back again later.")

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

	/**
		Fetches details for the given show id. If none given then the currently viewed show's details are fetched.

		- Parameter showID: The id used to fetch the show's details.
	*/
	func fetchDetails(for showID: Int? = nil) {
		var including: [String] = []

		if showID == nil {
			including = ["seasons", "cast", "studios", "related-shows"]
		}

		KService.getDetails(forShowID: showID ?? self.showID, including: including) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let shows):
				if showID == nil {
					self.show = shows.first
					self.seasons = shows.first?.relationships?.seasons?.data ?? []
					self.cast = shows.first?.relationships?.cast?.data ?? []
					self.studio = shows.first?.relationships?.studios?.data.first { studio in
						studio.attributes.isStudio ?? false
					} ?? shows.first?.relationships?.studios?.data.first
					self.relatedShows = shows.first?.relationships?.relatedShows?.data ?? []

						// Donate suggestion to Siri
					self.userActivity = self.show.openDetailUserActivity
				} else {
					if let show = shows.first {
						self.studioShows.append(show)
					}
				}
			case .failure: break
			}
		}
	}

	@objc func toggleFavorite() {
		self.show.toggleFavorite()
	}

	@objc func toggleReminder() {
		self.show.toggleReminder()
	}

	@objc func shareShow() {
		self.show.openShareSheet(on: self)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = show.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleShowIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = show.attributes.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleShowIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.show.openShareSheet(on: self, barButtonItem: sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.showDetailsCollectionViewController.seasonSegue.identifier {
			if let seasonsCollectionViewController = segue.destination as? SeasonsCollectionViewController {
				seasonsCollectionViewController.showID = self.show.id
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
				if let studio = self.studio {
					studioDetailsCollectionViewController.studioID = studio.id
				}
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.title = "Related"
				showsListCollectionViewController.showID = self.show.id
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier {
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let character = castCollectionViewCell.cast.relationships.characters.data.first {
					characterDetailsCollectionViewController.characterID = character.id
				}
			}
		} else if segue.identifier == R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier {
			if let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let person = castCollectionViewCell.cast.relationships.people.data.first {
					personDetailsCollectionViewController.personID = person.id
				}
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
				let synopsis = self.show.attributes.synopsis ?? ""
				if synopsis.isEmpty {
					itemsPerSection = 0
				}
			case .seasons:
				itemsPerSection = self.seasons.count
			case .cast:
				itemsPerSection = self.cast.count
			case .moreByStudio:
				if let studioShowsCount = self.studio?.relationships?.shows?.data.count {
					itemsPerSection = studioShowsCount
				}
			case .relatedShows:
				itemsPerSection = self.relatedShows.count
			case .sosumi:
				let copyright = self.show.attributes.copyright ?? ""
				if copyright.isEmpty {
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
			badgeCollectionViewCell?.showDetailBage = ShowDetail.Badge(rawValue: indexPath.item) ?? .rating
			badgeCollectionViewCell?.show = self.show
		case .synopsis:
			let textViewCollectionViewCell = showDetailCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
		case .rating:
			let ratingCollectionViewCell = showDetailCollectionViewCell as? RatingCollectionViewCell
			ratingCollectionViewCell?.show = self.show
		case .information:
			let informationCollectionViewCell = showDetailCollectionViewCell as? InformationCollectionViewCell
			informationCollectionViewCell?.showDetailInformation = ShowDetail.Information(rawValue: indexPath.item) ?? .type
			informationCollectionViewCell?.show = self.show
		case .seasons:
			let lockupCollectionViewCell = showDetailCollectionViewCell as? LockupCollectionViewCell
			lockupCollectionViewCell?.season = self.seasons[indexPath.item]
		case .cast:
			let castCollectionViewCell = showDetailCollectionViewCell as? CastCollectionViewCell
			castCollectionViewCell?.delegate = self
			castCollectionViewCell?.cast = self.cast[indexPath.item]
		case .moreByStudio:
			let smallLockupCollectionViewCell = showDetailCollectionViewCell as? SmallLockupCollectionViewCell
			smallLockupCollectionViewCell?.show = self.studioShows[indexPath.item]
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
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.segueID = showDetailSection.segueIdentifier
		titleHeaderCollectionReusableView.indexPath = indexPath
		titleHeaderCollectionReusableView.title = showDetailSection != .moreByStudio ? showDetailSection.stringValue : showDetailSection.stringValue + self.studio.attributes.name
		return titleHeaderCollectionReusableView
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.show.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
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
