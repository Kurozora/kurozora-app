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

		self.enableActions()
		self.configureUserDetails()
		self.handleRefreshControl()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFTMessageDidUpdate, object: nil)
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
		DispatchQueue.global(qos: .background).async {
			self.fetchFeedMessages()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		NotificationCenter.default.removeObserver(self, name: .KFTMessageDidUpdate, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		fetchFeedMessages()
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

	/// Configures the view with the user's details.
	func configureUserDetails() {
		profileImageButton.setImage(User.current?.attributes.profileImage ?? R.image.placeholders.userProfile(), for: .normal)
	}

	/// Fetch feed posts for the current section.
	func fetchFeedMessages() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your explore feed...")
			#endif
		}

		KService.getFeedExplore(next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessageResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.feedMessages = []
				}

				// Append new data and save next page url
				self.feedMessages.append(contentsOf: feedMessageResponse.data)
				self.nextPageURL = feedMessageResponse.next
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		DispatchQueue.main.async {
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

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kFeedMessageTextEditorViewController)
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
			// Show detail for explore cell
			if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
				if let feedMessageID = sender as? Int {
					fmDetailsTableViewController.feedMessageID = feedMessageID
				}
			}
		}
	}

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == R.segue.feedTableViewController.profileSegue.identifier {
			return WorkflowController.shared.isSignedIn()
		}

		return true
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
		let feedMessageCell: BaseFeedMessageCell!

		if feedMessages[indexPath.section].attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
		}

		feedMessageCell.delegate = self
		feedMessageCell.liveReplyEnabled = false
		feedMessageCell.liveReShareEnabled = true
		feedMessageCell.feedMessage = feedMessages[indexPath.section]
		return feedMessageCell
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
