//
//  LyricsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import SwiftTheme
import UIKit

// MARK: - Data Source
class LyricsDataSource: UITableViewDiffableDataSource<LyricsViewController.SectionLayoutKind, Int> {}

final class LyricsViewController: KTableViewController {
	// MARK: - Enums
	enum SectionLayoutKind: Hashable {
		case main
	}

	private enum Item {
		case line(Lyrics.Line, rawStartMs: Int)
		case interlude(rawStartMs: Int, rawEndMs: Int)

		var rawStartMs: Int {
			switch self {
			case .line(_, let start): return start
			case .interlude(let start, _): return start
			}
		}

		var isInterlude: Bool {
			switch self {
			case .interlude: return true
			case .line: return false
			}
		}
	}

	// MARK: - Views
	private lazy var optionsButton: KnockoutButton = {
		let button = KnockoutButton(symbol: .Symbols.translate)
		button.showsMenuAsPrimaryAction = true
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 44),
			button.heightAnchor.constraint(equalTo: button.widthAnchor),
		])
		return button
	}()

	private lazy var pictureInPictureButton: KnockoutButton = {
		let button = KnockoutButton(symbol: UIImage(systemName: "pip.enter"))
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 44),
			button.heightAnchor.constraint(equalTo: button.widthAnchor),
		])
		button.addAction(UIAction { _ in
			FloatingLyricsManager.shared.togglePictureInPicture()
		}, for: .touchUpInside)
		return button
	}()

	/// The subscription mirroring the Picture in Picture state onto the button.
	private var pictureInPictureSubscription: AnyCancellable?

	// MARK: - Properties
	private var lyrics: Lyrics?
	private let songID: KurozoraItemID
	private let gapThresholdMs = 4000

	private var dataSource: LyricsDataSource!

	private var displayLink: CADisplayLink?
	private var activeIndex = -1
	private var isUserScrolling = false
	private var isBlurSuppressed = false
	private var wasPlaying = false
	private var hasPerformedInitialSync = false
	private var hasLoadedLyrics = false

	private var showsSecondaryText = UserSettings.lyricsShowsTransliteration
	private var selectedTranslationLanguage: String? = UserSettings.lyricsTranslationLanguage

	private var offsetMs: Int {
		return self.lyrics?.attributes.lyricOffsetMs ?? 0
	}

	/// A Boolean value that indicates whether this song is the one loaded in the player.
	private var isCurrentSong: Bool {
		return MusicManager.shared.currentKKSong?.id == self.songID
	}

	/// A Boolean value that indicates whether playback can be time-synced to the lyrics.
	private var canTimeSync: Bool {
		return MusicManager.shared.authorizationState == .authorized && MusicManager.shared.hasAMSubscription
	}

	/// The line cells currently on screen, including any still held by an in-flight recenter transform.
	private var onScreenLineCells: [LyricsLineCollectionViewCell] {
		var visited: Set<ObjectIdentifier> = []
		var cells: [LyricsLineCollectionViewCell] = []

		for case let lineCell as LyricsLineCollectionViewCell in self.tableView.visibleCells where visited.insert(ObjectIdentifier(lineCell)).inserted {
			cells.append(lineCell)
		}

		for case let lineCell as LyricsLineCollectionViewCell in self.tableView.subviews where visited.insert(ObjectIdentifier(lineCell)).inserted {
			cells.append(lineCell)
		}

		return cells
	}

	private var items: [Item] = []

	private var lineAlignments: [Int: NSTextAlignment] = [:]

	private var backgroundLineIndices: Set<Int> = []

	private var availableTransliterationLanguages: [String] = []

	private var availableTranslationLanguages: [String] = []

	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - Initializers
	init(songID: KurozoraItemID, lyrics: Lyrics? = nil) {
		self.songID = songID
		self.lyrics = lyrics
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.lyrics
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissLyrics))

		self.configureTableView()
		self.configureDataSource()
		self.presentFloatingOptionsButton()

		NotificationCenter.default.addObserver(self, selector: #selector(self.themeDidChange), name: .ThemeUpdateNotification, object: nil)

		if let lyrics = self.lyrics {
			self.applyLyrics(lyrics)
		} else {
			self.fetchLyrics()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.updatePictureInPictureButton()

		if self.canTimeSync {
			self.startDisplayLink()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopDisplayLink()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.view.bringSubviewToFront(self.optionsButton)
		self.view.bringSubviewToFront(self.pictureInPictureButton)

		let bottomInset = self.canTimeSync ? self.tableView.bounds.height * 0.8 : 16
		if self.tableView.contentInset.bottom != bottomInset {
			self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: bottomInset, right: 0)
		}

		if !self.hasPerformedInitialSync, self.tableView.bounds.height > 0 {
			self.hasPerformedInitialSync = true

			if self.canTimeSync {
				self.performInitialSync()
			} else {
				self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.adjustedContentInset.top), animated: false)
			}
		}
	}

	// MARK: - Functions
	override func reloadLocalization() {
		guard self.isViewLoaded else { return }
		self.title = L10n.lyrics
		self.updateOptionsMenu()
	}

	private func configureTableView() {
		self.tableView.separatorStyle = .none
		self.tableView.showsVerticalScrollIndicator = false
		self.tableView.rowHeight = UITableView.automaticDimension
		self.tableView.estimatedRowHeight = 72
	}

	override func configureEmptyDataView() {
		guard self.hasLoadedLyrics, self.items.isEmpty else { return }

		self.emptyBackgroundView.configureImageView(image: .Empty.personQuestion)
		self.emptyBackgroundView.configureLabels(title: L10n.lyricsUnavailableTitle, detail: L10n.lyricsUnavailableDetail)
	}

	/// Floats the options button over the view's bottom trailing edge.
	private func presentFloatingOptionsButton() {
		self.view.addSubview(self.optionsButton)

		let inset: CGFloat = 12

		NSLayoutConstraint.activate([
			self.optionsButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			self.optionsButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -inset),
		])

		self.optionsButton.isHidden = !self.hasLoadedLyrics
		self.updateOptionsButtonAppearance()

		self.view.addSubview(self.pictureInPictureButton)

		NSLayoutConstraint.activate([
			self.pictureInPictureButton.trailingAnchor.constraint(equalTo: self.optionsButton.trailingAnchor),
			self.pictureInPictureButton.bottomAnchor.constraint(equalTo: self.optionsButton.topAnchor, constant: -8),
		])

		self.updatePictureInPictureButton()

		self.pictureInPictureSubscription = FloatingLyricsManager.shared.$isPictureInPictureActive
			.receive(on: RunLoop.main)
			.sink { [weak self] isActive in
				self?.pictureInPictureButton.isActiveState = isActive
			}
	}

	/// Shows the Picture in Picture button only when this song plays time-synced with lyrics.
	private func updatePictureInPictureButton() {
		let manager = FloatingLyricsManager.shared
		self.pictureInPictureButton.isHidden = !(manager.isPictureInPictureSupported && self.canTimeSync && self.isCurrentSong && !self.items.isEmpty)
	}

	private func updateOptionsButtonAppearance() {
		let secondaryTextActive = self.showsSecondaryText && !self.availableTransliterationLanguages.isEmpty
		self.optionsButton.isActiveState = secondaryTextActive || self.selectedTranslationLanguage != nil
	}

	@objc private func themeDidChange() {
		self.updateOptionsButtonAppearance()
	}

	/// Rebuilds the derived content from the given lyrics and refreshes the view.
	///
	/// - Parameter lyrics: The lyrics to display.
	private func applyLyrics(_ lyrics: Lyrics?) {
		self.lyrics = lyrics
		self.hasLoadedLyrics = true

		self.items = self.buildItems()
		self.lineAlignments = self.computeLineAlignments()
		self.backgroundLineIndices = self.computeBackgroundLineIndices()
		self.availableTransliterationLanguages = self.meaningfulTransliterationLanguages(in: lyrics)
		self.availableTranslationLanguages = Array(Set((lyrics?.attributes.lines ?? []).flatMap { $0.translations.map(\.language) })).sorted()

		self.updateDataSource()
		self.updateOptionsMenu()
		self.optionsButton.isHidden = self.items.isEmpty
		self.updatePictureInPictureButton()
		self.configureEmptyDataView()

		self.hasPerformedInitialSync = false
		self.view.setNeedsLayout()
	}

	/// Fetches the song's lyrics and applies them once they arrive.
	private func fetchLyrics() {
		Task { [weak self] in
			guard let self = self else { return }

			do {
				let lyricsResponse = try await KService.lyrics(for: SongIdentity(id: self.songID)).response()
				self.applyLyrics(lyricsResponse.data.first)
			} catch {
				print(error.localizedDescription)
				self.applyLyrics(nil)
			}
		}
	}

	// MARK: Items
	private func buildItems() -> [Item] {
		var items: [Item] = []
		var previousEndMs = 0

		for line in self.lyrics?.attributes.lines ?? [] {
			let beginMs = line.beginMs ?? previousEndMs

			if self.canTimeSync, beginMs - previousEndMs >= self.gapThresholdMs {
				items.append(.interlude(rawStartMs: previousEndMs, rawEndMs: beginMs))
			}

			items.append(.line(line, rawStartMs: beginMs))
			previousEndMs = line.endMs ?? beginMs
		}

		return items
	}

	/// Resolves each line's horizontal alignment from its singing agent.
	///
	/// Lines alternate sides whenever the agent changes from the previous line's; consecutive lines by the same agent share a side, and group agents stay on the main side without affecting the alternation.
	///
	/// - Returns: The alignment for each line, keyed by item index.
	private func computeLineAlignments() -> [Int: NSTextAlignment] {
		let agentTypes = Dictionary((self.lyrics?.attributes.agents ?? []).map { ($0.key, $0.type.lowercased()) }, uniquingKeysWith: { first, _ in first })

		var alignments: [Int: NSTextAlignment] = [:]
		var lastPersonAgent: String?
		var lastPersonWasDuet = false

		for (index, item) in self.items.enumerated() {
			switch item {
			case .interlude:
				continue
			case .line(let line, _):
				let isDuet = self.isDuet(line: line, agentTypes: agentTypes, lastPersonAgent: &lastPersonAgent, lastPersonWasDuet: &lastPersonWasDuet)
				alignments[index] = isDuet ? .right : .natural
			}
		}

		return alignments
	}

	/// Finds the line items that carry background vocals.
	///
	/// - Returns: The item indices whose lines include background words.
	private func computeBackgroundLineIndices() -> Set<Int> {
		var indices: Set<Int> = []

		for (index, item) in self.items.enumerated() {
			switch item {
			case .line(let line, _):
				if line.words.contains(where: { $0.background }) {
					indices.insert(index)
				}
			case .interlude:
				continue
			}
		}

		return indices
	}

	/// Determines whether a line sings on the duet (trailing) side.
	///
	/// - Parameters:
	///    - line: The line to resolve.
	///    - agentTypes: The agent type keyed by agent identifier.
	///    - lastPersonAgent: The previous person agent's identifier, updated in place.
	///    - lastPersonWasDuet: The previous person agent's side, updated in place.
	///
	/// - Returns: `true` when the line belongs on the trailing side.
	private func isDuet(line: Lyrics.Line, agentTypes: [String: String], lastPersonAgent: inout String?, lastPersonWasDuet: inout Bool) -> Bool {
		let agent = line.agent ?? ""
		let type = agentTypes[agent]

		if type == "group" {
			return false
		}

		if lastPersonAgent == nil {
			let isDuet = type == "other"
			lastPersonAgent = agent
			lastPersonWasDuet = isDuet
			return isDuet
		}

		if lastPersonAgent == agent {
			return lastPersonWasDuet
		}

		let isDuet = !lastPersonWasDuet
		lastPersonAgent = agent
		lastPersonWasDuet = isDuet
		return isDuet
	}

	// MARK: Sync
	private func startDisplayLink() {
		guard self.displayLink == nil else { return }

		let displayLink = CADisplayLink(target: self, selector: #selector(self.tick))
		displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30)
		displayLink.add(to: .main, forMode: .common)
		self.displayLink = displayLink
	}

	private func stopDisplayLink() {
		self.displayLink?.invalidate()
		self.displayLink = nil
	}

	private func performInitialSync() {
		let positionMs = self.currentPositionMs()
		self.activeIndex = self.isCurrentSong ? self.activeItemIndex(forPositionMs: positionMs) : -1

		self.refreshActiveStyling()

		UIView.performWithoutAnimation {
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
		}

		self.tableView.layoutIfNeeded()

		if self.activeIndex >= 0 {
			self.scrollToActiveItem(animated: false)
		} else {
			self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.adjustedContentInset.top), animated: false)
		}

		self.tableView.layoutIfNeeded()
		self.updateActiveItem(positionMs: positionMs)
	}

	private func currentPositionMs() -> Int {
		return self.isCurrentSong ? Int(MusicManager.shared.currentPlaybackSeconds * 1000) : 0
	}

	@objc private func tick() {
		let positionMs = self.currentPositionMs()

		let isPlaying = self.isCurrentSong && MusicManager.shared.isPlaying
		if isPlaying != self.wasPlaying {
			self.wasPlaying = isPlaying
			self.refreshActiveStyling()
		}

		let newIndex = self.isCurrentSong ? self.activeItemIndex(forPositionMs: positionMs) : -1
		if newIndex != self.activeIndex {
			let interludeInvolved = self.isInterlude(self.activeIndex) || self.isInterlude(newIndex)
			let backgroundInvolved = self.backgroundLineIndices.contains(self.activeIndex) || self.backgroundLineIndices.contains(newIndex)
			self.activeIndex = newIndex
			self.refreshActiveStyling()

			if interludeInvolved {
				self.tableView.beginUpdates()
				self.tableView.endUpdates()
			} else if backgroundInvolved {
				if !self.isUserScrolling {
					self.restoreBlur()
				}

				self.animateLayoutChange(pinningActiveLineTo: self.recenterAnchorScreenY()) {
					self.tableView.beginUpdates()
					self.tableView.endUpdates()
				}
			} else {
				if !self.isUserScrolling {
					self.restoreBlur()
				}

				self.scrollToActiveItem(animated: true)
			}
		}

		self.updateActiveItem(positionMs: positionMs)
	}

	private func activeItemIndex(forPositionMs positionMs: Int) -> Int {
		var index = -1
		for (itemIndex, item) in self.items.enumerated() {
			if item.rawStartMs + self.offsetMs <= positionMs {
				index = itemIndex
			} else {
				break
			}
		}
		return index
	}

	private func isInterlude(_ index: Int) -> Bool {
		return self.items.indices.contains(index) && self.items[index].isInterlude
	}

	/// The row of the line to anchor at the focal point.
	///
	/// - Returns: The row to anchor.
	private func rowToCenter() -> Int? {
		guard self.items.indices.contains(self.activeIndex) else { return nil }

		if !self.isInterlude(self.activeIndex) {
			return self.activeIndex
		}

		for row in stride(from: self.activeIndex - 1, through: 0, by: -1) where !self.isInterlude(row) {
			return row
		}

		return nil
	}

	private func updateActiveItem(positionMs: Int) {
		guard self.items.indices.contains(self.activeIndex) else { return }
		guard let cell = self.tableView.cellForRow(at: IndexPath(row: self.activeIndex, section: 0)) else { return }

		switch self.items[self.activeIndex] {
		case .line:
			(cell as? LyricsLineCollectionViewCell)?.setProgress(ms: positionMs)
		case .interlude(let rawStartMs, let rawEndMs):
			let remainingMs = (rawEndMs + self.offsetMs) - positionMs
			(cell as? LyricsInterludeCollectionViewCell)?.setProgress(remainingMs: remainingMs, totalMs: rawEndMs - rawStartMs)
		}
	}

	private func setScrollSuppressed(_ suppressed: Bool) {
		self.onScreenLineCells.forEach { $0.setScrollSuppressed(suppressed) }
	}

	/// Hides the blur on every line until the next recenter.
	private func suppressBlur() {
		guard !self.isBlurSuppressed else { return }
		self.isBlurSuppressed = true
		self.setScrollSuppressed(true)
	}

	/// Restores the per-line blur.
	private func restoreBlur() {
		guard self.isBlurSuppressed else { return }
		self.isBlurSuppressed = false
		self.setScrollSuppressed(false)
	}

	/// Applies the active or static reveal styling to a line cell.
	///
	/// - Parameters:
	///    - cell: The line cell to style.
	///    - index: The cell's item index.
	private func applyPlaybackStyling(to cell: LyricsLineCollectionViewCell, at index: Int) {
		guard self.canTimeSync else {
			cell.setStaticReveal()
			return
		}

		cell.setActive(index == self.activeIndex, blurRadius: self.blurRadius(forRow: index))
		cell.setScrollSuppressed(self.isBlurSuppressed)
	}

	private func refreshActiveStyling() {
		for cell in self.tableView.visibleCells {
			guard let indexPath = self.tableView.indexPath(for: cell) else { continue }
			let isActive = indexPath.row == self.activeIndex

			if let lineCell = cell as? LyricsLineCollectionViewCell {
				lineCell.setActive(isActive, blurRadius: self.blurRadius(forRow: indexPath.row))
			} else if let interludeCell = cell as? LyricsInterludeCollectionViewCell {
				interludeCell.setActive(isActive)
			}
		}
	}

	/// The blur radius for a line, growing with its distance from the active line.
	///
	/// - Parameter row: The row of the line.
	///
	/// - Returns: The blur radius in points.
	private func blurRadius(forRow row: Int) -> CGFloat {
		guard self.canTimeSync, self.isCurrentSong, MusicManager.shared.isPlaying, self.activeIndex >= 0 else { return 0 }
		return LyricsLayout.blurRadius(forDistance: abs(row - self.activeIndex))
	}

	/// The on-screen Y at which the active line is anchored.
	private func recenterAnchorScreenY() -> CGFloat {
		return self.tableView.adjustedContentInset.top + self.tableView.bounds.height * 0.35
	}

	/// Sets the content offset so the active line's top sits at the given on-screen Y.
	///
	/// - Parameter screenY: The target on-screen Y for the active line's top.
	private func pinActiveLine(toScreenY screenY: CGFloat) {
		guard self.items.indices.contains(self.activeIndex) else { return }

		let path = IndexPath(row: self.activeIndex, section: 0)
		let minY = -self.tableView.adjustedContentInset.top
		let maxY = max(minY, self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.adjustedContentInset.bottom)
		let targetY = min(max(self.tableView.rectForRow(at: path).minY - screenY, minY), maxY)
		self.tableView.contentOffset = CGPoint(x: 0, y: targetY)
	}

	/// Applies a height change, holds the active line's top at a target on-screen Y, then glides every other visible row to absorb the change.
	///
	/// - Parameters:
	///    - targetScreenY: The on-screen Y to hold the active line's top at.
	///    - mutate: The height-changing mutations to apply.
	private func animateLayoutChange(pinningActiveLineTo targetScreenY: CGFloat, mutate: () -> Void) {
		let oldOffset = self.tableView.contentOffset.y
		var oldScreenY: [IndexPath: CGFloat] = [:]
		for cell in self.tableView.visibleCells {
			if let indexPath = self.tableView.indexPath(for: cell) {
				oldScreenY[indexPath] = cell.frame.minY - oldOffset
			}
		}

		UIView.performWithoutAnimation {
			mutate()
			self.tableView.layoutIfNeeded()
			self.pinActiveLine(toScreenY: targetScreenY)
			self.tableView.layoutIfNeeded()
		}

		let newOffset = self.tableView.contentOffset.y
		for cell in self.tableView.visibleCells {
			guard let indexPath = self.tableView.indexPath(for: cell), let previousScreenY = oldScreenY[indexPath] else { continue }

			let delta = previousScreenY - (cell.frame.minY - newOffset)
			guard abs(delta) > 0.5 else { continue }

			cell.transform = CGAffineTransform(translationX: 0, y: delta)
			UIView.animate(withDuration: LyricsLayout.scrollAnimationDuration, delay: 0, usingSpringWithDamping: LyricsLayout.scrollSpringDamping, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
				cell.transform = .identity
			}
		}
	}

	private func scrollToActiveItem(animated: Bool) {
		guard !self.isUserScrolling, let row = self.rowToCenter() else { return }

		let indexPath = IndexPath(row: row, section: 0)
		let rect = self.tableView.rectForRow(at: indexPath)
		let anchorScreenY = self.recenterAnchorScreenY()
		let minY = -self.tableView.adjustedContentInset.top
		let maxY = max(minY, self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.adjustedContentInset.bottom)
		let targetY = min(max(rect.minY - anchorScreenY, minY), maxY)

		guard animated else {
			self.tableView.setContentOffset(CGPoint(x: 0, y: targetY), animated: false)
			return
		}

		let deltaY = targetY - self.tableView.contentOffset.y
		guard abs(deltaY) > 0.5 else { return }

		self.tableView.setContentOffset(CGPoint(x: 0, y: targetY), animated: false)
		self.tableView.layoutIfNeeded()

		var cells = self.tableView.visibleCells.sorted { $0.frame.minY < $1.frame.minY }
		if deltaY < 0 {
			cells.reverse()
		}

		for (index, cell) in cells.enumerated() {
			cell.transform = CGAffineTransform(translationX: 0, y: deltaY)
			UIView.animate(
				withDuration: LyricsLayout.scrollAnimationDuration,
				delay: Double(index) * LyricsLayout.scrollStaggerDelay,
				usingSpringWithDamping: LyricsLayout.scrollSpringDamping,
				initialSpringVelocity: 0,
				options: [.beginFromCurrentState, .allowUserInteraction]
			) {
				cell.transform = .identity
			}
		}
	}

	// MARK: Options
	private func updateOptionsMenu() {
		let largerText = UserSettings.lyricsLargerText
		let secondaryTextTitle = self.showsSecondaryText ? largerText.hideSecondaryTextTitle : largerText.showSecondaryTextTitle
		let secondaryTextImage = self.showsSecondaryText ? .Symbols.captionsBubbleSlash : UIImage(systemName: "captions.bubble")
		let secondaryTextAction = UIAction(
			title: secondaryTextTitle,
			image: secondaryTextImage,
			attributes: self.availableTransliterationLanguages.isEmpty ? .disabled : []
		) { [weak self] _ in
			self?.showsSecondaryText.toggle()
			self?.optionsChanged()
		}

		let translationElement: UIMenuElement
		if self.availableTranslationLanguages.isEmpty {
			translationElement = UIAction(title: L10n.translation, image: UIImage(systemName: "character.bubble"), attributes: .disabled) { _ in }
		} else {
			var children: [UIMenuElement] = [
				UIAction(title: L10n.off, state: self.selectedTranslationLanguage == nil ? .on : .off) { [weak self] _ in
					self?.selectedTranslationLanguage = nil
					self?.optionsChanged()
				}
			]
			for language in self.availableTranslationLanguages {
				let name = Locale.current.localizedString(forIdentifier: language) ?? language
				children.append(UIAction(title: name, state: self.selectedTranslationLanguage == language ? .on : .off) { [weak self] _ in
					self?.selectedTranslationLanguage = language
					self?.optionsChanged()
				})
			}
			translationElement = UIMenu(title: L10n.translation, image: UIImage(systemName: "character.bubble"), options: .singleSelection, children: children)
		}

		self.optionsButton.menu = UIMenu(children: [translationElement, secondaryTextAction])
		self.updateOptionsButtonAppearance()
	}

	private func optionsChanged() {
		UserSettings.set(self.showsSecondaryText, forKey: .lyricsShowsTransliteration)
		UserSettings.set(self.selectedTranslationLanguage, forKey: .lyricsTranslationLanguage)

		self.updateOptionsMenu()
		self.reloadPreservingActiveLine()
	}

	/// Reloads the list, keeping the active line at its on-screen position.
	private func reloadPreservingActiveLine() {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems(snapshot.itemIdentifiers)

		let path = IndexPath(row: self.activeIndex, section: 0)
		guard self.items.indices.contains(self.activeIndex), self.tableView.indexPathsForVisibleRows?.contains(path) == true else {
			self.dataSource.apply(snapshot, animatingDifferences: true)
			return
		}

		let anchorScreenY = self.tableView.rectForRow(at: path).minY - self.tableView.contentOffset.y

		self.animateLayoutChange(pinningActiveLineTo: anchorScreenY) {
			self.dataSource.apply(snapshot, animatingDifferences: false)
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
		}
	}

	// MARK: Mapping
	private func pairs(for line: Lyrics.Line) -> (main: [KaraokeWordPair], background: [KaraokeWordPair], hasWordTiming: Bool) {
		let transliteration = line.transliterations.first
		let hasRomaji = self.transliterationDiffers(transliteration, from: line.text)
		let romajiWords = hasRomaji ? transliteration?.words : nil

		if line.words.isEmpty {
			let texts = self.orderedTexts(original: line.text, romaji: hasRomaji ? transliteration?.text : nil)
			let pair = KaraokeWordPair(primary: texts.primary, secondary: texts.secondary, beginMs: line.beginMs ?? 0, endMs: line.endMs ?? 0, trailingSpace: false)
			return ([pair], [], false)
		}

		var mainPairs: [KaraokeWordPair] = []
		var backgroundPairs: [KaraokeWordPair] = []

		for (index, word) in line.words.enumerated() {
			let romaji = (romajiWords?.indices.contains(index) ?? false) ? romajiWords?[index].text : nil
			let texts = self.orderedTexts(original: word.text, romaji: romaji)
			let pair = KaraokeWordPair(primary: texts.primary, secondary: texts.secondary, beginMs: word.beginMs, endMs: word.endMs, trailingSpace: word.trailingSpace)

			if word.background {
				backgroundPairs.append(pair)
			} else {
				mainPairs.append(pair)
			}
		}

		return (mainPairs, backgroundPairs, true)
	}

	/// Orders a word's original text and its pronunciation by size, honoring the larger text setting.
	///
	/// - Parameters:
	///    - original: The original text of the word.
	///    - romaji: The romanized pronunciation of the word.
	///
	/// - Returns: The text drawn larger and the text drawn smaller beneath it.
	private func orderedTexts(original: String, romaji: String?) -> (primary: String, secondary: String?) {
		guard let romaji = romaji else { return (original, nil) }

		switch UserSettings.lyricsLargerText {
		case .lyrics:
			return (original, self.showsSecondaryText ? romaji : nil)
		case .pronunciation:
			return (romaji, self.showsSecondaryText ? original : nil)
		}
	}

	private func translationText(for line: Lyrics.Line) -> String? {
		guard let language = self.selectedTranslationLanguage else { return nil }
		return line.translations.first { $0.language == language }?.text
	}

	/// Whether the transliteration adds romanization beyond the original line.
	///
	/// - Parameters:
	///    - transliteration: The line's transliteration.
	///    - original: The original line text.
	///
	/// - Returns: `true` when the transliteration differs from the original.
	private func transliterationDiffers(_ transliteration: Lyrics.Transliteration?, from original: String) -> Bool {
		guard let transliteration = transliteration else { return false }
		return transliteration.text.trimmingCharacters(in: .whitespacesAndNewlines) != original.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	/// The transliteration languages that add romanization beyond the original lines.
	///
	/// - Parameter lyrics: The lyrics to inspect.
	///
	/// - Returns: The languages whose transliteration differs from the original on at least one line.
	private func meaningfulTransliterationLanguages(in lyrics: Lyrics?) -> [String] {
		var languages: Set<String> = []

		for line in lyrics?.attributes.lines ?? [] {
			for transliteration in line.transliterations where self.transliterationDiffers(transliteration, from: line.text) {
				languages.insert(transliteration.language)
			}
		}

		return languages.sorted()
	}

	@objc private func dismissLyrics() {
		self.dismiss(animated: true)
	}
}

