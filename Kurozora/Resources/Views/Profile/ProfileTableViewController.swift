//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ProfileTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileNavigationItem: UINavigationItem!
	@IBOutlet weak var postMessageButton: UIBarButtonItem!
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var onlineIndicatorView: UIView!
	@IBOutlet weak var onlineIndicatorContainerView: UIView!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bioTextView: KTextView!
	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!

	@IBOutlet weak var followButton: KTintedButton!

	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var achievementsButton: KButton!
	@IBOutlet weak var followingButton: KButton!
	@IBOutlet weak var followersButton: KButton!
	@IBOutlet weak var reviewsButton: KButton!

	@IBOutlet weak var selectBannerImageButton: KButton!
	@IBOutlet weak var selectProfileImageButton: KButton!
	@IBOutlet weak var editProfileButton: KTintedButton!

	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var userIdentity: UserIdentity? = nil
	var user: User! = User.current {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.userIdentity = UserIdentity(id: self.user.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
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

	var editingMode: Bool = false
	var currentImageView: String = ""
	var placeholderText = "Describe yourself!"
	var originalBioText: String? = nil {
		didSet {
			self.editedBioText = self.originalBioText
		}
	}
	var editedBioText: String? = nil {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}
	var originalProfileImage: UIImage! = UIImage() {
		didSet {
			self.editedProfileImage = self.originalProfileImage
		}
	}
	var editedProfileImage: UIImage! = UIImage() {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}
	var editedProfileImageURL: URL? = nil
	var originalBannerImage: UIImage! = UIImage() {
		didSet {
			self.editedBannerImage = self.originalBannerImage
		}
	}
	var editedBannerImage: UIImage! = UIImage() {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}
	var editedBannerImageURL: URL? = nil
	var hasChanges: Bool {
		return self.originalBioText != self.editedBioText
		|| self.profileImageHasChanges
		|| self.bannerImageHasChanges
	}
	var profileImageHasChanges: Bool {
		return !self.originalProfileImage.isEqual(to: self.editedProfileImage)
	}
	var bannerImageHasChanges: Bool {
		return !self.originalBannerImage.isEqual(to: self.editedBannerImage)
	}

	var oldLeftBarItems: [UIBarButtonItem]?
	var oldRightBarItems: [UIBarButtonItem]?

	// Styling
	var countValueAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign
		]
	}
	var countTitleAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign,
			NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2).bold
		]
	}

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
	/// Initialize a new instance of ProfileTableViewController with the given user id.
	///
	/// - Parameter userID: The user id to use when initializing the view.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
	static func `init`(with userID: String) -> ProfileTableViewController {
		if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
			profileTableViewController.userIdentity = UserIdentity(id: userID)
			return profileTableViewController
		}

		fatalError("Failed to instantiate ProfileTableViewController with the given user id.")
	}

	/// Initialize a new instance of ProfileTableViewController with the given user object.
	///
	/// - Parameter user: The `User` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
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

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// If there are unsaved changes, enable the Save button and disable the ability to
		// dismiss using the pull-down gesture.
		if self.editingMode {
			self.navigationItem.rightBarButtonItem?.isEnabled = self.hasChanges
			self.isModalInPresentation = self.hasChanges
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateAttributedText), name: .ThemeUpdateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif

		if self.userIdentity == nil {
			self.userIdentity = UserIdentity(id: self.user.id)
		}

		// Fetch user details
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchUserDetails()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.updateHeaderViewFrame()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchUserDetails()
		}
	}

	override func configureEmptyDataView() {
		// MARK: - HERE: Look at this
		let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2
		var detailString: String

		if self.userIdentity?.id == User.current?.id {
			detailString = "There are no messages on your feed!"
		} else {
			detailString = "There are no messages on this feed!"
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.comment()!)
		emptyBackgroundView.configureLabels(title: "No Posts", detail: detailString)
		emptyBackgroundView.verticalOffset = verticalOffset

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

	/// Update the attributed text.
	@objc private func updateAttributedText() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureCountButtons()
		}
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		DispatchQueue.main.sync { [weak self] in
			guard let self = self else { return }

			// Start update process
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.tableView.reloadSections([indexPath.section], with: .none)
			}
		}
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		DispatchQueue.main.sync { [weak self] in
			guard let self = self else { return }

			// Start delete process
			self.tableView.performBatchUpdates({
				if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
					self.feedMessages.remove(at: indexPath.section)
					self.tableView.deleteSections([indexPath.section], with: .automatic)
				}
			}, completion: nil)
		}
	}

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.user?.makeContextMenu(in: self, userInfo: [:])
	}

	/// Fetches user detail.
	@MainActor
	private func fetchUserDetails() async {
		guard let userIdentity = self.userIdentity else { return }

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing profile details...")
		#endif

		do {
			let userResponse = try await KService.getDetails(forUser: userIdentity).value

			self.user = userResponse.data.first
			self.configureProfile()

			// Donate suggestion to Siri
			self.userActivity = self.user.openDetailUserActivity
		} catch {
			print(error.localizedDescription)
		}

		await self.fetchFeedMessages()
	}

	/// Fetches posts for the user whose page is being viewed.
	@MainActor
	func fetchFeedMessages() async {
		guard let userIdentity = self.userIdentity else { return }

		do {
			let feedMessageResponse = try await KService.getFeedMessages(forUser: userIdentity, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.feedMessages = []
			}

			// Save next page url and append new data
			self.nextPageURL = feedMessageResponse.next
			self.feedMessages.append(contentsOf: feedMessageResponse.data)
		} catch {
			print(error.localizedDescription)
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	fileprivate func configureCountButtons() {
		guard let user = self.user else { return }

		// Configure achievements button
		var achievementsCount = 0
		if let achievements = user.relationships?.badges?.data {
			achievementsCount = achievements.count
		}

		let achievementsCountString = NSAttributedString(string: "\(achievementsCount)", attributes: self.countValueAttributes)
		let achievementsTitleString = NSAttributedString(string: "\n\(Trans.achievements)", attributes: self.countTitleAttributes)
		let achievementsButtonTitle = NSMutableAttributedString()
		achievementsButtonTitle.append(achievementsCountString)
		achievementsButtonTitle.append(achievementsTitleString)

		self.achievementsButton.setAttributedTitle(achievementsButtonTitle, for: .normal)
		self.achievementsButton.isHidden = false

		// Configure following & followers count
		let followingCount = user.attributes.followingCount
		let followingCountString = NSAttributedString(string: followingCount.kkFormatted, attributes: self.countValueAttributes)
		let followingTitleString = NSAttributedString(string: "\nFollowing", attributes: self.countTitleAttributes)
		let followingButtonTitle = NSMutableAttributedString()
		followingButtonTitle.append(followingCountString)
		followingButtonTitle.append(followingTitleString)

		self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		self.followingButton.isHidden = false

		let followerCount = user.attributes.followerCount
		let followerCountString = NSAttributedString(string: followerCount.kkFormatted, attributes: self.countValueAttributes)
		let followerTitleString = NSAttributedString(string: "\nFollowers", attributes: self.countTitleAttributes)
		let followersButtonTitle = NSMutableAttributedString()
		followersButtonTitle.append(followerCountString)
		followersButtonTitle.append(followerTitleString)

		self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		self.followersButton.isHidden = false

		// Configure reviews count
		let reviewsCount = user.attributes.ratingsCount
		let reviewsCountString = NSAttributedString(string: reviewsCount.kkFormatted, attributes: self.countValueAttributes)
		let reviewsTitleString = NSAttributedString(string: "\nReviews", attributes: self.countTitleAttributes)
		let reviewsButtonTitle = NSMutableAttributedString()
		reviewsButtonTitle.append(reviewsCountString)
		reviewsButtonTitle.append(reviewsTitleString)

		self.reviewsButton.setAttributedTitle(reviewsButtonTitle, for: .normal)
		self.reviewsButton.isHidden = false
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		guard let user = self.user else { return }
		self.configureNavBarButtons()

		// Configure username
		self.usernameLabel.text = user.attributes.username
		self.usernameLabel.isHidden = false

		// Configure online status
		self.onlineIndicatorContainerView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.onlineIndicatorContainerView.roundCorners(.allCorners, radius: 12.5)

		self.onlineIndicatorView.backgroundColor = user.attributes.activityStatus.colorValue
		self.onlineIndicatorView.roundCorners(.allCorners, radius: 7.5)

		self.onlineIndicatorContainerView.isHidden = false
		self.onlineIndicatorView.isHidden = false

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure banner image
		user.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure user bio
		self.bioTextView.setAttributedText(user.attributes.biographyMarkdown?.markdownAttributedString())

		// Configure count buttons
		self.configureCountButtons()

		// Configure edit button
		self.editProfileButton.isHidden = !(user.id == User.current?.id)

		// Configure follow button
		self.updateFollowButton()

		// Badges
		self.profileBadgeStackView.delegate = self
		self.profileBadgeStackView.configure(for: user)

		// Configure AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Hides and unhides elements to prepare for starting and ending of the edit mode.
	private func editMode(_ enabled: Bool) {
		self.editingMode = enabled
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
				let leftBarButtonItem = UIBarButtonItem(title: Trans.cancel, style: .plain, target: self, action: #selector(self.cancelButtonPressed(_:)))
				let rightBarButtonItem = UIBarButtonItem(title: Trans.done, style: .done, target: self, action: #selector(self.applyProfileEdit(_:)))
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

	/// Cancel profile edit mode and return to view mode.
	///
	/// - Parameter sender: The object requesting the cancelation of the edit mode.
	@objc func cancelButtonPressed(_ sender: Any) {
		self.confirmCancel(showingUpdate: self.hasChanges)
	}

	func cancelProfileEdit() {
		// User doesn't want changes to be saved, pute everything back.
		self.bioTextView.text = self.originalBioText
		self.profileImageView.image = self.originalProfileImage.copy() as? UIImage
		self.bannerImageView.image = self.originalBannerImage.copy() as? UIImage

		// Return to view mode
		self.editMode(false)
		self.tableView.updateHeaderViewFrame()
	}

	/// Confirm whether to cancel the profile update.
	///
	/// - Parameter showingUpdate: Indicates whether to show the update option.
	func confirmCancel(showingUpdate: Bool) {
		// Present a UIAlertController as an action sheet to have the user confirm losing any recent changes.
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }

			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
			if showingUpdate {
				// Send action.
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.update, style: .default) { _ in
					self.updateProfileDetails()
				})
			}

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.discard, style: .destructive) { _ in
				self.cancelProfileEdit()
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = self.navigationItem.leftBarButtonItem
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Update the user's profile details.
	///
	/// Sends `nil` if nothing should be updated.
	/// Sends an empty instance of the object to delete it.
	/// Otherwise sends the data that should be updated.
	func updateProfileDetails() {
		let biography = self.originalBioText == self.editedBioText ? nil : self.editedBioText

		// If `originalProfileImage` is equal to `editedProfileImage`, then no change has happened: return `nil`
		// If `originalProfileImage` is not equal to `editedProfileImage`, then something changed: return `editedProfileImage`
		// If `editedProfileImage` is equal to the user's placeholder, then the user removed the current profile image: return `UIImage()`
		let profileImageRequest: ProfileUpdateImageRequest?
		var profileImageURL: URL? = URL(string: "kurozora://profileimage")
		if let indefinitiveProfileImage = self.originalProfileImage.isEqual(to: self.editedProfileImage) ? nil : self.editedProfileImage {
			profileImageURL = indefinitiveProfileImage.isEqual(to: self.user.attributes.profilePlaceholderImage) ? nil : self.editedProfileImageURL
			profileImageRequest = profileImageURL == nil ? .delete : .update(url: profileImageURL)
		} else {
			profileImageRequest = nil
		}

		// If `originalBannerImage` is equal to `editedBannerImage`, then no change has happened: return `nil`
		// If `originalBannerImage` is not equal to `editedBannerImage`, then something changed: return `editedBannerImage`
		// If `editedBannerImage` is equal to the user's placeholder, then the user removed the current banner image: return `UIImage()`
		let bannerImageRequest: ProfileUpdateImageRequest?
		var bannerImageURL: URL? = URL(string: "kurozora://bannerimage")
		if let indefinitiveBannerImage = self.originalBannerImage.isEqual(to: self.editedBannerImage) ? nil : self.editedBannerImage {
			bannerImageURL = indefinitiveBannerImage.isEqual(to: self.user.attributes.bannerPlaceholderImage) ? nil : self.editedBannerImageURL
			bannerImageRequest = bannerImageURL == nil ? .delete : .update(url: bannerImageURL)
		} else {
			bannerImageRequest = nil
		}

		Task {
			do {
				let profileUpdateRequest = ProfileUpdateRequest(username: nil, nickname: nil, biography: biography, profileImageRequest: profileImageRequest, bannerImageRequest: bannerImageRequest, preferredLanguage: nil, preferredTVRating: nil, preferredTimezone: nil)

				// Perform update request.
				let userUpdateResponse = try await KService.updateInformation(profileUpdateRequest).value
				User.current?.attributes.update(using: userUpdateResponse.data)
				self.editMode(false)
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	/// Apply profile changes.
	///
	/// - Parameter sender: The object requesting the changes to be applied.
	@objc func applyProfileEdit(_ sender: UIBarButtonItem) {
		self.updateProfileDetails()
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user?.attributes.followStatus ?? .disabled
		switch followStatus {
		case .followed:
			self.followButton.setTitle(Trans.following, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle(Trans.follow, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle(Trans.follow, for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	/// Shows the text editor for posintg a new message.
	@objc func postNewMessage() {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

			if let kFeedMessageTextEditorViewController = R.storyboard.textEditor.kFeedMessageTextEditorViewController() {
				kFeedMessageTextEditorViewController.delegate = self
				kFeedMessageTextEditorViewController.dmToUser = self.user

				let kurozoraNavigationController = KNavigationController(rootViewController: kFeedMessageTextEditorViewController)
				kurozoraNavigationController.presentationController?.delegate = kFeedMessageTextEditorViewController
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
				kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
				kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
				kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
				self.present(kurozoraNavigationController, animated: true)
			}
		}
	}

	// MARK: - IBActions
	@IBAction func editProfileButtonPressed(_ sender: UIButton) {
		// Cache current profile data
		self.originalBioText = self.bioTextView.text
		self.originalProfileImage = self.profileImageView.image
		self.originalBannerImage = self.bannerImageView.image

		self.editMode(true)
	}

	@IBAction func followButtonPressed(_ sender: UIButton) {
		let userIdentity = UserIdentity(id: self.user.id)

		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

			Task {
				do {
					let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
					self.user?.attributes.update(using: followUpdateResponse.data)
					self.updateFollowButton()
				} catch {
					print("-----", error.localizedDescription)
				}
			}
		}
	}

	@IBAction func postMessageButton(_ sender: UIBarButtonItem) {
		self.postNewMessage()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.profileTableViewController.achievementsSegue.identifier:
			guard let achievementsTableViewController = segue.destination as? AchievementsTableViewController else { return }
			achievementsTableViewController.user = self.user
		case R.segue.profileTableViewController.followingSegue.identifier:
			guard let followTableViewController = segue.destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .following
			followTableViewController.usersListFetchType = .follow
		case R.segue.profileTableViewController.followersSegue.identifier:
			guard let followTableViewController = segue.destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .followers
			followTableViewController.usersListFetchType = .follow
		case R.segue.profileTableViewController.reviewsSegue.identifier:
			guard let reviewsListCollectionViewController = segue.destination as? ReviewsListCollectionViewController else { return }
			reviewsListCollectionViewController.user = self.user
		case R.segue.profileTableViewController.feedMessageDetailsSegue.identifier:
			guard let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController else { return }
			guard let feedMessageID = sender as? String else { return }
			fmDetailsTableViewController.feedMessageID = feedMessageID
		default: break
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
		let feedMessageCell: BaseFeedMessageCell?
		let feedMessage = self.feedMessages[indexPath.section]

		if feedMessage.attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
		}

		feedMessageCell?.delegate = self
		feedMessageCell?.liveReplyEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.liveReShareEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.configureCell(using: feedMessage)
		feedMessageCell?.moreButton.menu = feedMessage.makeContextMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReplyEnabled": feedMessageCell?.liveReplyEnabled,
			"liveReShareEnabled": feedMessageCell?.liveReShareEnabled
		])
		return feedMessageCell ?? UITableViewCell()
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
			let feedMessage = self.feedMessages[indexPath.section]

			guard let feedMessageUser = feedMessage.relationships.users.data.first else { return }
			guard feedMessageUser != self.user else { return }

			feedMessage.visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge
			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.performSegue(withIdentifier: R.segue.profileTableViewController.feedMessageDetailsSegue.identifier, sender: self.feedMessages[indexPath.section].relationships.parent?.data.first?.id)
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
		if self.currentImageView == "profile" {
			if let originalImage = info[.originalImage] as? UIImage {
				self.editedProfileImage = originalImage

				if let imageURL = info[.imageURL] as? URL {
					self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: User.current!.attributes.profilePlaceholderImage)
					self.editedProfileImageURL = imageURL
				} else {
					// Create a temporary image path
					let imageName = UUID().uuidString
					let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName, conformingTo: .image)

					// Save the image into the temporary path
					let data = originalImage.jpegData(compressionQuality: 0.1)
					try? data?.write(to: imageURL, options: [.atomic])

					// Save the image path
					self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: User.current!.attributes.profilePlaceholderImage)
					self.editedProfileImageURL = imageURL
				}
			}
		} else if self.currentImageView == "banner" {
			if let originalImage = info[.originalImage] as? UIImage {
				self.editedBannerImage = originalImage

				if let imageURL = info[.imageURL] as? URL {
					self.bannerImageView.setImage(with: imageURL.absoluteString, placeholder: User.current!.attributes.bannerPlaceholderImage)
					self.editedBannerImageURL = imageURL
				} else {
					// Create a temporary image path
					let imageName = UUID().uuidString
					let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName, conformingTo: .image)

					// Save the image into the temporary path
					let data = originalImage.jpegData(compressionQuality: 0.1)
					try? data?.write(to: imageURL, options: [.atomic])

					// Save the image path
					self.bannerImageView.setImage(with: imageURL.absoluteString, placeholder: User.current!.attributes.bannerPlaceholderImage)
					self.editedBannerImageURL = imageURL
				}
			}
		}

		// Reset selcted image view
		self.currentImageView = ""

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
			let imagePicker = UIImagePickerController()
			imagePicker.sourceType = .camera
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		self.present(imagePicker, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = "profile"

		let actionSheetAlertController = UIAlertController.actionSheet(title: "Profile Photo", message: "Choose an awesome photo 😉") { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if !self.editedProfileImage.isEqual(to: self.user.attributes.profilePlaceholderImage) {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
					self.profileImageView.image = self.user.attributes.profilePlaceholderImage
					self.editedProfileImage = self.profileImageView.image
				}))
			}
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
		self.currentImageView = "banner"

		let actionSheetAlertController = UIAlertController.actionSheet(title: "Banner Photo", message: "Choose a breathtaking photo 🌄") { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if !self.editedBannerImage.isEqual(to: self.user.attributes.bannerPlaceholderImage) {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
					self.bannerImageView.image = self.user.attributes.bannerPlaceholderImage
					self.editedBannerImage = self.bannerImageView.image
				}))
			}
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension ProfileTableViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		// The system calls this delegate method whenever the user attempts to pull down to dismiss and `isModalInPresentation` is false.
		// Clarify the user's intent by asking whether they want to cancel or update.
		self.confirmCancel(showingUpdate: true)
	}
}

// MARK: - UITextViewDelegate
extension ProfileTableViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.editedBioText = textView.text
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.updateHeaderViewFrame()
		}
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == self.placeholderText && textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue && editingMode {
			textView.text = ""
			textView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty && self.editingMode {
			textView.text = self.placeholderText
			textView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}

	func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(for: username).value
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = URL.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = URL.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")
					.url

				UIApplication.shared.kOpen(nil, deepLink: deeplink)
			}

			return false
		}

		return true
	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension ProfileTableViewController: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge

			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}
}
