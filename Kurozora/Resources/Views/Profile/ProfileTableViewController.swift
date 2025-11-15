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
	@IBOutlet weak var displayNameLabel: KLabel!
	@IBOutlet weak var usernameLabel: KSecondaryLabel!
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

	@IBOutlet weak var editProfileButton: KTintedButton!

	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var userIdentity: UserIdentity?
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
	static func `init`(with userID: KurozoraItemID) -> ProfileTableViewController {
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
		// MARK: Refactor
		let verticalOffset = (self.tableView.tableHeaderView?.frame.size.height ?? 0 - self.view.frame.size.height) / 2
		var detailString: String

		if self.userIdentity?.id == User.current?.id {
			detailString = "There are no messages on your feed!"
		} else {
			detailString = "There are no messages on this feed!"
		}

		emptyBackgroundView.configureImageView(image: .Empty.comment)
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
					self.feedMessages.remove(at: indexPath.row)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}
			}, completion: nil)
		}
	}

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.user?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
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
		if let achievements = user.relationships?.achievements?.data {
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
		let followingCountString = NSAttributedString(string: followingCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followingTitleString = NSAttributedString(string: "\nFollowing", attributes: self.countTitleAttributes)
		let followingButtonTitle = NSMutableAttributedString()
		followingButtonTitle.append(followingCountString)
		followingButtonTitle.append(followingTitleString)

		self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		self.followingButton.isHidden = false

		let followerCount = user.attributes.followerCount
		let followerCountString = NSAttributedString(string: followerCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followerTitleString = NSAttributedString(string: "\nFollowers", attributes: self.countTitleAttributes)
		let followersButtonTitle = NSMutableAttributedString()
		followersButtonTitle.append(followerCountString)
		followersButtonTitle.append(followerTitleString)

		self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		self.followersButton.isHidden = false

		// Configure reviews count
		let reviewsCount = user.attributes.ratingsCount
		let reviewsCountString = NSAttributedString(string: reviewsCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
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

		// Configure display name
		self.displayNameLabel.text = user.attributes.username
		self.displayNameLabel.isHidden = false

		// Configure username
		self.usernameLabel.text = "@\(user.attributes.slug)"
		self.usernameLabel.isHidden = false

		// Configure online status
		self.onlineIndicatorContainerView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.onlineIndicatorContainerView.layerCornerRadius = self.onlineIndicatorContainerView.frame.size.height / 2

		self.onlineIndicatorView.backgroundColor = user.attributes.activityStatus.colorValue
		self.onlineIndicatorView.layerCornerRadius = self.onlineIndicatorView.frame.size.height / 2

		self.onlineIndicatorContainerView.isHidden = false
		self.onlineIndicatorView.isHidden = false

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure banner image
		self.bannerImageView.theme_backgroundColor = KThemePicker.tintColor.rawValue
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

	/// Shows the text editor for posting a new message.
	@objc func postNewMessage() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

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
	@IBAction func followButtonPressed(_ sender: UIButton) {
		let userIdentity = UserIdentity(id: self.user.id)

		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			do {
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
				self.user?.attributes.update(using: followUpdateResponse.data)
				self.updateFollowButton()
			} catch {
				print("-----", error.localizedDescription)
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
			guard let feedMessageID = sender as? KurozoraItemID else { return }
			fmDetailsTableViewController.feedMessageID = feedMessageID
		case R.segue.profileTableViewController.editProfileSegue.identifier:
			guard let kNavigationController = segue.destination as? KNavigationController else { return }
			guard let editProfileViewController = kNavigationController.viewControllers.first as? EditProfileViewController else { return }
			editProfileViewController.user = self.user
		default: break
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedMessages.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedMessageCell: BaseFeedMessageCell?
		let feedMessage = self.feedMessages[indexPath.row]

		if feedMessage.attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
		}

		feedMessageCell?.delegate = self
		feedMessageCell?.liveReplyEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.liveReShareEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.configureCell(using: feedMessage, isOnProfile: true)
		feedMessageCell?.moreButton.menu = feedMessage.makeContextMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReplyEnabled": feedMessageCell?.liveReplyEnabled ?? false,
			"liveReShareEnabled": feedMessageCell?.liveReShareEnabled ?? false
		], sourceView: feedMessageCell?.moreButton, barButtonItem: nil)
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
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].heartMessage(via: self, userInfo: ["indexPath": indexPath])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.row]

			guard let feedMessageUser = feedMessage.relationships.users.data.first else { return }
			guard feedMessageUser != self.user else { return }

			feedMessage.visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge
			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.row].relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first else { return }

		self.performSegue(withIdentifier: R.segue.profileTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ProfileTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.insert(feedMessage, at: 0)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.profileTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - UITextViewDelegate
extension ProfileTableViewController: UITextViewDelegate {
	func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(for: username).value
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if url.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = url.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = url.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")

				UIApplication.shared.kOpen(nil, deepLink: URL(string: deeplink))
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
