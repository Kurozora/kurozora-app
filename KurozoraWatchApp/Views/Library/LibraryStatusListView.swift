//
//  LibraryStatusListView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists the entries of the selected kind that carry one library status.
struct LibraryStatusListView: View {
	// MARK: - Properties
	let status: LibraryStatus

	let viewModel: LibraryViewModel

	@Environment(WatchTheme.self) private var theme

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
						LibraryEntryDetailView(item: item)
					} label: {
						LibraryRowView(item: item)
					}
					.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
					.swipeActions(edge: .trailing, allowsFullSwipe: false) {
						Button {
							Task { await self.viewModel.toggleFavorite(item) }
						} label: {
							Label(
								item.isFavorited ? L10n.removeFromFavorites : L10n.addToFavorites,
								systemImage: item.isFavorited ? "heart.slash.fill" : "heart.fill"
							)
						}
						.tint(self.theme.tint)

						// The server accepts reminders on shows from subscribers only, and the watch
						// has no subscription flow to offer instead.
						if item.kind == .shows, User.isSubscribed {
							Button {
								Task { await self.viewModel.toggleReminder(item) }
							} label: {
								Label(
									item.isReminded ? L10n.removeReminder : L10n.addReminder,
									systemImage: item.isReminded ? "bell.slash.fill" : "bell.fill"
								)
							}
						}
					}
				}
			}
		}
		.themedNavigationTitle(self.status.watchTitle(for: self.viewModel.selectedKind))
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
