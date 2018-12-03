//
//  ProfileViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KDatabaseKit
import AXPhotoViewer
import EmptyDataSet_Swift
import FLAnimatedImage
import Kingfisher
import SCLAlertView
import SwiftyJSON
import UIImageColors
//import XCDYouTubeKit

class ProfileViewController: ThreadViewController, UITableViewDataSource, UITableViewDelegate, EmptyDataSetSource, EmptyDataSetDelegate {

    enum SelectedFeed: Int {
        case Feed = 0
        case Popular
        case Global
        case Profile
    }

	private let refreshControl = UIRefreshControl()

    var user: User?
	var posts: [JSON]?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBanner: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var activeAgo: UILabel!

    //    @IBOutlet weak var animeListButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!

    @IBOutlet weak var proBadge: UILabel!
    @IBOutlet weak var postsBadge: UILabel!
    @IBOutlet weak var tagBadge: UIButton!
    @IBOutlet weak var reputationBadge: DesignableLabel!
    
    @IBOutlet weak var moreSettingsButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var segmentedControlView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		//        if let profile = userProfile, profile.details.dataAvailable {
		//            updateFollowingButtons()
		//        }
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		if let id = user?.id, id != User.currentId() {
			fetchUserDetails(with: id)
		} else {
			if let id = User.currentId(), String(id) != "" {
				fetchUserDetails(with: id)
			}
		}

