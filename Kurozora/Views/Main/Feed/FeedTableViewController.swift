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
	var refreshController = UIRefreshControl()
	var rightBarButtonItems: [UIBarButtonItem]? = nil

	var feedMessages: [FeedMessage] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
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

		// Turn off activity indicator for now
		_prefersActivityIndicatorHidden = true

		// Add Refresh Control to Table View
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshController.addTarget(self, action: #selector(refreshFeedsData(_:)), for: .valueChanged)

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
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing your explore feed...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
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
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.feedMessages = []
					}

					// Append new data and save next page url
					self.feedMessages.append(contentsOf: feedMessageResponse.data)
					self.nextPageURL = feedMessageResponse.next

					// Reset refresh controller title
					self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh your explore feed!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
				}
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			self.refreshController.endRefreshing()
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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
		guard let feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.feedMessageCell.identifier)")
		}
		feedMessageCell.feedMessage = feedMessages[indexPath.row]
		return feedMessageCell
	}
}

// MARK: - UITableViewDelegate
extension FeedTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchFeedMessages()
			}
		}
	}
}

// MARK: - KRichTextEditorViewDelegate
//extension FeedTableViewController: KRichTextEditorViewDelegate {
//	func updateFeedMessages(with feedMessages: [FeedPost]) {
//		DispatchQueue.main.async {
//			for feedPost in feedMessages {
//				self.feedMessages.prepend(feedPost)
//			}
//		}
//	}
//}
