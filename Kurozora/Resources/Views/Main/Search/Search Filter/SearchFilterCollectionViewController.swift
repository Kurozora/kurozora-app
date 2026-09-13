//
//  SearchFilterCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol SearchFilterCollectionViewControllerDelegate: AnyObject {
	func searchFilterCollectionViewController(_ searchFilterCollectionViewController: SearchFilterCollectionViewController, didApply filter: SearchFilter)
	func searchFilterCollectionViewControllerDidReset(_ searchFilterCollectionViewController: SearchFilterCollectionViewController)
	func searchFilterCollectionViewControllerDidCancel(_ searchFilterCollectionViewController: SearchFilterCollectionViewController)
}

class SearchFilterCollectionViewController: KCollectionViewController {
	// MARK: - Views
	private var resetBarButtonItem: UIBarButtonItem!
	private var applyBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var searchType: SearchType?
	var descriptors: [FilterDescriptor] = []
	var filter: SearchFilter?

	/// The values the user has set on the page.
	var draft: [FilterKey: FilterValue] = [:]

	var dataSource: UICollectionViewDiffableDataSource<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>!

	var delegate: SearchFilterCollectionViewControllerDelegate?

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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configure()

		if let searchType = self.searchType {
			self.descriptors = searchType.filterDescriptors
		}

		self.draft = self.filter?.values ?? [:]

		self.configureDataSource()
		self.updateDataSource()
	}

	// MARK: - Functions
	private func configure() {
		self.configureView()
		self.configureCollectionView()
		self.configureResetBarButtonItem()
		self.configureApplyBarButtonItem()
		self.updateResetAvailability()
	}

	/// Returns the descriptor registered under the given key.
	///
	/// - Parameter key: The key of the descriptor.
	///
	/// - Returns: The matching descriptor.
	func descriptor(for key: FilterKey) -> FilterDescriptor? {
		return self.descriptors.first { $0.key == key }
	}

	/// Returns the value the user has set against the given key.
	///
	/// - Parameter key: The key to read.
	///
	/// - Returns: The value the user set.
	func draftValue(for key: FilterKey) -> FilterValue? {
		return self.draft[key]
	}

	/// Writes the given value against the given key.
	///
	/// - Parameters:
	///    - value: The value the user set.
	///    - key: The key to write.
	func setDraftValue(_ value: FilterValue?, for key: FilterKey) {
		if let value = value, !value.isEmpty {
			self.draft[key] = value
		} else {
			self.draft[key] = nil
		}

		self.updateResetAvailability()
	}

	private func configureView() {
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true
		self.title = L10n.filters
	}

	private func configureCollectionView() {
		self.collectionView.contentInset.bottom = 20
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
	}

	private func configureResetBarButtonItem() {
		self.resetBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.resetButtonPressed()
		})
		self.resetBarButtonItem.accessibilityLabel = L10n.reset
		self.navigationItem.leftBarButtonItem = self.resetBarButtonItem
	}

	private func configureApplyBarButtonItem() {
		self.applyBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.applyButtonPressed()
		})
		self.applyBarButtonItem.accessibilityLabel = L10n.apply
		self.navigationItem.rightBarButtonItem = self.applyBarButtonItem
	}

	private func updateResetAvailability() {
		self.resetBarButtonItem?.isEnabled = !self.draft.isEmpty
	}

	private func applyButtonPressed() {
		guard let searchType = self.searchType else { return }

		let newSearchFilter = SearchFilter(type: searchType, values: self.draft)
		let searchFilterCollectionViewController = self

		self.dismiss(animated: true) {
			searchFilterCollectionViewController.delegate?.searchFilterCollectionViewController(searchFilterCollectionViewController, didApply: newSearchFilter)
		}
	}

	private func resetButtonPressed() {
		self.filter = nil
		self.draft = [:]

		self.updateResetAvailability()
		self.updateDataSource()
	}
}

// MARK: - SearchFilterBaseCollectionViewCellDelegate
extension SearchFilterCollectionViewController: SearchFilterBaseCollectionViewCellDelegate {
	func searchFilterBaseCollectionViewCell(_ cell: SearchFilterBaseCollectionViewCell, didChangeValue value: AnyHashable?) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .searchFilter(let key, _):
			guard let descriptor = self.descriptor(for: key) else { return }

			self.setDraftValue(self.draftValue(from: value, for: descriptor), for: key)
		}
	}

	/// Returns the value the cell's report writes.
	///
	/// - Parameters:
	///    - value: The value the cell reported.
	///    - descriptor: The filter the cell presents.
	///
	/// - Returns: The value to hold against the filter.
	private func draftValue(from value: AnyHashable?, for descriptor: FilterDescriptor) -> FilterValue? {
		switch descriptor.control {
		case .date:
			guard let date = value as? Date else { return nil }

			return .date(date.timeIntervalSince1970)
		case .text:
			guard let text = value as? String, !text.isEmpty else { return nil }

			return .text(text)
		case .numberPills, .textPills, .booleanPills, .buckets, .duration:
			guard let title = value as? String else { return nil }

			return self.value(forOptionTitle: title, in: descriptor)
		}
	}
}
