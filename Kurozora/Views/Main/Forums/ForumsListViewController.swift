//
//  ForumsListViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsListViewControllerDelegate: class {
	func updateForumOrderButton(with orderType: ForumOrder)
}

class ForumsListViewController: KTableViewController {
	// MARK: - Properties
	#if !targetEnvironment(macCatalyst)
	var refreshController = UIRefreshControl()
	#endif

	var sectionTitle: String = ""
	var sectionID: Int!
	var sectionIndex: Int!
	var forumsThreads: [ForumsThread] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(sectionIndex, forKey: .forumsPage)

		// Setup library view controller delegate
		(tabmanParent as? ForumsViewController)?.forumsViewControllerDelegate = self

		// Update forum order button to reflect page settings
		delegate?.updateForumOrderButton(with: forumOrder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add bottom inset to avoid the tabbar obscuring the view
		tableView.contentInset.bottom = 50

		// Add Refresh Control to Table View
		#if !targetEnvironment(macCatalyst)
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshController.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)
		#endif

		// Fetch threads
		DispatchQueue.global(qos: .background).async {
			self.fetchThreads()
		}
	}

	// MARK: - Functions
	/**
		Refresh the threads data by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshThreadsData(_ sender: Any) {
		#if !targetEnvironment(macCatalyst)
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing \(sectionTitle) threads...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		#endif
		self.nextPageURL = nil
		fetchThreads()
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

			view.titleLabelString(NSAttributedString(string: "No Threads", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Be the first to post in the \(self.sectionTitle.lowercased()) forums!", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetch threads list for the current section.
	func fetchThreads() {
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
				self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh \(self.sectionTitle) threads.", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
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
		forumsCell.forumsCellDelegate = self
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
		return self.forumsThreads[indexPath.section].contextMenuConfiguration(in: self)
	}
}

// MARK: - ForumsCellDelegate
extension ForumsListViewController: ForumsCellDelegate {
	func voteOnForumsCell(_ cell: ForumsCell, with voteStatus: VoteStatus) {
		if let indexPath = tableView.indexPath(for: cell) {
			let forumsThread = self.forumsThreads[indexPath.section]
			forumsThread.voteOnThread(as: voteStatus) { [weak self] forumsThread in
				guard let self = self else { return }
				self.forumsThreads[indexPath.section] = forumsThread
				cell.forumsThread = forumsThread
			}
		}
	}

	func visitOriginalPosterProfile(_ cell: ForumsCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			let forumsThread = self.forumsThreads[indexPath.section]
			forumsThread.visitOriginalPosterProfile(from: self)
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
