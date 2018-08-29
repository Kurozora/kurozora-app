//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit

class ShowDetailViewController: UIViewController {
    
    private var showDetails: ShowDetails?
    var show: Show?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet public weak var collectionView: UICollectionView!
    
    var loadingView: LoaderView!

    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var trailerButton: UIButton!
//    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var ranksView: UIView!

    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var scoreRankLabel: UILabel!
    @IBOutlet weak var popularityRankLabel: UILabel!
    @IBOutlet weak var posterImageView: CachedImageView!
    @IBOutlet weak var bannerImageView: CachedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
        
        // Prepare view for data
        loadingView = LoaderView(parentView: view)
        ranksView.isHidden = true

        // Fetch details
        if let id = show?.id {
            fetchShowDetailsFor(id) { (showDetails) in
                self.showDetails = showDetails
                self.tableView?.reloadData()
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Fetch show details
    private func fetchShowDetailsFor(_ id: Int, completionHandler: @escaping (ShowDetails) -> ()) {
        loadingView.startAnimating()
        
        let urlString = GlobalVariables().baseUrlString + "anime/\(id)/details"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let showDetails = try JSONDecoder().decode(ShowDetails.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(showDetails)
                }
            } catch let err{
                NSLog("------ DETAILS ERROR: \(err)")
            }
        }.resume()
    }
    
