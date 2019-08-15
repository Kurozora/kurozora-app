//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift
import FLAnimatedImage
import Kingfisher
import SCLAlertView
import SwiftyJSON
//import XCDYouTubeKit

class ProfileTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	@IBOutlet weak var profileNavigationItem: UINavigationItem!

	@IBOutlet weak var userAvatar: UIImageView!
	@IBOutlet weak var profileView: UIView! {
		didSet {
			profileView.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var userBanner: UIImageView!
	@IBOutlet weak var bioTextView: UITextView! {
		didSet {
			bioTextView.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var followButton: UIButton! {
		didSet {
			followButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			followButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}


	@IBOutlet weak var reputationButton: UIButton! {
		didSet {
			reputationButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var badgesButton: UIButton!  {
		didSet {
			badgesButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var followingButton: UIButton! {
		didSet {
			followingButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var followersButton: UIButton! {
		didSet {
			followersButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}

	@IBOutlet weak var proBadgeButton: UIButton!
	@IBOutlet weak var tagBadgeButton: UIButton!

	@IBOutlet weak var selectBannerImageButton: UIButton!
	@IBOutlet weak var selectProfileImageButton: UIButton!
	@IBOutlet weak var editProfileButton: UIButton! {
		didSet {
			editProfileButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			editProfileButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	enum SelectedFeedStyle: Int {
        case Feed = 0
        case Popular
        case Global
        case Profile
    }

    var user: User?
	var otherUserID: Int?
	var posts: [JSON]?

	var imagePicker = UIImagePickerController()
	var oldLeftBarItems: [UIBarButtonItem]?
	var oldRightBarItems: [UIBarButtonItem]?
	var bioTextCache: String?
	var profileImageCache: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		if let otherUserID = otherUserID, otherUserID != 0 {
			fetchUserDetails(with: otherUserID)
//			profileNavigationItem.leftBarButtonItems?.remove(at: 1)
		} else if let currentID = User.currentID, String(currentID) != "" {
			fetchUserDetails(with: currentID)
//			profileNavigationItem.leftBarButtonItems?.remove(at: 0)
		}

		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh posts", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		refreshControl?.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)

		// Fetch posts
		fetchPosts()

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		
		// Setup empty table view
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetView { (view) in
			var title = "There are no posts on this timeline! Be the first to post :D"
			if User.currentID == self.user?.profile?.id {
				title = "There are no posts on your timeline!"
			}

			view.titleLabelString(NSAttributedString(string: title))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
		}
    }

	// MARK: - Functions
    @objc private func refreshPostsData(_ sender: Any) {
		// Fetch posts data
		refreshControl?.attributedTitle = NSAttributedString(string: "Reloading posts", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		fetchPosts()
	}

    private func fetchPosts() {
        self.tableView.reloadData()
		self.refreshControl?.endRefreshing()
    }

//    override public func fetchPosts() {
//        super.fetchPosts()
//        let username = self.username ?? user!.kurozoraUsername
//        fetchUserDetails(username: username)
//    }

	func sizeHeaderToFit() {
		guard let header = tableView.tableHeaderView else {
			return
		}
		let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
		header.frame.size.height = height
		tableView.tableHeaderView = header
	}

	private func fetchUserDetails(with id: Int) {
        Service.shared.getUserProfile(id, withSuccess: { (user) in
            guard let user = user else { return }

			DispatchQueue.main.async {
            	self.user = user
            	self.updateViewWithUser(user)
			}
        })
    }

    private func updateViewWithUser(_ user: User?) {
        // Setup username
        if let username = user?.profile?.username, username != "" {
            usernameLabel.text = username
		} else {
			usernameLabel.text = "Unknown"
		}
        
        // Setup avatar
        if let avatar = user?.profile?.avatar, avatar != "" {
            let avatar = URL(string: avatar)
            let resource = ImageResource(downloadURL: avatar!)
            userAvatar.kf.indicatorType = .activity
            userAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])

			let cache = ImageCache.default
			cache.store(userAvatar.image!, forKey: "currentUserAvatar")
        } else {
            userAvatar.image = #imageLiteral(resourceName: "default_avatar")
        }

        // Setup banner
        if let banner = user?.profile?.banner, banner != "" {
            let banner = URL(string: banner)
            let resource = ImageResource(downloadURL: banner!)
            userBanner.kf.indicatorType = .activity
			userBanner.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_banner"))
        } else {
            userBanner.image = #imageLiteral(resourceName: "default_banner")
        }

        // Setup user bio
        if let bio = user?.profile?.bio, bio != "" {
            self.bioTextView.text = bio

			if (self.bioTextView.frame.height < 67) {
				self.bioTextView.sizeThatFits(CGSize(width: self.bioTextView.frame.width, height: self.bioTextView.frame.height))
			} else {
				self.bioTextView.sizeThatFits(CGSize(width: self.bioTextView.frame.width, height: 67))
			}
		}
        
        // Setup reputation count
        if let reputationCount = user?.profile?.reputationCount, reputationCount > 0 {
			self.reputationButton.setTitle("\((reputationCount >= 10000) ? reputationCount.kFormatted : "\(reputationCount)") Reputation", for: .normal)
        } else {
			self.reputationButton.setTitle("0 Reputation", for: .normal)
        }
        
        // Setup following & followers count
        if let followingCount = user?.profile?.followingCount, followingCount > 0 {
            self.followingButton.setTitle("\((followingCount >= 10000) ? followingCount.kFormatted : "\(followingCount)") Following", for: .normal)
        } else {
            self.followingButton.setTitle("0 Following", for: .normal)
        }
        
        if let followerCount = user?.profile?.followerCount, followerCount > 0 {
            self.followersButton.setTitle("\((followerCount >= 10000) ? followerCount.kFormatted : "\(followerCount)") Followers", for: .normal)
        } else {
            self.followersButton.setTitle("0 Followers", for: .normal)
        }
        
        // Setup follow button
        if otherUserID == User.currentID || otherUserID == nil {
            followButton.isHidden = true
			editProfileButton.isHidden = false
        } else {
			if let currentlyFollowing = user?.currentlyFollowing, currentlyFollowing == true {
				followButton.setTitle(" Following", for: .normal)
			} else {
				followButton.setTitle(" Follow", for: .normal)
			}

            followButton.isHidden = false
            editProfileButton.isHidden = true
        }

        // Setup pro badge
        proBadgeButton.isHidden = true
        if let proBadge = user?.profile?.proBadge, String(proBadge) != "" {
            if proBadge {
                self.proBadgeButton.isHidden = false
                self.proBadgeButton.setTitle("PRO", for: .normal)
            }
        }

		// Setup badges
		if let badges = user?.profile?.badges, badges != [] {
			self.tagBadgeButton.isHidden = false
			for badge in badges {
				self.tagBadgeButton.setTitle(badge["text"].stringValue, for: .normal)
				self.tagBadgeButton.setTitleColor(UIColor(hexString: badge["textColor"].stringValue), for: .normal)
				self.tagBadgeButton.backgroundColor = UIColor(hexString: badge["backgroundColor"].stringValue)
				self.tagBadgeButton.borderColor = UIColor(hexString: badge["backgroundColor"].stringValue)
				self.userAvatar.borderColor = UIColor(hexString: badge["textColor"].stringValue)
				break
			}
		} else {
			self.tagBadgeButton.isHidden = true
		}
    }

	@objc func cancelProfileEdit(_ sender: Any) {
		if let sender = sender as? Bool, !sender {
			// If user cacncels, pute everything back
			self.bioTextView.text = self.bioTextCache
			self.userAvatar.image = self.profileImageCache
		}

		UIView.animate(withDuration: 1) {
			// Setup edit view
			// Hide edit view
			self.selectProfileImageButton.alpha = 0
			self.selectBannerImageButton.alpha = 0

			// Unhide previously hidden items
			self.editProfileButton.alpha = 1
			self.tagBadgeButton.alpha = 1

			// Show relevant actions
			self.profileNavigationItem.setLeftBarButton(nil, animated: true)
			self.profileNavigationItem.setRightBarButton(nil, animated: true)

			self.profileNavigationItem.setLeftBarButtonItems(self.oldLeftBarItems, animated: true)
			self.profileNavigationItem.setRightBarButtonItems(self.oldRightBarItems, animated: true)

			// Disable bio editing
			self.bioTextView.isScrollEnabled = false
			self.bioTextView.isEditable = false

			// Header view size to fit
//			self.sizeHeaderToFit()
		}
	}

	@objc func applyProfileEdit(_ sender: Any) {
		guard let bioText = bioTextView.text else { return }
		guard let profileImage = userAvatar.image else { return }
		var shouldUpdate = true

		if self.bioTextCache == bioText && self.profileImageCache == profileImage {
			shouldUpdate = false
			self.cancelProfileEdit(shouldUpdate)
		} else if self.bioTextCache == bioText || self.profileImageCache == profileImage {
			shouldUpdate = true
		}

		// If user applies changes clear the cache
		self.bioTextCache = nil
		self.profileImageCache = nil

		if shouldUpdate {
			Service.shared.updateInformation(withBio: bioText, profileImage: profileImage) { (update) in
				if update {
					self.cancelProfileEdit(update)
				}
			}
		}
	}

    // MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		var follow = 1

		let title = sender.title(for: .normal)
		if title == " Following" {
			follow = 0
		} else {
			follow = 1
		}

		Service.shared.follow(follow, user: otherUserID) { (success) in
			if success {
				if title == " Following" {
					sender.setTitle(" Follow", for: .normal)
				} else {
					sender.setTitle(" Following", for: .normal)
				}
			}
		}
	}

	@IBAction func editProfileButtonPressed(_ sender: UIButton) {
		// Cache current profile data
		self.bioTextCache = self.bioTextView.text
		self.profileImageCache = self.userAvatar.image

		UIView.animate(withDuration: 0.5) {
			// Setup edit view
			// Hide distractions
			self.editProfileButton.alpha = 0
			self.tagBadgeButton.alpha = 0

			// Add relevant actions
			// Save old actions
			self.oldLeftBarItems = self.profileNavigationItem.leftBarButtonItems
			self.oldRightBarItems = self.profileNavigationItem.rightBarButtonItems

			// Remove old actions
			self.profileNavigationItem.setLeftBarButton(nil, animated: true)
			self.profileNavigationItem.setRightBarButton(nil, animated: true)

			// Set new actions
			let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelProfileEdit(_:)))
			let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.applyProfileEdit(_:)))
			self.profileNavigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
			self.profileNavigationItem.setRightBarButton(rightBarButtonItem, animated: true)

			// Enable other relevant actions
			self.selectProfileImageButton.alpha = 1
			self.selectBannerImageButton.alpha = 1

			// Enable bio editing
			self.bioTextView.isScrollEnabled = true
			self.bioTextView.isEditable = true

			// Header view size to fit
			self.sizeHeaderToFit()
		}
	}

	@IBAction func showAvatar(_ sender: AnyObject) {
        if let avatar = user?.profile?.avatar, avatar != ""  {
            presentPhotoViewControllerWith(url: avatar, from: userAvatar)
        } else {
            presentPhotoViewControllerWith(string: "default_avatar", from: userAvatar)
        }
    }
    
    @IBAction func showBanner(_ sender: AnyObject) {
        if let banner = user?.profile?.banner, banner != "" {
			presentPhotoViewControllerWith(url: banner, from: userBanner)
        } else {
            presentPhotoViewControllerWith(string: "default_banner", from: userBanner)
        }
    }

	@IBAction func dismissButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

//	@IBAction func settingsBtnPressed(_ sender: Any) {
//		let storyboard:UIStoryboard = UIStoryboard(name: "settings", bundle: nil)
//		let vc = storyboard.instantiateViewController(withIdentifier: "SettingsSplitViewController") as! SettingsSplitViewController
//		self.present(vc, animated: true, completion: nil)
//	}

	// MARK: - Prepare for segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "BadgeSegue" {
			let vc = segue.destination as! BadgesTableViewController
			vc.badges = user?.profile?.badges
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let postCount = posts?.count, postCount != 0 {
			return postCount
		}
		return 2
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedPostCell: FeedPostCell = tableView.dequeueReusableCell(withIdentifier: "FeedPostCell") as! FeedPostCell

		// Profile Image
		if let profileImage = posts?[indexPath.row]["profile_image"].stringValue, profileImage != "" {
			let profileImage = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImage!, cacheKey: "currentUserAvatar")
			feedPostCell.profileImageView?.kf.indicatorType = .activity
			feedPostCell.profileImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			feedPostCell.profileImageView?.image = #imageLiteral(resourceName: "default_avatar")
		}

		// Username
		if let username = posts?[indexPath.row]["username"].stringValue, username != "" {
			feedPostCell.usernameLabel?.text = username
		} else {
			feedPostCell.usernameLabel?.text = "Unknown"
		}

		// Other Username
		if let otherUsername = posts?[indexPath.row]["other_username"].stringValue, otherUsername != "" {
			feedPostCell.otherUserNameLabel?.text = otherUsername

			feedPostCell.userSeparatorLabel?.isHidden = false
			feedPostCell.otherUserNameLabel?.isHidden = false
		} else {
			feedPostCell.otherUserNameLabel?.isHidden = true
			feedPostCell.userSeparatorLabel?.isHidden = true
		}

		// Post
		if let postText = posts?[indexPath.row]["post"].stringValue, postText != "" {
			feedPostCell.postTextView?.text = postText
		} else {
			feedPostCell.postTextView?.text = ""
		}

		// Likes
		if let hearts = posts?[indexPath.row]["likes"].intValue, hearts != 0 {
			feedPostCell.heartButton?.setTitle(" \(hearts)", for: .normal)
		} else {
			feedPostCell.heartButton?.setTitle("", for: .normal)
		}

		// Comments
		if let comments = posts?[indexPath.row]["comments"].intValue, comments != 0 {
			feedPostCell.commentButton?.setTitle(" \(comments)", for: .normal)
		} else {
			feedPostCell.commentButton?.setTitle("", for: .normal)
		}

		// ReShare
		if let share = posts?[indexPath.row]["shares"].intValue, share != 0 {
			feedPostCell.shareButton?.setTitle(" \(share)", for: .normal)
		} else {
			feedPostCell.shareButton?.setTitle("", for: .normal)
		}

		return feedPostCell
	}
}

// MARK: - UITableViewDelegate
extension ProfileTableViewController {
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let editedImage = info[.editedImage] as? UIImage{
			self.userAvatar.image = editedImage
		}

		//Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	// Image picker
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		let alert = UIAlertController(title: "Profile Picture 🖼", message: "Choose an awesome picture 😉", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		// If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
		if UIDevice.isPad {
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		}

		alert.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)

		self.present(alert, animated: true, completion: nil)
	}

	// Open the camera
	func openCamera(){
		if(UIImagePickerController .isSourceTypeAvailable(.camera)){
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			imagePicker.delegate = self

			self.present(imagePicker, animated: true, completion: nil)
		}
		else{
			let alert  = UIAlertController(title: "⚠️ Warning ⚠️", message: "You don't seem to have a camera 😢", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}

	// Choose image from camera roll
	func openPhotoLibrary(){
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self

		self.present(imagePicker, animated: true, completion: nil)
	}
}

//    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
//        configureFetchController()
//    }
//
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
//        let selectedFeed = SelectedFeedStyle(rawValue: segmentedControl.selectedSegmentIndex)!
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
//        if UIDevice.isPad {
//            navigationController?.present(viewController, animated: true, completion: nil)
//        } else {
//            navigationController?.pushViewController(viewController, animated: true)
//        }
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
//                let editProfileController =  UIStoryboard(name: "profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfile") as! EditProfileViewController
//                editProfileController.delegate = self
//                if UIDevice.isPad {
//                    self.presentSmallViewController(viewController: editProfileController, sender: sender)
//                } else {
//                    self.present(editProfileController, animated: true, completion: nil)
//                }
//            }))
//
//            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let settings = UIStoryboard(name: "settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
//                if UIDevice.isPad {
//                    self.presentSmallViewController(viewController: settings, sender: sender)
//                } else {
//                    self.animator = self.presentViewControllerModal(controller: settings)
//                }
//            }))
//
//            alert.addAction(UIAlertAction(title: "Online Users", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let userListController = UIStoryboard(name: "profile", bundle: nil).instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
//
//                self.presentSmallViewController(viewController: userListController, sender: sender)
//            }))
//
//            alert.addAction(UIAlertAction(title: "New Users", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) -> Void in
//                let userListController = UIStoryboard(name: "profile", bundle: nil).instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
//	
//                self.presentSmallViewController(viewController: userListController, sender: sender)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
//        self.present(alert, animated: true, completion: nil)
//    }
