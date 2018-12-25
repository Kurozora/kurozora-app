//
//  SearchViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import KDatabaseKit
//import KCommonKit
//import UIKit
//import Bolts

//enum SearchScope: Int {
//    case AllAnime = 0
//    case MyLibrary
//    case Users
//    case Forum
//}

//class SearchViewController: UIViewController {
//
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    var loadingView: LoaderView!
//    var animator: ZFModalTransitionAnimator!
//    var dataSource: [PFObject] = [] {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//
//    var emptyDataSource: [[AnyObject]] = [[],[],[],[]]
//
//    var currentOperation = Operation()
//    var initialSearchScope: SearchScope!
//
//    func initWithSearchScope(searchScope: SearchScope) {
//        initialSearchScope = searchScope
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        AnimeCell.registerNibFor(collectionView: collectionView)
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//        layout.itemSize = CGSize(width: view.bounds.size.width, height: 132)
//
//        loadingView = LoaderView(parentView: view)
//
//        searchBar.placeholder = "Enter your search"
//        searchBar.becomeFirstResponder()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(updateETACells), name: NSNotification.Name(rawValue: LibraryUpdatedNotification), object: nil)
//
//        var allBrowseTypes = BrowseType.allItems()
//        allBrowseTypes.append(BrowseType.Filtering.rawValue)
//        emptyDataSource[0] = allBrowseTypes as [AnyObject]
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        view.endEditing(true)
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    @objc func updateETACells() {
//        let indexPaths = collectionView.indexPathsForVisibleItems
//        collectionView.reloadItems(at: indexPaths)
//    }
//
//    func fetchDataWithQuery(text: String, searchScope: SearchScope) {
//
//        if searchScope == .MyLibrary {
//
//            guard let library = LibraryController.sharedInstance.library else {
//                return
//            }
//            self.dataSource = library.filter({ anime in
//
//                if anime.progress == nil {
//                    return false
//                }
//                if let title = anime.title, title.lowercaseString.range(of: text.lowercaseString) != nil {
//                    return true
//                }
//                if let titleEnglish = anime.titleEnglish, titleEnglish.lowercaseString.range(of: text.lowercaseString) != nil {
//                    return true
//                }
//                return false
//            })
//            return
//        }
//
//
//        loadingView.startAnimating()
//        collectionView.animateFadeOut()
//
//        var query: PFQuery!
//
//        switch searchScope {
//        case .AllAnime:
//            let query1 = Anime.query()!
//            query1.whereKey("title", matchesRegex: text, modifiers: "i")
//
//            let query2 = Anime.query()!
//            query2.whereKey("titleEnglish", matchesRegex: text, modifiers: "i")
//
//            let orQuery = PFQuery.orQueryWithSubqueries([query1, query2])
//            orQuery.limit = 40
//            orQuery.orderByAscending("popularityRank")
//
//            query = orQuery
//
//        case .Users:
//            query = User.query()!
//            query.limit = 40
//            query.whereKey("kurozoraUsername", matchesRegex: text, modifiers: "i")
//            query.orderByAscending("kurozoraUsername")
//
//        case .Forum:
//            query = Thread.query()!
//            query.limit = 40
//            query.whereKey("title", matchesRegex: text, modifiers: "i")
//            query.includeKey("tags")
//            query.includeKey("startedBy")
//            query.includeKey("lastPostedBy")
//            query.orderByAscending("updatedAt")
//        default:
//            break
//        }
//
//        currentOperation.cancel()
//        let newOperation = Operation()
//
//        dispatch_after_delay(0.6, queue: dispatch_get_main_queue()) { _ in
//
//            if newOperation.cancelled == true {
//                return
//            }
//
//            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//                print("fetched! \(text)")
//                if result != nil {
//                    if let anime = result as? [Anime] {
//                        LibrarySyncController.matchAnimeWithProgress(anime)
//                        self.dataSource = anime
//                    } else if let users = result as? [User] {
//                        self.dataSource = users
//                    } else if let threads = result as? [Thread] {
//                        self.dataSource = threads
//                    }
//                }
//
//                self.loadingView.stopAnimating()
//                self.collectionView.animateFadeIn()
//            })
//        }
//
//        currentOperation = newOperation
//    }
//
//    func dispatch_after_delay(delay: TimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) {
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
//        dispatch_after(time, queue, block)
//    }
//}
//
//extension SearchViewController: UICollectionViewDataSource {
//
//    func objectAtIndex(indexPath: IndexPath) -> AnyObject {
//        return dataSource.count > 0 ? dataSource[indexPath.row] : emptyDataSource[searchBar.selectedScopeButtonIndex][indexPath.row]
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.count > 0 ? dataSource.count : emptyDataSource[searchBar.selectedScopeButtonIndex].count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let object = objectAtIndex(indexPath: indexPath)
//
//        if let anime = object as? Anime {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCell.id, for: indexPath) as! AnimeCell
//            cell.configureWithAnime(anime)
//            return cell
//
//        } else if let profile = object as? User {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! BasicCollectionCell
//
//            if let avatarFile = profile.avatarThumb {
//                cell.titleimageView.setImageWithPFFile(avatarFile)
//            }
//            cell.titleLabel.text = profile.kurozoraUsername
//            cell.layoutIfNeeded()
//            return cell
//
//        } else if let thread = object as? Thread {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadCell", for: indexPath) as! BasicCollectionCell
//            cell.titleLabel.text = thread.title
//            cell.layoutIfNeeded()
//            return cell
//        } else if let string = object as? String {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadCell", for: indexPath) as! BasicCollectionCell
//            cell.titleLabel.text = string
//            cell.layoutIfNeeded()
//            return cell
//        }
//
//        return UICollectionViewCell()
//    }
//}
//
//extension SearchViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let object = objectAtIndex(indexPath: indexPath)
//
//        if let anime = object as? Anime {
//            self.animator = presentAnimeModal(anime: anime)
//        } else if let user = object as? User {
//            let profileController = KAnimeKit.profileViewController()
//            profileController.initWithUser(user: user)
//            navigationController?.pushViewController(profileController, animated: true)
//        } else if let thread = object as? Thread {
//            let threadController = KAnimeKit.customThreadViewController()
//
//            if let episode = thread.episode, let anime = thread.anime {
//                threadController.initWithEpisode(episode, anime: anime)
//            } else {
//                threadController.initWithThread(thread)
//            }
//
//            if InAppController.hasAnyPro() == nil {
//                threadController.interstitialPresentationPolicy = .Automatic
//            }
//            navigationController?.pushViewController(threadController, animated: true)
//        } else if let string = object as? String {
//            guard let browse = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: "Browse") as? BrowseViewController,
//                let browseType = BrowseType(rawValue: string) else {
//                    return
//            }
//            browse.currentBrowseType = browseType
//            navigationController?.pushViewController(browse, animated: true)
//        }
//    }
//}
//
//extension SearchViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let object = objectAtIndex(indexPath: indexPath)
//
//        if let _ = object as? Anime {
//            return CGSize(width: view.bounds.size.width, height: 132)
//        } else if let _ = object as? User {
//            return CGSize(width: view.bounds.size.width, height: 44)
//        } else if let _ = object as? Thread {
//            return CGSize(width: view.bounds.size.width, height: 44)
//        } else if let _ = object as? String {
//            return CGSize(width: view.bounds.size.width, height: 44)
//        }
//
//        return CGSize.zero
//    }
//}
//
//extension SearchViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        startNewFetch()
//        view.endEditing(true)
//        searchBar.enableCancelButton()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        startNewFetch()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        startNewFetch()
//        collectionView.reloadData()
//    }
//
//    func startNewFetch() {
//
//        guard let query = searchBar.text,
//            let searchScope = SearchScope(rawValue: searchBar.selectedScopeButtonIndex), query.count > 0 else {
//                return
//        }
//
//        fetchDataWithQuery(text: query, searchScope: searchScope)
//    }
//}
//
//extension SearchViewController: UINavigationBarDelegate {
//    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
//        return UIBarPosition.topAttached
//    }
//}
//
//extension SearchViewController: ModalTransitionScrollable {
//    var transitionScrollView: UIScrollView? {
//        return collectionView
//    }
//}
