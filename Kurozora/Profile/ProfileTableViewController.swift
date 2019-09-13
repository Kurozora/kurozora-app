//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import FLAnimatedImage
import Kingfisher
import SCLAlertView
import SwiftyJSON
import SwiftTheme

class ProfileTableViewController: UITableViewController {
	@IBOutlet weak var profileNavigationItem: UINavigationItem!

	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var profileBorderView: UIView! {
		didSet {
			profileBorderView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var bannerImageView: UIImageView!
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

	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var reputationButton: UIButton! {
		didSet {
			reputationButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var badgesButton: UIButton! {
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

	var bannerImageViewHeightConstraint: NSLayoutConstraint?
	var currentImageView: UIImageView?

	var user: User? {
		didSet {
			self.configureProfile()
			self.tableView.reloadData()
		}
	}
	var otherUserID: Int? = nil {
		didSet {
			if otherUserID != nil {
				enableDismissButton()
			}
		}
	}
	var feedPostElement: [FeedPostElement]? = nil
	var editingMode: Bool = false

	var imagePicker = UIImagePickerController()
	var oldLeftBarItems: [UIBarButtonItem]?
	var oldRightBarItems: [UIBarButtonItem]?

	var bioTextCache: String?
	var profileImageCache: UIImage?
	var bannerImageCache: UIImage?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup banner image height
		self.bannerImageViewHeightConstraint = bannerImageView.heightAnchor.constraint(equalToConstant: view.height / 3)
		self.bannerImageViewHeightConstraint?.isActive = true

		// Setup biography text delegate
		self.bioTextView.delegate = self

		// Fetch user details
		if otherUserID != nil {
			fetchUserDetails(for: otherUserID)
			//			profileNavigationItem.leftBarButtonItems?.remove(at: 1)
		} else {
			fetchUserDetails(for: User.currentID)
			//			profileNavigationItem.leftBarButtonItems?.remove(at: 0)
		}

		// Setup refresh controller
		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh posts!", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		refreshControl?.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)

		// Fetch posts
		fetchPosts()

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	// MARK: - Prepare for segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "BadgeSegue" {
			let vc = segue.destination as! BadgesTableViewController
			vc.badges = user?.profile?.badges
		} else if let followTableViewController = segue.destination as? FollowTableViewController {
			followTableViewController.userID = otherUserID ?? User.currentID
			if segue.identifier == "FollowingSegue" {
				followTableViewController.followList = "following"
			} else if segue.identifier == "FollowersSegue" {
				followTableViewController.followList = "followers"
			}
		}
	}

	// MARK: - Functions
	/**
	Instantiates and returns a view controller from the relevant storyboard.

	- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "profile", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController")
	}

	/**
	Refresh the posts data by fetching new items from the server.

	- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshPostsData(_ sender: Any) {
		// Fetch posts data
		refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing posts...", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		fetchPosts()
	}

	/// Fetches posts for the user whose page is being viewed.
	private func fetchPosts() {
		self.tableView.reloadData()
		self.refreshControl?.endRefreshing()
	}

	/**
	Fetches user detail for the given user id.

	- Parameter userID: The user id for which the details should be fetched.
	*/
	private func fetchUserDetails(for userID: Int?) {
		guard let userID = userID else { return }
		Service.shared.getUserProfile(userID, withSuccess: { user in
			DispatchQueue.main.async {
				self.user = user
			}
		})
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		guard let user = user else { return }
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		// Setup username
		if let username = user.profile?.username, !username.isEmpty {
			usernameLabel.text = username
		} else {
			usernameLabel.text = "Unknown"
		}

		// Setup profile image
		if let profileImage = user.profile?.profileImage, !profileImage.isEmpty {
			let profileImage = URL(string: profileImage)
			let resource = ImageResource(downloadURL: profileImage!)
			profileImageView.kf.indicatorType = .activity
			profileImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])

			let cache = ImageCache.default
			cache.store(profileImageView.image!, forKey: "currentprofileImageView")
		} else {
			profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
		}

		// Setup banner image
		if let banner = user.profile?.banner, !banner.isEmpty {
			let banner = URL(string: banner)
			let resource = ImageResource(downloadURL: banner!)
			bannerImageView.kf.indicatorType = .activity
			bannerImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_banner_image"))
		} else {
			bannerImageView.image = #imageLiteral(resourceName: "default_banner_image")
		}

		// Setup user bio
		if let bio = user.profile?.bio, !bio.isEmpty {
			self.bioTextView.text = bio
		}

		// Setup reputation count
		if let reputationCount = user.profile?.reputationCount {
			let count = NSAttributedString(string: "\((reputationCount >= 10000) ? reputationCount.kFormatted : "\(reputationCount)")", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.textColor.stringValue) ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nReputation", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.subTextColor.stringValue) ?? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let reputationButtonTitle = NSMutableAttributedString()
			reputationButtonTitle.append(count)
			reputationButtonTitle.append(title)

			self.reputationButton.setAttributedTitle(reputationButtonTitle, for: .normal)
		}

		// Setup following & followers count
		if let followingCount = user.profile?.followingCount {
			let count = NSAttributedString(string: "\((followingCount >= 10000) ? followingCount.kFormatted : "\(followingCount)")", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.textColor.stringValue) ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowing", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.subTextColor.stringValue) ?? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followingButtonTitle = NSMutableAttributedString()
			followingButtonTitle.append(count)
			followingButtonTitle.append(title)

			self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		}

		if let followerCount = user.profile?.followerCount {
			let count = NSAttributedString(string: "\((followerCount >= 10000) ? followerCount.kFormatted : "\(followerCount)")", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.textColor.stringValue) ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowers", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.subTextColor.stringValue) ?? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followersButtonTitle = NSMutableAttributedString()
			followersButtonTitle.append(count)
			followersButtonTitle.append(title)

			self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		}

		// Setup follow button
		if otherUserID == User.currentID || otherUserID == nil {
			followButton.isHidden = true
			editProfileButton.isHidden = false
		} else {
			if let currentlyFollowing = user.profile?.following, currentlyFollowing == true {
				followButton.setTitle("✓ Following", for: .normal)
			} else {
				followButton.setTitle("＋ Follow", for: .normal)
			}

			followButton.isHidden = false
			editProfileButton.isHidden = true
		}

		// Setup pro badge
		proBadgeButton.isHidden = true
		if let proBadge = user.profile?.proBadge, !String(proBadge).isEmpty {
			if proBadge {
				self.proBadgeButton.isHidden = false
				self.proBadgeButton.setTitle("PRO", for: .normal)
			}
		}

		// Setup badge & badge button
		if let badges = user.profile?.badges {
			// Setup user badge (a.k.a tag)
			if !badges.isEmpty {
				self.tagBadgeButton.isHidden = false
				for badge in badges {
					self.tagBadgeButton.setTitle(badge.text, for: .normal)
					self.tagBadgeButton.setTitleColor(UIColor(hexString: badge.textColor ?? "#00ABF1"), for: .normal)
					self.tagBadgeButton.backgroundColor = UIColor(hexString: badge.backgroundColor ?? "#B6EAFF")
					self.tagBadgeButton.borderColor = UIColor(hexString: badge.textColor ?? "#00ABF1")
					self.profileBorderView.borderColor = UIColor(hexString: badge.textColor ?? "#00ABF1")
					break
				}
			} else {
				self.tagBadgeButton.isHidden = true
			}

			// Setup badge button
			let count = NSAttributedString(string: "\(badges.count)", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.textColor.stringValue) ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nBadges", attributes: [
				NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.subTextColor.stringValue) ?? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let badgesButtonTitle = NSMutableAttributedString()
			badgesButtonTitle.append(count)
			badgesButtonTitle.append(title)

			self.badgesButton.setAttributedTitle(badgesButtonTitle, for: .normal)
		}

		// Setup AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Hides and unhides elements to prepare for starting and ending of the edit mode.
	private func editMode(_ enabled: Bool) {
		editingMode = enabled
		if enabled {
			UIView.animate(withDuration: 0.5) {
				self.buttonsStackView.alpha = 0.5
				self.buttonsStackView.isUserInteractionEnabled = false

				// Hide edit button
				self.editProfileButton.alpha = 0

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

				// Stop scrolling
				self.tableView.isScrollEnabled = false
				self.tableView.visibleCells.forEach { $0.alpha = 0.5; $0.isUserInteractionEnabled = false }

				// Setup bio text if necessary
				if self.bioTextView.text.isEmpty {
					self.bioTextView.text = "Describe yourself!"
				}
			}

			// Enable bio editing
			self.bioTextView.isEditable = true
		} else {
			UIView.animate(withDuration: 1) {
				self.buttonsStackView.alpha = 1
				self.buttonsStackView.isUserInteractionEnabled = true

				// Unhide edit button
				self.editProfileButton.alpha = 1

				// Hide select buttons
				self.selectProfileImageButton.alpha = 0
				self.selectBannerImageButton.alpha = 0

				// Show relevant actions
				self.profileNavigationItem.setLeftBarButton(nil, animated: true)
				self.profileNavigationItem.setRightBarButton(nil, animated: true)

				self.profileNavigationItem.setLeftBarButtonItems(self.oldLeftBarItems, animated: true)
				self.profileNavigationItem.setRightBarButtonItems(self.oldRightBarItems, animated: true)

				// Enable scrolling
				self.tableView.isScrollEnabled = true
				self.tableView.visibleCells.forEach { $0.alpha = 1; $0.isUserInteractionEnabled = true }

				// Reset bio text if necessary
				if self.bioTextView.text == "Describe yourself!" {
					self.bioTextView.text = ""
				}
			}

			// Disable bio editing
			self.bioTextView.isEditable = false
		}
	}

	/**
	Cancel profile edit mode and return to view mode.

	- Parameter sender: The object requesting the cancelation of the edit mode.
	*/
	@objc func cancelProfileEdit(_ sender: Any) {
		// User doesn't want changes to be saved, pute everything back.
		self.bioTextView.text = self.bioTextCache
		self.profileImageView.image = self.profileImageCache
		self.bannerImageView.image = self.bannerImageCache

		// Return to view mode
		editMode(false)
		self.tableView.updateHeaderViewFrame()
	}

	/**
	Apply profile changes.

	- Parameter sender: The object requesting the changes to be applied.
	*/
	@objc func applyProfileEdit(_ sender: UIBarButtonItem) {
		guard let bioText = bioTextView.text else { return }
		guard let profileImage = profileImageView.image else { return }
		guard let bannerImage = bannerImageView.image else { return }
		var shouldUpdate = true

		if self.bioTextCache == bioText && self.profileImageCache == profileImage && self.bannerImageCache == bannerImage {
			shouldUpdate = false
			self.editMode(shouldUpdate)
		}

		// User wants to save changes, clear the cache.
		self.bioTextCache = nil
		self.profileImageCache = nil
		self.bannerImageCache = nil

		if shouldUpdate {
			Service.shared.updateInformation(withBio: bioText, profileImage: profileImage, bannerImage: bannerImage) { (update) in
				if update {
					self.editMode(!update)
				}
			}
		}
	}

	/// Enable and show the dismiss button.
	func enableDismissButton() {
		// Save old actions
		self.oldLeftBarItems = self.profileNavigationItem.leftBarButtonItems

		// Remove old actions
		self.profileNavigationItem.setLeftBarButton(nil, animated: true)

		// Set new actions
		let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissButtonPressed))
		self.profileNavigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
	}

	/// Dismiss the view. Used by the dismiss button when viewing other users' profile.
	@objc fileprivate func dismissButtonPressed() {
		dismiss(animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func editProfileButtonPressed(_ sender: UIButton) {
		// Cache current profile data
		self.bioTextCache = self.bioTextView.text
		self.profileImageCache = self.profileImageView.image
		self.bannerImageCache = self.bannerImageView.image

		editMode(true)
	}

	@IBAction func followButtonPressed(_ sender: UIButton) {
		let follow = user?.profile?.following ?? false ? 0 : 1

		Service.shared.follow(follow, user: otherUserID) { (success) in
			if success {
				if follow == 0 {
					sender.setTitle("＋ Follow", for: .normal)
					self.user?.profile?.following = false
				} else {
					sender.setTitle("✓ Following", for: .normal)
					self.user?.profile?.following = true
				}
			}
		}
	}

	@IBAction func showProfileImage(_ sender: AnyObject) {
		if let profileImage = user?.profile?.profileImage, !profileImage.isEmpty {
			presentPhotoViewControllerWith(url: profileImage, from: profileImageView)
		} else {
			presentPhotoViewControllerWith(string: "default_profile_image", from: profileImageView)
		}
	}

	@IBAction func showBanner(_ sender: AnyObject) {
		if let banner = user?.profile?.banner, !banner.isEmpty {
			presentPhotoViewControllerWith(url: banner, from: bannerImageView)
		} else {
			presentPhotoViewControllerWith(string: "default_banner_image", from: bannerImageView)
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let postCount = feedPostElement?.count else { return 1 }
		return postCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if feedPostElement == nil {
			let emptyProfileCell = tableView.dequeueReusableCell(withIdentifier: "EmptyProfileCell") as! EmptyProfileCell
			var title = "There are no posts on your timeline!"
			if otherUserID != nil {
				title = "There are no posts on this timeline! Be the first to post :D"
			}
			emptyProfileCell.title = title
			return emptyProfileCell
		}

		let feedPostCell = tableView.dequeueReusableCell(withIdentifier: "FeedPostCell") as! FeedPostCell
		feedPostCell.feedPostElement = feedPostElement?[indexPath.row]
		return feedPostCell
	}
}

// MARK: - UITableViewDelegate
extension ProfileTableViewController {
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.currentImageView?.image = editedImage
		}

		//Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			imagePicker.delegate = self

			self.present(imagePicker, animated: true, completion: nil)
		} else {
			SCLAlertView().showWarning("Well, this is awkward.", subTitle: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self

		self.present(imagePicker, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = self.profileImageView
		let alert = UIAlertController(title: "Profile Photo", message: "Choose an awesome photo 😉", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		if UIDevice.isPad {
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		}

		self.present(alert, animated: true, completion: nil)
	}

	@IBAction func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = self.bannerImageView
		let alert = UIAlertController(title: "Banner Photo", message: "Choose a breathtaking photo 🌄", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		if UIDevice.isPad {
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		}

		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - UITextViewDelegate
extension ProfileTableViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		bioTextCache = textView.text
		if textView.text == "Describe yourself!" && editingMode {
			textView.text = ""
		}
	}

	func textViewDidChange(_ textView: UITextView) {
		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text == "" && editingMode {
			textView.text = "Describe yourself!"
		}
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
//        case .feed:
//            let followingQuery = userProfile!.following().query()
//            followingQuery.orderByDescending("activeStart")
//            followingQuery.limit = 1000
//            innerQuery.whereKey("userTimeline", matchesKey: "objectId", inQuery: followingQuery)
//        case .popular:
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
//                let userListController = UIStoryboard(name: "profile", bundle: nil).instantiateViewController(withIdentifier: "FollowTableViewController") as! UserListViewController
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
