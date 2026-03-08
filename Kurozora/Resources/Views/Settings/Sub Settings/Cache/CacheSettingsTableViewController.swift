//
//  CacheSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Kingfisher
import UIKit

class CacheSettingsTableViewController: SubSettingsViewController {
	// MARK: - Properties
	private var imageCacheSize: String = "—"
	private var richLinkCacheSize: String = "—"
	/// The title label's bottom edge in the table view's content coordinate space. Computed once, constant thereafter.
	private var titleLabelBottomInContent: CGFloat?

	/// Callback to notify the parent settings table to refresh the cache size label.
	var onCacheCleared: (() -> Void)?

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		Task { [weak self] in
			await self?.loadCacheSizes()
		}
	}

	// MARK: - Functions
	/// Fetches the sizes of all cache components and updates the UI.
	private func loadCacheSizes() async {
		// Perform file I/O off the main thread.
		let richLink = RichLink.shared
		let richLinkBytes = await Task.detached(priority: .userInitiated) {
			richLink.cacheSize()
		}.value
		self.richLinkCacheSize = self.formatBytes(richLinkBytes)

		do {
			let bytes = try await ImageCache.default.diskStorageSize
			self.imageCacheSize = self.formatBytes(bytes)
		} catch {
			self.imageCacheSize = "—"
		}

		self.tableView.reloadSections(IndexSet(integer: Section.cacheComponents.rawValue), with: .none)
	}

	/// Formats a byte count into a human-readable MiB string.
	private func formatBytes(_ bytes: UInt) -> String {
		let sizeInMiB = Double(bytes) / 1024 / 1024
		return String(format: "%.2f", sizeInMiB) + "MiB"
	}

	/// Clears the cache for a specific component.
	private func clearCache(for component: CacheComponent) async {
		switch component {
		case .images:
			KingfisherManager.shared.cache.clearMemoryCache()
			await KingfisherManager.shared.cache.clearDiskCache()
			await KingfisherManager.shared.cache.cleanExpiredDiskCache()
		case .richLinks:
			RichLink.shared.clearCache()
		}
	}

	/// Clears all cache components and reloads sizes.
	private func clearAllCaches() async {
		RichLink.shared.clearCache()
		KingfisherManager.shared.cache.clearMemoryCache()
		await KingfisherManager.shared.cache.clearDiskCache()
		await KingfisherManager.shared.cache.cleanExpiredDiskCache()
		await self.loadCacheSizes()
		self.onCacheCleared?()
	}
}

// MARK: - KTableViewDataSource
extension CacheSettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SettingsHeaderCell.self,
			SettingsCell.self,
			DestructiveSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension CacheSettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }

		switch section {
		case .header:
			return 1
		case .cacheComponents:
			return CacheComponent.allCases.count
		case .actions:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

		switch section {
		case .header:
			guard let headerCell = tableView.dequeueReusableCell(withIdentifier: SettingsHeaderCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsHeaderCell.reuseID)")
			}
			headerCell.configure(image: .Icons.clearCache, title: Trans.cache, description: Trans.cacheHeaderDescription)
			return headerCell
		case .cacheComponents:
			guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			let component = CacheComponent.allCases[indexPath.row]
			let sizeString: String

			switch component {
			case .images:
				sizeString = self.imageCacheSize
			case .richLinks:
				sizeString = self.richLinkCacheSize
			}

			settingsCell.configure(title: component.title, detail: sizeString)
			settingsCell.chevronImageView?.isHidden = true
			settingsCell.secondaryLabel?.isHidden = false
			return settingsCell
		case .actions:
			guard let destructiveCell = tableView.dequeueReusableCell(withIdentifier: DestructiveSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(DestructiveSettingsCell.reuseID)")
			}
			destructiveCell.configure(title: Trans.clearAll)
			return destructiveCell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }

		switch section {
		case .cacheComponents:
			return Trans.clearCacheFooterMessage
		case .header, .actions:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension CacheSettingsTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let section = Section(rawValue: section) else {
			return super.tableView(tableView, heightForHeaderInSection: section)
		}

		switch section {
		case .header:
			return .leastNormalMagnitude
		case .cacheComponents, .actions:
			return super.tableView(tableView, heightForHeaderInSection: section.rawValue)
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let section = Section(rawValue: indexPath.section) else { return }

		switch section {
		case .header, .cacheComponents:
			return
		case .actions:
			let alertController = self.presentAlertController(title: Trans.clearAllCache, message: nil, defaultActionButtonTitle: Trans.cancel)
			alertController.addAction(UIAlertAction(title: Trans.clearAll, style: .destructive) { [weak self] _ in
				Task { @MainActor in
					guard let self = self else { return }
					await self.clearAllCaches()
				}
			})
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard Section(rawValue: indexPath.section) == .cacheComponents else { return nil }

		let component = CacheComponent.allCases[indexPath.row]
		let clearAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
			guard let self = self else {
				completionHandler(false)
				return
			}

			Task { @MainActor in
				await self.clearCache(for: component)
				await self.loadCacheSizes()
				self.onCacheCleared?()
				completionHandler(true)
			}
		}
		clearAction.backgroundColor = .kLightRed
		clearAction.image = UIImage(systemName: "minus.circle")

		let configuration = UISwipeActionsConfiguration(actions: [clearAction])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return Section(rawValue: indexPath.section) == .cacheComponents
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Lazily compute the threshold once the header cell is visible, laid out, and in a window.
		if self.titleLabelBottomInContent == nil,
		   let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.header.rawValue)) as? SettingsHeaderCell,
		   headerCell.primaryLabel.bounds.height > 0,
		   headerCell.window != nil {
			let labelFrame = headerCell.primaryLabel.convert(headerCell.primaryLabel.bounds, to: self.tableView)
			self.titleLabelBottomInContent = labelFrame.maxY
		}

		guard let threshold = self.titleLabelBottomInContent else { return }

		// The content-space Y of the top visible edge, accounting for the nav bar inset.
		let visibleTop = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
		let isScrolledPast = visibleTop >= threshold
		let shouldShowTitle = isScrolledPast

		if shouldShowTitle, self.title == nil {
			self.title = Trans.cache
		} else if !shouldShowTitle, self.title != nil {
			self.title = nil
		}
	}
}

// MARK: - Enums
private extension CacheSettingsTableViewController {
	enum Section: Int, CaseIterable {
		case header
		case cacheComponents
		case actions
	}

	enum CacheComponent: Int, CaseIterable {
		case images
		case richLinks

		var title: String {
			switch self {
			case .images:
				return Trans.images
			case .richLinks:
				return Trans.richLinks
			}
		}
	}
}
