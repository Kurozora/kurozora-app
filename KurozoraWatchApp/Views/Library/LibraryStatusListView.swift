//
//  LibraryStatusListView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists the user's shows that carry one library status.
struct LibraryStatusListView: View {
	// MARK: - Properties
	let status: LibraryStatus

	let viewModel: LibraryViewModel

	// MARK: - Body
	var body: some View {
		Group {
			if self.items.isEmpty {
				if self.viewModel.isSyncing {
					LoadingView()
				} else {
					EmptyStateView(systemImage: "rectangle.stack", message: L10n.libraryStatusEmpty)
				}
			} else {
				List(self.items) { item in
					NavigationLink {
						ShowDetailView(item: item)
					} label: {
						LibraryRowView(item: item)
					}
					.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
				}
			}
		}
		.themedNavigationTitle(self.status.watchTitle)
		.onAppear {
			self.viewModel.refreshSyncState()
		}
		.onReceive(NotificationCenter.default.publisher(for: .KLibrarySyncProgressDidChange)) { _ in
			self.viewModel.refreshSyncState()
		}
	}

	// MARK: - Computed
	private var items: [LibraryItem] {
		return self.viewModel.items(for: self.status)
	}
}
