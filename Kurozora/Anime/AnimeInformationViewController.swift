//
//  AnimeInformationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import Shimmer
import KCommonKit
import KDatabaseKit
//import XCDYouTubeKit
//import FBSDKShareKit
//import Bolts
//import Parse

//enum AnimeSection: Int {
//    case Synopsis = 0
//    case Relations
//    case Information
//    case ExternalLinks
//
//    static var allSections: [AnimeSection] = [.Synopsis,.Relations,.Information,.ExternalLinks]
//}
//
//extension AnimeInformationViewController: StatusBarVisibilityProtocol {
//    func shouldHideStatusBar() -> Bool {
//        return hideStatusBar()
//    }
//    func updateCanHideStatusBar(canHide: Bool) {
//        canHideStatusBar = canHide
//    }
//}

//public class AnimeInformationViewController: AnimeBaseViewController {
//
//    let HeaderCellHeight: CGFloat = 39
//    var HeaderViewHeight: CGFloat = 0
//    let TopBarHeight: CGFloat = 44
//    let StatusBarHeight: CGFloat = 22
//
//    var canHideStatusBar = true
//    var subAnimator: ZFModalTransitionAnimator!
//    var playerController: XCDYouTubeVideoPlayerViewController?
//
//    @IBOutlet weak var listButton: UIButton!
//
//    override var anime: Anime! {
//        didSet {
//            updateInformationWithAnime()
//        }
//    }
//
//    var loadingView: LoaderView!
//
//    @IBOutlet weak var trailerButton: UIButton!
//    @IBOutlet weak var shimeringView: FBShimmeringView!
//    @IBOutlet weak var separatorView: UIView!
//    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var etaLabel: UILabel!
//    @IBOutlet weak var closeButton: UIButton!
//    @IBOutlet weak var ranksView: UIView!
//
//    @IBOutlet weak var animeTitle: UILabel!
//    @IBOutlet weak var tagsLabel: UILabel!
//    @IBOutlet weak var ratingLabel: UILabel!
//    @IBOutlet weak var membersCountLabel: UILabel!
//    @IBOutlet weak var scoreRankLabel: UILabel!
//    @IBOutlet weak var popularityRankLabel: UILabel!
//    @IBOutlet weak var posterImageView: UIImageView!
//    @IBOutlet weak var fanartImageView: UIImageView!
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        HeaderViewHeight = UIDevice.isPad() ? 400 : 274
//
//        shimeringView.contentView = animeTitle
//        shimeringView.shimmering = true
//
//        tableView.estimatedRowHeight = 44.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//        if UIDevice.isPad() {
//            let header = tableView.tableHeaderView!
//            var frame = header.frame
//            frame.size.height = 500 - 44 - 30
//            tableView.tableHeaderView?.frame = frame
//            view.insertSubview(tableView, belowSubview: fanartImageView)
//        }
//
//        loadingView = LoaderView(parentView: view)
//
//        ranksView.isHidden = true
//        fetchCurrentAnime()
//
//        // Video notifications
//        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(moviePlayerPlaybackDidFinish), name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        canHideStatusBar = true
//        self.scrollViewDidScroll(tableView)
//    }
//
//    func fetchCurrentAnime() {
//        loadingView.startAnimating()
//
//        let query = Anime.queryWith(objectID: anime.objectId!)
//        query.includeKey("details")
//        query.includeKey("relations")
//        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//
//            if let _ = error {
//
//            } else {
//                if let anime = objects?.first as? Anime {
//                    anime.progress = self.anime.progress
//                    self.anime = anime
//                }
//            }
//        }
//    }
//
//    func updateInformationWithAnime() {
//        if anime.details.dataAvailable && isViewLoaded() {
//
//            self.ranksView.isHidden = false
//
//            if let progress = anime.progress {
//                updateListButtonTitle(progress.list)
//            } else {
//                updateListButtonTitle(string: "Add to list ")
//            }
//
//            animeTitle.text = anime.title
//            tagsLabel.text = anime.informationString()
//
//            if let status = AnimeStatus(rawValue: anime.status) {
//                switch status {
//                case .CurrentlyAiring:
//                    etaLabel.text = "Airing    "
//                    etaLabel.backgroundColor = UIColor.watching()
//                case .FinishedAiring:
//                    etaLabel.text = "Aired    "
//                    etaLabel.backgroundColor = UIColor.completed()
//                case .NotYetAired:
//                    etaLabel.text = "Not Aired    "
//                    etaLabel.backgroundColor = UIColor.planning()
//                }
//            }
//
//            ratingLabel.text = String(format:"%.2f / %d", anime.membersScore, anime.progress?.score ?? 0)
//            membersCountLabel.text = String(anime.ratingCount)
//            scoreRankLabel.text = "#\(anime.rank)"
//            popularityRankLabel.text = "#\(anime.popularityRank)"
//
//            posterImageView.setImageFrom(urlString: anime.imageUrl)
//            fanartImageView.setImageFrom(urlString: anime.fanartURLString())
//
//            if let youtubeID = anime.details.youtubeID, youtubeID.characters.count > 0 {
//                trailerButton.isHidden = false
//                trailerButton.layer.borderWidth = 1.0;
//                trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
//            } else {
//                trailerButton.isHidden = true
//            }
//
//            loadingView.stopAnimating()
//            tableView.dataSource = self
//            tableView.delegate = self
//            tableView.reloadData()
//        }
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func showFanart(sender: AnyObject) {
//
//        var imageString = ""
//
//        if let fanartUrl = anime.fanart, fanartUrl.count != 0 {
//            imageString = fanartUrl
//        } else {
//            imageString = anime.imageUrl
//        }
//
//        guard let imageURL = NSURL(string: imageString) else {
//            return
//        }
//        presentingViewController(fanartImageView, imageUrl: imageURL)
//    }
//
//    @IBAction func showPoster(sender: AnyObject) {
//
//        let hdImage = anime.imageUrl.stringByReplacingOccurrencesOfString(".jpg", withString: "l.jpg")
//        guard let imageURL = NSURL(string: hdImage) else {
//            return
//        }
//        presentImageViewController(posterImageView, imageUrl: imageURL)
//    }
//
//
//    @IBAction func dismissViewController(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func playTrailerPressed(sender: AnyObject) {
//
//        if let trailerURL = anime.details.youtubeID {
//            playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: trailerURL)
//            presentMoviePlayerViewControllerAnimated(playerController)
//        }
//    }
//
//    @IBAction func addToListPressed(sender: AnyObject) {
//
//        let progress = anime.progress
//
//        var title: String = ""
//        if progress == nil {
//            title = "Add to list"
//        } else {
//            title = "Move to list"
//        }
//
//        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        alert.popoverPresentationController?.sourceView = listButton.superview
//        alert.popoverPresentationController?.sourceRect = listButton.frame
//
//        alert.addAction(UIAlertAction(title: "Watching", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            self.updateProgressWithList(list: .Watching)
//        }))
//        alert.addAction(UIAlertAction(title: "Planning", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            self.updateProgressWithList(list: .Planning)
//        }))
//        alert.addAction(UIAlertAction(title: "On-Hold", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            self.updateProgressWithList(list: .OnHold)
//        }))
//        alert.addAction(UIAlertAction(title: "Completed", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            self.updateProgressWithList(list: .Completed)
//        }))
//        alert.addAction(UIAlertAction(title: "Dropped", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            self.updateProgressWithList(list: .Dropped)
//        }))
//
//        if let progress = progress {
//            alert.addAction(UIAlertAction(title: "Remove from Library", style: UIAlertActionStyle.destructive, handler: { (alertAction: UIAlertAction!) -> Void in
//
//                self.loadingView.startAnimating()
//                let deleteFromMALTask = LibrarySyncController.deleteAnime(progress)
//                let deleteFromParseTask = progress.deleteInBackground()
//
//                BFTask(forCompletionOfAllTasks: [deleteFromMALTask, deleteFromParseTask]).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//                    self.loadingView.stopAnimating()
//                    self.anime.progress = nil
//
//                    NSNotificationCenter.default.postNotificationName(LibraryUpdatedNotification, object: nil)
//
//                    self.dismissViewControllerAnimated(true, completion: nil)
//
//                    return nil
//                })
//
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func updateProgressWithList(list: MALList) {
//
//        if let progress = anime.progress {
//            progress.updateList(list)
//            LibrarySyncController.updateAnime(progress)
//            progress.saveInBackgroundWithBlock({ (result, error) -> Void in
//                NSNotificationCenter.default.postNotificationName(LibraryUpdatedNotification, object: nil)
//            })
//            updateListButtonTitle(progress.list)
//
//        } else {
//
//            // Create!
//            let progress = AnimeProgress()
//            progress.anime = anime
//            progress.user = User.currentUser()!
//            progress.startDate = NSDate()
//            progress.updateList(list)
//            progress.watchedEpisodes = 0
//            progress.collectedEpisodes = 0
//            progress.score = 0
//
//            let query = AnimeProgress.query()!
//            query.whereKey("anime", equalTo: anime)
//            query.whereKey("user", equalTo: User.currentUser()!)
//            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//                if let _ = error {
//                    // Handle error
//                } else if let result = result as? [AnimeProgress], result.count == 0 {
//                    // Create AnimeProgress, if it's not on Parse
//                    LibrarySyncController.addAnime(progress)
//                    self.anime.progress = progress
//
//                    progress.saveInBackground().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
//
//                        NSNotificationCenter.default.postNotificationName(LibraryUpdatedNotification, object: nil)
//                        return nil
//                    })
//                    self.updateListButtonTitle(progress.list)
//                } else {
//                    self.presentBasicAlertWithTitle("Anime already in Library", message: "You might need to sync your library first, select 'Library' tab")
//                }
//            })
//        }
//    }
//
//    func updateListButtonTitle(string: String) {
//        listButton.setTitle(string + " " + FontAwesome.AngleDown.rawValue, for: .normal)
//    }
//
//    @IBAction func moreOptionsPressed(sender: AnyObject) {
//
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        alert.popoverPresentationController?.sourceView = sender.superview
//        alert.popoverPresentationController?.sourceRect = sender.frame
//
//        alert.addAction(UIAlertAction(title: "Rate anime", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//
//            if let progress = self.anime.progress, let tabBarController = self.tabBarController, let title = self.anime.title {
//                RateViewController.showRateDialogWith(tabBarController, title: "Rate \(title)", initialRating: Float(progress.score)/2.0, anime: self.anime, delegate: self)
//            } else {
//                let alert = UIAlertController(title: "Not saved", message: "Add the anime to your library first", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler:nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//
//        }))
//
//        if let _ = anime.nextEpisode {
//            let scheduledReminder = ReminderController.scheduledReminderFor(anime)
//            let remindersTitle = scheduledReminder == nil ? "Enable reminders" : "Disable reminders"
//            let actionStyle: UIAlertActionStyle = scheduledReminder == nil ? .Default : .Destructive
//            alert.addAction(UIAlertAction(title: remindersTitle, style: actionStyle, handler: { (alertAction: UIAlertAction!) -> Void in
//                if let _ = self.anime.progress, let _ = self.tabBarController, let _ = self.anime.title {
//                    if let _ = scheduledReminder {
//                        ReminderController.disableReminderForAnime(self.anime)
//                    } else {
//                        _ = ReminderController.scheduleReminderForAnime(self.anime)
//                    }
//                } else {
//                    let alert = UIAlertController(title: "Not saved", message: "Add the anime to your library first", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler:nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Refresh Images", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction!) -> Void in
//            let params = ["malID": self.anime.myAnimeListID]
//            PFCloud.callFunctionInBackground("updateAnimeInformation", withParameters: params, block: { (result, error) -> Void in
//                self.presentBasicAlertWithTitle("Refreshing..", message: "Data will be refreshed soon")
//                print("Refreshed!!")
//            })
//        }))
//
//        alert.addAction(UIAlertAction(title: "Send on Messenger", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//
//            let photo = FBSDKSharePhoto()
//            photo.image = self.fanartImageView.image
//
//            let content = FBSDKSharePhotoContent()
//            content.photos = [photo]
//
//            FBSDKMessageDialog.showWithContent(content, delegate: nil)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//
//            let photo = FBSDKSharePhoto()
//            photo.image = self.fanartImageView.image
//
//            let content = FBSDKSharePhotoContent()
//            content.photos = [photo]
//
//            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//
//            var textToShare = ""
//
//            if let progress = self.anime.progress {
//
//                switch progress.myAnimeListList() {
//                case .Planning:
//                    textToShare += "I'm planning to watch"
//                case .Watching:
//                    textToShare += "I'm watching"
//                case .Completed:
//                    textToShare += "I've completed"
//                case .Dropped:
//                    textToShare += "I've dropped"
//                case .OnHold:
//                    textToShare += "I'm watching"
//                }
//                textToShare += " \(self.anime.title!) via #AozoraApp"
//            } else {
//                textToShare = "Check out \(self.anime.title!) via #AozoraApp"
//            }
//
//
//            var objectsToShare: [AnyObject] = [textToShare as AnyObject]
//            if let image = self.fanartImageView.image {
//                objectsToShare.append( image )
//            }
//
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList,UIActivityType.print];
//            self.present(activityVC, animated: true, completion: nil)
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
//
//        self.present(alert, animated: true, completion: nil)
//
//    }
//    // MARK: - Helper Functions
//
//    func hideStatusBar() -> Bool {
//        let offset = HeaderViewHeight - self.scrollView().contentOffset.y - TopBarHeight
//        return offset > StatusBarHeight ? true : false
//    }
//
//    // MARK: - Notifications
//
//    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
//        playerController = nil;
//    }
//
//
//}
//
//extension AnimeInformationViewController: UIScrollViewDelegate {
//    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let newOffset = HeaderViewHeight-scrollView.contentOffset.y
//        let topBarOffset = newOffset - TopBarHeight
//
//        if topBarOffset > StatusBarHeight {
//            if !UIApplication.shared.isStatusBarHidden {
//                if canHideStatusBar {
//                    UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
//                    separatorView.isHidden = true
//                    closeButton.isHidden = true
//                    navigationBarHeightConstraint.constant = TopBarHeight
//                }
//            }
//            navigationBarTopConstraint.constant = topBarOffset
//        } else {
//            if UIApplication.shared.isStatusBarHidden {
//                UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
//            }
//            separatorView.isHidden = false
//            closeButton.isHidden = false
//            let totalHeight = TopBarHeight + StatusBarHeight
//            if totalHeight - topBarOffset <= totalHeight {
//                navigationBarHeightConstraint.constant = totalHeight - topBarOffset
//                navigationBarTopConstraint.constant = topBarOffset
//            } else {
//                navigationBarHeightConstraint.constant = totalHeight
//                navigationBarTopConstraint.constant = 0
//            }
//        }
//    }
//}
//
//extension AnimeInformationViewController: UITableViewDataSource {
//
//    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return anime.dataAvailable ? AnimeSection.allSections.count : 0
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        var numberOfRows = 0
//        switch AnimeSection(rawValue: section)! {
//        case .Synopsis: numberOfRows = 1
//        case .Relations: numberOfRows = anime.relations.totalRelations
//        case .Information: numberOfRows = 11
//        case .ExternalLinks: numberOfRows = anime.externalLinks.count
//        }
//
//        return numberOfRows
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch AnimeSection(rawValue: indexPath.section)! {
//        case .Synopsis:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SynopsisCell") as! SynopsisCell
//            cell.synopsisLabel.attributedText = anime.details.attributedSynopsis()
//            cell.layoutIfNeeded()
//            return cell
//        case .Relations:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationCell
//            let relation = anime.relations.relationAtIndex(indexPath.row)
//            cell.titleLabel.text = relation.relationType.rawValue
//            cell.detailLabel.text = relation.title
//            cell.layoutIfNeeded()
//            return cell
//        case .Information:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationCell
//
//            switch indexPath.row {
//            case 0:
//                cell.titleLabel.text = "Type"
//                cell.detailLabel.text = anime.type
//            case 1:
//                cell.titleLabel.text = "Episodes"
//                cell.detailLabel.text = (anime.episodes != 0) ? anime.episodes.description : "?"
//            case 2:
//                cell.titleLabel.text = "Status"
//                cell.detailLabel.text = anime.status.capitalizedString
//            case 3:
//                cell.titleLabel.text = "Aired"
//                let startDate = anime.startDate != nil && anime.startDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? anime.startDate!.mediumDate() : "?"
//                let endDate = anime.endDate != nil && anime.endDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? anime.endDate!.mediumDate() : "?"
//                cell.detailLabel.text = "\(startDate) - \(endDate)"
//            case 4:
//                cell.titleLabel.text = "Producers"
//                cell.detailLabel.text = anime.producers.joined(separator: ", ")
//            case 5:
//                cell.titleLabel.text = "Genres"
//                cell.detailLabel.text = anime.genres.joined(separator: ", ")
//            case 6:
//                cell.titleLabel.text = "Duration"
//                let duration = (anime.duration != 0) ? anime.duration.description : "?"
//                cell.detailLabel.text = "\(duration) min"
//            case 7:
//                cell.titleLabel.text = "Classification"
//                cell.detailLabel.text = anime.details.classification
//            case 8:
//                cell.titleLabel.text = "English Titles"
//                cell.detailLabel.text = anime.details.englishTitles.count != 0 ? anime.details.englishTitles.joined(separator: "\n") : "-"
//            case 9:
//                cell.titleLabel.text = "Japanese Titles"
//                cell.detailLabel.text = anime.details.japaneseTitles.count != 0 ? anime.details.japaneseTitles.joined(separator: "\n") : "-"
//            case 10:
//                cell.titleLabel.text = "Synonyms"
//                cell.detailLabel.text = anime.details.synonyms.count != 0 ? anime.details.synonyms.joined(separator: "\n") : "-"
//            default:
//                break
//            }
//            cell.layoutIfNeeded()
//            return cell
//
//        case .ExternalLinks:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleLinkCell") as! SimpleLinkCell
//
//            let link = anime.linkAtIndex(indexPath.row)
//            cell.linkLabel.text = link.site.rawValue
//            switch link.site {
//            case .Crunchyroll:
//                cell.linkLabel.backgroundColor = UIColor.crunchyroll()
//            case .OfficialSite:
//                cell.linkLabel.backgroundColor = UIColor.officialSite()
//            case .Daisuki:
//                cell.linkLabel.backgroundColor = UIColor.daisuki()
//            case .Funimation:
//                cell.linkLabel.backgroundColor = UIColor.funimation()
//            case .MyAnimeList:
//                cell.linkLabel.backgroundColor = UIColor.myAnimeList()
//            case .Hummingbird:
//                cell.linkLabel.backgroundColor = UIColor.hummingbird()
//            case .Anilist:
//                cell.linkLabel.backgroundColor = UIColor.anilist()
//            case .Other:
//                cell.linkLabel.backgroundColor = UIColor.other()
//            }
//            return cell
//
//        }
//    }
//
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
//        var title = ""
//
//        switch AnimeSection(rawValue: section)! {
//        case .Synopsis:
//            title = "Synopsis"
//        case .Relations:
//            title = "Relations"
//        case .Information:
//            title = "Information"
//        case .ExternalLinks:
//            title = "External Links"
//        }
//
//        cell.titleLabel.text = title
//        return cell.contentView
//    }
//
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 1
//    }
//
//}
//
//extension AnimeInformationViewController: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let section = AnimeSection(rawValue: indexPath.section)!
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        switch section {
//
//        case .Synopsis:
//            let synopsisCell = tableView.cellForRow(at: indexPath) as! SynopsisCell
//            synopsisCell.synopsisLabel.numberOfLines = (synopsisCell.synopsisLabel.numberOfLines == 8) ? 0 : 8
//
//            UIView.animate(withDuration: 0.25, animations: { () -> Void in
//                tableView.beginUpdates()
//                tableView.endUpdates()
//            })
//
//        case .Relations:
//
//            let relation = anime.relations.relationAtIndex(indexPath.row)
//            // TODO: Parse is fetching again inside presenting AnimeInformationVC
//            let query = Anime.queryWith(malID: relation.animeID)
//            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//                if let anime = objects?.first as? Anime {
//                    self.subAnimator = self.presentAnimeModal(anime)
//                }
//            }
//
//        case .Information:break
//        case .ExternalLinks:
//            let link = anime.linkAtIndex(indexPath.row)
//
//            let (navController, webController) = KDatabaseKit.webViewController()
//            let initialUrl = URL(string: link.url)
//            webController.initWithInitialUrl(initialUrl)
//            presentViewController(navController, animated: true, completion: nil)
//        }
//
//    }
//}
//
//extension AnimeInformationViewController: RateViewControllerProtocol {
//
//    public func rateControllerDidFinishedWith(anime: Anime, rating: Float) {
//
//        RateViewController.updateAnime(anime, withRating: rating*2.0)
//        updateInformationWithAnime()
//    }
//}
