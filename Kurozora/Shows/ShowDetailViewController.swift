//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import Kingfisher
import SCLAlertView
import BottomPopup
import Cosmos

enum AnimeSection: Int {
    case synopsis
    case information
    case cast

    static var allSections: [AnimeSection] = [.synopsis, .information, .cast]
}

class ShowDetailViewController: UIViewController, ShowRatingDelegate {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Compact detail vars
    let headerHeightInSection: CGFloat = 40
    var headerViewHeight: CGFloat = 470
    let compactDetailsHeight: CGFloat = 88

    // View vars
    var headerView: UIView!
    var loadingView: LoaderView!
    var window: UIWindow?
    
    var showDetails: ShowDetails?
    var showId: Int?
    var showRating: Double?
    var castDetails: [JSON]?
    var cast: CastDetails?

    // MARK: - IBoutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    // Compact detail view
    @IBOutlet weak var compactDetailsView: UIView!
    @IBOutlet weak var compactShowTitleLabel: UILabel!
    @IBOutlet weak var compactTagsLabel: UILabel!
    
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
    @IBOutlet weak var scoreRankLabel: UILabel!
    @IBOutlet weak var popularityRankLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    
    func getRating(value: Double?) {
        if let rating = value {
            self.cosmosView.rating = rating
            self.cosmosView.update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Prepare view for data
        loadingView = LoaderView(parentView: view)
        loadingView.startAnimating()

        // Fetch details
        if let id = showId {
            KCommonKit.shared.showId = id
            
            Service.shared.getDetailsFor(id) { (showDetails) in
                self.showDetails = showDetails
                self.updateDetailWithShow(self.showDetails)
                self.tableView.reloadData()
            }
            
            Service.shared.getCastFor(id, withSuccess: { (cast, castActors) in
                self.cast = cast
                self.castDetails = cast.actors
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }) { (errorMessage) in
                SCLAlertView().showError("Can't get cast details", subTitle: errorMessage)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollViewDidScroll(tableView)
    }

    // MARK: - IBAction
    @IBAction func favoriteBtnPressed(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func showRating(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController
        vc?.showDetails = showDetails
        vc?.delegate = self
        vc?.modalTransitionStyle = .crossDissolve
        vc?.modalPresentationStyle = .overCurrentContext
        self.present(vc!, animated: true, completion: nil)
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

	@IBAction func chooseStatusButton(_ sender: AnyObject) {
		let selectedList = "watching" //update this for selected value
		let action = UIAlertController.actionSheetWithItems(items: [("Watching","watching"),("Completed","completed"),("Dropped","dropped")], currentSelection: selectedList, action: { (value)  in
			guard let showId = self.showId else {return}

			Service.shared.addLibraryFor(status: value.lowercased(), showId: showId, withSuccess: { (success) in
				if !success {
					SCLAlertView().showError("Error adding to library", subTitle: "There was an error while adding this anime to your library. Please try again!")
				}
			}, andFailure: { (errorMessage) in
				SCLAlertView().showError("Can't add to library", subTitle: errorMessage)
			})
		})
		action.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.present(action, animated: true, completion: nil)
	}

	// Update view with details
    func updateDetailWithShow(_ show: ShowDetails?) {
        if showDetails != nil {
//            if let progress = show?.progress {
//                updateListButtonTitle(progress.list)
//            } else {
//                updateListButtonTitle(string: "Add to list ")
//           }

            // Configure title label
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
            if let averageRating = showDetails?.averageRating, averageRating > 0.00 {
                ratingLabel.text = String(format:"%.2f / %d", averageRating, /*show?.progress?.score ??*/ 5.00)
            } else {
                ratingLabel.text = "Not enough ratings"
            }

            if let ratingCount = showDetails?.ratingCount, ratingCount > 0 {
                membersCountLabel.text = String(ratingCount)
            } else {
                membersCountLabel.text = "-"
            }
            
            // Configure rank label
            if let scoreRank = showDetails?.rank, scoreRank > 0 {
                scoreRankLabel.text = String(scoreRank)
            } else {
                scoreRankLabel.text = "-"
            }

            if let popularRank = showDetails?.popularityRank, popularRank > 0 {
                popularityRankLabel.text = String(popularRank)
            } else {
                popularityRankLabel.text = "-"
            }

            if let posterThumb = showDetails?.posterThumbnail, posterThumb != "" {
                let posterThumb = URL(string: posterThumb)
                let resource = ImageResource(downloadURL: posterThumb!)
                posterImageView.kf.indicatorType = .activity
                posterImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                posterImageView.image = UIImage(named: "placeholder_poster")
            }

            if let bannerImage = showDetails?.banner, bannerImage != "" {
                let bannerImage = URL(string: bannerImage)
                let resource = ImageResource(downloadURL: bannerImage!)
                bannerImageView.kf.indicatorType = .activity
                bannerImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                bannerImageView.image = UIImage(named: "placeholder_banner")
            }

            if let youtubeID = showDetails?.youtubeId, youtubeID.count > 0 {
                trailerButton.isHidden = false
                trailerButton.layer.borderWidth = 1.0;
                trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
            } else {
                trailerButton.isHidden = true
            }
        }
        
        // Stop loaderview
        loadingView.stopAnimating()
    }
    
    // MARK: - Functions
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
    
    func addBottomSheetView() {
        let storyboard:UIStoryboard? = UIStoryboard(name: "details", bundle: nil)
         guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "Actors") as? CastTableViewController else { return }
         present(popupVC, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func showBanner(_ sender: AnyObject) {
        if let banner = showDetails?.banner, banner != "" {
            presentPhotoViewControllerWith(url: banner)
        } else {
            presentPhotoViewControllerWith(string: "placeholder_banner")
        }
    }
    
    @IBAction func cellTapped(_ tap: UITapGestureRecognizer) {
        let cell = tap.view as? ShowCharacterCell
        let pointInCell: CGPoint = tap.location(in: cell?.contentView)
        let view: UIView? = cell?.contentView.hitTest(pointInCell, with: nil)
        let pointInTable = tap.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: pointInTable) {
            if (self.tableView.cellForRow(at: indexPath) as? ShowCharacterCell) != nil {
                if view == cell?.actorImageView {
                    if let imageUrl = castDetails?[indexPath.row]["image"].stringValue, imageUrl != "" {
                        presentPhotoViewControllerWith(url: imageUrl)
                    } else {
                        presentPhotoViewControllerWith(string: "placeholder_person")
                    }
                }
            }
        }
    }
    
    @IBAction func showPoster(_ sender: AnyObject) {
        if let poster = showDetails?.poster, poster != "" {
            presentPhotoViewControllerWith(url: poster)
        } else {
            presentPhotoViewControllerWith(string: "placeholder_poster")
        }
    }

    @IBAction func playTrailerPressed(sender: AnyObject) {
//        if let trailerURL = showDetails?.youtubeId {
////            presentLightboxViewController(imageUrl: "", text: "", videoUrl: trailerURL)
//        }
    }
    
    @IBAction func showCastDrawer(_ sender: Any) {
        addBottomSheetView()
    }
}

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
    }
}

extension ShowDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return showDetails != nil ? AnimeSection.allSections.count : 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        switch AnimeSection(rawValue: section)! {
        case .synopsis: numberOfRows = 1
        case .information: numberOfRows = (User.isAdmin() == true) ? 8 : 7
        case .cast:
            if let actorsCount = castDetails?.count, actorsCount <= 5 {
                numberOfRows = actorsCount
            } else if let actorsCount = castDetails?.count, actorsCount > 5 {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! ShowSynopsisCell
            cell.synopsisTextView.attributedText = showDetails?.attributedSynopsis()
            cell.layoutIfNeeded()
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! ShowDetailCell
            
            if let isAdmin = User.isAdmin(), isAdmin == false && indexPath.row == 0 {
                indexPath.row = 1
            }

            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "ID"
                if let id = showDetails?.id, id > 0 {
                    cell.detailLabel.text = String(id)
                } else {
                    cell.detailLabel.text = "Error getting id"
                }
            case 1:
                cell.titleLabel.text = "Type"
                if let type = showDetails?.type, type != "" {
                    cell.detailLabel.text = type
                } else {
                    cell.detailLabel.text = "-"
                }
            case 2:
                cell.titleLabel.text = "Seasons"
                if let seasons = showDetails?.seasons, seasons > 0 {
                    cell.detailLabel.text = seasons.description
                } else {
                    cell.detailLabel.text = "-"
                }
            case 3:
                cell.titleLabel.text = "Episodes"
                if let episode = showDetails?.episodes, episode > 0 {
                    cell.detailLabel.text = episode.description
                } else {
                    cell.detailLabel.text = "-"
                }
            case 4:
                cell.titleLabel.text = "Aired"
                if let startDate = showDetails?.startDate, let endDate = showDetails?.endDate {
                    cell.detailLabel.text = startDate.mediumDate() + " - " + endDate.mediumDate()
                } else {
                    cell.detailLabel.text = "N/A - N/A"
                }
            case 5:
                cell.titleLabel.text = "Network"
                if let network = showDetails?.network, network != "" {
                    cell.detailLabel.text = network
                } else {
                    cell.detailLabel.text = "-"
                }
//            case 6:
//                cell.titleLabel.text = "Genres"
//                if let genre = showDetails?.genre, genre != "" {
//                    cell.detailLabel.text = genre
//                } else {
//                    cell.detailLabel.text = "-"
//                }
            case 6:
                cell.titleLabel.text = "Duration"
                if let duration = showDetails?.runtime, duration > 0 {
                    cell.detailLabel.text = "\(duration) min"
                } else {
                    cell.detailLabel.text = "-"
                }
            case 7:
                cell.titleLabel.text = "Rating"
                if let watchRating = showDetails?.watchRating, watchRating != "" {
                    cell.detailLabel.text = watchRating
                } else {
                    cell.detailLabel.text = "-"
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
            cell.layoutIfNeeded()
            return cell
        case .cast:
            let castCell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCharacterCell
            
            if let actorName = castDetails?[indexPath.row]["name"] {
                castCell.actorName.text = actorName.stringValue
            }
            
            if let actorRole = castDetails?[indexPath.row]["role"] {
                castCell.actorJob.text = actorRole.stringValue
            }

            if let castImage = castDetails?[indexPath.row]["image"].stringValue {
                let castImage = URL(string: castImage)
                let resource = ImageResource(downloadURL: castImage!)
                castCell.actorImageView.kf.indicatorType = .activity
                castCell.actorImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_person"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            }
            
            if indexPath.row == 5 {
                let moreCell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell")!
                return moreCell
            }
            
            castCell.layoutIfNeeded()
            return castCell
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
        var title = ""

        switch AnimeSection(rawValue: section)! {
        case .synopsis:
            title = "Synopsis"
        case .information:
            title = "Information"
        case .cast:
            title = "Actors"
        }

        cell.titleLabel.text = title
        return cell.contentView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? headerHeightInSection : 1
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
