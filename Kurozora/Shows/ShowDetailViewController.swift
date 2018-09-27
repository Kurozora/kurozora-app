//
//  ShowDetailViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit
import TRON
import SwiftyJSON
import Kingfisher
import SCLAlertView

enum AnimeSection: Int {
    case synopsis
    case information
    case cast

    static var allSections: [AnimeSection] = [.synopsis, .information, .cast]
}

class ShowDetailViewController: UIViewController {

    let tron = TRON(baseURL: "https://kurozora.app/api/v1/")

    let HeaderCellHeight: CGFloat = 39
    var loadingView: LoaderView!
    var window: UIWindow?

    let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView

    var showDetails: ShowDetails?
    var show: Show?
    var castDetails: [JSON]?

    @IBOutlet weak var tableView: UITableView!

    // MARK: - IBoutlet
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

    @IBAction func favoriteBtnPressed(_ sender: Any) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)

        // Prepare view for data
        loadingView = LoaderView(parentView: view)

        // Fetch details
        if let id = show?.id {
            fetchShowDetailsFor(id) { (showDetails) in
                self.showDetails = showDetails
                self.updateDetailWithShow(self.showDetails)
                self.tableView.reloadData()
            }

            Service.shared.getCastFor(id, withSuccess: { (cast) in
                self.castDetails = cast
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }) { (errorMsg) in
                SCLAlertView().showError("Can't get cast details", subTitle: "There was an error while retrieving cast details. Please check your internet connection and refresh this page.")
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statusBar.isHidden = true
    }

    // MARK: - IBAction

    @IBAction func showRating(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController
        vc?.showDetails = showDetails
        vc?.modalTransitionStyle = .crossDissolve
        vc?.modalPresentationStyle = .overCurrentContext
        self.present(vc!, animated: true, completion: nil)
    }

    @IBAction func closeButton(_ sender: Any) {
        self.statusBar.isHidden = false
        dismiss(animated: true, completion: nil)
    }

    // Throw json error
    class JSONError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR \(json)")
        }
    }

    // Fetch show details
    private func fetchShowDetailsFor(_ id: Int?, completionHandler: @escaping (ShowDetails) -> ()) {
        loadingView.startAnimating()

        guard let id = id else { return }

        let request : APIRequest<ShowDetails,JSONError> = tron.swiftyJSON.request("anime/\(id)/details")

        let sessionSecret = try? GlobalVariables().KDefaults.getString("session_secret")!
        let userId = try? GlobalVariables().KDefaults.getString("user_id")!

        request.headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "session_secret": sessionSecret!,
            "user_id": userId!
        ]

        request.perform(withSuccess: { showDetails in
            DispatchQueue.main.async {
                completionHandler(showDetails)
            }
        }, failure: { error in
            SCLAlertView().showError("Connection error", subTitle: "There was an error while connecting to the servers. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            
            print("Received rating error: \(error)")
        })
    }

    // Update view with details
    func updateDetailWithShow(_ show: ShowDetails?) {
        if show != nil {
//            if let progress = show?.progress {
//                updateListButtonTitle(progress.list)
//            } else {
//                updateListButtonTitle(string: "Add to list ")
//           }

            // Configure title label
            if let title = showDetails?.title {
                showTitleLabel.text = title
            } else {
                showTitleLabel.text = "Unknown"
            }

            // Configure rating button
            if let rating = showDetails?.currentRating {
                if rating == 0.0 {
                    ratingButton.setTitle("", for: .normal)
                } else if rating <= 1.0 {
                    ratingButton.setTitle("", for: .normal)
                } else if rating <= 2.0, rating > 1.0 {
                    ratingButton.setTitle("", for: .normal)
                } else if rating <= 3.0, rating > 2.0  {
                    ratingButton.setTitle("", for: .normal)
                } else if rating <= 4.0, rating > 3.0  {
                    ratingButton.setTitle("", for: .normal)
                } else if rating <= 5.0, rating > 4.0  {
                    ratingButton.setTitle("", for: .normal)
                } else {
                    ratingButton.setTitle("", for: .normal)
                }
            } else {
                ratingButton.setTitle("", for: .normal)
            }

            // Configure tags label
            if let tags = showDetails?.informationString() {
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
                    statusLabel.backgroundColor = UIColor.onHold()
                }
            }

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
                posterImageView.kf.setImage(with: resource, placeholder: UIImage(named: "colorful"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                posterImageView.image = UIImage(named: "colorful")
            }

            if let bannerImage = showDetails?.banner, bannerImage != "" {
                let bannerImage = URL(string: bannerImage)
                let resource = ImageResource(downloadURL: bannerImage!)
                bannerImageView.kf.indicatorType = .activity
                bannerImageView.kf.setImage(with: resource, placeholder: UIImage(named: "aozora"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                bannerImageView.image = UIImage(named: "aozora")
            }

            if let youtubeID = showDetails?.youtubeId, youtubeID.count > 0 {
                trailerButton.isHidden = false
                trailerButton.layer.borderWidth = 1.0;
                trailerButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
            } else {
                trailerButton.isHidden = true
            }
        }
    }

    // MARK: - IBActions
    @IBAction func showBanner(sender: AnyObject) {
        var bannerUrl: String?
        
        if let banner = showDetails?.banner {
            bannerUrl = banner
        } else {
            bannerUrl = showDetails?.bannerThumbnail
        }
        
        presentLightboxViewController(imageUrl: bannerUrl, text: "", videoUrl: "")
    }
    
    @IBAction func showPoster(sender: AnyObject) {
        var posterUrl: String?
        
        if let poster = showDetails?.poster {
            posterUrl = poster
        } else {
            posterUrl = showDetails?.posterThumbnail
        }

        presentLightboxViewController(imageUrl: posterUrl, text: "", videoUrl: "")
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playTrailerPressed(sender: AnyObject) {
        if let trailerURL = showDetails?.youtubeId {
            presentLightboxViewController(imageUrl: "", text: "", videoUrl: trailerURL)
        }
    }
}

extension ShowDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return show != nil ? AnimeSection.allSections.count : 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        switch AnimeSection(rawValue: section)! {
        case .synopsis: numberOfRows = 1
        case .information: numberOfRows = 6
        case .cast:
            if let actors = castDetails?.count {
                numberOfRows = actors
            } else {
                numberOfRows = 1
            }
        }
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch AnimeSection(rawValue: indexPath.section)! {
        case .synopsis:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowSynopsisCell") as! ShowSynopsisCell
            cell.synopsisTextView.attributedText = showDetails?.attributedSynopsis()
            cell.synopsisTextView.isSelectable = true
            cell.layoutIfNeeded()
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowDetailCell") as! ShowDetailCell

            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Type"
                if let type = showDetails?.type, type != "" {
                    cell.detailLabel.text = type
                } else {
                    cell.detailLabel.text = "-"
                }
            case 1:
                cell.titleLabel.text = "Episodes"
                if let episode = showDetails?.episodes, episode > 0 {
                    cell.detailLabel.text = episode.description
                } else {
                    cell.detailLabel.text = "-"
                }
            case 2:
                cell.titleLabel.text = "Status"
                if let status = showDetails?.status, status != "" {
                    cell.detailLabel.text = status.capitalized
                } else {
                    cell.detailLabel.text = "-"
                }
            case 3:
                cell.titleLabel.text = "Aired"
                if let startDate = showDetails?.startDate, let endDate = showDetails?.endDate {
                    cell.detailLabel.text = startDate.mediumDate() + " - " + endDate.mediumDate()
                } else {
                    cell.detailLabel.text = "N/A - N/A"
                }
//            case 4:
//                cell.titleLabel.text = "Producers"
//                if let producer = showDetails?.producers, producer != "" {
//                    cell.detailLabel.text = producer
//                } else {
//                    cell.detailLabel.text = "-"
//                }
//            case 5:
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
//            case 8:
//                cell.titleLabel.text = "English Titles"
//                if let englishTitle = showDetails?.englishTitles, englishTitle != "" {
//         er           cell.detailLabel.text = englishTitle
//                } else {
//                    cell.detailLabel.text = "-"
//                }
//            case 9:
//                cell.titleLabel.text = "Japanese Titles"
//                if let japaneseTitle = showDetails?.japaneseTitles, japaneseTitle != "" {
//                    cell.detailLabel.text = japaneseTitle
//                } else {
//                    cell.detailLabel.text = "-"
//                }
//            case 10:
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCastCell") as! ShowCharacterCell
            if let actorName = castDetails?[indexPath.row]["name"] {
                cell.actorName.text = actorName.stringValue
            }
            
            if let actorRole = castDetails?[indexPath.row]["role"] {
                cell.actorJob.text = actorRole.stringValue
            }

            if let castImage = castDetails?[indexPath.row]["image"].stringValue {
                let castImage = URL(string: castImage)
                let resource = ImageResource(downloadURL: castImage!)
                cell.actorImageView.kf.indicatorType = .activity
                cell.actorImageView.kf.setImage(with: resource, placeholder: UIImage(named: "PersonPlaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            }
            
            cell.layoutIfNeeded()
            return cell
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
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 1
    }
}

extension ShowDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = AnimeSection(rawValue: indexPath.section)!
        tableView.deselectRow(at: indexPath, animated: true)

        switch section {
        case .synopsis:
//            let synopsisCell = tableView.cellForRow(at: indexPath) as! ShowSynopsisCell
//            synopsisCell.synopsisTextView.numberOfLines = (synopsisCell.synopsisLabel.numberOfLines == 8) ? 0 : 8

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            })
        case .information: break
        case .cast: break
        }
    }
}
