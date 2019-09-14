//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Kingfisher
import Cosmos
import Intents
import IntentsUI
import SwiftTheme

protocol ShowDetailViewControllerDelegate: class {
	func updateShowInLibrary(for cell: LibraryCollectionViewCell?)
}

class ShowDetailViewController: UIViewController {
	// MARK: - IBoutlet
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var shadowImageView: UIImageView! {
		didSet {
			shadowImageView.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var moreButton: UIButton!

	// Compact detail view
	@IBOutlet weak var compactDetailsView: UIView! {
		didSet {
			compactDetailsView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var compactShowTitleLabel: UILabel! {
		didSet {
			compactShowTitleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var compactTagsLabel: UILabel! {
		didSet {
			compactTagsLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var compactCloseButton: UIButton! {
		didSet {
			compactCloseButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}

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
	@IBOutlet weak var ratingScoreLabel: UILabel!
	@IBOutlet weak var ratingScoreDecimalLabel: UILabel!
	@IBOutlet weak var ratingTitleLabel: UILabel!
	@IBOutlet weak var rankTitleLabel: UILabel!
	@IBOutlet weak var ageTitleLabel: UILabel!

	// Compact detail vars
	let headerHeightInSection: CGFloat = 48
	var headerViewHeight: CGFloat = 390
	let compactDetailsHeight: CGFloat = 88

	// Snapshot and Stretchy view vars
	var headerView: UIView!
	private var blurView: UIView?
	private let snapshotView = UIImageView()
	var shouldSnapshot = true
	var viewsAreHidden: Bool = false {
		didSet {
			self.tableView.alpha = viewsAreHidden ? 0 : 1
			self.tabBarController?.tabBar.alpha = viewsAreHidden ? 0 : 1

			if viewsAreHidden {
				view.backgroundColor = .clear
			} else {
				view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			}
		}
	}

	// Hero Transition vars
	var showID: Int? {
		didSet {
			fetchDetails()
		}
	}
	var heroID: String?

	// Misc vars
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			self.updateDetails()
		}
	}
	var actors: [ActorsElement]? {
		didSet {
			self.tableView.reloadData()
		}
	}
	weak var delegate: ShowDetailViewControllerDelegate?
	var libraryStatus: String?
	var exploreCollectionViewCell: ExploreCollectionViewCell? = nil
	var libraryCollectionViewCell: LibraryCollectionViewCell? = nil
	var statusBarShouldBeHidden = false

	override var prefersStatusBarHidden: Bool {
		return statusBarShouldBeHidden
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Show the status bar
		statusBarShouldBeHidden = true
		UIView.animate(withDuration: 0.3) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
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

		if exploreCollectionViewCell != nil {
			guard let exploreCollectionViewCell = exploreCollectionViewCell else { return }
			configureShowDetails(from: exploreCollectionViewCell)
		} else if libraryCollectionViewCell != nil {
			guard let libraryCollectionViewCell = libraryCollectionViewCell else { return }
			configureShowDetails(from: libraryCollectionViewCell)
		}

		toggleHeroID(on: true)

		// Make header view stretchable
		headerView = tableView.tableHeaderView
		tableView.tableHeaderView = nil
		tableView.addSubview(headerView)
		tableView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
		tableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)

		// Setup table view
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Hide the status bar
		statusBarShouldBeHidden = false
		UIView.animate(withDuration: 0.3) {
			self.setNeedsStatusBarAppearanceUpdate()
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
		if let showID = showID {
			KCommonKit.shared.showID = showID

			Service.shared.getDetails(forShow: showID) { (showDetailsElement) in
				DispatchQueue.main.async {
					self.showDetailsElement = showDetailsElement
					self.libraryStatus = showDetailsElement.currentUser?.libraryStatus
				}
			}

			Service.shared.getCastFor(showID, withSuccess: { (actors) in
				DispatchQueue.main.async {
					self.actors = actors
				}
			})
		}
	}

	/// Prepare the view to be dismissed.
	fileprivate func willDismiss() {
		viewsAreHidden = true
		blurView?.isHidden = true
		snapshotView.isHidden = false
		toggleHeroID(on: false)
	}

	/// Dismisses the view after the view has been prepared for dismissal.
	fileprivate func dismiss() {
		willDismiss()
		dismiss(animated: true, completion: nil)
	}

	/**
		Configures the view from the given Explore cell if the details view was requested from the Explore page.

		- Parameter cell: The explore cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: ExploreCollectionViewCell) {
		if cell.bannerImageView != nil {
			showTitleLabel.text = cell.titleLabel?.text
			bannerImageView.image = cell.bannerImageView?.image
		} else {
			posterImageView.image = cell.posterImageView?.image

			var decimalScore = cell.scoreButton?.titleForNormal
			decimalScore?.removeFirst()

			ratingScoreLabel.text = "\(cell.scoreButton?.titleForNormal?.first ?? "0")"
			ratingScoreDecimalLabel.text = decimalScore ?? "0"
		}
	}

	/**
		Configures the view from the given Library cell if the details view was requested from the Library page.

		- Parameter cell: The library cell from which the view should be configured.
	*/
	fileprivate func configureShowDetails(from cell: LibraryCollectionViewCell) {
		showTitleLabel.text = cell.titleLabel?.text
		bannerImageView.image = (cell as? LibraryDetailedColelctionViewCell)?.episodeImageView?.image
		posterImageView.image = cell.posterView?.image
	}

	/// Update view with the details fetched from the server.
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
			showTitleLabel.text = title
			compactShowTitleLabel.text = title
		} else {
			showTitleLabel.text = "Unknown"
			compactShowTitleLabel.text = "Unknown"
		}

		// Configure tags label
		compactTagsLabel.alpha = 0.80
		tagsLabel.text = showDetailsElement.informationString
		compactTagsLabel.text = showDetailsElement.informationString

		// Configure status label
		if let status = showDetailsElement.status, !status.isEmpty {
			statusButton.setTitle(status, for: .normal)
			if status == "Ended" {
				statusButton.backgroundColor = .dropped()
			} else {
				statusButton.backgroundColor = .planning()
			}
		} else {
			statusButton.setTitle("TBA", for: .normal)
			statusButton.backgroundColor = .onHold()
		}

//		if let status = AnimeStatus(rawValue: "not yet aired" /*(show?.status)!*/) {
//			switch status {
//			case .currentlyAiring:
//				statusLabel.text = "Airing"
//				statusLabel.backgroundColor = .watching()
//			case .finishedAiring:
//				statusLabel.text = "Aired"
//				statusLabel.backgroundColor = UIColor.completed()
//			case .notYetAired:
//				statusLabel.text = "Not Aired"
//				statusLabel.backgroundColor = UIColor.onHold()
//			}
//		}

		// Configure rating
		if let averageRating = showDetailsElement.averageRating, let ratingCount = showDetailsElement.ratingCount, averageRating > 0.00 {
			cosmosView.rating = averageRating

			var decimalScore = "\(modf(averageRating).1)"
			decimalScore.removeFirst()

			ratingScoreLabel.text = "\(modf(averageRating).0)"
			ratingScoreDecimalLabel.text = "." + decimalScore
			ratingTitleLabel.text = "\(ratingCount) Ratings"
		} else {
			cosmosView.rating = 0.0
			ratingScoreLabel.text = "0"
			ratingScoreDecimalLabel.text = ".0"
			ratingTitleLabel.text = "Not enough ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		}

		// Configure rank label
		if let scoreRank = showDetailsElement.rank, scoreRank > 0 {
			rankTitleLabel.text = "\(scoreRank)"
		} else {
			rankTitleLabel.text = "-"
		}

		// Configure poster view
		if let posterThumb = showDetailsElement.posterThumbnail, !posterThumb.isEmpty {
			let posterThumb = URL(string: posterThumb)
			let resource = ImageResource(downloadURL: posterThumb!)
			posterImageView.kf.indicatorType = .activity
			posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView.image = #imageLiteral(resourceName: "placeholder_poster_image")
		}

		// Configure banner view
		if let bannerImage = showDetailsElement.banner, !bannerImage.isEmpty {
			let bannerImage = URL(string: bannerImage)
			let resource = ImageResource(downloadURL: bannerImage!)
			bannerImageView.kf.indicatorType = .activity
			bannerImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"), options: [.transition(.fade(0.2))])
		} else {
			bannerImageView.image = #imageLiteral(resourceName: "placeholder_banner_image")
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
		tableView.reloadData()
	}

	/**
		Toggle HeroID to turn on and off the transition animation.

		- Parameter on: A boolean value indicating whether the transition should be turned on or off.
	*/
	fileprivate func toggleHeroID(on: Bool) {
		guard let heroID = heroID else { return }
		showTitleLabel.hero.id = on ? "\(heroID)_title" : nil
		tagsLabel.hero.id = on ? "\(heroID)_tags" : nil
		posterImageView.hero.id = on ? "\(heroID)_poster" : nil
		bannerContainerView.hero.id = on ? "\(heroID)_banner" : nil

		if (libraryCollectionViewCell as? LibraryDetailedColelctionViewCell)?.episodeImageView != nil || exploreCollectionViewCell?.bannerImageView != nil {
			snapshotView.hero.id = on ? nil : "\(heroID)_banner"
		} else {
			snapshotView.hero.id = on ? nil : "\(heroID)_poster"
		}
	}

	/// Creates a blur visual effect and adds it as a subview
	fileprivate func createBlurVisualEffect() {
		let blurEffectView = UIVisualEffectView()
		blurEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue)
		blurEffectView.frame = self.view.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		self.view.addSubview(blurEffectView)
		blurView = blurEffectView
		blurView?.isHidden = true
	}

	/// Creates a snapshot of the current view and adds it as a subview.
	fileprivate func createSnapshotOfView() {
		snapshotView.clipsToBounds = true
		snapshotView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		snapshotView.isUserInteractionEnabled = true

		snapshotView.layer.shadowColor = UIColor.black.cgColor
		snapshotView.layer.shadowOpacity = 0.2
		snapshotView.layer.shadowRadius = 10
		snapshotView.layer.shadowOffset = CGSize(width: -1, height: 2)

		let snapshotImage = view.createSnapshot()
		snapshotView.image = snapshotImage

		view.addSubview(snapshotView)
		snapshotView.frame = view.frame
		snapshotView.isHidden = true
	}

	/// Updates the frame of the header view to fix layout issues.
	fileprivate func updateHeaderView() {
		var headerRect = CGRect(x: 0, y: -headerViewHeight, width: tableView.bounds.width, height: headerViewHeight)

		if tableView.contentOffset.y < -headerViewHeight {
			headerRect.origin.y = tableView.contentOffset.y
			headerRect.size.height = -tableView.contentOffset.y
		}

		headerView.frame = headerRect
	}

	// MARK: - IBActions
	@IBAction func favoriteButtonPressed(_ sender: Any) {
		tableView.reloadData()
	}

	@IBAction func closeButtonPressed(_ sender: UIButton) {
		createBlurVisualEffect()
		createSnapshotOfView()
		dismiss()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		guard let showID = showID else { return }
		var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

		if let title = showDetailsElement?.title, !title.isEmpty {
			shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(activityVC, animated: true, completion: nil)
		}
	}

	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		let action = UIAlertController.actionSheetWithItems(items: [("Planning", "Planning"), ("Watching", "Watching"), ("Completed", "Completed"), ("Dropped", "Dropped"), ("On-Hold", "OnHold")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.showID else { return }

			if self.libraryStatus != value {
				Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
					if success {
						// Update entry in library
						self.libraryStatus = value
						self.delegate?.updateShowInLibrary(for: self.libraryCollectionViewCell)

						let libraryUpdateNotificationName = Notification.Name("Update\(title)Section")
						NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

						self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
					}
				})
			}
		})

		if let libraryStatus = libraryStatus, !libraryStatus.isEmpty {
			action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
				Service.shared.removeFromLibrary(withID: self.showID, withSuccess: { (success) in
					if success {
						self.libraryStatus = ""

						self.delegate?.updateShowInLibrary(for: self.libraryCollectionViewCell)

						self.libraryStatusButton.setTitle("ADD", for: .normal)
					}
				})
			}))
		}
		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(action, animated: true, completion: nil)
		}
	}

	@IBAction func showRating(_ sender: Any) {
		tableView.safeScrollToRow(at: IndexPath(row: 0, section: ShowSections.rating.rawValue), at: .top, animated: true)
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
		if let kNavigationController = segue.destination as? KNavigationController {
			if segue.identifier == "SynopsisSegue" {
				if let synopsisViewController = kNavigationController.viewControllers.first as? SynopsisViewController {
					synopsisViewController.synopsis = showDetailsElement?.synopsis
				}
			} else if segue.identifier == "ActorsSegue" {
				if let castTableViewController = kNavigationController.viewControllers.first as? CastCollectionViewController {
					castTableViewController.actors = actors
				}
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ShowDetailViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return showDetailsElement != nil ? ShowSections.all.count : 0
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let showSections = ShowSections(rawValue: section) else { return 0 }
		var numberOfRows = 0

		switch showSections {
		case .synopsis:
			if let synopsis = showDetailsElement?.synopsis, !synopsis.isEmpty {
				numberOfRows = 1
			}
		case .information:
			numberOfRows = User.isAdmin ? 11 : 10
		case .rating:
			numberOfRows = 1
		case .cast:
			if let actorsCount = actors?.count, actorsCount > 0 {
				numberOfRows = 2
			}
		case .related: break
		}

		return numberOfRows
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let indexPath = indexPath

		switch ShowSections(rawValue: indexPath.section)! {
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
		case .cast:
			let showCharacterCell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCharacterCell
			showCharacterCell.actorElement = actors?[indexPath.row]
			showCharacterCell.delegate = self
			if indexPath.row == 1 {
				showCharacterCell.separatorView.isHidden = true
			}
			return showCharacterCell
		case .related:
			let showRelatedCell = tableView.dequeueReusableCell(withIdentifier: "ShowRelatedCell") as! ShowRelatedCell
			return showRelatedCell
		}
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let showTitleCell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
		var title = ""

		if let showSection = ShowSections(rawValue: section) {
			switch showSection {
			case .synopsis:
				if let synopsis = showDetailsElement?.synopsis, !synopsis.isEmpty {
					title = "Synopsis"
				}
			case .information:
				title = "Information"
			case .rating:
				title = "Ratings"
			case .cast:
				if let castCount = actors?.count, castCount != 0 {
					title = "Actors"
					showTitleCell.seeMoreActorsButton.isHidden = castCount < 2
				}
			case .related:
				title = "Related"
			}
		}

		showTitleCell.titleLabel.text = title
		return showTitleCell.contentView
	}

	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? headerHeightInSection : CGFloat.leastNormalMagnitude
	}

	// Reload table to fix layout - NEEDS A BETTER FIX IF POSSIBLE
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: nil, completion: { _ in
			self.tableView.reloadData()
		})
	}
}

