//
//  RequestRefundTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import StoreKit
import UIKit

class RequestRefundTableViewController: SubSettingsViewController {
	// MARK: - Properties
	var transactions: [StoreTransaction] = []

	var dataSource: RequestRefundDataSource!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.refund
		self.headerTitle = L10n.requestRefund
		self.headerDescription = L10n.requestRefundHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()
		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self._prefersRefreshControlDisabled = false
		self._prefersActivityIndicatorHidden = false

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.configureDataSource()
		self.updateDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchTransactions()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Icons.refund)
		self.emptyBackgroundView.configureLabels(title: L10n.refundEmptyTitle, detail: L10n.refundEmptyDetail)
		self.tableView.backgroundView?.alpha = 0
	}

	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchTransactions()
		}
	}

	// MARK: - Functions
	/// Fetches the user's StoreKit transactions.
	func fetchTransactions() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true
		self._prefersActivityIndicatorHidden = false

		do {
			let response = try await KService.storeTransactions().response()
			self.transactions = response.data
		} catch {
			print("🧾 Failed to fetch store transactions: \(error.localizedDescription)")
		}

		self.endFetch()
	}

	private func endFetch() {
		self.isRequestInProgress = false
		self._prefersActivityIndicatorHidden = true
		self.updateDataSource()
		self.toggleEmptyDataView()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	private func toggleEmptyDataView() {
		if self.transactions.isEmpty {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	func transactions(in section: SectionLayoutKind) -> [StoreTransaction] {
		switch section {
		case .header:
			return []
		case .purchased:
			return self.transactions.filter { $0.attributes.isRefundable }
		case .refunded:
			return self.transactions.filter { !$0.attributes.isRefundable }
		}
	}
}

// MARK: - SectionLayoutKind
extension RequestRefundTableViewController {
	/// Sections of the Request Refund screen.
	enum SectionLayoutKind: Int, CaseIterable {
		/// The settings header section.
		case header

		/// Transactions eligible for refund.
		case purchased

		/// Transactions Apple has revoked.
		case refunded

		/// The section header title.
		var title: String? {
			switch self {
			case .header:
				return nil
			case .purchased:
				return L10n.purchasedSectionHeader
			case .refunded:
				return L10n.refundedSectionHeader
			}
		}
	}

	enum ItemKind: Hashable {
		// MARK: - Cases
		/// The settings header cell.
		case header

		/// A store transaction.
		case transaction(_ transaction: StoreTransaction)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .header:
				hasher.combine("header")
			case .transaction(let transaction):
				hasher.combine(transaction)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.header, .header):
				return true
			case (.transaction(let a), .transaction(let b)):
				return a == b
			default:
				return false
			}
		}
	}
}
