//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ProfileTableViewController: KTableViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case achievementsSegue
		case followingSegue
		case followersSegue
		case userReviewsListSegue
		case feedMessageDetailsSegue
		case editProfileSegue
	}

	// MARK: - Views
	private var postMessageButton: UIBarButtonItem!
	private var moreBarButtonItem: UIBarButtonItem!

	private let profileHeaderView = ProfileTableHeaderView()

	var sidebarBottomProfileView: KSidebarBottomProfileView?

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

	var feedMessages: [FeedMessage] = []

	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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
	init() {
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Initialize a new instance of ProfileTableViewController with the given user id.
	///
	/// - Parameter userID: The user id to use when initializing the view.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
	func callAsFunction(with userID: KurozoraItemID) -> ProfileTableViewController {
		let profileTableViewController = ProfileTableViewController()
		profileTableViewController.userIdentity = UserIdentity(id: userID)
		return profileTableViewController
	}

	/// Initialize a new instance of ProfileTableViewController with the given user object.
	///
	/// - Parameter user: The `User` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
	func callAsFunction(with user: User) -> ProfileTableViewController {
		let profileTableViewController = ProfileTableViewController()
		profileTableViewController.user = user
		return profileTableViewController
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleProfileDidUpdate(_:)), name: .KUserProfileDidUpdate, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif

		if self.userIdentity == nil {
			self.userIdentity = UserIdentity(id: self.user.id)
		}

		self.mediaViewerDelegate = self
		self.profileHeaderView.delegate = self
		self.profileHeaderView.bioTextViewDelegate = self
		self.tableView.setTableHeaderView(headerView: self.profileHeaderView)

		self.configureNavigationItems()

		// Fetch user details
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchUserDetails()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate(alongsideTransition: nil) { [weak self] _ in
			guard let self = self else { return }
			self.tableView.updateHeaderViewFrame()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KUserProfileDidUpdate, object: nil)

		if self.isMovingFromParent || self.isBeingDismissed, self.user == User.current {
			self.sidebarBottomProfileView?.isSelected = false
		}
	}

	@objc private func handleProfileDidUpdate(_ notification: Notification) {
		guard self.user.id == User.current?.id else { return }
		self.user = User.current
		self.configureProfile()

		self.profileHeaderView.overrideImages(
			profileImage: notification.userInfo?["profileImage"] as? UIImage,
			bannerImage: notification.userInfo?["bannerImage"] as? UIImage
		)
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
		// TODO: Refactor for proper centering
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

	/// Configures the more bar button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem = UIBarButtonItem(title: Trans.more, image: UIImage(systemName: "ellipsis.circle"))
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// Configures the post message bar button item.
	private func configurePostMessageBarButtonItem() {
		self.postMessageButton = UIBarButtonItem(title: Trans.postMessage, image: UIImage(systemName: "pencil.circle"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.postNewMessage()
		})
		self.navigationItem.rightBarButtonItems?.append(self.postMessageButton)
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.configureMoreBarButtonItem()
		self.configurePostMessageBarButtonItem()
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
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
		Task { @MainActor [weak self] in
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

	func endFetch() {
		self.tableView.reloadData {
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif
	}

	/// Fetches posts for the user whose page is being viewed.
	@MainActor
	func fetchFeedMessages() async {
		guard
			!self.isRequestInProgress,
			let userIdentity = self.userIdentity
		else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			let feedMessageResponse = try await KService.getFeedMessages(forUser: userIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

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

		self.endFetch()
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		guard let user = self.user else { return }
		self.configureNavBarButtons()
		self.profileHeaderView.configure(with: user)

		// Configure AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		self.profileHeaderView.updateFollowButton(for: self.user)
	}

	/// Shows the text editor for posting a new message.
	func postNewMessage() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let kFeedMessageTextEditorViewController = KFeedMessageTextEditorViewController()
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

	// MARK: - Actions
	private func followButtonPressed() {
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

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .achievementsSegue: return AchievementsTableViewController()
		case .followingSegue: return UsersListCollectionViewController()
		case .followersSegue: return UsersListCollectionViewController()
		case .feedMessageDetailsSegue: return FMDetailsTableViewController()
		case .editProfileSegue: return KNavigationController(rootViewController: EditProfileViewController(user: self.user))
		case .userReviewsListSegue: return UserReviewsListCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .achievementsSegue:
			guard let achievementsTableViewController = destination as? AchievementsTableViewController else { return }
			achievementsTableViewController.user = self.user
		case .followingSegue:
			guard let followTableViewController = destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .following
			followTableViewController.usersListFetchType = .follow
		case .followersSegue:
			guard let followTableViewController = destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .followers
			followTableViewController.usersListFetchType = .follow
		case .feedMessageDetailsSegue:
			guard
				let fmDetailsTableViewController = destination as? FMDetailsTableViewController,
				let feedMessage = sender as? FeedMessage
			else { return }
			fmDetailsTableViewController.feedMessageID = feedMessage.id
			fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
		case .userReviewsListSegue:
			guard let reviewsListCollectionViewController = destination as? UserReviewsListCollectionViewController else { return }
			reviewsListCollectionViewController.user = self.user
		case .editProfileSegue:
			break
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
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
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

// MARK: - MediaTransitionDelegate
extension ProfileTableViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		return index == 0 ? self.profileHeaderView.profileImageView : self.profileHeaderView.bannerImageView
	}

	func scrollThumbnailIntoView(for index: Int) {
		// Scroll the collection view to make sure the cell at the given index is visible.
//		let indexPath = IndexPath(item: index, section: 0)
//		self.tableView.safeScrollToRow(at: indexPath, at: .middle, animated: true)
	}
}

// MARK: - MediaViewerCellViewDelegate
extension ProfileTableViewController: MediaViewerViewDelegate {
	func mediaViewerViewDelegate(_ view: UIView, didTapImage imageView: UIImageView, at index: Int) {
		guard let user = self.user else { return }

		let profileURL = URL(string: user.attributes.profile?.url ?? "")
		let bannerURL = URL(string: user.attributes.banner?.url ?? "")
		var items: [MediaItem] = []

		if let profileURL = profileURL {
			items.append(MediaItem(
				url: profileURL,
				type: .image,
				title: user.attributes.username,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}
		if let bannerURL = bannerURL {
			items.append(MediaItem(
				url: bannerURL,
				type: .image,
				title: user.attributes.username,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}

		guard items.indices.contains(index) else { return }
		let albumVC = MediaAlbumViewController(items: items, startIndex: index)
		albumVC.transitionDelegateForThumbnail = self

		self.present(albumVC, animated: true)
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
			guard feedMessageUser != self.user else {
				self.view.animateShake()
				return
			}

			feedMessage.visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didLoadGIF sender: AnyObject) {
		self.tableView.beginUpdates()
		self.tableView.endUpdates()
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first

			guard let feedMessageUser = feedMessage?.relationships.users.data.first else { return }
			guard feedMessageUser != self.user else {
				self.view.animateShake()
				return
			}

			feedMessage?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first else { return }

		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
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
		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
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

// MARK: - ProfileTableHeaderViewDelegate
extension ProfileTableViewController: ProfileTableHeaderViewDelegate {
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didTapImageView imageView: UIImageView, at index: Int) {
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self.view, didTapImage: imageView, at: index)
	}

	func profileTableHeaderViewDidPressFollowButton(_ headerView: ProfileTableHeaderView) {
		self.followButtonPressed()
	}

	func profileTableHeaderViewDidPressEditProfile(_ headerView: ProfileTableHeaderView) {
		self.present(SegueIdentifiers.editProfileSegue, sender: self)
	}

	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressAchievementsButton button: UIButton) {
		self.show(SegueIdentifiers.achievementsSegue, sender: self)
	}

	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressFollowingButton button: UIButton) {
		self.show(SegueIdentifiers.followingSegue, sender: self)
	}

	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressFollowersButton button: UIButton) {
		self.show(SegueIdentifiers.followersSegue, sender: self)
	}

	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressReviewsButton button: UIButton) {
		self.show(SegueIdentifiers.userReviewsListSegue, sender: self)
	}

	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressBadge profileBadge: ProfileBadge, from button: UIButton) {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge

		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}
}

// MARK: - FMDetailsTableViewControllerDelegate
extension ProfileTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: KurozoraItemID) {
		self.feedMessages.removeFirst { feedMessage in
			feedMessage.id == messageID
		}
		self.tableView.reloadData()
	}
}
