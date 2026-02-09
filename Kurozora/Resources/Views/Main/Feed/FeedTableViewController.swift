//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class FeedTableViewController: KTableViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case feedMessageDetailsSegue
		case settingsSegue
	}

	// MARK: - Views
	private var settingsBarButtonItem: UIBarButtonItem!
	private var postMessageButtonBarButtonItem: UIBarButtonItem!
	private var profileBarButtonItem: ProfileBarButtonItem!

	// MARK: - Properties
	var rightBarButtonItems: [UIBarButtonItem]?
	var feedMessages: [FeedMessage] = []

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
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!")
		#endif

		self.title = Trans.feed

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
			await self.fetchFeedMessages()
		}
	}

	/// Configures the settings bar button item.
	private func configureSettingsBarButtonItem() {
		self.settingsBarButtonItem = UIBarButtonItem(title: Trans.settings, image: UIImage(systemName: "gear"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.segueToSettings()
		})
		self.navigationItem.leftBarButtonItem = self.settingsBarButtonItem
	}

	/// Configures the post message bar button item.
	private func configurePostMessageBarButtonItem() {
		self.postMessageButtonBarButtonItem = UIBarButtonItem(title: Trans.postMessage, image: UIImage(systemName: "pencil.circle"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.postNewMessage()
		})
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
		self.navigationItem.rightBarButtonItems?.insert(self.profileBarButtonItem, at: 0)

		self.configureUserDetails()
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureSettingsBarButtonItem()
		self.configurePostMessageBarButtonItem()
		self.configureProfileBarButtonItem()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.comment)
		emptyBackgroundView.configureLabels(title: "No Feed", detail: "Can't get feed list. Please refresh the page or restart the app and check your WiFi connection.")

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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!")
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your explore feed...")
		#endif

		do {
			let feedMessageResponse = try await KService.getFeedExplore(next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

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
	func segueToSettings() {
		let settingsSplitViewController = SettingsSplitViewController.instantiate()
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		self.present(settingsSplitViewController, animated: true)
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem.image = User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile
	}

	/// Performs segue to the profile view.
	func segueToProfile() async {
		let isSignedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard isSignedIn else { return }

		let profileTableViewController = ProfileTableViewController.instantiate()
		self.show(profileTableViewController, sender: nil)
	}

	/// Shows the text editor for posting a new message.
	func postNewMessage() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let kFeedMessageTextEditorViewController = KFeedMessageTextEditorViewController.instantiate()
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

		if feedMessage.attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
		}

		feedMessageCell?.delegate = self
		feedMessageCell?.liveReplyEnabled = false
		feedMessageCell?.liveReShareEnabled = true
		feedMessageCell?.configureCell(using: feedMessage, isOnProfile: false)
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

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
		}
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

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didLoadGIF sender: AnyObject) {
		self.tableView.beginUpdates()
		self.tableView.endUpdates()
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.row].relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first else { return }
		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
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
		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
	}
}

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
		let alertView = UIAlertController(title: "\(tagType) tag detected", message: "\(payload)", preferredStyle: .alert)
		alertView.addAction(title: "OK")
		self.show(alertView, sender: nil)
	}
}
