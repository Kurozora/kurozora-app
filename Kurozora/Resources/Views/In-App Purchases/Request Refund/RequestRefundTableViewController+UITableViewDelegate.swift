//
//  RequestRefundTableViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import StoreKit
import UIKit

extension RequestRefundTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: section), sectionIdentifier != .header else {
			return .leastNormalMagnitude
		}
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		guard case .transaction(let transaction) = itemKind, transaction.attributes.isRefundable else { return }
		guard let windowScene = self.view.window?.windowScene else { return }
		guard let transactionID = UInt64(transaction.attributes.transactionID) else { return }

		Task { [weak self] in
			let result = try? await Transaction.beginRefundRequest(for: transactionID, in: windowScene)
			if result == .success {
				await self?.fetchTransactions()
			}
		}
	}
}
