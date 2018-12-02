//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KRichTextEditor
import SwiftyJSON
import Tabman
import Pageboy
import SCLAlertView

class ForumsViewController: TabmanViewController, PageboyViewControllerDataSource {
//    enum SelectedList: Int {
//        case Recent = 0
//        case New
//        case Tag
//        case Anime
//    }
    
    var sections:[JSON]?
    var sectionsCount:Int?
//    let recentActivityString = "Recent Activity"
//    let newThreadsString = "New Threads"

//    var isReload = false
//    var tagsDataSource: [ThreadTag] = []
//    var animeDataSource: [Anime] = []
//    var dataSource: [Thread]?
    
    @IBOutlet var tableView: UITableView!
//    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var createThreadButton: UIButton!

//    var fetchController = FetchController()
//    var refreshControl = UIRefreshControl()
//    var selectedList: SelectedList = .Recent
//    var selectedThreadTag: ThreadTag?
//    var selectedAnime: Anime?
//    var timer: Timer!

    private var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Service.shared.getForumSections(withSuccess: { (sections) in
            DispatchQueue.main.async {
                self.sections = sections
                self.sectionsCount = sections?.count
                self.reloadPages()
            }
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting sections", subTitle: errorMessage)
        }
        
        dataSource = self
        
        // configure the bar
        self.bar.location = .top
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            // State
            appearance.state.selectedColor = .white
            appearance.state.color =  UIColor.white.withAlphaComponent(0.5)
            
            // Style
            appearance.style.background = .blur(style: .light)
            appearance.style.showEdgeFade = true
            
            // Indicator
            appearance.indicator.bounces = true
            appearance.indicator.useRoundedCorners = true
            appearance.indicator.color = .orange
            
            // Layout
            appearance.layout.itemDistribution = .fill
            
        })
        
        self.bar.behaviors = [.autoHide(.never)]
//        tableView.estimatedRowHeight = 150.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//        addRefreshControl(refreshControl, action: #selector(refetchThreads), forTableView: tableView)
//
//        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeList))
//        navigationBarTitle.addGestureRecognizer(tapGestureRecognizer)
//
//        fetchThreadTags()
//        fetchAnimeTags()
//        prepareForList(selectedList: selectedList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        if let sectionsCount = sections?.count, sectionsCount != 0 {
            initializeViewControllers(with: sectionsCount)
            return sectionsCount
        }
        return 0
    }
    
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "forums", bundle: nil)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "ForumsChild") as! ForumsChildViewController
            if let sectionTitle = sections?[index]["name"].stringValue, sectionTitle != "" {
                viewController.sectionTitle = sectionTitle
                barItems.append(Item(title: sectionTitle))
            }

			if let sectionId = sections?[index]["id"].intValue, sectionId != 0 {
				viewController.sectionId = sectionId
			}

            viewControllers.append(viewController)
        }
        
        self.bar.items = barItems
        self.viewControllers = viewControllers
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
	@IBAction func createThreadButton(_ sender: Any) {
		let editorStoryboard = KRichTextEditor.editorStoryboard()
		let vc = editorStoryboard.instantiateInitialViewController()
		present(vc!, animated: true, completion: nil)
	}
	//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let child_1 = ChildViewController()
//
//        guard isReload else {
//            return [child_1]
//        }
//
//        var childViewControllers = [child_1]
//
//        for index in childViewControllers.indices {
//            let nElements = childViewControllers.count - index
//            let n = (Int(arc4random()) % nElements) + index
//            if n != index {
//                childViewControllers.swapAt(index, n)
//            }
//        }
//        let nItems = 1 + (arc4random() % 8)
//        return Array(childViewControllers.prefix(Int(nItems)))
//    }
//
//    override func reloadPagerTabStripView() {
//        isReload = true
//        if arc4random() % 2 == 0 {
//            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
//        } else {
//            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
//        }
//        super.reloadPagerTabStripView()
//    }
    
