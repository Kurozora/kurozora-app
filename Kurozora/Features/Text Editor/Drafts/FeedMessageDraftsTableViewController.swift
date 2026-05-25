//
//  FeedMessageDraftsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Data Source
class FeedMessageDraftDataSource: UITableViewDiffableDataSource<FeedMessageDraftsTableViewController.SectionLayoutKind, UUID> {}

/// Delegate protocol for handling draft selection.
protocol FeedMessageDraftsTableViewControllerDelegate: AnyObject {
	/// Called when the user selects a draft from the list.
	///
	/// - Parameters:
	///   - controller: The draft list controller.
	///   - draft: The selected draft.
	func draftListViewController(_ controller: FeedMessageDraftsTableViewController, didSelectDraft draft: FeedMessageDraft)
}

/// Presents a list of saved feed message drafts with swipe-to-delete support.
final class FeedMessageDraftsTableViewController: KTableViewController {
	// MARK: - Enums
	enum SectionLayoutKind: Hashable {
		case main
	}

	// MARK: - Properties
	/// The account slug to fetch drafts for.
	var userSlug: String = ""

	/// The delegate notified when a draft is selected.
	weak var delegate: FeedMessageDraftsTableViewControllerDelegate?

	/// The diffable data source.
	var dataSource: FeedMessageDraftDataSource!

	private var drafts: [FeedMessageDraft] = []

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
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
	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.drafts

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.drafts.lowercased()))
		#endif

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(self.dismissButtonPressed(_:))
		)

		self.configureDataSource()
		self.loadDrafts()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.loadDrafts()
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: UIImage(systemName: "archivebox")!)
		self.emptyBackgroundView.configureLabels(title: L10n.noDraftsTitle, detail: L10n.noDraftsDetail)
		self.tableView.backgroundView?.alpha = 0
	}

	private func toggleEmptyDataView() {
		if self.drafts.isEmpty {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	private func loadDrafts() {
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.drafts.lowercased()))
		#endif

		self.drafts = DraftStore.shared.drafts(forUserSlug: self.userSlug)
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.drafts.lowercased()))
		#endif
	}

	@objc private func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
}

// MARK: - KTableViewDataSource
extension FeedMessageDraftsTableViewController {
	func configureDataSource() {
		let draftCellRegistration = UITableView.CellRegistration<FeedMessageDraftTableViewCell, UUID> { [weak self] cell, _, uuid in
			guard
				let self = self,
				let draft = self.drafts.first(where: { $0.uuid == uuid })
			else { return }
			cell.configure(using: DraftCellViewModel(draft: draft))
		}

		self.dataSource = FeedMessageDraftDataSource(tableView: self.tableView) { tableView, indexPath, uuid -> UITableViewCell? in
			return tableView.dequeueConfiguredReusableCell(using: draftCellRegistration, for: indexPath, item: uuid)
		}
	}

	func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, UUID>()
		if !self.drafts.isEmpty {
			snapshot.appendSections([.main])
			snapshot.appendItems(self.drafts.map(\.uuid), toSection: .main)
		}
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - UITableViewDelegate
extension FeedMessageDraftsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard
			let uuid = self.dataSource.itemIdentifier(for: indexPath),
			let draft = self.drafts.first(where: { $0.uuid == uuid })
		else { return }
		self.delegate?.draftListViewController(self, didSelectDraft: draft)
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: L10n.delete) { [weak self] _, _, completionHandler in
			guard
				let self = self,
				let uuid = self.dataSource.itemIdentifier(for: indexPath)
			else {
				completionHandler(false)
				return
			}

			self.drafts.removeAll { $0.uuid == uuid }
			DraftStore.shared.deleteDraft(uuid: uuid)
			self.updateDataSource()
			self.toggleEmptyDataView()
			completionHandler(true)
		}
		deleteAction.backgroundColor = .kLightRed
		deleteAction.image = UIImage(systemName: "minus.circle")

		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}
}

// MARK: - FeedMessageDraftsTableViewControllerDelegate
extension FeedMessageDraftsTableViewControllerDelegate where Self: KFeedMessageTextEditorViewDelegate & UIViewController {
	func draftListViewController(_ controller: FeedMessageDraftsTableViewController, didSelectDraft draft: FeedMessageDraft) {
		controller.dismiss(animated: true) { [weak self] in
			self?.kFeedMessageTextEditorView(openDraftInNewComposer: draft)
		}
	}
}

// MARK: - KFeedMessageTextEditorViewDelegate
extension KFeedMessageTextEditorViewDelegate where Self: FeedMessageDraftsTableViewControllerDelegate & UIViewController {
	func makeDraftsMenu() -> UIMenu {
		let draftsAction = UIAction(title: L10n.drafts, image: UIImage(systemName: "archivebox")) { [weak self] _ in
			guard let self = self,
				  let slug = User.current?.attributes.slug else { return }

			let draftsVC = FeedMessageDraftsTableViewController()
			draftsVC.userSlug = slug
			draftsVC.delegate = self

			let nav = KNavigationController(rootViewController: draftsVC)
			nav.navigationBar.prefersLargeTitles = false
			if let sheet = nav.sheetPresentationController {
				sheet.detents = [.medium(), .large()]
				sheet.prefersGrabberVisible = true
			}
			self.present(nav, animated: true)
		}
		return UIMenu(children: [draftsAction])
	}
}
