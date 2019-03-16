//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import Kingfisher
import SCLAlertView
import BottomPopup
import Cosmos
import NVActivityIndicatorView
import Intents
import IntentsUI

enum AnimeSection: Int {
	case synopsis
	case information
	case cast

	static var allSections: [AnimeSection] = [.synopsis, .information, .cast]
}

class ShowDetailViewController: UIViewController, NVActivityIndicatorViewable, ShowRatingDelegate {
	// MARK: - IBoutlet
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var moreButton: UIButton!

	// Drag to dismiss
	@IBOutlet weak var dismissButton: UIButton!
	@IBOutlet weak var dismissButtonCenterToMoreButton: NSLayoutConstraint!

	// Compact detail view
	@IBOutlet weak var compactDetailsView: UIView!
	@IBOutlet weak var compactShowTitleLabel: UILabel!
	@IBOutlet weak var compactTagsLabel: UILabel!
	@IBOutlet weak var compactCloseButton: UIButton!

	// Action buttons
	@IBOutlet weak var listButton: UIButton!
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var reminderButton: UIButton!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var showTitleLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var trailerButton: UIButton!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var favoriteButton: UIButton!

	// Analytics title view
	@IBOutlet weak var scoreRankTitleLabel: UILabel!
	@IBOutlet weak var popularityRankTitleLabel: UILabel!
	@IBOutlet weak var ratingTitleLabel: UILabel!
	@IBOutlet weak var membersCountTitleLabel: UILabel!

	// Analytics detail view
	@IBOutlet weak var scoreRankLabel: UILabel!
	@IBOutlet weak var popularityRankLabel: UILabel!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var membersCountLabel: UILabel!
	
	// Compact detail vars
	let headerHeightInSection: CGFloat = 40
	var headerViewHeight: CGFloat = 470
	let compactDetailsHeight: CGFloat = 88

	// View vars
	var headerView: UIView!

	// Drag to dismiss vars
	let lightImpact = UIImpactFeedbackGenerator(style: .light)
	let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
	var scrollToTop = false

	// Misc vars
	var showDetails: ShowDetails?
	var showID: Int?
	var showTitle: String?
	var heroID: String?
	var libraryStatus: String?
	var showRating: Double?
	var actors: [ActorsElement]?

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
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		// Donate suggestion to Siri
		userActivity = NSUserActivity(activityType: "OpenAnimeIntent")
		if let title = showDetails?.title, let showID = showID {
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

		// Theme
		view.theme_backgroundColor = "Global.backgroundColor"
		compactDetailsView.theme_backgroundColor = "Global.backgroundColor"
		compactCloseButton.theme_setTitleColor("Global.tintColor", forState: .normal)

		scoreRankTitleLabel.theme_textColor = "Global.textColor"
		scoreRankTitleLabel.alpha = 0.80
		popularityRankTitleLabel.theme_textColor = "Global.textColor"
		popularityRankTitleLabel.alpha = 0.80
		ratingTitleLabel.theme_textColor = "Global.textColor"
		ratingTitleLabel.alpha = 0.80
		membersCountTitleLabel.theme_textColor = "Global.textColor"
		membersCountTitleLabel.alpha = 0.80

		// Hero transition
		if let showTitle = showTitle, let heroID = heroID {
			showTitleLabel.hero.id = "\(heroID)_\(showTitle)_title"
			bannerImageView.hero.id = "\(heroID)_\(showTitle)_banner"
			tagsLabel.hero.id = "\(heroID)_\(showTitle)_progress"
			posterImageView.hero.id = "\(heroID)_\(showTitle)_poster"
		}
		
		startAnimating(CGSize(width: 100, height: 100), type: NVActivityIndicatorType.ballScaleMultiple, color: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), minimumDisplayTime: 3)

		if UIDevice.hasTapticEngine {
			dismissButtonCenterToMoreButton.constant = 22
		}

		// Make header view stretchable
		headerView = tableView.tableHeaderView
		tableView.tableHeaderView = nil
		tableView.addSubview(headerView)
		tableView.contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
		tableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
		updateHeaderView()

		if UIDevice.isPad() {
			var frame = headerView.frame
			frame.size.height = 500 - 44 - 30
			tableView.tableHeaderView?.frame = frame
			view.insertSubview(tableView, belowSubview: bannerImageView)
		}

