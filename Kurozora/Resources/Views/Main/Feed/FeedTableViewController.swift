//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Kingfisher
import KurozoraKit
import UIKit

class FeedTableViewController: KTableViewController, ProfileNavigable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case feedMessageDetailsSegue
		case settingsSegue
	}

	// MARK: - Views
	private var settingsBarButtonItem: UIBarButtonItem!
	private var postMessageButtonBarButtonItem: UIBarButtonItem!
	var profileBarButtonItem: ProfileBarButtonItem?

	// MARK: - Properties
	var rightBarButtonItems: [UIBarButtonItem]?
	var feedMessages: [FeedMessage] = []
	private var pendingLayoutUpdate: DispatchWorkItem?
	var heightCache: [IndexPath: CGFloat] = [:]
	private var expandedMessageIDs: Set<KurozoraItemID> = []
	private var expandedOPIDs: Set<KurozoraItemID> = []

	/// The next page url of the pagination.
	var nextPageCursor: PageCursor?

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

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.enableActions()
			self.configureUserDetails()
			self.handleRefreshControl()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.exploreFeed.lowercased(with: Locale.current)))
		#endif

		self.title = L10n.feed

		// Configure navigation bar items
		self.configureNavigationItems()
		self.enableActions()

		// Fetch feed posts.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFeedMessages()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateFeedMessageTranslation(_:)), name: .KTranslationDidUpdate, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KTranslationDidUpdate, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageCursor = nil
		self.heightCache.removeAll()
		self.expandedMessageIDs.removeAll()
		self.expandedOPIDs.removeAll()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFeedMessages()
		}
	}

	/// Configures the settings bar button item.
	private func configureSettingsBarButtonItem() {
		self.settingsBarButtonItem = UIBarButtonItem(title: L10n.settings, image: UIImage(systemName: "gear"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.segueToSettings()
		})
		self.navigationItem.leftBarButtonItem = self.settingsBarButtonItem
	}

	/// Configures the post message bar button item.
	private func configurePostMessageBarButtonItem() {
		self.postMessageButtonBarButtonItem = UIBarButtonItem(
			title: L10n.postMessage,
			image: UIImage(systemName: "pencil.circle"),
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.postNewMessage()
			},
			menu: self.makeDraftsMenu()
		)
		self.navigationItem.rightBarButtonItem = self.postMessageButtonBarButtonItem
	}

	/// Configures the profile bar button item.
	private func configureProfileBarButtonItem() {
		self.profileBarButtonItem = ProfileBarButtonItem(primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			Task {
				await self.segueToProfile()
			}
		})

		if let profileBarButtonItem = self.profileBarButtonItem {
			self.navigationItem.rightBarButtonItems?.insert(profileBarButtonItem, at: 0)
		}

		self.configureUserDetails()
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureSettingsBarButtonItem()
		self.configurePostMessageBarButtonItem()
		self.configureProfileBarButtonItem()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.message2)
		emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.feed), detail: L10n.cantGetListDetail(L10n.feed.lowercased(with: Locale.current)))

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

	/// Deletes a message from the given index path.
	///
	/// - Parameter indexPath: The index path of the message to be deleted.
	func deleteMessage(at indexPath: IndexPath) {
		self.tableView.performBatchUpdates({
			self.feedMessages.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		}, completion: nil)
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

	/// Reloads the rows whose translation state changed.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessageTranslation(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			guard let identities = notification.object as? Set<TranslationIdentity> else {
				self.heightCache.removeAll()
				self.tableView.reloadData()
				return
			}

			let indexPaths = self.tableView.indexPathsForVisibleRows?.filter { indexPath in
				guard let identity = self.feedMessages[safe: indexPath.row]?.translationIdentity else { return false }
				return identities.contains(identity)
			}

			guard let indexPaths = indexPaths, !indexPaths.isEmpty else { return }

			indexPaths.forEach { self.heightCache.removeValue(forKey: $0) }
			self.tableView.reloadRows(at: indexPaths, with: .none)
		}
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.deleteMessage(at: indexPath)
			}
		}
	}

	func endFetch() {
		self.tableView.reloadData {
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.exploreFeed.lowercased(with: Locale.current)))
		#endif
	}

	/// Fetch feed posts for the current section.
	@MainActor
	func fetchFeedMessages() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.exploreFeed.lowercased(with: Locale.current)))
		#endif

		do {
			let feedMessageResponse = try await KService.feedExplore().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.feedMessages = []
			}

			// Save next page url and append new data
			self.nextPageCursor = feedMessageResponse.nextCursor
			self.feedMessages.append(contentsOf: feedMessageResponse.data)

			// The table's prefetching never covers the first screen, so start the page
			// translating here instead of letting it swap in under the reader.
			if #available(iOS 26.4, macCatalyst 26.4, *) {
				TranslationService.shared.prefetch(feedMessageResponse.data)
			}
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			if !User.isSignedIn {
				if let barButtonItem = self.navigationItem.rightBarButtonItems?[safe: 1] {
					self.rightBarButtonItems = [barButtonItem]

					self.navigationItem.rightBarButtonItems?.remove(at: 1)
				}
			} else {
				if let rightBarButtonItems = self.rightBarButtonItems, self.navigationItem.rightBarButtonItems?.count == 1 {
					self.navigationItem.rightBarButtonItems?.append(contentsOf: rightBarButtonItems)
					self.rightBarButtonItems = nil
				}
			}
		}
	}

	/// Performs segue to the settings view.
	@objc func segueToSettings() {
		let settingsSplitViewController = SettingsSplitViewController()
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		self.present(settingsSplitViewController, animated: true)
	}

	@objc func segueToProfile() {
		Task {
			await self.segueToProfile()
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.configure(for: User.current)
	}

	/// Shows the text editor for posting a new message.
	@objc func postNewMessage() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let kFeedMessageTextEditorViewController = KFeedMessageTextEditorViewController()
			kFeedMessageTextEditorViewController.delegate = self

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

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .feedMessageDetailsSegue: return FMDetailsTableViewController()
		case .settingsSegue: return KNavigationController(rootViewController: SettingsSplitViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .feedMessageDetailsSegue:
			// Segue to feed message details
			guard
				let fmDetailsTableViewController = destination as? FMDetailsTableViewController,
				let feedMessage = sender as? FeedMessage
			else { return }
			fmDetailsTableViewController.feedMessageID = feedMessage.id
			fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
		case .settingsSegue: return
		}
	}
}

