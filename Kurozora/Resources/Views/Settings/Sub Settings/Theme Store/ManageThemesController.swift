//
//  ManageThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

private struct ThemeDownloadHandle {
	let task: Task<Void, Never>
	let startedAt: Date
	var progress: Double
}

class ManageThemesCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	private let minimumPendingDwell: TimeInterval = 0.5

	private var downloads: [KurozoraItemID: ThemeDownloadHandle] = [:]

	var appThemes: [AppTheme] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>!

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
	override init() {
		super.init()
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	private func sharedInit() {
		// Fetch app themes
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchAppThemes()
		}
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.themeStore

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()
		self.updateDataSource()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.appThemes = []

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchAppThemes()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Symbols.swatchpaletteFill)
		emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.themes), detail: L10n.noThemesAvailableDetail)

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches themes from the server.
	@MainActor
	func fetchAppThemes() async {
		do {
			let appThemeResponse = try await KService.themeStore().response()
			self.appThemes = appThemeResponse.data
		} catch {
			self._prefersActivityIndicatorHidden = true
			print(error.localizedDescription)
		}
	}
}

// MARK: - ThemesCollectionViewCellDelegate
extension ManageThemesCollectionViewController: ThemesCollectionViewCellDelegate {
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIView) {
		switch cell.kTheme {
		case .kurozora:
			KTheme.kurozora.switchToTheme()
		case .day:
			KTheme.day.switchToTheme()
		case .night:
			KTheme.night.switchToTheme()
		case .grass:
			KTheme.grass.switchToTheme()
		case .sky:
			KTheme.sky.switchToTheme()
		case .sakura:
			KTheme.sakura.switchToTheme()
		case .other(let theme):
			if self.downloads[theme.id] != nil {
				self.cancelDownload(of: theme)
				return
			}

			if !KThemeStyle.themeExist(for: theme) || !KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
				Task {
					guard await WorkflowController.shared.isProOrSubscribed(on: self) else { return }
					self.startDownload(of: theme)
				}
				return
			}

			KThemeStyle.switchTo(appTheme: theme)
		}
	}

	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, downloadStateFor appTheme: AppTheme) -> KDownloadButtonState {
		if let handle = self.downloads[appTheme.id] {
			let dwellElapsed = Date().timeIntervalSince(handle.startedAt) >= self.minimumPendingDwell
			if dwellElapsed && handle.progress > 0 {
				return .downloading(progress: handle.progress)
			}
			return .pending
		}

		let currentThemeID = UserSettings.currentTheme
		let exists = KThemeStyle.themeExist(for: appTheme)
		let isUpToDate = !exists || KThemeStyle.isUpToDate(appTheme.id, version: appTheme.attributes.version)

		if exists && (User.isPro || User.isSubscribed) && !isUpToDate {
			return .start(title: L10n.themeButtonUpdate)
		}
		if exists {
			let isSelected = currentThemeID == appTheme.id.rawValue
			let title = isSelected ? "USING" : "USE"
			return .downloaded(title: title, opensMenuOnTap: isSelected)
		}
		return .start(title: L10n.themeButtonGet)
	}

	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, menuFor appTheme: AppTheme) -> UIMenu? {
		guard KThemeStyle.themeExist(for: appTheme) else {
			return nil
		}

		let isSelected = UserSettings.currentTheme == appTheme.id.rawValue

		var actions: [UIAction] = []

		if !isSelected {
			let applyAction = UIAction(title: L10n.applyTheme, image: UIImage(systemName: "checkmark.circle")) { _ in
				KThemeStyle.switchTo(appTheme: appTheme)
			}
			actions.append(applyAction)
		}

		if User.isPro || User.isSubscribed {
			let redownloadAction = UIAction(title: L10n.redownloadTheme, image: UIImage(systemName: "arrow.uturn.down")) { [weak self] _ in
				self?.startDownload(of: appTheme)
			}
			actions.append(redownloadAction)
		}

		let removeAction = UIAction(title: L10n.removeTheme, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
			self?.removeDownloadedTheme(appTheme)
		}
		actions.append(removeAction)

		return UIMenu(title: "", children: actions)
	}

	fileprivate func startDownload(of appTheme: AppTheme) {
		let themeID = appTheme.id
		let startedAt = Date()

		self.downloads[themeID]?.task.cancel()

		let task = Task { @MainActor [weak self] in
			guard let self = self else { return }

			do {
				try await KThemeStyle.downloadTheme(for: appTheme) { progress in
					self.downloads[themeID]?.progress = progress
					self.refreshCell(for: themeID)
				}

				try Task.checkCancellation()

				let remaining = self.minimumPendingDwell - Date().timeIntervalSince(startedAt)
				if remaining > 0 {
					try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
				}

				self.downloads.removeValue(forKey: themeID)
				KThemeStyle.switchTo(appTheme: appTheme)
				self.refreshCell(for: themeID)
			} catch is CancellationError {
				self.downloads.removeValue(forKey: themeID)
				self.refreshCell(for: themeID)
			} catch {
				self.downloads.removeValue(forKey: themeID)
				self.refreshCell(for: themeID)
				print(error.localizedDescription)
			}
		}

		self.downloads[themeID] = ThemeDownloadHandle(task: task, startedAt: startedAt, progress: 0)
		self.refreshCell(for: themeID)

		let minimumPendingDwell = self.minimumPendingDwell

		Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: UInt64(minimumPendingDwell * 1_000_000_000))
			guard let self = self, self.downloads[themeID] != nil else { return }
			self.refreshCell(for: themeID)
		}
	}

	fileprivate func cancelDownload(of appTheme: AppTheme) {
		self.downloads[appTheme.id]?.task.cancel()
	}

	fileprivate func removeDownloadedTheme(_ appTheme: AppTheme) {
		do {
			try KThemeStyle.removeTheme(for: appTheme)
			if UserSettings.currentTheme == appTheme.id.rawValue {
				KThemeStyle.switchTo(style: .default)
			}
			self.refreshCell(for: appTheme.id)
		} catch {
			print(error.localizedDescription)
		}
	}

	private func refreshCell(for themeID: KurozoraItemID) {
		guard let itemIndex = self.appThemes.firstIndex(where: { $0.id == themeID }) else { return }

		let indexPath = IndexPath(item: itemIndex, section: SectionLayoutKind.premium.rawValue)
		guard let cell = self.collectionView.cellForItem(at: indexPath) as? ThemesCollectionViewCell else { return }

		cell.refreshAffordance()
	}
}

// MARK: - SectionLayoutKind
extension ManageThemesCollectionViewController {
	/// List of theme section layout kind.
	///
	/// ```swift
	/// case default = 0
	/// case premium = 1
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case `default` = 0
		case premium = 1
	}
}
