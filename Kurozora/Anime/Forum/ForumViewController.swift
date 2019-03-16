//
//  ForumViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
//import Bolts
//import iAd
//import Parse

public class ForumViewController: AnimeBaseViewController {
//
//    var dataSource: [Thread] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//
//    var loadingView: LoaderView!
//    var fetchController = FetchController()
//    var animator: ZFModalTransitionAnimator!
//
//    @IBOutlet weak public var navigationBar: UINavigationItem!
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        navigationBar.title = "\(anime.title!) Discussion"
//
//        tableView.estimatedRowHeight = 150.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//
//        loadingView = LoaderView(parentView: view)
//        loadingView.startAnimating()
//        fetchAnimeRelatedThreads()
//    }
//
//    func fetchAnimeRelatedThreads() {
//
//        let query = Thread.query()!
//        query.whereKey("tags", containedIn: [anime])
//        query.includeKey("tags")
//        query.includeKey("anime")
//        query.includeKey("startedBy")
//        query.includeKey("lastPostedBy")
//        fetchController.configureWith(self, query: query, tableView: tableView, limit: 100)
//    }
//
//    @IBAction func createAnimeThread(sender: AnyObject) {
//
//        if User.currentUserLoggedIn() {
//            let comment = KDatabaseKit.newThreadViewController()
//            comment.initWith(threadType: .Custom, delegate: self, anime: anime)
//            animator = presentViewControllerModal(comment)
//        } else {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Me' tab to login", style: .alert)
//        }
//    }
//}
//
//extension ForumViewController: UITableViewDataSource {
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return fetchController.dataCount()
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell") as! TopicCell
//
//        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
//        let title = thread.title
//
//        if let _ = thread.episode {
//            cell.typeLabel.text = " "
//        } else {
//            cell.typeLabel.text = ""
//        }
//
//        cell.title.text = title
//        let lastPostedByUsername = thread.lastPostedBy?.aozoraUsername ?? ""
//        cell.information.text = "\(thread.replyCount) comments · \(thread.updatedAt!.timeAgo()) · \(lastPostedByUsername)"
//        cell.layoutIfNeeded()
//        return cell
//    }
//
//}
//
//extension ForumViewController: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if let tabBar = tabBarController as? CustomTabBarController {
//            tabBar.disableDragDismiss()
//        }
//
//        let thread = fetchController.objectAtIndex(indexPath.row) as! Thread
//
//        let threadController = KAnimeKit.customThreadViewController()
//        if let episode = thread.episode, let anime = thread.anime  {
//            threadController.initWithEpisode(episode, anime: anime)
//        } else {
//            threadController.initWithThread(thread)
//        }
//
//        navigationController?.pushViewController(threadController, animated: true)
//    }
//}
//
//extension ForumViewController: FetchControllerDelegate {
//    public func didFetchFor(skip: Int) {
//        self.loadingView.stopAnimating()
//    }
//}
//
//extension ForumViewController: CommentViewControllerDelegate {
//    public func commentViewControllerDidFinishedPosting(post: PFObject, parentPost: PFObject?, edited: Bool) {
//        fetchAnimeRelatedThreads()
//    }
}
