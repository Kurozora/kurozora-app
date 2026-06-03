//
//  ParentalGuideCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ParentalGuideCollectionViewController: KCollectionViewController, TypedSegueHandling {
	// MARK: - SegueIdentifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case parentalGuideCategoryEntriesSegue
	}

	// MARK: - Properties
	/// The maximum number of entries shown inline per category before a "See All" button is offered.
	static let maxEntriesPerCategory = 5

	/// The media context driving fetches and submissions.
	var mediaType: ParentalGuide.MediaType?

	/// The aggregate stats received from the server.
	var stats: ParentalGuideStats?

	/// The user-submitted entries received from the server.
	var entries: [ParentalGuideEntry] = []

	/// The ids of entries whose reason text is currently expanded.
	var expandedEntryIDs: Set<KurozoraItemID> = []

	/// The category currently being edited via the editor sheet.
	var pendingEditorCategory: ParentalGuideCategory?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	private lazy var addBarButtonItem: UIBarButtonItem = {
		return UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: self.makeAddMenu())
	}()

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
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.parentalGuide
		self.collectionView.contentInset.top = 20
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.navigationItem.rightBarButtonItem = self.addBarButtonItem

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchEntries()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.parentalGuide.lowercased(with: Locale.current)))
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.entryDidUpdate(_:)), name: .KPGEntryDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.entryDidDelete(_:)), name: .KPGEntryDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KPGEntryDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KPGEntryDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchEntries()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.reminders)
		self.emptyBackgroundView.configureLabels(
			title: L10n.noParentalGuideYet,
			detail: L10n.beTheFirstToContribute
		)
		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fetches the parental guide aggregate + entries.
	func fetchEntries() async {
		guard let mediaType = self.mediaType else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self._prefersActivityIndicatorHidden = false
		}

		do {
			let response: ParentalGuideResponse

			switch mediaType {
			case .show(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			case .literature(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			case .game(let identity, _, _, _, _):
				response = try await KService.parentalGuide(for: identity).response()
			}

			self.stats = response.data.stats
			self.entries = response.data.entries
		} catch let error as APIError {
			let underlying = error.underlying.map { String(reflecting: $0) } ?? "—"
			print("ParentalGuide fetch failed [HTTP \(error.statusCode ?? -1)]: \(error.message) | server=\(error.errors.map { $0.detail }) | underlying=\(underlying)")
		} catch {
			print("ParentalGuide fetch failed:", String(reflecting: error))
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/// Returns the entries for a specific category.
	///
	/// - Parameter category: The category whose entries to return.
	///
	/// - Returns: The entries for the category.
	func entries(for category: ParentalGuideCategory) -> [ParentalGuideEntry] {
		return self.entries.filter { $0.attributes.category == category }
	}

	/// Returns the short summary value (e.g. average rating) shown in the top Summary section.
	///
	/// - Parameter category: The category whose summary to render.
	///
	/// - Returns: A localized value string, or "None" when no submissions exist.
	func summaryValue(for category: ParentalGuideCategory) -> String {
		guard let categoryStats = self.stats?.stats(for: category), categoryStats.totalCount > 0 else {
			return L10n.parentalGuideNoSubmissions
		}

		return categoryStats.averageRating.stringValue
	}

	/// Returns the ordered key/value pairs that populate the Summary card.
	///
	/// - Returns: An array starting with the rating row followed by one row per ``ParentalGuideCategory``.
	func summaryRows() -> [(key: String, value: String)] {
		var rows: [(key: String, value: String)] = [
			(L10n.parentalGuideRating, self.mediaType?.ratingDisplay ?? L10n.parentalGuideRatingUnknown)
		]
		rows.append(contentsOf: ParentalGuideCategory.allCases.map { (key: $0.displayName, value: self.summaryValue(for: $0)) })
		return rows
	}

	/// Returns the sentiment subtitle shown under each per-category section header when entries exist.
	///
	/// - Parameter category: The category whose sentiment to render.
	///
	/// - Returns: A short sentence such as "3 of 5 found this Mild", or `nil` when no aggregate is known.
	func sentimentSubtitle(for category: ParentalGuideCategory) -> String? {
		guard let categoryStats = self.stats?.stats(for: category), categoryStats.totalCount > 0 else {
			return nil
		}

		let rating = categoryStats.averageRating.stringValue.lowercased()
		return L10n.parentalGuideSentiment(categoryStats.matchingCount, categoryStats.totalCount, rating)
	}

	/// Returns whether the authenticated user has an entry in the given category.
	///
	/// - Parameter category: The category to check.
	///
	/// - Returns: Whether the user has an existing entry.
	func hasOwnEntry(in category: ParentalGuideCategory) -> Bool {
		return self.ownEntry(in: category) != nil
	}

	/// Returns the authenticated user's entry in the given category, if any.
	///
	/// - Parameter category: The category to check.
	///
	/// - Returns: The user's entry, or `nil`.
	func ownEntry(in category: ParentalGuideCategory) -> ParentalGuideEntry? {
		guard let viewerID = User.current?.id.rawValue else { return nil }

		return self.entries.first { entry in
			entry.attributes.category == category && entry.attributes.userID == viewerID
		}
	}

	/// Reloads the cell at `indexPath` without rebuilding the rest of the snapshot.
	///
	/// - Parameter indexPath: The index path whose item should be re-rendered.
	func reloadEntry(at indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Replaces the entry at the given index path with the updated entry.
	///
	/// - Parameter notification: The notification carrying the updated entry and index path.
	@objc func entryDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			guard let updatedEntry = notification.userInfo?["entry"] as? ParentalGuideEntry else {
				Task { [weak self] in
					await self?.fetchEntries()
				}
				return
			}

			let isExisting = self.entries.contains { $0.id == updatedEntry.id }

			if let index = self.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
				self.entries[index] = updatedEntry
			} else {
				self.entries.insert(updatedEntry, at: 0)
			}

			if isExisting {
				self.reconfigureEntry(updatedEntry)
			} else {
				self.updateDataSource()
			}
		}
	}

	/// Forces the diffable data source to reconfigure the cell rendering `entry`to propagate changes without a full snapshot reload.
	///
	/// - Parameter entry: The entry whose cell should be re-rendered.
	private func reconfigureEntry(_ entry: ParentalGuideEntry) {
		var snapshot = self.dataSource.snapshot()
		let item = ItemKind.entry(entry)

		guard snapshot.itemIdentifiers.contains(item) else { return }

		snapshot.reconfigureItems([item])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Removes the entry referenced in the notification.
	///
	/// - Parameter notification: The notification carrying the deleted entry id.
	@objc func entryDidDelete(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			guard let deletedID = notification.userInfo?["entryID"] as? KurozoraItemID else {
				Task { [weak self] in
					await self?.fetchEntries()
				}
				return
			}

			self.entries.removeAll { $0.id == deletedID }
			self.updateDataSource()
		}
	}

	/// Builds the menu listing every category as a destination for a new entry.
	///
	/// - Returns: A menu whose actions present the editor for each category.
	private func makeAddMenu() -> UIMenu {
		let actions = ParentalGuideCategory.allCases.map { category in
			UIAction(title: category.displayName, image: UIImage(systemName: category.systemImageName)) { [weak self] _ in
				self?.presentEditor(for: category)
			}
		}

		return UIMenu(title: "", children: actions)
	}

	/// Presents the editor for a fresh submission in the given category.
	///
	/// - Parameter category: The category to pre-select on the editor's form.
	func presentEditor(for category: ParentalGuideCategory) {
		guard let mediaType = self.mediaType else { return }

		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let editorViewController = ParentalGuideEditorCollectionViewController()
			editorViewController.mediaType = mediaType
			editorViewController.category = category
			editorViewController.existingEntry = nil

			let navigationController = KNavigationController(rootViewController: editorViewController)
			navigationController.modalPresentationStyle = .formSheet
			navigationController.presentationController?.delegate = editorViewController

			self.present(navigationController, animated: true)
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .parentalGuideCategoryEntriesSegue:
			return ParentalGuideCategoryEntriesCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .parentalGuideCategoryEntriesSegue:
			guard let destination = destination as? ParentalGuideCategoryEntriesCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			guard let category = self.snapshot.sectionIdentifiers[indexPath.section].category else { return }

			destination.mediaType = self.mediaType
			destination.category = category
			destination.entries = self.entries(for: category)
		}
	}
}
