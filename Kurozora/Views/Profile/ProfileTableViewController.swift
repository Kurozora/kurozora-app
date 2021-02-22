//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MobileCoreServices

class ProfileTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileNavigationItem: UINavigationItem!

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var onlineIndicatorLabel: KSecondaryLabel!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bioTextView: KTextView!

	@IBOutlet weak var followButton: KTintedButton!

	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var reputationButton: KButton!
	@IBOutlet weak var badgesButton: KButton!
	@IBOutlet weak var followingButton: KButton!
	@IBOutlet weak var followersButton: KButton!

	@IBOutlet weak var proBadgeButton: UIButton!
	@IBOutlet weak var tagBadgeButton: UIButton!

	@IBOutlet weak var selectBannerImageButton: KButton!
	@IBOutlet weak var selectProfileImageButton: KButton!
	@IBOutlet weak var editProfileButton: KTintedButton!

	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var userID = User.current?.id ?? 0
	var user: User! = User.current {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.userID = self.user.id

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing profile messages...")
			#endif

			self.configureProfile()
		}
	}

	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if self.dismissButtonIsEnabled {
				self.enableDismissButton()
			}
		}
	}
	var feedMessages: [FeedMessage] = [] {
		didSet {
			self.tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				self.toggleEmptyDataView()
			}

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
			#endif
		}
	}
	var nextPageURL: String?

	var currentImageView: UIImageView?
	var placeholderText = "Describe yourself!"
	var editingMode: Bool = false

	var imagePicker = UIImagePickerController()
	var profileImageFilePath: String? = nil
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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/**
		Initialize a new instance of ProfileTableViewController with the given user id.

		- Parameter userID: The user id to use when initializing the view.

		- Returns: an initialized instance of ProfileTableViewController.
	*/
	static func `init`(with userID: Int) -> ProfileTableViewController {
		if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
			profileTableViewController.userID = userID
			return profileTableViewController
		}

		fatalError("Failed to instantiate ProfileTableViewController with the given user id.")
	}

	/**
		Initialize a new instance of ProfileTableViewController with the given user object.

		- Parameter user: The `User` object to use when initializing the view controller.

		- Returns: an initialized instance of ProfileTableViewController.
	*/
	static func `init`(with user: User) -> ProfileTableViewController {
		if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
			profileTableViewController.user = user
			return profileTableViewController
		}

		fatalError("Failed to instantiate ProfileTableViewController with the given User object.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFTMessageDidUpdate, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif

		// Fetch posts
		DispatchQueue.global(qos: .background).async {
			self.fetchUserDetails()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		self.fetchUserDetails()
	}

	override func configureEmptyDataView() {
		// MARK: - HERE: Look at this
//		let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2

		var detailString: String

		if self.userID == User.current?.id {
			detailString = "There are no messages on your feed!"
		} else {
			detailString = "There are no messages on this feed!"
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.comment()!)
		emptyBackgroundView.configureLabels(title: "No Posts", detail: detailString)

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/**
		Updates the feed message with the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func updateFeedMessage(_ notification: NSNotification) {
		// Start delete process
		self.tableView.performBatchUpdates({
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.tableView.reloadSections([indexPath.section], with: .none)
			}
		}, completion: nil)
	}

	/// Fetches posts for the user whose page is being viewed.
	func fetchFeedMessages() {
		KService.getFeedMessages(forUserID: self.userID, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessageResponse):
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.feedMessages = []
					}

					// Append new data and save next page url
					self.feedMessages.append(contentsOf: feedMessageResponse.data)
					self.nextPageURL = feedMessageResponse.next
				}
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/// Fetches user detail.
	private func fetchUserDetails() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing profile details...")
			#endif
		}

		KService.getProfile(forUserID: self.userID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let users):
				DispatchQueue.main.async {
					self.user = users.first
				}
			case .failure: break
			}
		}

		self.fetchFeedMessages()
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		// Configure username
		usernameLabel.text = self.user?.attributes.username
		usernameLabel.isHidden = false

		// Configure online status
		onlineIndicatorLabel.text = self.user?.attributes.activityStatus.stringValue
		onlineIndicatorLabel.isHidden = false

		// Configure profile image
		profileImageView.image = self.user?.attributes.profileImage

		// Configure banner image
		if let bannerImageURL = self.user?.attributes.bannerImageURL {
			bannerImageView.setImage(with: bannerImageURL, placeholder: R.image.placeholders.userBanner()!)
		}

		// Configure user bio
		if let biography = self.user?.attributes.biography {
			self.bioTextView.text = biography
		}

		// Configure reputation count
		if let reputationCount = self.user?.attributes.reputationCount {
			let count = NSAttributedString(string: reputationCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nReputation", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let reputationButtonTitle = NSMutableAttributedString()
			reputationButtonTitle.append(count)
			reputationButtonTitle.append(title)

			self.reputationButton.setAttributedTitle(reputationButtonTitle, for: .normal)
		}

		// Configure following & followers count
		if let followingCount = self.user?.attributes.followingCount {
			let count = NSAttributedString(string: followingCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowing", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followingButtonTitle = NSMutableAttributedString()
			followingButtonTitle.append(count)
			followingButtonTitle.append(title)

			self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		}

		if let followerCount = self.user?.attributes.followerCount {
			let count = NSAttributedString(string: followerCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowers", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followersButtonTitle = NSMutableAttributedString()
			followersButtonTitle.append(count)
			followersButtonTitle.append(title)

			self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		}

		// Configure edit button
		self.editProfileButton.isHidden = !(self.user?.id == User.current?.id)

		// Configure follow button
		self.updateFollowButton()

		// Configure pro badge
		self.proBadgeButton.isHidden = !(self.user?.attributes.isPro ?? false)

		// Configure badge & badge button
		if let badges = self.user?.relationships?.badges?.data {
			// Configure user badge (a.k.a tag)
			if !badges.isEmpty {
				self.tagBadgeButton.isHidden = false
				for badge in badges {
					self.tagBadgeButton.setTitle(badge.attributes.name, for: .normal)
					self.tagBadgeButton.setTitleColor(UIColor(hexString: badge.attributes.textColor), for: .normal)
					self.tagBadgeButton.backgroundColor = UIColor(hexString: badge.attributes.backgroundColor)
					self.tagBadgeButton.borderColor = UIColor(hexString: badge.attributes.textColor)
					self.profileImageView.borderColor = UIColor(hexString: badge.attributes.textColor)
					break
				}
			} else {
				self.tagBadgeButton.isHidden = true
			}

			// Configure badge button
			let count = NSAttributedString(string: "\(badges.count)", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nBadges", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let badgesButtonTitle = NSMutableAttributedString()
			badgesButtonTitle.append(count)
			badgesButtonTitle.append(title)

			self.badgesButton.setAttributedTitle(badgesButtonTitle, for: .normal)
		}

		// Configure AutoLayout
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
			UIView.animate(withDuration: 0.5) {
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
		var bioText: String? = bioTextView.text.trimmed
		var bannerImage = bannerImageView.image
		var bioTextUnchanged = false

		// If everything is the same then dismiss and don't send a request to apply new information.
		if self.bioTextCache == self.placeholderText,
		   self.bioTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
			bioTextUnchanged = true
			bioText = nil
		}

		if bioTextUnchanged &&
			self.profileImageFilePath == nil,
			self.bannerImageCache == bannerImage {
			// Nothing to change, clear the cache.
			self.bioTextCache = nil
			self.profileImageCache = nil
			self.bannerImageCache = nil
			self.editMode(false)
			return
		}

		// If the banner is the same, then ignore.
		if self.bannerImageCache == bannerImage {
			bannerImage = UIImage().cropped(to: .zero)
		}

		// User wants to save changes, clear the cache.
		self.bioTextCache = nil
		self.profileImageCache = nil
		self.bannerImageCache = nil

		KService.updateInformation(biography: bioText, bannerImage: bannerImage, profileImageFilePath: profileImageFilePath) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				self.editMode(false)
			case .failure: break
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
		if let favoriteShowsCollectionViewController = R.storyboard.favorites.favoriteShowsCollectionViewController() {
			favoriteShowsCollectionViewController.user = self.user
			favoriteShowsCollectionViewController.dismissButtonIsEnabled = true

			let kNavigationViewController = KNavigationController(rootViewController: favoriteShowsCollectionViewController)
			self.present(kNavigationViewController, animated: true)
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList(_ sender: UIBarButtonItem) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			// Go to last watched episode
			if User.isSignedIn {
				let showFavoriteShowsList = UIAlertAction.init(title: "Favorite shows", style: .default, handler: { (_) in
					self?.showFavoriteShowsList()
				})
				showFavoriteShowsList.setValue(UIImage(systemName: "heart.circle"), forKey: "image")
				showFavoriteShowsList.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(showFavoriteShowsList)
			}
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user?.attributes.followStatus ?? .disabled
		switch followStatus {
		case .followed:
			self.followButton.setTitle("✓ Following", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle("＋ Follow", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle("＋ Follow", for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	// MARK: - IBActions
	@IBAction func editProfileButtonPressed(_ sender: UIButton) {
		// Cache current profile data
		self.bioTextCache = self.bioTextView.text.isNilOrEmpty ? placeholderText : self.bioTextView.text.trimmed
		self.profileImageCache = self.profileImageView.image
		self.bannerImageCache = self.bannerImageView.image

		self.editMode(true)
	}

	@IBAction func followButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			KService.updateFollowStatus(forUserID: self.user.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let followUpdate):
					self.user?.attributes.update(using: followUpdate)
					self.updateFollowButton()
				case .failure: break
				}
			}
		}
	}

	@IBAction func moreBarButtonPressed(_ sender: UIBarButtonItem) {
		self.showActionList(sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.profileTableViewController.badgeSegue.identifier {
			if let badgesTableViewController = segue.destination as? BadgesTableViewController {
				badgesTableViewController.user = self.user
			}
		} else if let followTableViewController = segue.destination as? FollowTableViewController {
			followTableViewController.user = self.user

			if segue.identifier == R.segue.profileTableViewController.followingSegue.identifier {
				followTableViewController.followList = .following
			} else if segue.identifier == R.segue.profileTableViewController.followersSegue.identifier {
				followTableViewController.followList = .followers
			}
		} else if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
			if let feedMessageID = sender as? Int {
				fmDetailsTableViewController.feedMessageID = feedMessageID
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.feedMessages.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedMessageCell: BaseFeedMessageCell!

		if feedMessages[indexPath.section].attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
		}

		feedMessageCell.delegate = self
		feedMessageCell.liveReplyEnabled = User.current?.id == self.userID
		feedMessageCell.liveReShareEnabled = User.current?.id == self.userID
		feedMessageCell.feedMessage = self.feedMessages[indexPath.section]
		return feedMessageCell
	}
}

// MARK: - KTableViewDataSource
extension ProfileTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			FeedMessageCell.self,
			FeedMessageReShareCell.self
		]
	}
}

// MARK: - BaseFeedMessageCellDelegate
extension ProfileTableViewController: BaseFeedMessageCellDelegate {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].heartMessage(via: self, userInfo: ["indexPath": indexPath])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressMoreButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].actionList(on: self, button, userInfo: [
				"indexPath": indexPath,
				"liveReplyEnabled": cell.liveReplyEnabled,
				"liveReShareEnabled": cell.liveReShareEnabled
			])
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ProfileTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.prepend(feedMessage)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.profileTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.currentImageView?.image = editedImage
		}

		if let imageURL = info[.imageURL] as? URL {
			profileImageFilePath = imageURL.absoluteString
		}

		// Dismiss the UIImagePicker after selection
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
			if User.isPro {
				imagePicker.mediaTypes = [(kUTTypeGIF as String), (kUTTypePNG as String), (kUTTypeJPEG as String)]
			} else {
				imagePicker.mediaTypes = [(kUTTypePNG as String), (kUTTypeJPEG as String)]
			}
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
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
		let actionSheetAlertController = UIAlertController.actionSheet(title: "Profile Photo", message: "Choose an awesome photo 😉") { [weak self] actionSheetAlertController in
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self?.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self?.openPhotoLibrary()
			}))
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
			popoverController.permittedArrowDirections = .up
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	@IBAction func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = self.bannerImageView
		let actionSheetAlertController = UIAlertController.actionSheet(title: "Banner Photo", message: "Choose a breathtaking photo 🌄") { [weak self] actionSheetAlertController in
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self?.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self?.openPhotoLibrary()
			}))
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
			popoverController.permittedArrowDirections = .up
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
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