		// Fetch details
		if let showID = showID {
			KCommonKit.shared.showID = showID

			Service.shared.getDetails(forShow: showID) { (showDetails) in
				DispatchQueue.main.async() {
					self.showDetails = showDetails
					self.libraryStatus = showDetails.libraryStatus
					self.updateDetailWithShow(self.showDetails)
					self.tableView.reloadData()
				}
			}

			Service.shared.getCastFor(showID, withSuccess: { (actors) in
				DispatchQueue.main.async() {
					self.actors = actors
					self.tableView.reloadData()
				}
			})
		}

		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension

//		if #available(iOS 12.0, *) {
//			presentAddAnimeToSiriViewController()
//		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Hide the status bar
		statusBarShouldBeHidden = false
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}

	// MARK: - Functions
	// Update view with details
	func updateDetailWithShow(_ show: ShowDetails?) {
		if showDetails != nil {
			// Configure library status
			if let libraryStatus = showDetails?.libraryStatus, libraryStatus != "" {
				listButton.setTitle("\(libraryStatus.capitalized) ", for: .normal)
			} else {
				listButton.setTitle("Add to list ", for: .normal)
			}

			// Configure title label
			showTitleLabel.theme_textColor = "Global.textColor"
			compactShowTitleLabel.theme_textColor = "Global.textColor"
			if let title = showDetails?.title {
				showTitleLabel.text = title
				compactShowTitleLabel.text = title
			} else {
				showTitleLabel.text = "Unknown"
				compactShowTitleLabel.text = "Unknown"
			}

			// Configure rating button
			if let rating = showDetails?.currentRating {
				showRating = rating
				self.cosmosView.rating = rating
			} else {
				self.cosmosView.rating = 0.0
			}

			// Configure tags label
			tagsLabel.theme_textColor = "Global.textColor"
			tagsLabel.alpha = 0.80
			compactTagsLabel.theme_textColor = "Global.textColor"
			compactTagsLabel.alpha = 0.80
			if let tags = showDetails?.informationString() {
				tagsLabel.text = tags
				compactTagsLabel.text = tags
			} else {
				tagsLabel.text = "Unknown · N/A · 0 eps · 0 min · 0000"
				compactTagsLabel.text = "Unknown · N/A · 0 eps · 0 min · 0000"
			}

			// Configure status label
			if let status = showDetails?.status, status != "" {
				statusLabel.text = status.capitalized
				if status == "Ended" {
					statusLabel.backgroundColor = .dropped()
				} else {
					statusLabel.backgroundColor = .planning()
				}
			} else {
				statusLabel.backgroundColor = .onHold()
				statusLabel.text = "TBA".capitalized
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
			ratingLabel.theme_textColor = "Global.textColor"
			if let averageRating = showDetails?.averageRating, averageRating > 0.00 {
				ratingLabel.text = String(format:"%.2f / %d", averageRating, /*show?.progress?.score ??*/ 5.00)
			} else {
				ratingLabel.text = "Not enough ratings"
			}

			membersCountLabel.theme_textColor = "Global.textColor"
			if let ratingCount = showDetails?.ratingCount, ratingCount > 0 {
				membersCountLabel.text = String(ratingCount)
			} else {
				membersCountLabel.text = "-"
			}

			// Configure rank label
			scoreRankLabel.theme_textColor = "Global.textColor"
			if let scoreRank = showDetails?.rank, scoreRank > 0 {
				scoreRankLabel.text = String(scoreRank)
			} else {
				scoreRankLabel.text = "-"
			}

			popularityRankLabel.theme_textColor = "Global.textColor"
			if let popularRank = showDetails?.popularityRank, popularRank > 0 {
				popularityRankLabel.text = String(popularRank)
			} else {
				popularityRankLabel.text = "-"
			}

			// Configure poster view
			if let posterThumb = showDetails?.posterThumbnail, posterThumb != "" {
				let posterThumb = URL(string: posterThumb)
				let resource = ImageResource(downloadURL: posterThumb!)
				posterImageView.kf.indicatorType = .activity
				posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
			} else {
				posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
			}

			// Configure banner view
			if let bannerImage = showDetails?.banner, bannerImage != "" {
				let bannerImage = URL(string: bannerImage)
				let resource = ImageResource(downloadURL: bannerImage!)
				bannerImageView.kf.indicatorType = .activity
				bannerImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
			} else {
				bannerImageView.image = #imageLiteral(resourceName: "placeholder_banner")
			}

			if let youtubeID = showDetails?.youtubeId, youtubeID.count > 0 {
				trailerButton.isHidden = false
				trailerButton.layer.borderWidth = 1.0;
				trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
			} else {
				trailerButton.isHidden = true
			}

			// Display details
			quickDetailsView.isHidden = false
			self.stopAnimating()
		}
	}

	func scrollView() -> UIScrollView {
		return tableView
	}

	func updateHeaderView() {
		var headerRect = CGRect(x: 0, y: -headerViewHeight, width: tableView.bounds.width, height: headerViewHeight)

		if tableView.contentOffset.y < -headerViewHeight {
			headerRect.origin.y = tableView.contentOffset.y
			headerRect.size.height = -tableView.contentOffset.y
		}

		headerView.frame = headerRect
	}

	func getRating(value: Double?) {
		if let rating = value {
			self.cosmosView.rating = rating
			self.cosmosView.update()
		}
	}

	// MARK: - IBActions
	@IBAction func favoriteButtonPressed(_ sender: Any) {
		tableView.reloadData()
	}

	@IBAction func closeButtonPressed(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		var shareText: String!
		guard let showID = showID else { return }

		if let title = showDetails?.title {
			shareText = "https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"
		} else {
			shareText = "https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"
		}

		let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

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
				if !success {
					SCLAlertView().showError("Error adding to library", subTitle: "There was an error while adding this anime to your library. Please try again!")
				} else {
					self.libraryStatus = value
					self.listButton.setTitle(title + " ", for: .normal)
				}
			})
		})

		action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
			Service.shared.removeFromLibrary(withID: self.showID, withSuccess: { (success) in
				if !success {
					SCLAlertView().showError("Error removing from library", subTitle: "There was an error while removing this anime from your library. Please try again!")
				} else {
					self.libraryStatus = ""
					self.listButton.setTitle("Add to list ", for: .normal)
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

	@IBAction func showCastDrawer(_ sender: AnyObject) {
		let storyboard:UIStoryboard? = UIStoryboard(name: "details", bundle: nil)
		guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "Actors") as? CastTableViewController else { return }
		popupVC.actors = actors
		present(popupVC, animated: true, completion: nil)
	}

	// MARK: - UITapGestureRecognizer
	@IBAction func showRating(_ sender: Any) {
		let storyboard : UIStoryboard = UIStoryboard(name: "rate", bundle: nil)
		let rateViewController = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController
		rateViewController?.showDetails = showDetails
		rateViewController?.showRatingdelegate = self
		rateViewController?.modalTransitionStyle = .crossDissolve
		rateViewController?.modalPresentationStyle = .overCurrentContext
		self.present(rateViewController!, animated: true, completion: nil)
	}

	@IBAction func showBanner(_ sender: AnyObject) {
		if let banner = showDetails?.banner, banner != "" {
			presentPhotoViewControllerWith(url: banner)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_banner")
		}
	}

	@IBAction func showPoster(_ sender: AnyObject) {
		if let poster = showDetails?.poster, poster != "" {
			presentPhotoViewControllerWith(url: poster)
		} else {
			presentPhotoViewControllerWith(string: "placeholder_poster")
		}
	}

	@IBAction func showCast(_ tap: UITapGestureRecognizer) {
		let cell = tap.view as? ShowCharacterCell
		let pointInCell: CGPoint = tap.location(in: cell?.contentView)
		let view: UIView? = cell?.contentView.hitTest(pointInCell, with: nil)
		let pointInTable = tap.location(in: self.tableView)

		if let indexPath = self.tableView.indexPathForRow(at: pointInTable) {
			if (self.tableView.cellForRow(at: indexPath) as? ShowCharacterCell) != nil {
				if view == cell?.actorImageView {
					if let imageUrl = actors?[indexPath.row].image, imageUrl != "" {
						presentPhotoViewControllerWith(url: imageUrl)
					} else {
						presentPhotoViewControllerWith(string: "placeholder_person")
					}
				}
			}
		}
	}

	@IBAction func playTrailerPressed(sender: AnyObject) {
		//        if let trailerURL = showDetails?.youtubeId {
		////            presentLightboxViewController(imageUrl: "", text: "", videoUrl: trailerURL)
		//        }
	}
}

// MARK: - UIScrollViewDelegate
extension ShowDetailViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateHeaderView()

		let bannerHeight = bannerImageView.bounds.height
		let newOffset = bannerHeight - scrollView.contentOffset.y
		let compactDetailsOffset = newOffset - compactDetailsHeight

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

		// Reached the top of view
		if (scrollView.isAtTop) {
			let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)

			if (actualPosition.y >= 250 && actualPosition.y <= 260) {
				// If user scrolls down when at the top of the view
				self.lightImpact.impactOccurred()
				UIView.animate(withDuration: 0.75, animations: {
					self.dismissButton.setTitle("Drag To Dismiss", for: .normal)
					self.dismissButton.alpha = 1
				})
			} else if (actualPosition.y >= 300 && actualPosition.y <= 310) {
				// If user scrolls down past "Drag To Dismiss"
				self.heavyImpact.impactOccurred()
				UIView.animate(withDuration: 0.45, animations: {
					self.dismissButton.setTitle("Release To Dismiss", for: .normal)
				})
			} else if (actualPosition.y <= 250) {
				// If scroll is idle
				UIView.animate(withDuration: 0.45, animations: {
					self.dismissButton.setTitle("Drag To Dismiss", for: .normal)
					self.dismissButton.alpha = 0
				})
			}
		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if scrollView.isAtTop {
			let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)

			if (actualPosition.y > 300) {
				// If user lifts finger after "Release To Dismiss" shows up
				self.heavyImpact.impactOccurred()
				self.dismiss(animated: true, completion: nil)
			} else if (actualPosition.y < 300) {
				// If user lifts finger before "Release To Dismiss" shows up
				self.lightImpact.impactOccurred()
				UIView.animate(withDuration: 0.45, animations: {
					self.dismissButton.alpha = 0
				})
			}
		}
	}

	func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {

		scrollToTop = true
	}
}