    // Update view with details
    func updateDetailWithShow(_ show: Show?) {
        if ((showDetails?.anime) != nil) && isViewLoaded {
            
            self.ranksView.isHidden = false
            
            if let progress = show?.progress {
                updateListButtonTitle(progress.list)
            } else {
                updateListButtonTitle(string: "Add to list ")
            }
            
            showTitle.text = show?.title
            tagsLabel.text = show.informationString()
            
            if let status = AnimeStatus(rawValue: (show?.status)!) {
                switch status {
                case .currentlyAiring:
                    etaLabel.text = "Airing    "
                    etaLabel.backgroundColor = UIColor.watching()
                case .finishedAiring:
                    etaLabel.text = "Aired    "
                    etaLabel.backgroundColor = UIColor.completed()
                case .notYetAired:
                    etaLabel.text = "Not Aired    "
                    etaLabel.backgroundColor = UIColor.planning()
                }
            }
            
            ratingLabel.text = String(format:"%.2f / %d", show?.membersScore, show?.progress?.score ?? 0)
            membersCountLabel.text = String(show?.membersCount)
            scoreRankLabel.text = "#\(show?.rank)"
            popularityRankLabel.text = "#\(show?.popularityRank)"
            
            posterImageView.loadImage(urlString: (show?.posterThumbnail)!)
            bannerImageView.loadImage(urlString: (show?.banner)!)
            
            if let youtubeID = show?.details.youtubeID, youtubeID.characters.count > 0 {
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
        
        var imageString = ""
        
        if let bannertUrl = show?.banner, bannertUrl.count != 0 {
            imageString = bannertUrl
        } else {
            imageString = (show?.posterThumbnail)!
        }
        
        guard let bannerUrl = NSURL(string: imageString) else {
            return
        }
        presentingViewController(bannerImageView, imageUrl: bannerUrl)
    }
    
    @IBAction func showPoster(sender: AnyObject) {
        
        let hdImage = show?.poster
        
        guard let posterUrl = NSURL(string: hdImage!) else {
            return
        }
        presentImageViewController(posterImageView, imageUrl: posterUrl)
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playTrailerPressed(sender: AnyObject) {
        
        if let trailerURL = show?.details.youtubeID {
//            playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: trailerURL)
//            presentMoviePlayerViewControllerAnimated(playerController)
        }
    }
}

extension AnimeInformationViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return show?.dataAvailable ? AnimeSection.allSections.count : 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        switch AnimeSection(rawValue: section)! {
        case .synopsis: numberOfRows = 1
        case .relations: numberOfRows = show?.relations.totalRelations
        case .information: numberOfRows = 11
        case .externalLinks: numberOfRows = show?.externalLinks.count
        }
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .synopsis:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SynopsisCell") as! SynopsisCell
            cell.synopsisLabel.attributedText = show?.details.attributedSynopsis()
            cell.layoutIfNeeded()
            return cell
        case .relations:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationCell
            let relation = show?.relations.relationAtIndex(indexPath.row)
            cell.titleLabel.text = relation.relationType.rawValue
            cell.detailLabel.text = relation.title
            cell.layoutIfNeeded()
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationCell
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Type"
                cell.detailLabel.text = show?.type
            case 1:
                cell.titleLabel.text = "Episodes"
                cell.detailLabel.text = (show?.episodes != 0) ? anime.episodes.description : "?"
            case 2:
                cell.titleLabel.text = "Status"
                cell.detailLabel.text = show?.status.capitalizedString
            case 3:
                cell.titleLabel.text = "Aired"
                let startDate = show?.startDate != nil && show?.startDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? show?.startDate!.mediumDate() : "?"
                let endDate = show?.endDate != nil && show?.endDate?.compare(Date(timeIntervalSince1970: 0)) != ComparisonResult.orderedAscending ? anime.endDate!.mediumDate() : "?"
                cell.detailLabel.text = "\(startDate) - \(endDate)"
            case 4:
                cell.titleLabel.text = "Producers"
                cell.detailLabel.text = show?.producers.joined(separator: ", ")
            case 5:
                cell.titleLabel.text = "Genres"
                cell.detailLabel.text = show?.genres.joined(separator: ", ")
            case 6:
                cell.titleLabel.text = "Duration"
                let duration = (anime.duration != 0) ? show?.duration.description : "?"
                cell.detailLabel.text = "\(duration) min"
            case 7:
                cell.titleLabel.text = "Classification"
                cell.detailLabel.text = show?.details.classification
            case 8:
                cell.titleLabel.text = "English Titles"
                cell.detailLabel.text = show?.details.englishTitles.count != 0 ? show?.details.englishTitles.joined(separator: "\n") : "-"
            case 9:
                cell.titleLabel.text = "Japanese Titles"
                cell.detailLabel.text = show?.details.japaneseTitles.count != 0 ? show?.details.japaneseTitles.joined(separator: "\n") : "-"
            case 10:
                cell.titleLabel.text = "Synonyms"
                cell.detailLabel.text = show?.details.synonyms.count != 0 ? show?.details.synonyms.joined(separator: "\n") : "-"
            default:
                break
            }
            cell.layoutIfNeeded()
            return cell
            
        case .ExternalLinks:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleLinkCell") as! SimpleLinkCell
            
            let link = show.linkAtIndex(indexPath.row)
            cell.linkLabel.text = link.site.rawValue
            switch link.site {
            case .crunchyroll:
                cell.linkLabel.backgroundColor = UIColor.crunchyroll()
            case .OfficialSite:
                cell.linkLabel.backgroundColor = UIColor.officialSite()
            case .daisuki:
                cell.linkLabel.backgroundColor = UIColor.daisuki()
            case .funimation:
                cell.linkLabel.backgroundColor = UIColor.funimation()
            case .myAnimeList:
                cell.linkLabel.backgroundColor = UIColor.myAnimeList()
            case .hummingbird:
                cell.linkLabel.backgroundColor = UIColor.hummingbird()
            case .kitsu:
                cell.linkLabel.backgroundColor = UIColor.hummingbird()
            case .anilist:
                cell.linkLabel.backgroundColor = UIColor.anilist()
            case .other:
                cell.linkLabel.backgroundColor = UIColor.other()
            }
            return cell
            
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
        var title = ""
        
        switch AnimeSection(rawValue: section)! {
        case .synopsis:
            title = "Synopsis"
        case .relations:
            title = "Relations"
        case .Information:
            title = "Information"
        case .externalLinks:
            title = "External Links"
        }
        
        cell.titleLabel.text = title
        return cell.contentView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 1
    }
    
}

extension AnimeInformationViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = AnimeSection(rawValue: indexPath.section)!
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch section {
            
        case .synopsis:
            let synopsisCell = tableView.cellForRow(at: indexPath) as! SynopsisCell
            synopsisCell.synopsisLabel.numberOfLines = (synopsisCell.synopsisLabel.numberOfLines == 8) ? 0 : 8
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            })
            
        case .relations:
            
            let relation = show?.relations.relationAtIndex(indexPath.row)
            // TODO: Parse is fetching again inside presenting AnimeInformationVC
            let query = show?.queryWith(malID: relation.animeID)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if let anime = objects?.first as? Anime {
                    self.subAnimator = self.presentAnimeModal(anime)
                }
            }
            
        case .information:break
        case .externalLinks:
            let link = show.linkAtIndex(indexPath.row)
            
            let (navController, webController) = KDatabaseKit.webViewController()
            let initialUrl = URL(string: link.url)
            webController.initWithInitialUrl(initialUrl)
            presentViewController(navController, animated: true, completion: nil)
        }
        
    }
}
