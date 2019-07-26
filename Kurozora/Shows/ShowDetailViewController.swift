//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Kingfisher
import BottomPopup
import Cosmos
import NVActivityIndicatorView
import Intents
import IntentsUI

protocol ShowDetailViewControllerDelegate: class {
	func updateShowInLibrary(for cell: LibraryCollectionViewCell?)
}

class ShowDetailViewController: UIViewController, NVActivityIndicatorViewable {
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
	@IBOutlet weak var listButton: UIButton!
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
			// self.compactDetailsView.alpha = 0 // Should always be hidden

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
	var showDetails: ShowDetails? {
		didSet {
			self.updateDetails()
		}
	}
	var actors: [ActorsElement]? {
		didSet {
			self.tableView.reloadData()
		}
	}
	var delegate: ShowDetailViewControllerDelegate?
	var libraryStatus: String?
	var showRating: Double?
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
		if let title = showDetails?.showDetailsElement?.title, let showID = showID {
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

		if UIDevice.isPad() {
			var frame = headerView.frame
			frame.size.height = 500 - 44 - 30
			tableView.tableHeaderView?.frame = frame
			view.insertSubview(tableView, belowSubview: bannerImageView)
		}

		// Fetch details
//		fetchDetails()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension
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
	func fetchDetails() {
		if let showID = showID {
			KCommonKit.shared.showID = showID

			Service.shared.getDetails(forShow: showID) { (showDetails) in
				DispatchQueue.main.async() {
					self.showDetails = showDetails
					self.libraryStatus = showDetails.userProfile?.libraryStatus
				}
			}

			Service.shared.getCastFor(showID, withSuccess: { (actors) in
				DispatchQueue.main.async() {
					self.actors = actors
				}
			})
		}
	}

	fileprivate func dismiss() {
		viewsAreHidden = true
		blurView?.isHidden = true
		snapshotView.isHidden = false
		toggleHeroID(on: false)
		dismiss(animated: true, completion: nil)
	}

	fileprivate func configureShowDetails(from cell: ExploreCollectionViewCell) {
		if cell.bannerImageView != nil {
			showTitleLabel.text = cell.titleLabel?.text
			bannerImageView.image = cell.bannerImageView?.image
		} else {
			posterImageView.image = cell.posterImageView?.image

			var decimalScore = cell.scoreLabel?.text
			decimalScore?.removeFirst()

			ratingScoreLabel.text = "\(cell.scoreLabel?.text?.first ?? "0")"
			ratingScoreDecimalLabel.text = (decimalScore != "") ? decimalScore : "0"
		}

		// Setup shadows
		shadowView.applyShadow()
		reminderButton.applyShadow()
		favoriteButton.applyShadow()
	}

	fileprivate func configureShowDetails(from cell: LibraryCollectionViewCell) {
		showTitleLabel.text = cell.titleLabel?.text
		bannerImageView.image = cell.episodeImageView?.image
		posterImageView.image = cell.posterView?.image
	}

	// Update view with details
	fileprivate func updateDetails() {
		guard let showDetailsElement = showDetails?.showDetailsElement else { return }
		guard let userProfile = showDetails?.userProfile else { return }

		// Configure library status
		if let libraryStatus = userProfile.libraryStatus, libraryStatus != "" {
			let mutableAttributedTitle = NSMutableAttributedString()
			let  attributedTitleString = NSAttributedString(string: "\(libraryStatus.capitalized) ", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
			let attributedIconString = NSAttributedString(string: "", attributes: [.font : UIFont.init(name: "FontAwesome", size: 15)!])
			mutableAttributedTitle.append(attributedTitleString)
			mutableAttributedTitle.append(attributedIconString)

			listButton.setAttributedTitle(mutableAttributedTitle, for: .normal)
		} else {
			listButton.setTitle("ADD", for: .normal)
		}

		// Configure title label
		if let title = showDetailsElement.title, title != "" {
			showTitleLabel.text = title
			compactShowTitleLabel.text = title
		} else {
			showTitleLabel.text = "Unknown"
			compactShowTitleLabel.text = "Unknown"
		}

		// Configure rating button
		if let rating = userProfile.currentRating, rating != 0 {
			self.showRating = rating
			self.cosmosView.rating = rating
		} else {
			self.cosmosView.rating = 0.0
		}

		// Configure tags label
		compactTagsLabel.alpha = 0.80
		tagsLabel.text = showDetailsElement.informationString()
		compactTagsLabel.text = showDetailsElement.informationString()

		// Configure status label
		if let status = showDetailsElement.status, status != "" {
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

		//            if let status = AnimeStatus(rawValue: "not yet aired" /*(show?.status)!*/) {
		//                switch status {
		//                case .currentlyAiring:
		//                    statusLabel.text = "Airing"
		//                    statusLabel.backgroundColor = .watching()
		//                case .finishedAiring:
		//                    statusLabel.text = "Aired"
		//                    statusLabel.backgroundColor = UIColor.completed()
		//                case .notYetAired:
		//                    statusLabel.text = "Not Aired"
		//                    statusLabel.backgroundColor = UIColor.onHold()
		//                }
		//            }

		// Configure ratings label
		if let averageRating = showDetailsElement.averageRating, let ratingCount = showDetailsElement.ratingCount, averageRating > 0.00 {
			var decimalScore = "\(modf(averageRating).1)"
			decimalScore.removeFirst()

			ratingScoreLabel.text = "\(modf(averageRating).0)"
			ratingScoreDecimalLabel.text = "." + decimalScore
			ratingTitleLabel.text = "\(ratingCount) Ratings"
		} else {
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
		if let posterThumb = showDetailsElement.posterThumbnail, posterThumb != "" {
			let posterThumb = URL(string: posterThumb)
			let resource = ImageResource(downloadURL: posterThumb!)
			posterImageView.kf.indicatorType = .activity
			posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
		}

		// Configure banner view
		if let bannerImage = showDetailsElement.banner, bannerImage != "" {
			let bannerImage = URL(string: bannerImage)
			let resource = ImageResource(downloadURL: bannerImage!)
			bannerImageView.kf.indicatorType = .activity
			bannerImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
		} else {
			bannerImageView.image = #imageLiteral(resourceName: "placeholder_banner")
		}

//		if let youtubeID = showDetailsElement.youtubeID, youtubeID != "" {
//			trailerButton.isHidden = false
//		} else {
//			trailerButton.isHidden = true
//		}
		trailerButton.isHidden = false

		// Display details
		quickDetailsView.isHidden = false
		tableView.reloadData()
	}

	fileprivate func toggleHeroID(on: Bool) {
		guard let heroID = heroID else { return }
		showTitleLabel.hero.id = on ? "\(heroID)_title" : nil
		tagsLabel.hero.id = on ? "\(heroID)_tags" : nil
		posterImageView.hero.id = on ? "\(heroID)_poster" : nil
		bannerContainerView.hero.id = on ? "\(heroID)_banner" : nil

		if libraryCollectionViewCell?.episodeImageView != nil || exploreCollectionViewCell?.bannerImageView != nil {
			snapshotView.hero.id = on ? nil : "\(heroID)_banner"
		} else {
			snapshotView.hero.id = on ? nil : "\(heroID)_poster"
		}
	}

	fileprivate func createSnapshotOfView() {
		if !UIAccessibility.isReduceTransparencyEnabled {
			let blurEffect = UIBlurEffect(style: .extraLight)
			let blurEffectView = UIVisualEffectView(effect: blurEffect)
			blurEffectView.frame = self.view.bounds
			blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

			self.view.addSubview(blurEffectView)
			blurView = blurEffectView
			blurView?.isHidden = true
		}

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
		if shouldSnapshot {
			createSnapshotOfView()
		}
		dismiss()
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		guard let showID = showID else { return }
		var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

		if let title = showDetails?.showDetailsElement?.title, title != "" {
			shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		present(activityVC, animated: true, completion: nil)
	}

	@IBAction func chooseStatusButtonPressed(_ sender: AnyObject) {
		let action = UIAlertController.actionSheetWithItems(items: [("Planning", "Planning"),("Watching","Watching"),("Completed","Completed"),("Dropped","Dropped"),("On-Hold", "OnHold")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.showID else {return}

			Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
				if success {
					// Update entry in library
					self.libraryStatus = value
					self.delegate?.updateShowInLibrary(for: self.libraryCollectionViewCell)

					let libraryUpdateNotificationName = Notification.Name("Update\(title)Section")
					NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

					let mutableAttributedTitle = NSMutableAttributedString()
					let  attributedTitleString = NSAttributedString(string: "\(title) ", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
					let attributedIconString = NSAttributedString(string: "", attributes: [.font : UIFont.init(name: "FontAwesome", size: 15)!])
					mutableAttributedTitle.append(attributedTitleString)
					mutableAttributedTitle.append(attributedIconString)

					self.listButton.setAttributedTitle(mutableAttributedTitle, for: .normal)
				}
			})
		})

		action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
			Service.shared.removeFromLibrary(withID: self.showID, withSuccess: { (success) in
				if success {
					self.libraryStatus = ""
					self.delegate?.updateShowInLibrary(for: self.libraryCollectionViewCell)

					let mutableAttributedTitle = NSMutableAttributedString()
					let  attributedTitleString = NSAttributedString(string: "ADD", attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium)])
					mutableAttributedTitle.append(attributedTitleString)
					self.listButton.setAttributedTitle(mutableAttributedTitle, for: .normal)
				}
			})
		}))
		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.present(action, animated: true, completion: nil)
	}

	@IBAction func showRating(_ sender: Any) {
		let storyboard : UIStoryboard = UIStoryboard(name: "rate", bundle: nil)
		let rateViewController = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController
		rateViewController?.showDetailsElement = showDetails?.showDetailsElement
		rateViewController?.showRatingdelegate = self
		rateViewController?.modalTransitionStyle = .crossDissolve
		rateViewController?.modalPresentationStyle = .overCurrentContext
		self.present(rateViewController!, animated: true, completion: nil)
	}

	@IBAction func showBanner(_ sender: AnyObject) {
		if let banner = showDetails?.showDetailsElement?.banner, banner != "" {
			presentPhotoViewControllerWith(url: banner, from: bannerImageView)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_banner", from: bannerImageView)
		}
	}

	@IBAction func showPoster(_ sender: AnyObject) {
		if let poster = showDetails?.showDetailsElement?.poster, poster != "" {
			presentPhotoViewControllerWith(url: poster, from: posterImageView)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_poster", from: posterImageView)
		}
	}

	@IBAction func playTrailerPressed(_ sender: UIButton) {
		if let youtubeID = showDetails?.showDetailsElement?.youtubeID, youtubeID != "" {
			presentVideoViewControllerWith(string: youtubeID)
		} else {
			presentVideoViewControllerWith(string: "-QpuPy9EPhk")
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SynopsisSegue" {
			if let synopsisViewController = segue.destination as? SynopsisViewController {
				synopsisViewController.synopsis = showDetails?.showDetailsElement?.synopsis
			}
		} else if segue.identifier == "ActorsSegue" {
			if let castTableViewController = segue.destination as? CastCollectionViewController {
				castTableViewController.actors = actors
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ShowDetailViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return showDetails?.showDetailsElement != nil ? ShowSections.allSections.count : 0
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numberOfRows = 0

		switch ShowSections(rawValue: section)! {
		case .synopsis:
			numberOfRows = (showDetails?.showDetailsElement?.synopsis != "") ? 1 : 0
		case .information:
			numberOfRows = (User.isAdmin == true) ? 11 : 10
		case .cast:
			if let actorsCount = actors?.count, actorsCount > 0 {
				numberOfRows = 2
			} else {
				numberOfRows = 0
			}
		case .related:
			numberOfRows = 0
		}

		return numberOfRows
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let indexPath = indexPath

		switch ShowSections(rawValue: indexPath.section)! {
		case .synopsis:
			let synopsisCell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! SynopsisCell
			synopsisCell.showDetailsElement = showDetails?.showDetailsElement
			synopsisCell.layoutIfNeeded()
			return synopsisCell
		case .information:
			let informationCell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! InformationTableViewCell
			informationCell.indexPathRow = indexPath.row
			informationCell.showDetailsElement = showDetails?.showDetailsElement
			informationCell.layoutIfNeeded()
			return informationCell
		case .cast:
			let castCell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCharacterCell
			castCell.actorElement = actors?[indexPath.row]
			castCell.delegate = self
			if indexPath.row == 1 {
				castCell.separatorView.isHidden = true
			}
			castCell.layoutIfNeeded()
			return castCell
		case .related:
			let relatedCell = tableView.dequeueReusableCell(withIdentifier: "ShowRelatedCell") as! ShowRelatedCell
			return relatedCell
		}
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let showTitleCell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
		var title = ""

		switch ShowSections(rawValue: section)! {
		case .synopsis:
			title = (showDetails?.showDetailsElement?.synopsis != "") ? "Synopsis" : ""
		case .information:
			title = "Information"
		case .cast:
			guard let castCount = actors?.count else { return showTitleCell.contentView }
			title = (castCount != 0) ? "Actors" : ""
			showTitleCell.seeMoreActorsButton.isHidden = !(castCount > 2)
		case .related:
			title = "Related"
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
		coordinator.animate(alongsideTransition: nil, completion: {
			_ in
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
			self.createSnapshotOfView()
			shouldSnapshot = false
		}

		// Variables for showing/hiding compact details view
		let bannerHeight = bannerImageView.bounds.height
		let newOffset = bannerHeight - scrollView.contentOffset.y
		let compactDetailsOffset = newOffset - compactDetailsHeight

		// Logic for showing/hiding compact details view
		if compactDetailsOffset > bannerHeight {
			UIView.animate(withDuration: 0.75) {
				self.quickDetailsView.alpha = 1
			}

			UIView.animate(withDuration: 0) {
				self.compactDetailsView.alpha = 0
			}
		} else {
			UIView.animate(withDuration: 0) {
				self.quickDetailsView.alpha = 0
			}

			UIView.animate(withDuration: 0.75) {
				self.compactDetailsView.alpha = 1
			}
		}

		let yPositionForDismissal: CGFloat = 30
		let yContentOffset = tableView.contentOffset.y
		let newHeaderViewHeight = headerViewHeight + topLayoutGuide.length

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
		let newHeaderViewHeight = headerViewHeight + topLayoutGuide.length

		if yContentOffset < -newHeaderViewHeight && scrollView.isTracking {
			viewsAreHidden = false
			snapshotView.isHidden = true
			blurView?.isHidden = true
		}
	}
}

// MARK: - ShowRatingDelegate
extension ShowDetailViewController: ShowRatingDelegate {
	func getRating(value: Double?) {
		if let rating = value {
			self.cosmosView.rating = rating
			self.cosmosView.update()
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
