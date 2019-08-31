//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import Kingfisher
import SwiftTheme

protocol LibraryListViewControllerDelegate: class {
	func updateLayoutChangeButton(current layout: LibraryListStyle)
}

class LibraryListCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	private let refreshControl = UIRefreshControl()

	var library: [LibraryElement]? {
		didSet {
			collectionView.reloadData {
				if self.collectionView.numberOfItems() != 0 {
					self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
				}
			}
		}
	}
    var sectionTitle: String?
	var sectionIndex: Int?
	var libraryLayout: LibraryListStyle = .detailed
	var delegate: LibraryListViewControllerDelegate?
	var gap: CGFloat {
		return UIDevice.isPad ? 40 : 20
	}
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			if UIDevice.isLandscape {
				switch UIDevice.type {
				case .iPhone_5_5S_5C_SE:	return (libraryLayout == .detailed) ? (2.08, 2.0) : (6, 2.4)
				case .iPhone_6_6S_7_8:		return (libraryLayout == .detailed) ? (2.08, 2.0) : (6, 2.4)
				case .iPhone_6_6S_7_8_PLUS:	return (libraryLayout == .detailed) ? (2.08, 2.0) : (6, 2.4)
				case .iPhone_Xr:			return (libraryLayout == .detailed) ? (2.32, 1.8) : (8, 2.6)
				case .iPhone_X_Xs:			return (libraryLayout == .detailed) ? (2.32, 1.8) : (8, 2.6)
				case .iPhone_Xs_Max:		return (libraryLayout == .detailed) ? (2.32, 1.8) : (8, 2.6)

				case .iPad, .iPadAir3, .iPadPro11, .iPadPro12: return (libraryLayout == .detailed) ? (3.06, 3.8) : (8, 4.2)
				}
			}

			switch UIDevice.type {
			case .iPhone_5_5S_5C_SE:	return (libraryLayout == .detailed) ? (1, 3.2) : (2.18, 2.8)
			case .iPhone_6_6S_7_8:		return (libraryLayout == .detailed) ? (1, 3.2) : (3.34, 4.2)
			case .iPhone_6_6S_7_8_PLUS:	return (libraryLayout == .detailed) ? (1, 3.2) : (3.34, 4.2)
			case .iPhone_Xr:			return (libraryLayout == .detailed) ? (1, 3.8) : (3.34, 5.2)
			case .iPhone_X_Xs:			return (libraryLayout == .detailed) ? (1, 3.8) : (3.34, 5.2)
			case .iPhone_Xs_Max:		return (libraryLayout == .detailed) ? (1, 3.8) : (3.34, 5.2)

			case .iPad, .iPadAir3, .iPadPro11, .iPadPro12: return (libraryLayout == .detailed) ? (2, 4.8) : (6, 6.0)
			}
		}
	}

	#if DEBUG
	var newNumberOfItems: (forWidth: CGFloat, forHeight: CGFloat)?
	var _numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			guard let newNumberOfItems = newNumberOfItems else { return numberOfItems }
			return newNumberOfItems
		}
	}
	#endif

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserSettings.set(sectionIndex, forKey: .libraryPage)
		delegate?.updateLayoutChangeButton(current: libraryLayout)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		
		guard let sectionTitle = sectionTitle else {return}
		let lowerdSectionTitle = sectionTitle.lowercased()

		// Add Refresh Control to Collection View
		if #available(iOS 10.0, *) {
			collectionView.refreshControl = refreshControl
		} else {
			collectionView.addSubview(refreshControl)
		}

		refreshControl.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(lowerdSectionTitle) list!", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		refreshControl.addTarget(self, action: #selector(refreshLibraryData(_:)), for: .valueChanged)

		// Observe NotificationCenter for update notification
		let libraryUpdateNotificationName = Notification.Name("Update\(sectionTitle)Section")
		NotificationCenter.default.addObserver(self, selector: #selector(fetchLibrary), name: libraryUpdateNotificationName, object: nil)

		fetchLibrary()

		if #available(iOS 11.0, *) {
			collectionView.dragDelegate = self
		}

        // Setup empty collection view
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
        
        collectionView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "Your \(lowerdSectionTitle) list is empty!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? LibraryCollectionViewCell, let showTabBarController = segue.destination as? ShowDetailTabBarController {
			showTabBarController.libraryCollectionViewCell = currentCell
			showTabBarController.showID = currentCell.libraryElement?.id
			if let showTitle = currentCell.libraryElement?.title {
				showTabBarController.heroID = "library_\(showTitle)"
				showTabBarController.showDetailViewControllerDelegate = self
			}
		}
	}

	// MARK: - Functions
	/**
		Refresh the library data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshLibraryData(_ sender: Any) {
		// Fetch library data
		guard let sectionTitle = sectionTitle?.lowercased() else {return}
		refreshControl.attributedTitle = NSAttributedString(string: "Refreshing your \(sectionTitle) list...", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		fetchLibrary()
	}

	/**
		Fetch the library items for the current user.
	*/
	@objc private func fetchLibrary() {
		guard let sectionTitle = sectionTitle else {return}

		Service.shared.getLibrary(withStatus: sectionTitle, withSuccess: { (library) in
			DispatchQueue.main.async {
				self.library = library
				self.refreshControl.endRefreshing()
				self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh your \(sectionTitle) list!", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
			}
		})
	}

	func show(at indexPath: IndexPath) -> LibraryElement? {
		return library?[indexPath.row]
    }
}

// MARK: - UICollectionViewDataSource
extension LibraryListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let libraryCount = library?.count, libraryCount != 0 {
			return libraryCount
		}
		return 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let libraryCell = collectionView.dequeueReusableCell(withReuseIdentifier: libraryLayout.rawValue, for: indexPath) as! LibraryCollectionViewCell

		libraryCell.libraryElement = library?[indexPath.item]

		return libraryCell
	}
}

// MARK: - UICollectionViewDelegate
extension LibraryListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}, completion: nil)
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.4,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LibraryListCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.bounds.width - gap) / _numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.bounds.width - gap) / numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / numberOfItems.forHeight)
		#endif
	}
}

// MARK: - UICollectionViewDragDelegate
extension LibraryListCollectionViewController: UICollectionViewDragDelegate {
	@available(iOS 11.0, *)
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let libraryCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryCollectionViewCell else { return [UIDragItem]() }
        let selectedShow = show(at: indexPath)

		guard let userActivity = selectedShow?.openDetailUserActivity else { return [UIDragItem]() }
		let itemProvider = NSItemProvider(object: (libraryCollectionViewCell as? LibraryDetailedColelctionViewCell)?.episodeImageView?.image ?? libraryCollectionViewCell.posterView.image!)
		itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = selectedShow

        return [dragItem]
    }
}

// MARK: - ShowDetailViewControllerDelegate
extension LibraryListCollectionViewController: ShowDetailViewControllerDelegate {
	func updateShowInLibrary(for libraryCell: LibraryCollectionViewCell?) {
		guard let libraryCell = libraryCell else { return }
		guard let indexPath = collectionView.indexPath(for: libraryCell) else { return }

		collectionView.performBatchUpdates({
			library?.remove(at: indexPath.item)
			collectionView.deleteItems(at: [indexPath])
		})

		collectionView.reloadData()
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