// MARK: - UITableViewDelegate
extension ShowDetailViewController: UITableViewDelegate {
}

// MARK: - UIScrollViewDelegate
extension ShowDetailViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateHeaderView()
		if shouldSnapshot && scrollView.isTracking {
			self.createBlurVisualEffect()
			self.createSnapshotOfView()
			shouldSnapshot = false
		}

		// Variables for showing/hiding compact details view
		let bannerHeight = bannerImageView.bounds.height
		let newOffset = bannerHeight - scrollView.contentOffset.y
		let compactDetailsOffset = newOffset - compactDetailsHeight

		// Logic for showing/hiding compact details view
		if compactDetailsOffset > bannerHeight {
			UIView.animate(withDuration: 0.5) {
				self.quickDetailsView.alpha = 1
			}

			UIView.animate(withDuration: 0) {
				self.compactDetailsView.alpha = 0
			}
		} else {
			UIView.animate(withDuration: 0) {
				self.quickDetailsView.alpha = 0
			}

			UIView.animate(withDuration: 0.5) {
				self.compactDetailsView.alpha = 1
			}
		}

		let yPositionForDismissal: CGFloat = 30
		let yContentOffset = tableView.contentOffset.y
		let newHeaderViewHeight = headerViewHeight + view.safeAreaInsets.top

		if yContentOffset < -newHeaderViewHeight && scrollView.isTracking {
			viewsAreHidden = true
			snapshotView.isHidden = false
			blurView?.isHidden = false

			let scale = (300 + newHeaderViewHeight + yContentOffset) / 300

			snapshotView.transform = CGAffineTransform(scaleX: scale, y: scale)
			snapshotView.layer.cornerRadius = -yContentOffset > yPositionForDismissal ? yPositionForDismissal : -yContentOffset

			if yPositionForDismissal + yContentOffset <= -newHeaderViewHeight + -yPositionForDismissal {
				scrollView.isScrollEnabled = false
				dismiss()
			}
		} else if snapshotView.transform.a > 0.90 && scrollView.isTracking && scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
			viewsAreHidden = false
			snapshotView.isHidden = true
			blurView?.isHidden = true
		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		let yContentOffset = tableView.contentOffset.y
		let newHeaderViewHeight = headerViewHeight + view.safeAreaInsets.top

		if yContentOffset < -newHeaderViewHeight && scrollView.isTracking {
			viewsAreHidden = false
			snapshotView.isHidden = true
			blurView?.isHidden = true
		}
	}
}

// MARK: - ShowCharacterCellDelegate
extension ShowDetailViewController: ShowCharacterCellDelegate {
	func presentPhoto(withString string: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(string: string, from: imageView)
	}

	func presentPhoto(withUrl url: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(url: url, from: imageView)
	}
}
