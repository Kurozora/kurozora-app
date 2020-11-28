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
	#if !targetEnvironment(macCatalyst)
	var refreshController = UIRefreshControl()
	#endif
	var rightBarButtonItems: [UIBarButtonItem]? = nil

	var feedMessages: [FeedMessage] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.tableView.reloadEmptyDataSet()
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
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFTMessageDidUpdate, object: nil)

		// Add Refresh Control to Table View
		#if !targetEnvironment(macCatalyst)
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshController.addTarget(self, action: #selector(refreshFeedsData(_:)), for: .valueChanged)
		#endif

		// Configure navigation bar items
		self.enableActions()
		self.configureUserDetails()

		// Fetch feed posts.
		DispatchQueue.global(qos: .background).async {
			self.fetchFeedMessages()
		}
	}

	// MARK: - Functions
	/**
		Refresh the feeds data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshFeedsData(_ sender: Any) {
		#if !targetEnvironment(macCatalyst)
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing your explore feed...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		#endif
		self.nextPageURL = nil
		fetchFeedMessages()
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Feed", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get feed list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	@objc func updateFeedMessage(_ notification: NSNotification) {
		// Start delete process
		self.tableView.performBatchUpdates({
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let feedMessage = notification.userInfo?["feedMessage"] as? FeedMessage {
				self.feedMessages[indexPath.section] = feedMessage
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
		KService.getFeedExplore(next: nextPageURL) { [weak self] result in
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

//				if self.tableView.numberOfSections != 0 {
//					self.tableView.reloadSections(IndexSet(0...self.feedMessages.count), with: .automatic)
//				}

				self.tableView.reloadData()

				// Reset refresh controller title
				#if !targetEnvironment(macCatalyst)
				self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
				#endif
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshController.endRefreshing()
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

	// MARK: - IBActions
	@IBAction func profileButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
				self.show(profileTableViewController, sender: nil)
			}
		}
	}

	@IBAction func postMessageButton(_ sender: UIBarButtonItem) {
		WorkflowController.shared.isSignedIn {
			if let kFeedMessageTextEditorViewController = R.storyboard.textEditor.kFeedMessageTextEditorViewController() {
				kFeedMessageTextEditorViewController.delegate = self

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kFeedMessageTextEditorViewController)
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				self.present(kurozoraNavigationController, animated: true)
			}
		}
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

// MARK: - UITableViewDelegate
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			self.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: baseFeedMessageCell.feedMessage.id)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 5 {
			if self.nextPageURL != nil {
				self.fetchFeedMessages()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			baseFeedMessageCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			baseFeedMessageCell.usernameLabel.theme_tintColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			baseFeedMessageCell.postTextView.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			baseFeedMessageCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			baseFeedMessageCell.usernameLabel.theme_tintColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			baseFeedMessageCell.postTextView.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.feedMessages[indexPath.section].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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
	func heartMessage(_ cell: BaseFeedMessageCell) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.section]
			feedMessage.heartMessage(via: self, userInfo: ["indexPath": indexPath])
		}
	}

	func replyToMessage(_ cell: BaseFeedMessageCell) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.section]
			feedMessage.replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
		}
	}

	func reShareMessage(_ cell: BaseFeedMessageCell) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.section]
			feedMessage.reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
		}
	}

	func visitOriginalPosterProfile(_ cell: BaseFeedMessageCell) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.section]
			feedMessage.visitOriginalPosterProfile(from: self)
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
extension FeedTableViewController: KFeedMessageTextEditorViewDelegate {
	func updateMessages(with feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.prepend(feedMessage)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}