		// Add Refresh Control to Collection View
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}

		refreshControl.tintColor = UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		refreshControl.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)

		fetchPosts()

		//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")

		// Setup table view
		tableView.delegate = self
		tableView.dataSource = self

		// Setup empty table view
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self

		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "There are no posts on your timeline!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
		}

		tableView.rowHeight = UITableView.automaticDimension
    }
    @objc private func refreshPostsData(_ sender: Any) {
		// Fetch posts data
		refreshControl.attributedTitle = 			NSAttributedString(string: "Reloading posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 255/255, green: 174/255, blue: 30/255, alpha: 1.0)])
		fetchPosts()
	}

    private func fetchPosts() {
        self.tableView.reloadData()
		self.refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let postCount = posts?.count, postCount != 0 {
			return postCount
		}
		return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let timelinePostCell:TimelinePostCell = tableView.dequeueReusableCell(withIdentifier: "TimelinePostCell") as! TimelinePostCell

		// Profile Image
		if let profileImage = posts?[indexPath.row]["profile_image"].stringValue, profileImage != "" {
			let profileImage = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImage!)
			timelinePostCell.profileImageView.kf.indicatorType = .activity
			timelinePostCell.profileImageView.kf.setImage(with: resource, placeholder: UIImage(named: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
		}else {
			timelinePostCell.profileImageView.image = UIImage(named: "default_avatar")
		}

		// Username
		if let username = posts?[indexPath.row]["username"].stringValue, username != "" {
			timelinePostCell.userNameLabel.text = username
		} else {
			timelinePostCell.userNameLabel.text = "Unknown"
		}

		// Other Username
		if let otherUsername = posts?[indexPath.row]["other_username"].stringValue, otherUsername != "" {
			timelinePostCell.otherUserNameLabel.text = otherUsername

			timelinePostCell.userSeparatorLabel.isHidden = false
			timelinePostCell.otherUserNameLabel.isHidden = false
		} else {
			timelinePostCell.otherUserNameLabel.isHidden = true
			timelinePostCell.userSeparatorLabel.isHidden = true
		}

		// Post
		if let postText = posts?[indexPath.row]["post"].stringValue, postText != "" {
			timelinePostCell.postTextView.text = postText
		} else {
			timelinePostCell.postTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
		}

		// Likes
		if let likes = posts?[indexPath.row]["likes"].intValue, likes != 0 {
			timelinePostCell.likeLabel.text = "\(likes) Likes"
		} else {
			timelinePostCell.likeLabel.text = "0 Likes"
		}

		// Comments
		if let comments = posts?[indexPath.row]["comments"].intValue, comments != 0 {
			timelinePostCell.commentLabel.text = "\(comments) Comments"
		} else {
			timelinePostCell.commentLabel.text = "0 Comments"
		}

        return timelinePostCell
    }

//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
    func sizeHeaderToFit() {
        guard let header = tableView.tableHeaderView else {
            return
        }
        
        if user?.id != User.currentId() {
            segmentedControl.isHidden = true
        }

        header.setNeedsLayout()
        header.layoutIfNeeded()

        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.size.width

        let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = header.frame

        frame.size.height = height
        header.frame = frame
        tableView.tableHeaderView = header
    }

    // MARK: - Fetching
	
//    override public func fetchPosts() {
//        super.fetchPosts()
//        let username = self.username ?? user!.kurozoraUsername
//        fetchUserDetails(username: username)
//    }

	private func fetchUserDetails(with id: Int) {
//        if let _ = self.user {
//            configureFetchController()
//        }
        
        Service.shared.getUserProfile(id, withSuccess: { (user) in
            guard let user = user else { return }

			DispatchQueue.main.async {
            	self.user = user
            	self.updateViewWithUser(user)
			}
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting information", subTitle: errorMessage)
        }
    }

    private func updateViewWithUser(_ user: User?) {
        // Username
        if let username = user?.username, username != "" {
            usernameLabel.text = username
		} else {
			usernameLabel.text = "Unknown"
		}
        
        // Avatar
        if let avatar = user?.avatar, avatar != "" {
            let avatar = URL(string: avatar)
            let resource = ImageResource(downloadURL: avatar!)
            userAvatar.kf.indicatorType = .activity
            userAvatar.kf.setImage(with: resource, placeholder: UIImage(named: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }else {
            userAvatar.image = UIImage(named: "default_avatar")
        }

        // Banner
        if let banner = user?.banner, banner != "" {
            let banner = URL(string: banner)
            let resource = ImageResource(downloadURL: banner!)
            userBanner.kf.indicatorType = .activity
            userBanner.kf.setImage(with: resource, placeholder: UIImage(named: "colorful"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            
            if let userBanner = userBanner.image {
                let colors = userBanner.getColors()
                
                backgroundView.backgroundColor = colors.background
                segmentedControl.tintColor = colors.detail
                aboutLabel.textColor = colors.secondary
                postButton.backgroundColor = colors.primary
            }
        } else {
            userBanner.image = UIImage(named: "colorful")
        }
        
        // User bio
        if let bio = user?.bio, bio != "" {
            self.aboutLabel.text = bio
        } else {
            self.aboutLabel.text = ""
            self.aboutLabel.isHidden = true
            self.aboutButton.isHidden = true
        }
        
        // User activity
        if let activeEnd = user?.activeEnd, activeEnd != "" {
            let timeAgo = Date.timeAgo(activeEnd)
            let activeEndFormatted = timeAgo == "Just now" ? "Active now" : "\(timeAgo) ago"
            
            if let activeAgo = user?.active, String(activeAgo) != "" {
                self.activeAgo.text = activeAgo ? "Active now" : activeEndFormatted
            }
        } else {
            self.activeAgo.text = ""
        }
        
        // Post count
        if let postCount = user?.postCount, postCount > 0 {
            if postCount >= 1000 {
                self.postsBadge.text = "" + String(format: "%.1fk", Float(postCount-49)/1000.0 )
            } else {
                self.postsBadge.text = "" + String(postCount)
            }
        } else {
            self.postsBadge.text = "0"
        }
        
        // Reputation count
        if let reputationCount = user?.reputationCount, reputationCount > 0 {
            if reputationCount >= 10000 {
                self.reputationBadge.text = "" + String(format: "%.1fk", Float(reputationCount-49)/10000.0 )
            } else {
                self.reputationBadge.text = "" + String(reputationCount)
            }
        } else {
            self.postsBadge.text = "0"
        }
        
        // Following & Followers count
        if let following = user?.followingCount, following > 0 {
            self.followingButton.setTitle("\(following) Following", for: .normal)
        } else {
            self.followingButton.setTitle("0 Following", for: .normal)
        }
        
        if let follower = user?.followerCount, follower > 0 {
            self.followersButton.setTitle("\(follower) Followers", for: .normal)
        } else {
            self.followersButton.setTitle("0 Followers", for: .normal)
        }
        
        // Follow button
        if let id = user?.id, id != User.currentId() {
            followButton.isHidden = true
        } else {
            followButton.isHidden = false
            moreSettingsButton.isHidden = true
        }
        
        //            if user?.id != User.currentId() {
        //                let relationQuery = User.currentUser()!.following().query()
        //                relationQuery.whereKey("kurozoraUsername", equalTo: username)
        //
        //                relationQuery.findObjectsInBackgroundWithBlock { (result, error) -> Void in
        //                    if let _ = result?.last as? User {
        //                        // Following this user
        //                        self.followButton.setTitle("  Following", forState: .Normal)
        //                        user.followingThisUser = true
        //                    } else if let _ = error {
        //                        // TODO: Show error
        //
        //                    } else {
        //                        // NOT following this user
        //                        self.followButton.setTitle("  Follow", forState: .Normal)
        //                        user.followingThisUser = false
        //                    }
        //                    self.followButton.layoutIfNeeded()
        //                }
        //            }

//        if let _ = tabBarController {
//            navigationItem.leftBarButtonItem = nil
//        }

        // Pro badge
        proBadge.isHidden = true
        
        if let proBadge = user?.proBadge, String(proBadge) != "" {
            if proBadge {
                self.proBadge.isHidden = false
                self.proBadge.text = "PRO"
            }
        }

//        if let isAdmin = User.isAdmin() {
//            if isAdmin {
//                self.tagBadge.text = "Anime CEO"
//                self.tagBadge.textColor = UIColor.green
//                self.tagBadge.backgroundColor = UIColor.black
//            }
//        } else {}
		if let badges = user?.badges, badges != [] {
			for badge in badges {
				self.tagBadge.setTitle(badge["text"].stringValue, for: .normal)
				self.tagBadge.setTitleColor(UIColor(hexString: badge["textColor"].stringValue), for: .normal)
				self.tagBadge.backgroundColor = UIColor(hexString: badge["backgroundColor"].stringValue)
				break
			}
		} else {
			self.tagBadge.setTitle("Kokosei", for: .normal)
		}
    }

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
    // MARK: - IBAction
    @IBAction func showAvatar(_ sender: AnyObject) {
        if let avatar = user?.avatar, avatar != ""  {
            presentPhotoViewControllerWith(url: avatar)
        } else {
            presentPhotoViewControllerWith(string: "default_avatar")
        }
    }
    
    @IBAction func showBanner(_ sender: AnyObject) {
        if let banner = user?.banner, banner != "" {
            presentPhotoViewControllerWith(url: banner)
        } else {
            presentPhotoViewControllerWith(string: "placeholder_banner")
        }
    }

	//	MARK: - Prepare for segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "BadgeSegue") {
			let vc = segue.destination as! BadgesTableViewController
			vc.badges = user?.badges
		}
	}

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
//    @IBAction func showMoreSettings(sender: AnyObject) {
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

    // MARK: - Overrides

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}

// MARK: - EditProfileViewControllerProtocol
extension ProfileViewController: EditProfileViewControllerProtocol {
    func editProfileViewControllerDidEditedUser(user: User?) {
        self.user = user
        
        if let id = user?.id, String(id) != "" {
            self.fetchUserDetails(with: id)
        }
    }

    @IBAction func settingsBtnPressed(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "settings", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsSplitView") as! UISplitViewController
        self.present(vc, animated: true, completion: nil)
    }
}
