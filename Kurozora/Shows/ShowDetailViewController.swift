//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit

enum AnimeSection: Int {
    case synopsis = 0
//    case relations
    case information
//    case externalLinks

    static var allSections: [AnimeSection] = [.synopsis, /*.relations,*/ .information/*, .externalLinks*/]
}

class ShowDetailViewController: UIViewController {
    
    let HeaderCellHeight: CGFloat = 39
    var loadingView: LoaderView!
    var window: UIWindow?
    
    private var showDetails: ShowDetails?
    var show: Show?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet public weak var collectionView: UICollectionView!
    
    // MARK: - IBoutlet
//    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var separatorView: UIView!
//    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    // Compact detail view
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    // Action buttons
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    
    // Quick details view
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var scoreRankLabel: UILabel!
    @IBOutlet weak var popularityRankLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
//        tableView?.delegate = self
//        tableView?.dataSource = self
        
        // Prepare view for data
        loadingView = LoaderView(parentView: view)

        // Fetch details
        if let id = show?.id {
            fetchShowDetailsFor(id) { (showDetails) in
                NSLog("--------------- FETCH DETAILS -------------")
                NSLog("--------------- \(showDetails) -------------")
                
                self.updateDetailWithShow(self.show)
                self.showDetails = showDetails
                self.tableView?.reloadData()
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction
    
    @IBAction func showRating(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController
        vc?.modalTransitionStyle = .crossDissolve
        vc?.modalPresentationStyle = .overCurrentContext
        self.present(vc!, animated: true, completion: nil)
    }
    
    // Fetch show details
    private func fetchShowDetailsFor(_ id: Int, completionHandler: @escaping (ShowDetails) -> ()) {
        loadingView.startAnimating()
        
        NSLog("--------------- LOADING -------------")
        
        let urlString = GlobalVariables().baseUrlString + "anime/\(id)/details"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let showDetails = try JSONDecoder().decode(ShowDetails.self, from: data)
                
                NSLog("--------------- DECODING -------------")
                NSLog("--------------- \(showDetails) -------------")
                DispatchQueue.main.async {
                    NSLog("--------------- DISPATCHED -------------")
                    completionHandler(showDetails)
                }
            } catch let err{
                NSLog("------ DETAILS ERROR: \(err)")
            }
        }.resume()
    }
    