//    // MARK: - NavigationBar Options
//
//    func prepareForList(selectedList: SelectedList) {
//        self.selectedList = selectedList
//
//        switch selectedList {
//        case .Recent:
//            navigationBarTitle.text = recentActivityString
//            fetchThreads()
//        case .New:
//            navigationBarTitle.text = newThreadsString
//            fetchThreads()
//        case .Tag:
//            if let selectedThreadTag = selectedThreadTag {
//                navigationBarTitle.text = selectedThreadTag.name
//                fetchTagThreads(selectedThreadTag)
//            }
//        case .Anime:
//            if let anime = selectedAnime {
//                navigationBarTitle.text = anime.title!
//                fetchTagThreads(anime)
//            }
//        }
//        navigationBarTitle.text! += " " + FontAwesome.AngleDown.rawValue
//    }
//
//    @objc func changeList() {
//        if let sender = navigationController?.navigationBar,
//            let viewController = tabBarController, view.window != nil {
//            let tagsTitles = tagsDataSource.map({ " #"+$0.name })
//            let animeTitles = animeDataSource.map({ " #"+($0.title ?? "") })
//
//
//            let dataSource = [[recentActivityString, newThreadsString], tagsTitles, animeTitles]
//            DropDownListViewController.showDropDownListWith(
//                sender: sender,
//                viewController: viewController,
//                delegate: self,
//                dataSource: dataSource)
//        }
//    }
//
//    @objc func reloadTableView() {
//        tableView.reloadData()
//    }
//
//    // MARK: - Fetching
//
//    @objc func refetchThreads() {
//        prepareForList(selectedList: selectedList)
//    }
//
//    var startDate: NSDate?
//
//    func fetchThreads() {
//        startDate = NSDate()
//    }
//
//    func fetchTagThreads(tag: PFObject) {
//
//        let query = Thread.query()!
//        query.whereKey("pinType", equalTo: "tag")
//        query.whereKey("tags", containedIn: [tag])
//        query.includeKey("tags")
//        query.includeKey("lastPostedBy")
//        query.includeKey("startedBy")
//        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
//            if let pinnedData = result as? [Thread] {
//                let query = Thread.query()!
//
//                query.whereKey("tags", containedIn: [tag])
//                query.whereKeyDoesNotExist("pinType")
//                query.includeKey("tags")
//                query.includeKey("lastPostedBy")
//                query.includeKey("startedBy")
//                query.orderByDescending("updatedAt")
//                self.fetchController.configureWith(self, query: query, tableView: self.tableView, limit: 50, pinnedData: pinnedData)
//            }
//        }
//    }
//
//    func fetchThreadTags() {
//        let query = ThreadTag.query()!
//        query.orderByAscending("order")
//        query.whereKey("visible", equalTo: true)
//        query.findObjectsInBackground().continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
//            self.tagsDataSource = task.result as! [ThreadTag]
//            return nil
//        }
//    }
//
//    func fetchAnimeTags() {
//        let query = Anime.query()!
//        query.whereKey("startDate", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-3*30*24*60*60))
//        query.whereKey("status", equalTo: "currently airing")
//        query.orderByAscending("rank")
//        query.findAllObjectsInBackground().continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
//            self.animeDataSource = task.result as! [Anime]
//            return nil
//        }
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func createThread(sender: AnyObject) {
//
//        if User.currentUserLoggedIn() {
//            let comment = ANParseKit.newThreadViewController()
//            if let selectedAnime = selectedAnime, selectedList == .Anime {
//                comment.initCustomThreadWithDelegate(self, tags: [selectedAnime])
//            } else {
//                comment.initCustomThreadWithDelegate(self)
//            }
//
//            animator = presentViewControllerModal(comment)
//        } else {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Me' tab to login", style: .alert)
//        }
//    }
//
//    @IBAction func searchForums(sender: AnyObject) {
//
//        if let tabBar = tabBarController {
//            tabBar.presentSearchViewController(searchScope: .Forum)
//        }
//    }
//
//}
//
//extension ForumsViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return fetchController.dataCount()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell") as! TopicCell
//
//        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
//        let title = thread.title
//
//        if let _ = thread.episode {
//            cell.typeLabel.text = " "
//        } else if let _ = thread.pinType {
//            cell.typeLabel.text = " "
//        } else if thread.locked {
//            cell.typeLabel.text = " "
//        } else if let _ = thread.youtubeID {
//            cell.typeLabel.text = " "
//        } else {
//            cell.typeLabel.text = ""
//        }
//
//        cell.title.text = title
//        let lastPostedByUsername = thread.lastPostedBy?.aozoraUsername ?? ""
//        cell.information.text = "\(thread.replyCount) comments · \(thread.updatedAt!.timeAgo()) · \(lastPostedByUsername)"
//        cell.tagsLabel.updateTags(thread.tags, delegate: self, addLinks: false)
//        cell.layoutIfNeeded()
//        return cell
//    }
//}
//
//extension ForumsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
//
//        let threadController = KAnimeKit.customThreadViewController()
//
//        if let episode = thread.episode, let anime = thread.anime {
//            threadController.initWithEpisode(episode, anime: anime)
//        } else {
//            threadController.initWithThread(thread)
//        }
//
//        if InAppController.hasAnyPro() == nil {
//            threadController.interstitialPresentationPolicy = .Automatic
//        }
//
//        navigationController?.pushViewController(threadController, animated: true)
//    }
//}
//
//extension ForumsViewController: FetchControllerDelegate {
//    func didFetchFor(skip: Int) {
//
//        if let startDate = startDate {
//            print("Load forums = \(NSDate().timeIntervalSince(startDate as Date))s")
//            self.startDate = nil
//        }
//
//        refreshControl.endRefreshing()
//        loadingView.stopAnimating()
//    }
//}
//
//extension ForumsViewController: DropDownListDelegate {
//    func selectedAction(sender trigger: UIView, action: String, indexPath: IndexPath) {
//
//        if trigger.isEqual(navigationController?.navigationBar) {
//            switch (indexPath.row, indexPath.section) {
//            case (0, 0):
//                prepareForList(selectedList: .Recent)
//            case (1, 0):
//                prepareForList(selectedList: .New)
//            case (_, 1):
//                selectedThreadTag = tagsDataSource[indexPath.row]
//                prepareForList(selectedList: .Tag)
//            case (_, 2):
//                selectedAnime = animeDataSource[indexPath.row]
//                prepareForList(selectedList: .Anime)
//            default: break
//            }
//        }
//    }
//
//    func dropDownDidDismissed(selectedAction: Bool) {
//    }
//}
//
//extension ForumsViewController: CommentViewControllerDelegate {
//    func commentViewControllerDidFinishedPosting(post: PFObject, parentPost: PFObject?, edited: Bool) {
//        prepareForList(selectedList: selectedList)
//    }
}
