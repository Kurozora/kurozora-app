//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ForumsListViewController: KTableViewController {
	// MARK: - Properties
	var sectionTitle: String = ""
	var sectionID: Int!
	var sectionIndex: Int!
	var forumsThreads: [ForumsThread] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			tableView.reloadData {
				self.toggleEmptyDataView()
			}
		}
	}
	var nextPageURL: String?
	var forumOrder: ForumOrder = .best
	weak var delegate: ForumsListViewControllerDelegate?

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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .forumsPage)

		// Setup library view controller delegate
		(self.tabmanParent as? ForumsViewController)?.forumsViewControllerDelegate = self

		// Update forum order button to reflect page settings
		self.delegate?.updateForumOrderButton(with: self.forumOrder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(updateForumsCell(_:)), name: .KFTDidUpdate, object: nil)

		// Add bottom inset to avoid the tabbar obscuring the view
		self.tableView.contentInset.bottom = 50

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads.")
		#endif

		// Fetch threads
		DispatchQueue.global(qos: .background).async {
			self.fetchThreads()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		self.fetchThreads()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.comment()!)
		emptyBackgroundView.configureLabels(title: "No Threads", detail: "Be the first to post in the \(self.sectionTitle.lowercased()) forums!")

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

	/// Fetch threads list for the current section.
	func fetchThreads() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing \(self.sectionTitle) threads...")
			#endif
		}

		KService.getForumsThreads(forSection: sectionID, orderedBy: forumOrder, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let forumsThreadResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.forumsThreads = []
				}

				// Append new data and save next page url
				self.forumsThreads.append(contentsOf: forumsThreadResponse.data)
				self.nextPageURL = forumsThreadResponse.next

				// Reset refresh controller title
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.")
				#endif
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/**
		Updates the forums threads with the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func updateForumsCell(_ notification: NSNotification) {
		let userInfo = notification.userInfo
		if let indexPath = userInfo?["indexPath"] as? IndexPath {
			let forumsCell = tableView.cellForRow(at: indexPath) as? ForumsCell
			forumsCell?.configureCell()
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.forumsListViewController.threadSegue.identifier {
			let threadViewController = segue.destination as? ThreadTableViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.sectionTitle = sectionTitle
			threadViewController?.forumsThread = sender as? ForumsThread
		}
	}
}

// MARK: - UITableViewDataSource
extension ForumsListViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.forumsThreads.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let forumsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forumsCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.forumsCell.identifier)")
		}
		forumsCell.forumsThread = self.forumsThreads[indexPath.section]
		forumsCell.delegate = self
		return forumsCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: R.segue.forumsListViewController.threadSegue, sender: self.forumsThreads[indexPath.section])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 5 {
			if self.nextPageURL != nil {
				self.fetchThreads()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let forumsCell = tableView.cellForRow(at: indexPath) as? ForumsCell {
			forumsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			forumsCell.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			forumsCell.contentLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			forumsCell.byLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue

		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let forumsCell = tableView.cellForRow(at: indexPath) as? ForumsCell {
			forumsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			forumsCell.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			forumsCell.contentLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			forumsCell.byLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.forumsThreads[indexPath.section].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
	}
}

// MARK: - ForumsCellDelegate
extension ForumsListViewController: ForumsCellDelegate {
	func voteOnForumsCell(_ cell: ForumsCell, with voteStatus: VoteStatus) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.forumsThreads[indexPath.section].voteOnThread(as: voteStatus, at: indexPath)
		}
	}

	func visitOriginalPosterProfile(_ cell: ForumsCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.forumsThreads[indexPath.section].visitOriginalPosterProfile(from: self)
		}
	}

	func showActionsList(_ cell: ForumsCell, sender: UIButton) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.forumsThreads[indexPath.section].actionList(sender, userInfo: ["indexPath": indexPath])
		}
	}
}

// MARK: - LibraryViewControllerDelegate
extension ForumsListViewController: ForumsViewControllerDelegate {
	func orderForums(by forumOrder: ForumOrder) {
		self.forumOrder = forumOrder
		self.fetchThreads()
	}

	func orderValue() -> ForumOrder {
		return self.forumOrder
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ForumsListViewController: KRichTextEditorViewDelegate {
	func updateThreadsList(with forumsThreads: [ForumsThread]) {
		DispatchQueue.main.async {
			for forumsThread in forumsThreads {
				self.forumsThreads.prepend(forumsThread)
			}
		}
	}
}
