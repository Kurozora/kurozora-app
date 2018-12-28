//
//  AnimeListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift
import SCLAlertView
import SwiftyJSON
import Kingfisher

//protocol AnimeListControllerDelegate: class {
//    func controllerRequestRefresh() -> BFTask
//}

class AnimeListViewController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var collectionView: UICollectionView!

	private let refreshControl = UIRefreshControl()

	var library: [JSON]?
    var sectionTitle: String?
	var libraryLayout = "Detailed"

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let sectionTitle = sectionTitle?.lowercased() else {return}

		// Add Refresh Control to Collection View
		if #available(iOS 10.0, *) {
			collectionView.refreshControl = refreshControl
		} else {
			collectionView.addSubview(refreshControl)
		}

		refreshControl.tintColor = UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) list", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		refreshControl.addTarget(self, action: #selector(refreshLibraryData(_:)), for: .valueChanged)

		fetchLibrary()

        // Setup collection view
		collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup empty collection view
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
        
        collectionView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "Your \(sectionTitle) list is empty!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }

	@objc private func refreshLibraryData(_ sender: Any) {
		// Fetch library data
		guard let sectionTitle = sectionTitle?.lowercased() else {return}
		refreshControl.attributedTitle = NSAttributedString(string: "Reloading \(sectionTitle) list", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		fetchLibrary()
	}

	private func fetchLibrary() {
		guard let sectionTitle = sectionTitle?.lowercased() else {return}

		Service.shared.getLibrary(withStatus: sectionTitle, withSuccess: { (library) in
			DispatchQueue.main.async {
				self.library = library
				self.collectionView.reloadData()
				self.refreshControl.endRefreshing()
				self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) list", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
			}
		})
	}
}

// MARK: - UICollectionViewDataSource
extension AnimeListViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let libraryCount = library?.count, libraryCount != 0 {
			return libraryCount
		}
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if libraryLayout == "Detailed" {
			let libraryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailedCell", for: indexPath) as! LibraryCell

			if let title = library?[indexPath.row]["title"].stringValue, title != "" {
				libraryCell.titleLabel.text = title
			} else {
				libraryCell.titleLabel.text = "Unknown"
			}

			if let posterThumb = library?[indexPath.row]["poster_thumbnail"].stringValue, posterThumb != "" {
				let posterThumb = URL(string: posterThumb)
				let resource = ImageResource(downloadURL: posterThumb!)
				libraryCell.posterView.kf.indicatorType = .activity
				libraryCell.posterView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
			} else {
				libraryCell.posterView.image = UIImage(named: "placeholder_poster")
			}

			if let bannerImage = library?[indexPath.row]["background_thumbnail"].stringValue, bannerImage != "" {
				let bannerImage = URL(string: bannerImage)
				let resource = ImageResource(downloadURL: bannerImage!)
				libraryCell.episodeImageView?.kf.indicatorType = .activity
				libraryCell.episodeImageView?.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_banner"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
			} else {
				libraryCell.episodeImageView?.image = UIImage(named: "placeholder_banner")
			}

			if let episodeCount = library?[indexPath.row]["episode_count"].intValue, let averageRating = library?[indexPath.row]["average_rating"].doubleValue {
				libraryCell.userProgressLabel.text = "TV ·  \(episodeCount) ·  \(averageRating)"
			} else {
				libraryCell.userProgressLabel.text = "TV ·  0 ·  5"
			}

			return libraryCell
		} else if libraryLayout == "Compact" {
			let libraryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompactCell", for: indexPath) as! LibraryCell

			if let posterThumb = library?[indexPath.row]["poster_thumbnail"].stringValue, posterThumb != "" {
				let posterThumb = URL(string: posterThumb)
				let resource = ImageResource(downloadURL: posterThumb!)
				libraryCell.posterView.kf.indicatorType = .activity
				libraryCell.posterView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
			} else {
				libraryCell.posterView.image = UIImage(named: "placeholder_poster")
			}

			return libraryCell
		}

		return UICollectionViewCell()
	}
}

