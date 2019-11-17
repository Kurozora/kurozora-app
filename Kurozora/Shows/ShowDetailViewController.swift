//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Cosmos
import Intents
import IntentsUI
import SwiftTheme

protocol ShowDetailViewControllerDelegate: class {
	func updateShowInLibrary(for cell: LibraryBaseCollectionViewCell?)
}

class ShowDetailViewController: UITableViewController {
	// MARK: - IBoutlet
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var shadowImageView: UIImageView! {
		didSet {
			shadowImageView.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var moreButton: UIButton!

	// Action buttons
	@IBOutlet weak var libraryStatusButton: UIButton! {
		didSet {
			libraryStatusButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			libraryStatusButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel! {
		didSet {
			showTitleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var statusButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var trailerButton: UIButton!
	@IBOutlet weak var trailerLabel: UILabel! {
		didSet {
			trailerLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var favoriteButton: UIButton!

	// Analytics view
	@IBOutlet weak var ratingTitleLabel: UILabel! {
		didSet {
			ratingTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var rankTitleLabel: UILabel! {
		didSet {
			rankTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageTitleLabel: UILabel! {
		didSet {
			ageTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var ratingScoreLabel: UILabel! {
		didSet {
			ratingScoreLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var rankScoreLabel: UILabel! {
		didSet {
			rankScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageScoreLabel: UILabel! {
		didSet {
			ageScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var bannerImageViewHeightConstraint: NSLayoutConstraint!

	// MARK: - Properties
	// Show detail
	var showID: Int?
	var showDetailsElement: ShowDetailsElement? = nil {
		didSet {
			self.showID = showDetailsElement?.id
			self.libraryStatus = showDetailsElement?.currentUser?.libraryStatus
		}
	}
	var seasons: [SeasonsElement]? {
		didSet {
			self.tableView.reloadData()
		}
	}
	var actors: [ActorsElement]? {
		didSet {
			self.tableView.reloadData()
		}
	}
	weak var delegate: ShowDetailViewControllerDelegate?
	var libraryStatus: String?
	var exploreBaseCollectionViewCell: ExploreBaseCollectionViewCell? = nil
	var libraryBaseCollectionViewCell: LibraryBaseCollectionViewCell? = nil
	var statusBarIsHidden = true

	override var prefersStatusBarHidden: Bool {
		return statusBarIsHidden
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Setup navigation controller with special settings
		self.viewsAreHidden(true)
		navigationController?.navigationBar.prefersLargeTitles = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Donate suggestion to Siri
		userActivity = NSUserActivity(activityType: "OpenAnimeIntent")
		if let title = showDetailsElement?.title, let showID = showID {
			let title = "Open \(title)"
			userActivity?.title = title
			userActivity?.userInfo = ["showID": showID]
			if #available(iOS 12.0, *) {
				userActivity?.suggestedInvocationPhrase = title
				userActivity?.isEligibleForPrediction = true
			}
			userActivity?.isEligibleForSearch = true
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		if exploreBaseCollectionViewCell != nil {
			configureShowDetails(from: exploreBaseCollectionViewCell)
		} else if libraryBaseCollectionViewCell != nil {
			configureShowDetails(from: libraryBaseCollectionViewCell)
		}

		// Update view with details
		if showDetailsElement != nil {
			DispatchQueue.main.async {
				self.updateDetails()
			}
		}

		// Fetch show details.
		self.fetchDetails()

		// Update banner image height constraint.
		self.updateBannerImageViewHeight()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Reset the navigation bar
		self.viewsAreHidden(false)
		navigationController?.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async {
			self.updateBannerImageViewHeight()
			self.tableView.updateHeaderViewFrame()
		}
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "details", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "ShowDetailViewController")
	}

	/// Fetches details for the currently viewed show.
	func fetchDetails() {
		if showDetailsElement == nil {
			KService.shared.getDetails(forShow: showID) { (showDetailsElement) in
				DispatchQueue.main.async {
					self.showDetailsElement = showDetailsElement
					self.updateDetails()
					self.tableView.reloadData()
				}
			}
		}

		if seasons == nil {
			KService.shared.getSeasonsFor(showID) { (seasons) in
				DispatchQueue.main.async {
					self.seasons = seasons
				}
			}
		}

		KService.shared.getCastFor(showID, withSuccess: { (actors) in
			DispatchQueue.main.async {
				self.actors = actors
			}
		})
	}

	/**
		Configures the view from the given Explore cell if the details view was requested from the Explore page.

		- Parameter cell: The explore cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: ExploreBaseCollectionViewCell?) {
		guard let cell = cell else { return }
		if cell.bannerImageView != nil {
			showTitleLabel.text = cell.primaryLabel?.text
			bannerImageView.image = cell.bannerImageView?.image
		} else {
			posterImageView.image = cell.posterImageView?.image
			ratingScoreLabel.text = "\((cell as? ExploreSmallCollectionViewCell)?.scoreButton.titleForNormal ?? "0")"
		}
	}

	/**
		Configures the view from the given Library cell if the details view was requested from the Library page.

		- Parameter cell: The library cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: LibraryBaseCollectionViewCell?) {
		guard let cell = cell else { return }
		showTitleLabel.text = cell.titleLabel?.text
		bannerImageView.image = (cell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image
		posterImageView.image = cell.posterImageView?.image
	}

	/// Updates the view with the details fetched from the server.
	fileprivate func updateDetails() {
		guard let showDetailsElement = showDetailsElement else { return }
		guard let currentUser = showDetailsElement.currentUser else { return }

		// Configure library status
		if let libraryStatus = currentUser.libraryStatus, !libraryStatus.isEmpty {
			self.libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
		} else {
			libraryStatusButton.setTitle("ADD", for: .normal)
		}

		// Configure title label
		if let title = showDetailsElement.title, !title.isEmpty {
			self.title = title
			showTitleLabel.text = title
		} else {
			self.title = "Unknown"
			showTitleLabel.text = "Unknown"
		}

		// Configure tags label
		tagsLabel.text = showDetailsElement.informationString

		// Configure status label
		if let status = showDetailsElement.status, !status.isEmpty {
			statusButton.setTitle(status, for: .normal)
			if status == "Ended" {
				statusButton.backgroundColor = .dropped
			} else {
				statusButton.backgroundColor = .planning
			}
		} else {
			statusButton.setTitle("TBA", for: .normal)
			statusButton.backgroundColor = .onHold
		}

		if let airingStatus = ShowDetail.AiringStatus(rawValue: showDetailsElement.status ?? "Ended") {
			statusButton.setTitle(airingStatus.stringValue, for: .normal)
			statusButton.backgroundColor = airingStatus.colorValue
		}

		// Configure rating
		if let averageRating = showDetailsElement.averageRating, let ratingCount = showDetailsElement.ratingCount, averageRating > 0.00 {
			cosmosView.rating = averageRating
			ratingScoreLabel.text = "\(averageRating)"
			ratingTitleLabel.text = "\(ratingCount) Ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		} else {
			cosmosView.rating = 0.0
			ratingScoreLabel.text = "0.0"
			ratingTitleLabel.text = "Not enough ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		}

		// Configure rank label
		if let rankScore = showDetailsElement.rank {
			rankScoreLabel.text = rankScore > 0 ? "#\(rankScore)" : "-"
		}

		// Configure age label
		if let ageScore = showDetailsElement.age {
			ageScoreLabel.text = !ageScore.isEmpty ? ageScore : "-"
		}

		// Configure poster view
		if posterImageView.image == nil {
			if let posterThumb = showDetailsElement.posterThumbnail {
				posterImageView.setImage(with: posterThumb, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
			}
		}

		// Configure banner view
		if bannerImageView.image == nil {
			if let bannerImage = showDetailsElement.banner {
				bannerImageView.setImage(with: bannerImage, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
			}
		}

		if let videoUrl = showDetailsElement.videoUrl, !videoUrl.isEmpty {
			trailerButton.isHidden = false
			trailerLabel.isHidden = false
		} else {
			trailerButton.isHidden = true
			trailerLabel.isHidden = true
		}

		// Configure shadows
		shadowView.applyShadow()
		reminderButton.applyShadow()
		favoriteButton.applyShadow()

		// Display details
		quickDetailsView.isHidden = false

		// Setup AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Updates the banner image view height.
	fileprivate func updateBannerImageViewHeight() {
		var viewHeight = view.height
		if UIDevice.isPhone && UIDevice.isLandscape {
			viewHeight = view.width
		}
		self.bannerImageViewHeightConstraint.constant = viewHeight / 3
		self.view.setNeedsUpdateConstraints()
		self.view.layoutIfNeeded()
	}

	/**
		Hides and unhides some views according to the given parameter.

		- Parameter isHidden: The boolean indicating whether to hide or unhide the views.
	*/
	fileprivate func viewsAreHidden(_ isHidden: Bool) {
		self.quickDetailsView.alpha = isHidden.int.cgFloat
		self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
		self.statusBarIsHidden = isHidden
		self.navigationController?.setNeedsStatusBarAppearanceUpdate()
	}

	// MARK: - IBActions
	@IBAction func favoriteButtonPressed(_ sender: Any) {
		tableView.reloadData()
	}

	@IBAction func closeButtonPressed(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}

	@IBAction func moreButtonPressed(_ sender: AnyObject) {
		guard let showID = showID else { return }
		var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

		if let title = showDetailsElement?.title, !title.isEmpty {
			shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			if let sender = sender as? UIBarButtonItem {
				popoverController.barButtonItem = sender
			} else {
				popoverController.sourceView = sender as? UIButton
				popoverController.sourceRect = sender.bounds
			}
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(activityVC, animated: true, completion: nil)
		}
	}

	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let action = UIAlertController.actionSheetWithItems(items: Library.Section.alertControllerItems, currentSelection: self.libraryStatus, action: { (title, value)  in
				guard let showID = self.showID else { return }

				if self.libraryStatus != value {
					KService.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
						if success {
							// Update entry in library
							self.libraryStatus = value
							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)

							let libraryUpdateNotificationName = Notification.Name("Update\(value)Section")
							NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

							self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
						}
					})
				}
			})

			if let libraryStatus = self.libraryStatus, !libraryStatus.isEmpty {
				action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
					KService.shared.removeFromLibrary(withID: self.showID, withSuccess: { (success) in
						if success {
							self.libraryStatus = ""

							self.delegate?.updateShowInLibrary(for: self.libraryBaseCollectionViewCell)

							self.libraryStatusButton.setTitle("ADD", for: .normal)
						}
					})
				}))
			}
			action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

			//Present the controller
			if let popoverController = action.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(action, animated: true, completion: nil)
			}
		}
	}

	@IBAction func showRating(_ sender: Any) {
		tableView.safeScrollToRow(at: IndexPath(row: 0, section: ShowDetail.Section.rating.rawValue), at: .middle, animated: true)
	}

	@IBAction func showBanner(_ sender: AnyObject) {
		if let banner = showDetailsElement?.banner, !banner.isEmpty {
			presentPhotoViewControllerWith(url: banner, from: bannerImageView)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_banner_image", from: bannerImageView)
		}
	}

	@IBAction func showPoster(_ sender: AnyObject) {
		if let poster = showDetailsElement?.poster, !poster.isEmpty {
			presentPhotoViewControllerWith(url: poster, from: posterImageView)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_poster_image", from: posterImageView)
		}
	}

	@IBAction func playTrailerPressed(_ sender: UIButton) {
		if let videoUrl = showDetailsElement?.videoUrl, !videoUrl.isEmpty {
			presentVideoViewControllerWith(string: videoUrl)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SynopsisSegue" {
			if let kNavigationController = segue.destination as? KNavigationController {
				if let synopsisViewController = kNavigationController.viewControllers.first as? SynopsisViewController {
					synopsisViewController.synopsis = showDetailsElement?.synopsis
				}
			}
		} else if segue.identifier == "SeasonsSegue" {
			if let seasonsCollectionViewController = segue.destination as? SeasonsCollectionViewController {
				seasonsCollectionViewController.seasons = seasons
			}
		} else if segue.identifier == "CastSegue" {
			if let castTableViewController = segue.destination as? CastCollectionViewController {
				castTableViewController.actors = actors
			}
		} else if segue.identifier == "EpisodesSegue" {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController {
				episodesCollectionViewController.seasonID = sender as? Int
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ShowDetailViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return showDetailsElement != nil ? ShowDetail.Section.all.count : 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let showSections = ShowDetail.Section(rawValue: section) else { return 0 }
		var numberOfRows = 0

		switch showSections {
		case .synopsis:
			if let synopsis = showDetailsElement?.synopsis, !synopsis.isEmpty {
				numberOfRows = 1
			}
		case .information:
			numberOfRows = User.isAdmin ? 11 : 9
		case .rating:
			numberOfRows = 1
		case .seasons:
			if let seasonsCount = seasons?.count, seasonsCount > 0 {
				numberOfRows = 1
			}
		case .cast:
			if let actorsCount = actors?.count, actorsCount > 0 {
				numberOfRows = 1
			}
		case .related: break
		}

		return numberOfRows
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let indexPath = indexPath

		switch ShowDetail.Section(rawValue: indexPath.section) {
		case .synopsis:
			let synopsisTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! SynopsisTableViewCell
			synopsisTableViewCell.showDetailsElement = showDetailsElement
			return synopsisTableViewCell
		case .information:
			let informationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! InformationTableViewCell
			informationTableViewCell.indexPathRow = indexPath.row
			informationTableViewCell.showDetailsElement = showDetailsElement
			return informationTableViewCell
		case .rating:
			let showRatingCell = tableView.dequeueReusableCell(withIdentifier: "ShowRatingCell") as! ShowRatingCell
			showRatingCell.showDetailsElement = showDetailsElement
			return showRatingCell
		case .seasons:
			let showSeasonsCell = tableView.dequeueReusableCell(withIdentifier: "ShowSeasonsCell") as! ShowSeasonsCell
			showSeasonsCell.seasons = seasons
			return showSeasonsCell
		case .cast:
			let showCastCell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCastCell
			showCastCell.actors = actors
			return showCastCell
		case .related:
			let showRelatedCell = tableView.dequeueReusableCell(withIdentifier: "ShowRelatedCell") as! ShowRelatedCell
			return showRelatedCell
		default:
			return UITableViewCell()
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let showTitleCell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
		return showTitleCell
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let showTitleCell = view as? ShowTitleCell {
			if let showSection = ShowDetail.Section(rawValue: section) {
				var title = showSection.stringValue

				switch showSection {
				case .synopsis:
					if let synopsis = showDetailsElement?.synopsis, synopsis.isEmpty {
						title = ""
					}
				case .information: break
				case .rating: break
				case .seasons:
					showTitleCell.seeMoreButton.isHidden = false
				case .cast:
					if let castCount = actors?.count {
						if castCount == 0 {
							title = ""
						}

						showTitleCell.seeMoreButton.isHidden = castCount < 2
					}
				case .related: break
				}

				showTitleCell.segueID = showSection.segueIdentifier
				showTitleCell.titleText = title
			}
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? UITableView.automaticDimension : .zero
	}
}

// MARK: - UITableViewDelegate
extension ShowDetailViewController {
}

// MARK: - UIScrollViewDelegate
extension ShowDetailViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.bounds.contains(quickDetailsView.center) {
			UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.viewsAreHidden(true)
			}, completion: nil)
		} else {
			UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(), animations: {
				self.viewsAreHidden(false)
			}, completion: nil)
		}
	}
}

// MARK: - ShowCastCellDelegate
extension ShowDetailViewController: ShowCastCellDelegate {
	func presentPhoto(withString string: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(string: string, from: imageView)
	}

	func presentPhoto(withImage image: UIImage, from imageView: UIImageView) {
		presentPhotoViewControllerWith(image: image, from: imageView)
	}

	func presentPhoto(withUrl url: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(url: url, from: imageView)
	}
}
