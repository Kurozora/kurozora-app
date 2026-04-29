//
//  SearchTokenSuggestionsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class SearchTokenSuggestionsTableViewController: KTableViewController {
	// MARK: - Sections
	/// The single section hosting the suggestion rows.
	enum Section: Hashable {
		case suggestions
	}

	// MARK: - Properties
	/// The types currently offered as suggestions.
	var types: [SearchType] = [] {
		didSet {
			self.applySnapshot()
		}
	}

	/// A closure invoked with the selected type when the user taps a row.
	var onSelect: ((SearchType) -> Void)?

	/// Whether a suggestion row is currently being touched.
	private(set) var isTrackingSuggestionTap = false

	/// The diffable data source backing the suggestions table.
	private var dataSource: UITableViewDiffableDataSource<Section, SearchType>!

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// MARK: - Initializers
	/// Creates a token suggestions view controller using the inset-grouped table style.
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.tableView.keyboardDismissMode = .none

		self.configureDataSource()
		self.applySnapshot()
		self.observeKeyboardNotifications()
		self.installTouchTracker()
	}

	// MARK: - Functions
	/// Wires up the diffable data source and its cell provider.
	private func configureDataSource() {
		self.dataSource = UITableViewDiffableDataSource<Section, SearchType>(tableView: self.tableView) { tableView, indexPath, type in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTokenSuggestionTableViewCell.self, for: indexPath) else {
				return UITableViewCell()
			}
			cell.configure(with: type)
			return cell
		}
	}

	/// Applies a snapshot containing the current suggestion `types`.
	private func applySnapshot() {
		guard let dataSource = self.dataSource else { return }

		var snapshot = NSDiffableDataSourceSnapshot<Section, SearchType>()
		snapshot.appendSections([.suggestions])
		snapshot.appendItems(self.types, toSection: .suggestions)
		dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Installs a zero-duration long-press recognizer that tracks the touch lifecycle on the
	/// suggestions table so ``isTrackingSuggestionTap`` straddles the entire UIKit event chain
	/// for a row tap.
	private func installTouchTracker() {
		let touchTracker = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTouchTracker(_:)))
		touchTracker.minimumPressDuration = 0
		touchTracker.cancelsTouchesInView = false
		touchTracker.delaysTouchesBegan = false
		touchTracker.delaysTouchesEnded = false
		touchTracker.delegate = self
		self.tableView.addGestureRecognizer(touchTracker)
	}

	/// Drives ``isTrackingSuggestionTap`` from the touch tracker's state.
	///
	/// - Parameter recognizer: The recognizer reporting the state change.
	@objc private func handleTouchTracker(_ recognizer: UILongPressGestureRecognizer) {
		switch recognizer.state {
		case .began:
			self.isTrackingSuggestionTap = true
		case .ended, .cancelled, .failed:
			// Defer the clear so any pending UIKit callbacks for this touch still observe the flag as `true`.
			DispatchQueue.main.async { [weak self] in
				self?.isTrackingSuggestionTap = false
			}
		default:
			break
		}
	}

	/// Subscribes to keyboard frame notifications so the table can keep its bottom row above the keyboard.
	private func observeKeyboardNotifications() {
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(self.keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		center.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	/// Adjusts the table's bottom safe-area inset so the last row is reachable above the keyboard.
	///
	/// - Parameter notification: The notification that triggered the frame change.
	@objc private func keyboardFrameWillChange(_ notification: Notification) {
		guard let endFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}

		let endFrame = self.view.convert(endFrameValue.cgRectValue, from: nil)
		let overlap = max(0, self.view.bounds.maxY - endFrame.minY)
		self.additionalSafeAreaInsets.bottom = overlap
	}

	/// Restores the table's bottom safe-area inset when the keyboard hides.
	///
	/// - Parameter notification: The notification that triggered the dismissal.
	@objc private func keyboardWillHide(_ notification: Notification) {
		self.additionalSafeAreaInsets.bottom = 0
	}
}

// MARK: - UIGestureRecognizerDelegate
extension SearchTokenSuggestionsTableViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

// MARK: - KTableViewDataSource
extension SearchTokenSuggestionsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SearchTokenSuggestionTableViewCell.self]
	}
}

// MARK: - UITableViewDataSource
extension SearchTokenSuggestionsTableViewController {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return L10n.suggestions
	}
}

// MARK: - UITableViewDelegate
extension SearchTokenSuggestionsTableViewController {
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? SearchTokenSuggestionTableViewCell else {
			return
		}

		cell.applyHighlightedAppearance()
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? SearchTokenSuggestionTableViewCell else {
			return
		}

		cell.applyUnhighlightedAppearance()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let type = self.dataSource.itemIdentifier(for: indexPath) else {
			return
		}

		self.onSelect?(type)
	}
}