// MARK: - UICollectionViewDelegate
extension AnimeListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let showID = library?[indexPath.row]["id"].intValue else {return}

		let storyboard = UIStoryboard(name: "details", bundle: nil)
		let showTabBarController = storyboard.instantiateViewController(withIdentifier: "ShowTabBarController") as? ShowTabBarController
		showTabBarController?.showID = showID

		self.present(showTabBarController!, animated: true, completion: nil)
	}
}

extension AnimeListViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if libraryLayout == "Detailed" {
			let collectionViewWidth = collectionView.frame.size.width - 32
			return CGSize(width: collectionViewWidth, height: 200)
		} else if libraryLayout == "Compact" {
			return CGSize(width: 80, height: 118)
		}

		return CGSize.zero
	}
}
//    weak var delegate: AnimeListControllerDelegate?
//
//    var animator: ZFModalTransitionAnimator!
//    var animeListType: AnimeList!
//    var currentLayout: LibraryLayout = .CheckIn
//    var currentSortType: SortType = .Title
//
//    var currentConfiguration: Configuration! {
//        didSet {
//
//            for (filterSection, value, _) in currentConfiguration {
//                if let value = value {
//                    switch filterSection {
//                    case .Sort:
//                        let sortType = SortType(rawValue: value)!
//                        if isViewLoaded {
//                            updateSortType(sortType: sortType)
//                        } else {
//                            currentSortType = sortType
//                        }
//                    case .View:
//                        let layoutType = LibraryLayout(rawValue: value)!
//                        if isViewLoaded {
//                            updateLayout(layout: layoutType, withSize: view.bounds.size)
//                        } else {
//                            currentLayout = layoutType
//                        }
//
//                    default: break
//                    }
//                }
//            }
//        }
//    }
//    var refreshControl = UIRefreshControl()
//
//    var animeList: [Anime] = [] {
//        didSet {
//            if collectionView != nil {
//                collectionView.reloadData()
//                if animeListType == AnimeList.Watching {
//                    collectionView.animateFadeIn()
//                }
//            }
//        }
//    }
//
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    func initWithList(animeList: AnimeList, configuration: Configuration) {
//        self.animeListType = animeList
//        self.currentConfiguration = configuration
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        updateLayout(layout: currentLayout, withSize: view.bounds.size)
//        updateSortType(sortType: currentSortType)
//        addRefreshControl(refreshControl: refreshControl, action: #selector(refreshLibrary), forTableView: collectionView)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        refreshControl.endRefreshing()
//        collectionView.animateFadeIn()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        updateLayout(layout: currentLayout, withSize: size)
//    }
//
//    @objc func refreshLibrary() {
//
//        delegate?.controllerRequestRefresh().continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//
//            self.refreshControl.endRefreshing()
//
//            if let error = task.error {
//                print("\(error)")
//            }
//            return nil
//        })
//
//    }
//
//    // MARK: - Sort and Layout
//
//    func updateLayout(layout: LibraryLayout, withSize viewSize: CGSize) {
//
//        currentLayout = layout
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//
//        switch currentLayout {
//        case .CheckIn:
//            let insets: CGFloat = UIDevice.isPad() ? 15 : 8
//
//            let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
//            let cellHeight: CGFloat = 165
//            var cellWidth: CGFloat = 0
//
//            layout.sectionInset = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
//            layout.minimumLineSpacing = CGFloat(insets)
//            layout.minimumInteritemSpacing = CGFloat(insets)
//
//            if UIDevice.isPad() {
//                cellWidth = (viewSize.width - (columns+1) * insets) / columns
//            } else {
//                cellWidth = viewSize.width - (insets*2)
//            }
//
//            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
//        case .Compact:
//            let margin: CGFloat = 4
//            let columns: CGFloat = UIDevice.isPad() ? (UIDevice.isLandscape() ? 14 : 10) : 5
//            let totalWidth: CGFloat = viewSize.width - (margin * (columns + 1))
//            let width = totalWidth / columns
//
//            layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
//            layout.minimumLineSpacing = margin
//            layout.minimumInteritemSpacing = margin
//            layout.itemSize = CGSize(width: width, height: width/83*116)
//        }
//
//        collectionView.collectionViewLayout.invalidateLayout()
//        collectionView.reloadData()
//    }
//
//    func updateSortType(sortType: SortType) {
//
//        currentSortType = sortType
//
//        switch self.currentSortType {
//        case .Rating:
//            animeList.sortInPlace({ $0.rank < $1.rank && $0.rank != 0 })
//        case .Popularity:
//            animeList.sortInPlace({ $0.popularityRank < $1.popularityRank })
//        case .Title:
//            animeList.sortInPlace({ $0.title < $1.title })
//        case .NextAiringEpisode:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
//                let startDate2 = anime2.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*1000)
//                return startDate1.compare(startDate2) == .OrderedAscending
//            })
//        case .Newest:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.startDate ?? NSDate()
//                let startDate2 = anime2.startDate ?? NSDate()
//                return startDate1.compare(startDate2) == .OrderedDescending
//            })
//        case .Oldest:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let startDate1 = anime1.startDate ?? NSDate()
//                let startDate2 = anime2.startDate ?? NSDate()
//                return startDate1.compare(startDate2) == .OrderedAscending
//
//            })
//        case .MyRating:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                let score1 = anime1.progress!.score ?? 0
//                let score2 = anime2.progress!.score ?? 0
//                return score1 > score2
//            })
//        case .NextEpisodeToWatch:
//            animeList.sortInPlace({ (anime1: Anime, anime2: Anime) in
//                let nextDate1 = anime1.progress!.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
//                let nextDate2 = anime2.progress!.nextEpisodeToWatchDate ?? NSDate(timeIntervalSinceNow: 60*60*24*365*100)
//                return nextDate1.compare(nextDate2) == .OrderedAscending
//            })
//            break;
//        default:
//            break;
//        }
//
//        if isViewLoaded {
//            collectionView.reloadData()
//        }
//    }
//
//}
//
//
//extension AnimeListViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return animeList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        switch currentLayout {
//        case .CheckIn:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheckIn", for: indexPath) as! LibraryAnimeCell
//
//            let anime = animeList[indexPath.row]
//            cell.delegate = self
//            cell.configureWithAnime(anime, showLibraryEta: true)
//            cell.layoutIfNeeded()
//            return cell
//
//        case .Compact:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Compact", for: indexPath) as! BasicCollectionCell
//
//            let anime = animeList[indexPath.row]
//            cell.titleimageView.setImageFrom(urlString: anime.imageUrl, animated: false)
//            cell.layoutIfNeeded()
//            return cell
//        }
//    }
//}
//
//
//
//extension AnimeListViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let anime = animeList[indexPath.row]
//        self.animator = presentAnimeModal(anime: anime)
//    }
//}
//
//extension AnimeListViewController: LibraryAnimeCellDelegate {
//    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime) {
//        if let progress = anime.progress {
//
//            if progress.myAnimeListList() == .Completed {
//                RateViewController.showRateDialogWith(self.tabBarController!, title: "You've finished\n\(anime.title!)!\ngive it a rating", initialRating: Float(progress.score)/2.0, anime: anime, delegate: self)
//            }
//
//            cell.configureWithAnime(anime, showLibraryEta: true)
//        }
//    }
//
//    func cellPressedEpisodeThread(cell: LibraryAnimeCell, anime: Anime, episode: Episode) {
//
//        let threadController = ANAnimeKit.customThreadViewController()
//        threadController.initWithEpisode(episode, anime: anime)
//
//        if InAppController.hasAnyPro() == nil {
//            threadController.interstitialPresentationPolicy = .Automatic
//        }
//
//        navigationController?.pushViewController(threadController, animated: true)
//    }
//}
//
//extension AnimeListViewController: RateViewControllerProtocol {
//    func rateControllerDidFinishedWith(anime: Anime, rating: Float) {
//        RateViewController.updateAnime(anime, withRating: rating*2.0)
//    }
//}
//
//extension AnimeListViewController: PagerTabStripChildItem {
//    func titleForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> String! {
//        return animeListType.rawValue
//    }
//
//    func colorForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> UIColor! {
//        return UIColor.white
//    }
