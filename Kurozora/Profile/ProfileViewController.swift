//
//  ProfileViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KDatabaseKit
import TTTAttributedLabel_moolban
//import XCDYouTubeKit

class ProfileViewController: UIViewController {

    enum SelectedFeed: Int {
        case Feed = 0
        case Popular
        case Global
        case Profile
    }

    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!
//    @IBOutlet weak var animeListButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var aboutLabel: TTTAttributedLabel!
    @IBOutlet weak var activeAgo: UILabel!

    @IBOutlet weak var proBadge: UILabel!
    @IBOutlet weak var postsBadge: UILabel!
    @IBOutlet weak var tagBadge: UILabel!

    @IBOutlet weak var segmentedControlView: UIView!

//    @IBOutlet weak var proBottomLayoutConstraint: NSLayoutConstraint!
//    @IBOutlet weak var settingsTrailingSpaceConstraint: NSLayoutConstraint!
//    @IBOutlet weak var tableBottomSpaceConstraint: NSLayoutConstraint!
//    @IBOutlet weak var segmentedControlTopSpaceConstraint: NSLayoutConstraint!
//    @IBOutlet weak var tableHeaderViewBottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!

    let username = User.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()

//        aboutLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
//        aboutLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
//        aboutLabel.delegate = self as! TTTAttributedLabelDelegate;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameLabel.text = username

//        navigationController?.setNavigationBarHidden(false, animated: true)

//        if let profile = userProfile, profile.details.dataAvailable {
//            updateFollowingButtons()
//        }
    }

//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    func sizeHeaderToFit() {
//        guard let header = tableView.tableHeaderView else {
//            return
//        }
//
//        if let userProfile = userProfile, !userProfile.isTheCurrentUser() {
//            tableHeaderViewBottomSpaceConstraint.constant = 8
//            segmentedControl.isHidden = true
//        }
//
//        header.setNeedsLayout()
//        header.layoutIfNeeded()
//
//        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.size.width
//
//        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
//        var frame = header.frame
//
//        frame.size.height = height
//        header.frame = frame
//        tableView.tableHeaderView = header
//    }
//
//
//
//    // MARK: - Fetching
//
//    override public func fetchPosts() {
//        super.fetchPosts()
//        let username = self.username ?? userProfile!.kurozoraUsername
//        fetchUserDetails(username: username)
//    }
//
//    func fetchUserDetails(username: String) {

//        self.aboutLabel.setText(user.details.about, afterInheritingLabelAttributesAndConfiguringWithBlock: { (attributedString) -> NSMutableAttributedString! in
//            return attributedString
//        })

//        let activeEndString = user.activeEnd.timeAgo()
//        let activeEndStringFormatted = activeEndString == "Just now" ? "active now" : "\(activeEndString) ago"
//        self.activeAgo.text = user.active ? "active now" : activeEndStringFormatted

//        if user.details.posts >= 1000 {
//            self.postsBadge.text = String(format: "%.1fk", Float(user.details.posts-49)/1000.0 )
//        } else {
//            self.postsBadge.text = user.details.posts.description
//        }

