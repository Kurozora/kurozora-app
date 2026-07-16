//
//  LibraryView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct LibraryView: View {
	// MARK: - Properties
	let viewModel: LibraryViewModel

	// MARK: - Body
	var body: some View {
		NavigationStack {
			Group {
				switch self.viewModel.loadState {
				case .idle, .loading:
					LoadingView()
				case .error(let message):
					ErrorView(systemImage: "exclamationmark.triangle", message: message) {
						Task { await self.viewModel.refresh() }
					}
				case .loaded:
					if self.viewModel.shows.isEmpty {
						EmptyStateView(systemImage: "rectangle.stack", message: "No shows in progress.\nStart watching on your iPhone!")
					} else {
						List(self.viewModel.shows, id: \.id) { show in
							NavigationLink(destination: ShowDetailView(show: show, initialLibraryStatus: .inProgress)) {
								LibraryRowView(show: show)
							}
						}
					}
				}
			}
			.navigationTitle("Library")
			.task {
				await self.viewModel.fetchIfNeeded()
			}
		}
	}
}