    // Update view with details
    func updateDetailWithShow(_ show: Show?) {
        
        NSLog("--------------- about to succeeded -------------")
        NSLog("--------------- \(String(describing: show)) -------------")
        if show != nil {
            
            NSLog("--------------- If succeeded -------------")
            NSLog("--------------- \(String(describing: showDetails?.anime)) -------------")
            
//            if let progress = show?.progress {
//                updateListButtonTitle(progress.list)
//            } else {
//                updateListButtonTitle(string: "Add to list ")
//            }
            
            // Configure title label
            if let title = show?.title {
                showTitleLabel.text = title
            } else {
                showTitleLabel.text = "Unknown"
            }
            
            // Configure tags label
            if let tags = show?.informationString() {
                tagsLabel.text = tags
            } else {
                tagsLabel.text = "Unknown · N/A · 0 eps · 0 min · 0000"
            }
            
            // Configure status label
            if let status = AnimeStatus(rawValue: "not yet aired" /*(show?.status)!*/) {
                switch status {
                case .currentlyAiring:
                    statusLabel.text = "Airing"
                    statusLabel.backgroundColor = UIColor.watching()
                case .finishedAiring:
                    statusLabel.text = "Aired"
                    statusLabel.backgroundColor = UIColor.completed()
                case .notYetAired:
                    statusLabel.text = "Not Aired"
                    statusLabel.backgroundColor = UIColor.planning()
                }
            }
        
            // Configure ratings label
            ratingLabel.text = String(format:"%.2f / %d", (show?.averageRating)!, /*show?.progress?.score ??*/ 5)
            if let ratingCount = show?.ratingCount {
                membersCountLabel.text = String(ratingCount)
            } else {
                membersCountLabel.text = "0"
            }
            
            // Configure rank label
            if let scoreRank = show?.rank {
                scoreRankLabel.text = String(scoreRank)
            } else {
                scoreRankLabel.text = "0"
            }
            
            if let popularRank = show?.popularityRank {
                popularityRankLabel.text = String(popularRank)
            } else {
                popularityRankLabel.text = "9999"
            }
            
            if let posterThumb = show?.posterThumbnail {
                do {
                    let url = URL(string: posterThumb)
                    let data = try Data(contentsOf: url!)
                    self.posterImageView.image = UIImage(data: data)
                }
                catch{
                    print(error)
                }
            } else {
                posterImageView.image = UIImage(named: "colorful")
            }
            
            if let bannerImage = show?.banner {
                do {
                    let url = URL(string: bannerImage)
                    let data = try Data(contentsOf: url!)
                    self.bannerImageView.image = UIImage(data: data)
                }
                catch{
                    print(error)
                }
            } else {
                bannerImageView.image = UIImage(named: "aozora")
            }
            
            if let youtubeID = show?.youtubeId, youtubeID.count > 0 {
                trailerButton.isHidden = false
                trailerButton.layer.borderWidth = 1.0;
                trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
            } else {
                trailerButton.isHidden = true
            }
            
            loadingView.stopAnimating()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func showBanner(sender: AnyObject) {
        var bannerUrl: String?
        
        if let banner = show?.banner {
            bannerUrl = banner
        } else {
            bannerUrl = show?.bannerThumbnail
        }
        
        presentLightboxViewController(imageUrl: bannerUrl, text: "", videoUrl: "")
    }
    
    @IBAction func showPoster(sender: AnyObject) {
        var posterUrl: String?
        
        if let poster = show?.poster {
            posterUrl = poster
        } else {
            posterUrl = show?.posterThumbnail
        }
        
        presentLightboxViewController(imageUrl: posterUrl, text: "", videoUrl: "")
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playTrailerPressed(sender: AnyObject) {
        if let trailerURL = show?.youtubeId {
            presentLightboxViewController(imageUrl: "", text: "", videoUrl: trailerURL)
        }
    }
}

extension ShowDetailViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return show != nil ? AnimeSection.allSections.count : 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        switch AnimeSection(rawValue: section)! {
        case .synopsis: numberOfRows = 1
//        case .relations: numberOfRows = show?.relations.totalRelations
        case .information: numberOfRows = 11
//        case .externalLinks: numberOfRows = (show?.externalLinks?.count)!
        }
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .synopsis:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! ShowSynopsisCell
            cell.synopsisLabel.attributedText = show?.attributedSynopsis()
            cell.layoutIfNeeded()
            return cell
//        case .relations:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! ShowDetailCell
//            let relation = show?.relations.relationAtIndex(indexPath.row)
//            cell.titleLabel.text = relation.relationType.rawValue
//            cell.detailLabel.text = relation.title
//            cell.layoutIfNeeded()
//            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! ShowDetailCell

            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Type"
                cell.detailLabel.text = show?.type
            case 1:
                cell.titleLabel.text = "Episodes"
                cell.detailLabel.text = (show?.episodes != 0) ? show?.episodes?.description : "?"
            case 2:
                cell.titleLabel.text = "Status"
                cell.detailLabel.text = show?.status?.capitalized
            case 3:
                cell.titleLabel.text = "Aired"
                let startDate = show?.startDate != nil && show?.startDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? show?.startDate!.mediumDate() : "?"
                let endDate = show?.endDate != nil && show?.endDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? show?.endDate!.mediumDate() : "?"
                cell.detailLabel.text = "\(startDate ?? "N/A") - \(endDate ?? "N/A")"
            case 4:
                cell.titleLabel.text = "Producers"
                cell.detailLabel.text = show?.producers
            case 5:
                cell.titleLabel.text = "Genres"
                cell.detailLabel.text = show?.genre
            case 6:
                cell.titleLabel.text = "Duration"
                let duration = (show?.runtime != 0) ? show?.runtime : 0
                cell.detailLabel.text = "\(String(describing: duration)) min"
            case 7:
                cell.titleLabel.text = "Classification"
                cell.detailLabel.text = show?.type
            case 8:
                cell.titleLabel.text = "English Titles"
                cell.detailLabel.text = (show?.englishTitles?.count)! != 0 ? show?.englishTitles : "-"
            case 9:
                cell.titleLabel.text = "Japanese Titles"
                cell.detailLabel.text = (show?.japaneseTitles?.count)! != 0 ? show?.japaneseTitles : "-"
            case 10:
                cell.titleLabel.text = "Synonyms"
                cell.detailLabel.text = (show?.synonyms?.count)! != 0 ? show?.synonyms : "-"
            default:
                break
            }
            cell.layoutIfNeeded()
            return cell
            
//        case .externalLinks:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowLinkCell") as! ShowLinkCell
//
//            let link = show?.linkAtIndex(indexPath.row)
//            cell.linkLabel.text = link.site.rawValue
//            switch link.site {
//            case .crunchyroll:
//                cell.linkLabel.backgroundColor = UIColor.crunchyroll()
//            case .OfficialSite:
//                cell.linkLabel.backgroundColor = UIColor.officialSite()
//            case .daisuki:
//                cell.linkLabel.backgroundColor = UIColor.daisuki()
//            case .funimation:
//                cell.linkLabel.backgroundColor = UIColor.funimation()
//            case .myAnimeList:
//                cell.linkLabel.backgroundColor = UIColor.myAnimeList()
//            case .hummingbird:
//                cell.linkLabel.backgroundColor = UIColor.hummingbird()
//            case .kitsu:
//                cell.linkLabel.backgroundColor = UIColor.hummingbird()
//            case .anilist:
//                cell.linkLabel.backgroundColor = UIColor.anilist()
//            case .other:
//                cell.linkLabel.backgroundColor = UIColor.other()
//            }
//            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleCell") as! ShowTitleCell
        var title = ""

        switch AnimeSection(rawValue: section)! {
        case .synopsis:
            title = "Synopsis"
//        case .relations:
//            title = "Relations"
        case .information:
            title = "Information"
//        case .externalLinks:
//            title = "External Links"
        }
        
        cell.titleLabel.text = title
        return cell.contentView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 1
    }
}

extension ShowDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = AnimeSection(rawValue: indexPath.section)!
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch section {
        case .synopsis:
            let synopsisCell = tableView.cellForRow(at: indexPath) as! ShowSynopsisCell
            synopsisCell.synopsisLabel.numberOfLines = (synopsisCell.synopsisLabel.numberOfLines == 8) ? 0 : 8
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            })
//        case .relations:
//            let relation = show?.relations.relationAtIndex(indexPath.row)
//            // TODO: Parse is fetching again inside presenting AnimeInformationVC
//            let query = show?.queryWith(malID: relation.animeID)
//            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//                if let anime = objects?.first as? Anime {
//                    self.subAnimator = self.presentAnimeModal(anime)
//                }
//            }
        case .information: break
//        case .externalLinks:
//            let link = show.linkAtIndex(indexPath.row)
//
//            let (navController, webController) = KDatabaseKit.webViewController()
//            let initialUrl = URL(string: link.url)
//            webController.initWithInitialUrl(initialUrl)
//            presentViewController(navController, animated: true, completion: nil)
        }
    }
}