//        if !user.isTheCurrentUser() {
//            let relationQuery = User.currentUser()!.following().query()
//            relationQuery.whereKey("kurozoraUsername", equalTo: username)
//            relationQuery.findObjectsInBackgroundWithBlock { (result, error) -> Void in
//                if let _ = result?.last as? User {
//                    // Following this user
//                    self.followButton.setTitle("  Following", forState: .Normal)
//                    user.followingThisUser = true
//                } else if let _ = error {
//                    // TODO: Show error
//
//                } else {
//                    // NOT following this user
//                    self.followButton.setTitle("  Follow", forState: .Normal)
//                    user.followingThisUser = false
//                }
//                self.followButton.layoutIfNeeded()
//            }
//        }
//    }
//
//    func updateViewWithUser(user: User) {
//        usernameLabel.text = user.aozoraUsername
//        title = user.aozoraUsername
//        if let avatarFile = user.avatarThumb {
//            userAvatar.setImageWithPFFile(avatarFile)
//        }
//
//        if let bannerFile = user.banner {
//            userBanner.setImageWithPFFile(bannerFile)
//        }
//
//        if let _ = tabBarController {
//            navigationItem.leftBarButtonItem = nil
//        }
//
//        let proPlusString = "PRO+"
//        let proString = "PRO"
//
//        proBadge.isHidden = true
//
//        if user.isTheCurrentUser() {
//            // If is current user, only show PRO when unlocked in-apps
//            if let _ = InAppController.purchasedProPlus() {
//                proBadge.isHidden = false
//                proBadge.text = proPlusString
//            } else if let _ = InAppController.purchasedPro() {
//                proBadge.isHidden = false
//                proBadge.text = proString
//            }
//        } else {
//            if user.badges.indexOf(proPlusString) != nil {
//                proBadge.isHidden = false
//                proBadge.text = proPlusString
//            } else if user.badges.indexOf(proString) != nil {
//                proBadge.isHidden = false
//                proBadge.text = proString
//            }
//        }
//
//
//        if user.isAdmin() {
//            tagBadge.backgroundColor = UIColor.aozoraPurple()
//        }
//
//        if User.currentUserIsGuest() {
//            followButton.isHidden = true
//            settingsButton.isHidden = true
//        } else if user.isTheCurrentUser() {
//            followButton.isHidden = true
//            settingsTrailingSpaceConstraint.constant = -10
//        } else {
//            followButton.isHidden = false
//        }
//
//        var hasABadge = false
//        for badge in user.badges where badge != proString && badge != proPlusString {
//            tagBadge.text = badge
//            hasABadge = true
//            break
//        }
//
//        if hasABadge {
//            tagBadge.isHidden = false
//        } else {
//            tagBadge.isHidden = true
//            proBottomLayoutConstraint.constant = 4
//        }
//    }
//
//    func updateFollowingButtons() {
//        if let profile = userProfile {
//            followingButton.setTitle("\(profile.details.followingCount) FOLLOWING", for: .normal)
//            followersButton.setTitle("\(profile.details.followersCount) FOLLOWERS", for: .naaaaormal)
//        }
//    }
//
//    func configureFetchController() {
//        var offset = tableView.contentOffset
//        if offset.y > 345 {
//            offset.y = 345
//        }
//        fetchController.configureWith(self, queryDelegate: self, tableView: self.tableView, limit: self.FetchLimit, datasourceUsesSections: true)
//        tableView.setContentOffset(offset, animated: false)
//    }
//
//    // MARK: - IBAction
//    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
//        configureFetchController()
//    }
//
//    @IBAction func followOrUnfollow(sender: AnyObject) {
//
//        if let thisProfileUser = userProfile,
//            let followingUser = thisProfileUser.followingThisUser,
//            let currentUser = User.currentUser(), !thisProfileUser.isTheCurrentUser() {
//
//            currentUser.followUser(thisProfileUser, follow: !followingUser)
//
//            if !followingUser {
//                // Follow
//                self.followButton.setTitle("  Following", for: .normal)
//                updateFollowingButtons()
//            } else {
//                // Unfollow
//                self.followButton.setTitle("  Follow", for: .normal)
//                updateFollowingButtons()
//            }
//        }
//    }
//
//    @IBAction func searchPressed(sender: AnyObject) {
//        if let tabBar = tabBarController {
//            tabBar.present(SearchViewController(coder: .AllAnime), animated: true)
//        }
//    }
//
//    public override func replyToThreadPressed(sender: AnyObject) {
//        super.replyToThreadPressed(sender: sender)
//
//        if let profile = userProfile, User.currentUserLoggedIn() {
//            let comment = KDatabaseKit.newPostViewController()
//            comment.initWithTimelinePost(self, postedIn: profile)
//            animator = presentViewControllerModal(comment)
//        } else {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Me' tab")
//        }
//    }
//
//
//    // MARK: - FetchControllerQueryDelegate
//
//    public override func queriesForSkip(skip: Int) -> [PFQuery]? {
//
//        let innerQuery = TimelinePost.query()!
//        innerQuery.skip = skip
//        innerQuery.limit = FetchLimit
//        innerQuery.whereKey("replyLevel", equalTo: 0)
//        innerQuery.orderByDescending("createdAt")
//
//        let selectedFeed = SelectedFeed(rawValue: segmentedControl.selectedSegmentIndex)!
//        switch selectedFeed {
//        case .Feed:
//            let followingQuery = userProfile!.following().query()
//            followingQuery.orderByDescending("activeStart")
//            followingQuery.limit = 1000
//            innerQuery.whereKey("userTimeline", matchesKey: "objectId", inQuery: followingQuery)
//        case .Popular:
//            innerQuery.whereKeyExists("likedBy")
//        case .Me:
//            innerQuery.whereKey("userTimeline", equalTo: userProfile!)
//        }
//
//        // 'Feed' query
//        let query = innerQuery.copy() as! PFQuery
//        query.includeKey("episode")
//        query.includeKey("postedBy")
//        query.includeKey("userTimeline")
//
//        let repliesQuery = TimelinePost.query()!
//        repliesQuery.skip = 0
//        repliesQuery.whereKey("parentPost", matchesKey: "objectId", inQuery: innerQuery)
//        repliesQuery.orderByAscending("createdAt")
//        repliesQuery.includeKey("episode")
//        repliesQuery.includeKey("postedBy")
//        repliesQuery.includeKey("userTimeline")
//
//        return [query, repliesQuery]
//    }
//
//
//    // MARK: - CommentViewControllerDelegate
//
//    public override func commentViewControllerDidFinishedPosting(newPost: PFObject, parentPost: PFObject?, edited: Bool) {
//        super.commentViewControllerDidFinishedPosting(newPost, parentPost: parentPost, edited: edited)
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
//            parentPost.replies.append(newPost)
//            tableView.reloadData()
//        } else if parentPost == nil {
//            // Inserting a new post in the top, if we're in the top of the thread
//            fetchController.dataSource.insert(newPost, atIndex: 0)
//            tableView.reloadData()
//        }
//    }
//
//
//    // MARK: - FetchControllerDelegate
//
//    public override func didFetchFor(skip: Int) {
//        super.didFetchFor(skip: skip)
//        if let userProfile = userProfile, userProfile.isTheCurrentUser() && segmentedControlView.hidden {
//            segmentedControlView.isHidden = false
//            scrollViewDidScroll(scrollView: tableView)
//            segmentedControlView.animateFadeIn()
//        }
//    }
//
//    func addMuteUserAction(alert: UIAlertController) {
//        alert.addAction(UIAlertAction(title: "Mute", style: UIAlertActionStyle.destructive, handler: {
//            (alertAction: UIAlertAction) -> Void in
//
//            let alertController = UIAlertController(title: "Mute", message: "Enter duration in minutes to mute", preferredStyle: .alert)
//
//            alertController.addTextField(
//                configurationHandler: {(textField: UITextField!) in
//                    textField.placeholder = "Enter duration in minutes"
//                    textField.textColor = UIColor.black
//                    textField.keyboardType = UIKeyboardType.numberPad
//            })
//
//            let action = UIAlertAction(title: "Submit",
//                                       style: UIAlertActionStyle.default,
//                                       handler: {[weak self]
//                                        (paramAction:UIAlertAction!) in
//
//                                        if let textField = alertController.textFields {
//
//                                            let durationTextField = textField as [UITextField]
//
//                                            guard let controller = self, let userProfile = self?.userProfile, let durationText = durationTextField[0].text, let duration = Double(durationText) else {
//                                                self?.presentBasicAlertWithTitle(title: "Woops", message: "Your mute duration is too long or you have entered characters.")
//                                                return
//                                            }
//
//                                            let date = Date().addingTimeInterval(duration * 60.0)
//                                            userProfile.details.mutedUntil = date
//                                            userProfile.saveInBackground()
//
//                                            controller.presentBasicAlertWithTitle(title: "Muted user", message: "You have muted " + self!.userProfile!.username!)
//
//                                        }
//            })
//
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
//                action -> Void in
//            }
//
//            alertController.addAction(action)
//            alertController.addAction(cancelAction)
//
//            self.present(alertController, animated: true, completion: nil)
//            alert.view.tintColor = UIColor.red
//
//        }))
//
//    }
//
//    func addUnmuteUserAction(alert: UIAlertController) {
//        alert.addAction(UIAlertAction(title: "Unmute", style: UIAlertActionStyle.destructive, handler: { (alertAction: UIAlertAction) -> Void in
//
//            guard let userProfile = self.userProfile, let username = userProfile.username else {
//                return
//            }
//            userProfile.details.mutedUntil = nil
//            userProfile.saveInBackground()
//
//            self.presentBasicAlertWithTitle("Unmuted user", message: "You have unmuted " + username)
//
//
//        }))
//    }
//
//    // MARK: - IBActions
//
//    func presentSmallViewController(viewController: UIViewController, sender: AnyObject) {
//        viewController.modalPresentationStyle = .popover
//        viewController.preferredContentSize = CGSize(width: 320, height: 500)
//
//        let popoverMenuViewController = viewController.popoverPresentationController
//        popoverMenuViewController?.permittedArrowDirections = .any
//        popoverMenuViewController?.sourceView = sender.superview
//        popoverMenuViewController?.sourceRect = sender.frame
//
//        if UIDevice.isPad() {
//            navigationController?.present(viewController, animated: true, completion: nil)
//        } else {
//            navigationController?.pushViewController(viewController, animated: true)
//        }
//    }
//
//    @IBAction func showFollowingUsers(sender: AnyObject) {
//        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserList") as! UserListViewController
//        let query = userProfile!.following().query()
//        query.orderByAscending("aozoraUsername")
//        userListController.initWithQuery(query, title: "Following", user: userProfile!)
//        presentSmallViewController(viewController: userListController, sender: sender)
//    }
//
//    @IBAction func showFollowers(sender: AnyObject) {
//        let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserList") as! UserListViewController
//        let query = User.query()!
//        query.whereKey("following", equalTo: userProfile!)
//        query.orderByAscending("aozoraUsername")
//        userListController.initWithQuery(query, title: "Followers", user: userProfile!)
//        presentSmallViewController(viewController: userListController, sender: sender)
//    }
//
//    @IBAction func showSettings(sender: AnyObject) {
//
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        alert.popoverPresentationController?.sourceView = sender.superview
//        alert.popoverPresentationController?.sourceRect = sender.frame
//
//        alert.addAction(UIAlertAction(title: "View Library", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//            if let userProfile = self.userProfile {
//                let navVC = UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "PublicLibraryNav") as! UINavigationController
//                let publicList = navVC.viewControllers.first as! PublicListViewController
//                publicList.initWithUser(userProfile)
//                self.animator = self.presentViewControllerModal(controller: navVC)
//            }
//        }))
//
//        guard let currentUser = User.currentUser() else {
//            return
//        }
//
//        if currentUser.isAdmin() && !userProfile!.isAdmin() || currentUser.isTopAdmin() {
//
//            guard let userProfile = userProfile else {
//                return
//            }
//
//            if let _ = userProfile.details.mutedUntil {
//                addUnmuteUserAction(alert: alert)
//            } else {
//                addMuteUserAction(alert: alert)
//            }
//        }
//
//        if let userProfile = userProfile, userProfile.isTheCurrentUser() {
//            alert.addAction(UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let editProfileController =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfile") as! EditProfileViewController
//                editProfileController.delegate = self
//                if UIDevice.isPad() {
//                    self.presentSmallViewController(viewController: editProfileController, sender: sender)
//                } else {
//                    self.present(editProfileController, animated: true, completion: nil)
//                }
//            }))
//
//            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
//                if UIDevice.isPad() {
//                    self.presentSmallViewController(viewController: settings, sender: sender)
//                } else {
//                    self.animator = self.presentViewControllerModal(controller: settings)
//                }
//            }))
//
//            alert.addAction(UIAlertAction(title: "Online Users", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserList") as! UserListViewController
//                let query = User.query()!
//                query.whereKeyExists("aozoraUsername")
//                query.whereKey("active", equalTo: true)
//                query.limit = 100
//                userListController.initWithQuery(query, title: "Online Users")
//
//                self.presentSmallViewController(viewController: userListController, sender: sender)
//            }))
//
//            alert.addAction(UIAlertAction(title: "New Users", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let userListController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserList") as! UserListViewController
//                let query = User.query()!
//                query.orderByDescending("joinDate")
//                query.whereKeyExists("aozoraUsername")
//                query.limit = 100
//                userListController.initWithQuery(query, title: "New Users")
//                self.presentSmallViewController(viewController: userListController, sender: sender)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    // MARK: - Overrides
//
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//
//        let topSpace = tableView.tableHeaderView!.bounds.size.height - 44 - scrollView.contentOffset.y
//        if topSpace < 64 {
//            segmentedControlTopSpaceConstraint.constant = 64
//        } else {
//            segmentedControlTopSpaceConstraint.constant = topSpace
//        }
//    }
//}
//
//// MARK: - EditProfileViewControllerProtocol
//extension ProfileViewController: EditProfileViewControllerProtocol {
//
//    func editProfileViewControllerDidEditedUser(user: User) {
//        userProfile = user
//        fetchUserDetails(username: user.kurozoraUsername)
//    }
    @IBAction func settingsBtnPressed(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "settings", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsController") as! UINavigationController
        self.show(vc, sender: self)
    }
}