// MARK: - UITableViewDataSource
extension ShowDetailViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return showDetails != nil ? AnimeSection.allSections.count : 0
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		var numberOfRows = 0

		switch AnimeSection(rawValue: section)! {
		case .synopsis: numberOfRows = (showDetails?.synopsis != "") ? 1 : 0
		case .information: numberOfRows = (User.isAdmin() == true) ? 9 : 8
		case .cast:
			if let actorsCount = actors?.count, actorsCount <= 5 {
				numberOfRows = actorsCount
			} else if let actorsCount = actors?.count, actorsCount > 5 {
				numberOfRows = 6
			} else {
				numberOfRows = 0
			}
		}

		return numberOfRows
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var indexPath = indexPath

		switch AnimeSection(rawValue: indexPath.section)! {
		case .synopsis:
			let synopsisCell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! ShowSynopsisCell
			synopsisCell.synopsisTextView.attributedText = showDetails?.attributedSynopsis()
			synopsisCell.layoutIfNeeded()
			return synopsisCell
		case .information:
			let informationCell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! ShowDetailCell

			if let isAdmin = User.isAdmin(), isAdmin == false && indexPath.row == 0 {
				indexPath.row = 2
			}

			informationCell.titleLabel.theme_textColor = "Global.tintColor"
			informationCell.detailLabel.theme_textColor = "Global.textColor"

			switch indexPath.row {
			case 0:
				informationCell.titleLabel.text = "ID"
				if let showID = showDetails?.id, showID > 0 {
					informationCell.detailLabel.text = String(showID)
				} else {
					informationCell.detailLabel.text = "No show id found"
				}
			case 1:
				informationCell.titleLabel.text = "IMDB ID"
				if let imdbId = showDetails?.imdbId, imdbId != "" {
					informationCell.detailLabel.text = imdbId
				} else {
					informationCell.detailLabel.text = "No IMDB ID found"
				}
			case 2:
				informationCell.titleLabel.text = "Type"
				if let type = showDetails?.type, type != "" {
					informationCell.detailLabel.text = type
				} else {
					informationCell.detailLabel.text = "-"
				}
			case 3:
				informationCell.titleLabel.text = "Seasons"
				if let seasons = showDetails?.seasons, seasons > 0 {
					informationCell.detailLabel.text = seasons.description
				} else {
					informationCell.detailLabel.text = "-"
				}
			case 4:
				informationCell.titleLabel.text = "Episodes"
				if let episode = showDetails?.episodes, episode > 0 {
					informationCell.detailLabel.text = episode.description
				} else {
					informationCell.detailLabel.text = "-"
				}
			case 5:
				informationCell.titleLabel.text = "Aired"
				if let startDate = showDetails?.startDate, let endDate = showDetails?.endDate {
					informationCell.detailLabel.text = startDate.mediumDate() + " - " + endDate.mediumDate()
				} else {
					informationCell.detailLabel.text = "N/A - N/A"
				}
			case 6:
				informationCell.titleLabel.text = "Network"
				if let network = showDetails?.network, network != "" {
					informationCell.detailLabel.text = network
				} else {
					informationCell.detailLabel.text = "-"
				}
				//            case 6:
				//                cell.titleLabel.text = "Genres"
				//                if let genre = showDetails?.genre, genre != "" {
				//                    cell.detailLabel.text = genre
				//                } else {
				//                    cell.detailLabel.text = "-"
			//                }
			case 7:
				informationCell.titleLabel.text = "Duration"
				if let duration = showDetails?.runtime, duration > 0 {
					informationCell.detailLabel.text = "\(duration) min"
				} else {
					informationCell.detailLabel.text = "-"
				}
			case 8:
				informationCell.titleLabel.text = "Rating"
				if let watchRating = showDetails?.watchRating, watchRating != "" {
					informationCell.detailLabel.text = watchRating
				} else {
					informationCell.detailLabel.text = "-"
				}
				//            case 9:
				//                cell.titleLabel.text = "English Titles"
				//                if let englishTitle = showDetails?.englishTitles, englishTitle != "" {
				//         er           cell.detailLabel.text = englishTitle
				//                } else {
				//                    cell.detailLabel.text = "-"
				//                }
				//            case 10:
				//                cell.titleLabel.text = "Japanese Titles"
				//                if let japaneseTitle = showDetails?.japaneseTitles, japaneseTitle != "" {
				//                    cell.detailLabel.text = japaneseTitle
				//                } else {
				//                    cell.detailLabel.text = "-"
				//                }
				//            case 11:
				//                cell.titleLabel.text = "Synonyms"
				//                if let synonyms = showDetails?.synonyms, synonyms != "" {
				//                    cell.detailLabel.text = synonyms
				//                } else {
				//                    cell.detailLabel.text = "-"
			//                }
			default:
				break
			}
			informationCell.layoutIfNeeded()
			return informationCell
		case .cast:
			let castCell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCharacterCell

			// Actor name
			if let actorName = actors?[indexPath.row].name {
				castCell.actorName.text = actorName
				castCell.actorName.theme_textColor = "Global.tintColor"
			}

			// Actor role
			if let actorRole = actors?[indexPath.row].role {
				castCell.actorJob.text = actorRole
				castCell.actorJob.theme_textColor = "Global.textColor"
			}

			// Actor image view
			if let actorImage = actors?[indexPath.row].image, actorImage != "" {
				let actorImageUrl = URL(string: actorImage)
				let resource = ImageResource(downloadURL: actorImageUrl!)
				castCell.actorImageView.kf.indicatorType = .activity
				castCell.actorImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_person"), options: [.transition(.fade(0.2))])
			} else {
				castCell.actorImageView.image = #imageLiteral(resourceName: "placeholder_person")
			}

			// Add gesture to actors image view
			if castCell.actorImageView.gestureRecognizers?.count ?? 0 == 0 {
				// if the image currently has no gestureRecognizer
				let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showCast(_:)))
				castCell.actorImageView.addGestureRecognizer(tapGesture)
				castCell.actorImageView.isUserInteractionEnabled = true
			}

			// Show more button when casts exceed 5 rows
			if indexPath.row == 5 {
				let seeMoreCharactersCell: SeeMoreCharactersCell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell") as! SeeMoreCharactersCell

				seeMoreCharactersCell.moreButton.theme_backgroundColor = "Global.tintColor"
				seeMoreCharactersCell.moreButton.theme_setTitleColor("Global.textColor", forState: .normal)
				
				return seeMoreCharactersCell
			}

			castCell.layoutIfNeeded()
			return castCell
		}
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let showTitleCell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
		var title = ""

		switch AnimeSection(rawValue: section)! {
		case .synopsis:
			title = (showDetails?.synopsis != "") ? "Synopsis" : ""
		case .information:
			title = "Information"
		case .cast:
			guard let castCount = actors?.count else { return showTitleCell.contentView }
			title = (castCount != 0) ? "Actors" : ""
		}

		showTitleCell.titleLabel.text = title
		showTitleCell.titleLabel.theme_textColor = "Global.textColor"
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
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = AnimeSection(rawValue: indexPath.section)!
		tableView.deselectRow(at: indexPath, animated: true)

		switch section {
		case .synopsis: break
		case .information: break
		case .cast: break
		}
	}
}
