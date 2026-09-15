//
//  PageRefreshable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view controller that reloads the content of its page.
@MainActor
protocol PageRefreshable: UIViewController {
	/// Reloads the content of the page.
	func handleRefreshControl()
}

extension KCollectionViewController: PageRefreshable {}

extension KTableViewController: PageRefreshable {}

extension KTabbedViewController: PageRefreshable {
	func handleRefreshControl() {
		(self.currentViewController as? PageRefreshable)?.handleRefreshControl()
	}
}
