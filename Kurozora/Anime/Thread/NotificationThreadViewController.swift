//
//  NotificationThreadViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse
import KCommonKit
import KDatabaseKit

public class NotificationThreadViewController: ThreadViewController {
//
//    @IBOutlet weak var viewMoreButton: UIButton!
//    var timelinePost: TimelinePostable?
//    var post: ThreadPostable?
//
//    public func initWithPost(post: Postable) {
//        if let timelinePost = post as? TimelinePostable {
//            self.timelinePost = timelinePost
//        } else if let threadPost = post as? ThreadPostable {
//            self.post = threadPost
//            self.thread = threadPost.thread
//        }
//        self.threadType = .Custom
//    }
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let timelinePost = timelinePost, timelinePost.userTimeline.isTheCurrentUser() {
//            tableView.tableHeaderView = nil
//        }
//
//        if let _ = timelinePost {
//            viewMoreButton.setTitle("View Timeline  ", for: .normal)
//            // Fetch posts, if not a thread
//            fetchPosts()
//        } else if let _ = post {
//            // Other class will call fetchPosts...
//            viewMoreButton.setTitle("View Thread  ", for: .normal)
//        }
//    }
//
//    override public func updateUIWithThread(thread: Thread) {
//        super.updateUIWithThread(thread: thread)
//
//        title = "Loading..."
//
//        if thread.locked {
//            navigationItem.rightBarButtonItem?.isEnabled = false
//        }
//    }
//
//    override public func fetchPosts() {
//        super.fetchPosts()
//        fetchController.configureWith(self, queryDelegate: self, tableView: tableView, limit: FetchLimit, datasourceUsesSections: true)
//    }
//
//    // MARK: - FetchControllerQueryDelegate
//
//    public override func queriesForSkip(skip: Int) -> [PFQuery]? {
//        super.queriesForSkip(skip: skip)
//        var innerQuery: PFQuery!
//        var repliesQuery: PFQuery!
//        if let timelinePost = timelinePost as? TimelinePost {
//            innerQuery = TimelinePost.query()!
//            innerQuery.whereKey("objectId", equalTo: timelinePost.objectId!)
//
//            repliesQuery = TimelinePost.query()!
//        } else if let post = post as? Post {
//            innerQuery = Post.query()!
//            innerQuery.whereKey("objectId", equalTo: post.objectId!)
//
//            repliesQuery = Post.query()!
//        }
//
//        let query = innerQuery.copy() as! PFQuery
//        query.includeKey("postedBy")
//        query.includeKey("userTimeline")
//
//        repliesQuery.skip = 0
//        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
//        repliesQuery.orderByAscending("createdAt")
//        repliesQuery.includeKey("postedBy")
//
//        return [query, repliesQuery]
//    }
//
//
//    // MARK: - CommentViewControllerDelegate
//
//    public override func commentViewControllerDidFinishedPosting(post: PFObject, parentPost: PFObject?, edited: Bool) {
//        super.commentViewControllerDidFinishedPosting(post, parentPost: parentPost, edited: edited)
//
//        if edited {
//            // Don't insert if edited
//            tableView.reloadData()
//            return
//        }
//
//        if let parentPost = parentPost {
//            // Inserting a new reply in-place
//            var parentPost = parentPost as! Commentable
//            parentPost.replies.append(post)
//            tableView.reloadData()
//        } else if parentPost == nil {
//            // Inserting a new post in the bottom, if we're in the bottom of the thread
//            if !fetchController.canFetchMoreData {
//                fetchController.dataSource.append(post)
//                tableView.reloadData()
//            }
//        }
//    }
//
//
//    // MARK: - FetchControllerDelegate
//
//    public override func didFetchFor(skip: Int) {
//        super.didFetchFor(skip: skip)
//        let post = fetchController.objectInSection(0)
//        if let post = post as? TimelinePostable {
//            navigationItem.title = "In " + post.userTimeline.aozoraUsername + " timeline"
//        } else if let post = post as? ThreadPostable {
//            navigationItem.title = "In " + post.thread.title
//        }
//    }
//
//    // MARK: - IBAction
//
//    public override func replyToThreadPressed(sender: AnyObject) {
//        super.replyToThreadPressed(sender: sender)
//
//        if let thread = thread, User.currentUserLoggedIn() {
//            let comment = KDatabaseKit.newPostViewController()
//            comment.initWith(thread, threadType: threadType, delegate: self)
//            presentViewController(comment, animated: true, completion: nil)
//        } else if let thread = thread, thread.locked {
//            presentBasicAlertWithTitle(title: "Thread is locked", message: nil)
//        } else {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Me' tab")
//        }
//    }
//
//    @IBAction func openUserProfile(sender: AnyObject) {
//        if let startedBy = thread?.startedBy {
//            openProfile(startedBy)
//        }
//    }
//
//    @IBAction func dismissViewController(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func viewAllPostsPressed(sender: AnyObject) {
//        if let timelinePost = timelinePost {
//            openProfile(timelinePost.userTimeline)
//
//        } else if let _ = post {
//            let threadController = KAnimeKit.customThreadViewController()
//            if let thread = thread, let episode = thread.episode, let anime = thread.anime {
//                threadController.initWithEpisode(episode, anime: anime)
//            } else {
//                threadController.initWithThread(thread: thread!)
//            }
//
//            if InAppController.hasAnyPro() == nil {
//                threadController.interstitialPresentationPolicy = .Automatic
//            }
//            navigationController?.pushViewController(threadController, animated: true)
//        }
//    }
//}
//
//
//extension NotificationThreadViewController: UINavigationBarDelegate {
//    public func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
//        return UIBarPosition.topAttached
//    }
}