// MARK: - KTableViewDataSource
extension LyricsViewController {
	private func configureDataSource() {
		let lineRegistration = UITableView.CellRegistration<LyricsLineCollectionViewCell, Int> { [weak self] cell, _, index in
			guard let self = self else { return }

			switch self.items[index] {
			case .line(let line, _):
				let mapped = self.pairs(for: line)
				cell.configure(pairs: mapped.main, backgroundPairs: mapped.background, hasWordTiming: mapped.hasWordTiming, translationText: self.translationText(for: line), offsetMs: self.offsetMs, alignment: self.lineAlignments[index] ?? .natural)
				self.applyPlaybackStyling(to: cell, at: index)
			case .interlude:
				break
			}
		}

		let interludeRegistration = UITableView.CellRegistration<LyricsInterludeCollectionViewCell, Int> { [weak self] cell, _, index in
			guard let self = self else { return }
			cell.setActive(index == self.activeIndex)
		}

		self.dataSource = LyricsDataSource(tableView: self.tableView) { [weak self] tableView, indexPath, index -> UITableViewCell? in
			guard let self = self else { return nil }

			switch self.items[index] {
			case .line:
				return tableView.dequeueConfiguredReusableCell(using: lineRegistration, for: indexPath, item: index)
			case .interlude:
				return tableView.dequeueConfiguredReusableCell(using: interludeRegistration, for: indexPath, item: index)
			}
		}
	}

	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		snapshot.appendSections([.main])
		snapshot.appendItems(Array(self.items.indices), toSection: .main)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}
}

// MARK: - UITableViewDelegate
extension LyricsViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch self.items[indexPath.row] {
		case .line:
			return UITableView.automaticDimension
		case .interlude:
			return indexPath.row == self.activeIndex ? UITableView.automaticDimension : .leastNonzeroMagnitude
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let lineCell = cell as? LyricsLineCollectionViewCell else { return }
		self.applyPlaybackStyling(to: lineCell, at: indexPath.row)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard self.canTimeSync else { return }

		let line: Lyrics.Line
		switch self.items[indexPath.row] {
		case .line(let lyricsLine, _):
			line = lyricsLine
		case .interlude:
			return
		}

		guard self.isCurrentSong, let beginMs = line.beginMs else { return }

		MusicManager.shared.seek(toSeconds: Double(beginMs + self.offsetMs) / 1000)

		if !MusicManager.shared.isPlaying {
			MusicManager.shared.togglePlayPause()
		}
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.isUserScrolling = true
		self.suppressBlur()
	}

	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.isUserScrolling = false
		}
	}

	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.isUserScrolling = false
	}
}
