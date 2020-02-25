//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Kingfisher
import SCLAlertView
import SwiftTheme

class ProfileTableViewController: KTableViewController {
	// MARK: - IBOutlets
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
			bioTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	@IBOutlet weak var followButton: UIButton! {
		didSet {
			followButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			followButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreButton: UIButton! {
		didSet {
			moreButton.theme_tintColor = KThemePicker.tintColor.rawValue
			moreButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
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

	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	@IBOutlet weak var bannerImageViewHeightConstraint: NSLayoutConstraint!

	// MARK: - Properties
	var currentImageView: UIImageView?
	var placeholderText = "Describe yourself!"

	var user: User? {
		didSet {
			self.configureProfile()
			_prefersActivityIndicatorHidden = true
			self.tableView.reloadData()
		}
	}
	var userID: Int?
	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if dismissButtonIsEnabled {
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

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup banner image height
		self.bannerImageViewHeightConstraint.constant = view.height / 3
		self.view.setNeedsUpdateConstraints()
		self.view.layoutIfNeeded()

		// Fetch user details
		fetchUserDetails(for: userID ?? User.currentID)

		// Setup refresh controller
		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh posts!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.kurozora])
		refreshControl?.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)

		// Fetch posts
		DispatchQueue.global(qos: .background).async {
			self.fetchPosts()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			let detailLabel = self.userID == User.currentID || self.userID == nil ? "There are no posts on your timeline!" : "There are no posts on this timeline! Be the first to post :D"
			let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2

			view.titleLabelString(NSAttributedString(string: "No Posts", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabel, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(verticalOffset < 0 ? 0 : verticalOffset)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	/**
		Refresh the posts data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshPostsData(_ sender: Any) {
		// Fetch posts data
		refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing posts...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.kurozora])
		fetchPosts()
	}

	/// Fetches posts for the user whose page is being viewed.
	private func fetchPosts() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
		}
	}

	/**
		Fetches user detail for the given user id.

		- Parameter userID: The user id for which the details should be fetched.
	*/
	private func fetchUserDetails(for userID: Int?) {
		guard let userID = userID else { return }
		KService.shared.getUserProfile(userID, withSuccess: { user in
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
		if let profileImage = user.profile?.profileImage {
			if let usernameInitials = user.profile?.username?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)

				if self.userID == User.currentID {
					profileImageView.setImage(with: profileImage, cacheKey: "currentUserProfileImage", placeholder: placeholderImage)
				} else {
					profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
				}
			}
		}

		// Setup banner image
		if let bannerImage = user.profile?.banner {
			bannerImageView.setImage(with: bannerImage, placeholder: R.image.placeholders.banner_image()!)
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
		if self.userID == User.currentID || self.userID == nil {
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
				self.tableView.visibleCells.forEach {
					$0.alpha = 0.5
					$0.isUserInteractionEnabled = false
				}

				// Setup bio text if necessary
				self.textViewDidEndEditing(self.bioTextView)
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
				self.tableView.visibleCells.forEach {
					$0.alpha = 1
					$0.isUserInteractionEnabled = true
				}

				// Reset bio text if necessary
				if self.bioTextView.text == self.placeholderText {
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
		let bioText = bioTextView.text
		var profileImage = profileImageView.image
		var bannerImage = bannerImageView.image
		var shouldUpdate = true
		var shouldUpdateProfileImage = true

		// If everything is the same then dismiss and don't send a request to apply new information.
		if self.bioTextCache == bioText && self.profileImageCache == profileImage && self.bannerImageCache == bannerImage {
			shouldUpdate = false
			self.editMode(shouldUpdate)
		}

		// If the profile image the same, then ignore.
		if self.profileImageCache == profileImage {
			profileImage = UIImage()
			shouldUpdateProfileImage = false
		}

		// If the banner is the same, then ignore.
		if self.bannerImageCache == bannerImage {
			bannerImage = UIImage()
		}

		// User wants to save changes, clear the cache.
		self.bioTextCache = nil
		self.profileImageCache = nil
		self.bannerImageCache = nil

		if shouldUpdate {
			KService.shared.updateInformation(for: bioText, username: nil, profileImage: profileImage, bannerImage: bannerImage) { (update) in
				if update {
					self.editMode(!update)
					if shouldUpdateProfileImage {
						User.refreshProfileImage(with: profileImage)
					}
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

	/// Performs segue to `FavoriteShowsCollectionViewController` with `FavoriteShowsSegue` as the identifier.
	fileprivate func showFavoriteShowsList() {
		if let favoriteShowsCollectionViewController = R.storyboard.library.favoriteShowsCollectionViewController() {
			favoriteShowsCollectionViewController.userID = userID
			favoriteShowsCollectionViewController.username = user?.profile?.username
			favoriteShowsCollectionViewController.dismissButtonIsEnabled = true

			let kNavigationViewController = KNavigationController(rootViewController: favoriteShowsCollectionViewController)
			self.present(kNavigationViewController)
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Go to last watched episode
		if User.isSignedIn {
			let showFavoriteShowsList = UIAlertAction.init(title: "Favorite shows", style: .default, handler: { (_) in
				self.showFavoriteShowsList()
			})
			showFavoriteShowsList.setValue(R.image.symbols.heart_circle()!, forKey: "image")
			showFavoriteShowsList.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(showFavoriteShowsList)
		}

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = moreButton
			popoverController.sourceRect = moreButton.bounds
		}

		self.present(action, animated: true, completion: nil)
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
		WorkflowController.shared.isSignedIn {
			let follow = self.user?.profile?.following ?? false ? 0 : 1

			KService.shared.follow(follow, user: self.userID) { (success) in
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
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		showActionList()
	}

	@IBAction func showProfileImage(_ sender: AnyObject) {
		if let profileImage = user?.profile?.profileImage, !profileImage.isEmpty {
			presentPhotoViewControllerWith(url: profileImage, from: profileImageView)
		} else {
			presentPhotoViewControllerWith(image: profileImageView.image, from: profileImageView)
		}
	}

	@IBAction func showBanner(_ sender: AnyObject) {
		if let banner = user?.profile?.banner, !banner.isEmpty {
			presentPhotoViewControllerWith(url: banner, from: bannerImageView)
		} else {
			presentPhotoViewControllerWith(string: "default_banner_image", from: bannerImageView)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.profileTableViewController.badgeSegue.identifier {
			if let badgesTableViewController = segue.destination as? BadgesTableViewController {
				badgesTableViewController.userProfile = user?.profile
			}
		} else if let followTableViewController = segue.destination as? FollowTableViewController {
			followTableViewController.user = user?.profile

			if segue.identifier == R.segue.profileTableViewController.followingSegue.identifier {
				followTableViewController.followList = "Following"
			} else if segue.identifier == R.segue.profileTableViewController.followersSegue.identifier {
				followTableViewController.followList = "Followers"
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let postCount = feedPostElement?.count else { return 0 }
		return postCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let feedPostCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedPostCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.feedPostCell.identifier)")
		}
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
		if textView.text == placeholderText && textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue && editingMode {
			textView.text = ""
			textView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func textViewDidChange(_ textView: UITextView) {
		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty && editingMode {
			textView.text = placeholderText
			textView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}
}
