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
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var dataSource: ShowDetailsDataSource = ShowDetailsDataSource()
	var showID: Int = 0

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
			showDetailsCollectionViewController.dataSource.show = show
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

		// Configure data sources
		self.dataSource.viewController = self
		self.collectionView.dataSource = self.dataSource
		self.collectionView.prefetchDataSource = self.dataSource

		// Fetch show details.
		if self.dataSource.show == nil {
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
			including = ["cast", "seasons", "songs", "studios", "related-shows"]
		}

		KService.getDetails(forShowID: showID ?? self.showID, including: including) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let shows):
				self.dataSource.show = shows.first
				self.dataSource.seasonIdentities = shows.first?.relationships?.seasons?.data ?? []
				self.dataSource.castIdentities = shows.first?.relationships?.cast?.data ?? []
				self.dataSource.showSongs = shows.first?.relationships?.showSongs?.data ?? []
				self.dataSource.studio = shows.first?.relationships?.studios?.data.first { studio in
					studio.attributes.isStudio ?? false
				} ?? shows.first?.relationships?.studios?.data.first
				self.dataSource.relatedShows = shows.first?.relationships?.relatedShows?.data ?? []

				// Donate suggestion to Siri
				self.userActivity = self.dataSource.show.openDetailUserActivity
			case .failure: break
			}
		}
	}

	@objc func toggleFavorite() {
		self.dataSource.show?.toggleFavorite()
	}

	@objc func toggleReminder() {
		self.dataSource.show?.toggleReminder()
	}

	@objc func shareShow() {
		self.dataSource.show?.openShareSheet(on: self)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.dataSource.show.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleShowIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.dataSource.show.attributes.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleShowIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.dataSource.show?.openShareSheet(on: self, barButtonItem: sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showDetailsCollectionViewController.seasonSegue.identifier:
			guard let seasonsCollectionViewController = segue.destination as? SeasonsCollectionViewController else { return }
			seasonsCollectionViewController.showID = self.dataSource.show.id
		case R.segue.showDetailsCollectionViewController.castSegue.identifier:
			guard let castCollectionViewController = segue.destination as? CastCollectionViewController else { return }
			castCollectionViewController.showID = self.dataSource.show.id
		case R.segue.showDetailsCollectionViewController.showSongsListSegue.identifier:
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showID = self.dataSource.show.id
		case R.segue.showDetailsCollectionViewController.episodeSegue.identifier:
			guard let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesCollectionViewController.seasonID = season.id
		case R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.showID = show.id
		case R.segue.showDetailsCollectionViewController.studioSegue.identifier:
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = self.dataSource.studio else { return }
			studioDetailsCollectionViewController.studioID = studio.id
		case R.segue.showDetailsCollectionViewController.showsListSegue.identifier:
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = "Related"
			showsListCollectionViewController.showID = self.dataSource.show.id
		case R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let character = self.dataSource.cast[indexPath.item].relationships.characters.data.first else { return }
			characterDetailsCollectionViewController.characterID = character.id
		case R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let person = self.dataSource.cast[indexPath.item].relationships.people.data.first else { return }
			personDetailsCollectionViewController.personID = person.id
		default: break
		}
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
				synopsisViewController.synopsis = self.dataSource.show.attributes.synopsis
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
