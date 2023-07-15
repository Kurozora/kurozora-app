//
//  FeedTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FeedTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var postMessageButton: UIBarButtonItem!
	@IBOutlet weak var profileImageButton: ProfileImageButton!

	// MARK: - Properties
	var rightBarButtonItems: [UIBarButtonItem]? = nil
	var feedMessages: [FeedMessage] = [] {
		didSet {
			self.tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				self.toggleEmptyDataView()
			}

			// Reset refresh controller title
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!")
			#endif
		}
	}
	var nextPageURL: String?

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
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
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

		// Configure navigation bar items
		self.enableActions()
		self.configureUserDetails()

		// Fetch feed posts.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFeedMessages()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
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

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.comment()!)
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
			self.feedMessages.remove(at: indexPath.section)
			self.tableView.deleteSections([indexPath.section], with: .automatic)
		}, completion: nil)
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		// Start update process
		if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
			self.tableView.reloadSections([indexPath.section], with: .none)
		}
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		// Start delete process
		self.tableView.performBatchUpdates({
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.deleteMessage(at: indexPath)
			}
		}, completion: nil)
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileImageButton.setImage(User.current?.attributes.profileImageView.image ?? R.image.placeholders.userProfile(), for: .normal)
	}

	/// Fetch feed posts for the current section.
	@MainActor
	func fetchFeedMessages() async {
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your explore feed...")
		#endif

		do {
			let feedMessageResponse = try await KService.getFeedExplore(next: self.nextPageURL).value

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

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			if !User.isSignedIn {
				if let barButtonItem = self.navigationItem.rightBarButtonItems?[1] {
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
		self.performSegue(withIdentifier: R.segue.feedTableViewController.settingsSegue, sender: nil)
	}

	/// Performs segue to the profile view.
	@objc func segueToProfile() {
		WorkflowController.shared.isSignedIn {
			if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
				self.show(profileTableViewController, sender: nil)
			}
		}
	}

	/// Shows the text editor for posintg a new message.
	@objc func postNewMessage() {
		WorkflowController.shared.isSignedIn {
			if let kFeedMessageTextEditorViewController = R.storyboard.textEditor.kFeedMessageTextEditorViewController() {
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
	}

	// MARK: - IBActions
	@IBAction func profileButtonPressed(_ sender: UIButton) {
		self.segueToProfile()
	}

	@IBAction func postMessageButton(_ sender: UIBarButtonItem) {
		self.postNewMessage()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.feedTableViewController.feedMessageDetailsSegue.identifier {
			// Show details of feed message
			if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
				guard let feedMessageID = sender as? String else { return }
				fmDetailsTableViewController.feedMessageID = feedMessageID
				fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension FeedTableViewController {
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
		feedMessageCell?.liveReplyEnabled = false
		feedMessageCell?.liveReShareEnabled = true
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

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge profileBadge: ProfileBadge) {
		self.presentAlertController(title: "", message: profileBadge.description)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.feedMessages[indexPath.section].relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			self.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: self.feedMessages[indexPath.section].relationships.parent?.data.first?.id)
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
extension FeedTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.prepend(feedMessage)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - FMDetailsTableViewControllerDelegate
extension FeedTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: String) {
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