// MARK: - UITableViewDataSource
extension FeedTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedMessages.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedMessageCell: BaseFeedMessageCell?
		let feedMessage = self.feedMessages[indexPath.row]
		let isExpanded = self.expandedMessageIDs.contains(feedMessage.id)
		let isSimpleReShare = feedMessage.attributes.isReShare && feedMessage.attributes.content.isEmpty
		let isQuoteReShare = feedMessage.attributes.isReShare && !feedMessage.attributes.content.isEmpty

		if isQuoteReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
		}

		feedMessageCell?.delegate = self
		feedMessageCell?.liveReplyEnabled = false
		feedMessageCell?.liveReShareEnabled = true

		if let reShareCell = feedMessageCell as? FeedMessageReShareCell {
			let parentID = feedMessage.relationships.parent?.data.first?.id
			let isOPExpanded = parentID.map { self.expandedOPIDs.contains($0) } ?? false
			reShareCell.configureCell(using: feedMessage, isOnProfile: false, isExpanded: isExpanded, isOPExpanded: isOPExpanded)
		} else if isSimpleReShare {
			let parent = feedMessage.relationships.parent?.data.first ?? feedMessage
			let resharer = feedMessage.relationships.users.data.first
			feedMessageCell?.configureCell(using: parent, isOnProfile: false, isExpanded: isExpanded, attributedTo: resharer)
		} else {
			feedMessageCell?.configureCell(using: feedMessage, isOnProfile: false, isExpanded: isExpanded)
		}

		feedMessageCell?.moreButton.menu = feedMessage.makeContextMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReplyEnabled": feedMessageCell?.liveReplyEnabled ?? false,
			"liveReShareEnabled": feedMessageCell?.liveReShareEnabled ?? false
		], sourceView: feedMessageCell?.moreButton, barButtonItem: nil)
		return feedMessageCell ?? UITableViewCell()
	}
}

// MARK: - KTableViewDataSource
extension FeedTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			FeedMessageCell.self,
			FeedMessageReShareCell.self
		]
	}
}

// MARK: - UITableViewDataSourcePrefetching
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		var imageURLs: [URL] = []

		for indexPath in indexPaths {
			self.feedMessages[safe: indexPath.row]?.collectPrefetchURLs(into: &imageURLs)
		}

		if !imageURLs.isEmpty {
			ImagePrefetcher(urls: imageURLs).start()
		}

		if #available(iOS 26.4, macCatalyst 26.4, *) {
			TranslationService.shared.prefetch(indexPaths.compactMap { self.feedMessages[safe: $0.row] })
		}
	}
}

// MARK: - BaseFeedMessageCellDelegate
extension FeedTableViewController: BaseFeedMessageCellDelegate {
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

	func baseFeedMessageCellReShareMenu(_ cell: BaseFeedMessageCell) -> UIMenu? {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return nil }
		let feedMessage = self.feedMessages[indexPath.row]

		return feedMessage.reShareMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReShareEnabled": cell.liveReShareEnabled
		])
	}

	func baseFeedMessageCellDidTapAttribution(_ cell: BaseFeedMessageCell) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let resharer = self.feedMessages[indexPath.row].relationships.users.data.first else { return }
		let profileTableViewController = ProfileTableViewController()(with: resharer)
		self.show(profileTableViewController, sender: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.row].visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didUpdateContentLayout sender: AnyObject) {
		self.pendingLayoutUpdate?.cancel()
		let work = DispatchWorkItem { [weak self] in
			guard let self else { return }
			self.tableView.performBatchUpdates(nil)
		}
		self.pendingLayoutUpdate = work
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: work)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMore sender: AnyObject) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		let id = self.feedMessages[indexPath.row].id
		self.expandedMessageIDs.insert(id)
		self.heightCache.removeValue(forKey: indexPath)
		self.tableView.reloadRows(at: [indexPath], with: .none)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMoreOnOP sender: AnyObject) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let parentID = self.feedMessages[indexPath.row].relationships.parent?.data.first?.id else { return }
		self.expandedOPIDs.insert(parentID)
		self.heightCache.removeValue(forKey: indexPath)
		self.tableView.reloadRows(at: [indexPath], with: .none)
	}

	func baseFeedMessageCellDidTapTranslation(_ cell: BaseFeedMessageCell) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		TranslationService.shared.toggleTranslation(for: self.feedMessages[indexPath.row])
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapTranslationSettings button: UIButton) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }

		TranslationSettingsViewController.present(for: self.feedMessages[indexPath.row], from: button, in: self)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.row].relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first else { return }
		self.show(.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - KRichTextEditorViewDelegate
extension FeedTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.insert(feedMessage, at: 0)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.show(.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - FeedMessageDraftsTableViewControllerDelegate
extension FeedTableViewController: FeedMessageDraftsTableViewControllerDelegate {}

// MARK: - FMDetailsTableViewControllerDelegate
extension FeedTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: KurozoraItemID) {
		self.feedMessages.removeFirst { feedMessage in
			feedMessage.id == messageID
		}
		self.tableView.reloadData()
	}
}

extension FeedTableViewController: UITextViewDelegate {
	func showHashTagAlert(_ tagType: String, payload: String) {
		let alertView = UIAlertController(title: L10n.tagDetected(tagType), message: "\(payload)", preferredStyle: .alert)
		alertView.addAction(title: L10n.okay)
		self.show(alertView, sender: nil)
	}
}
