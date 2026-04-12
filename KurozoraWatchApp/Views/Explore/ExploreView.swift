//
//  ExploreView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct ExploreView: View {
	// MARK: - Properties
	let viewModel: ExploreViewModel

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
					if self.viewModel.categories.isEmpty {
						EmptyStateView(systemImage: "house", message: "Nothing to explore right now.")
					} else {
						List {
							ForEach(self.viewModel.categories, id: \.id) { category in
								ExploreSectionView(
									category: category,
									shows: self.viewModel.showsByCategory[category.id.description, default: nil]
								)
							}
						}
					}
				}
			}
			.navigationTitle("Explore")
			#if DEBUG
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					DebugAPIEndpointButton()
					Spacer()
					DebugConsoleButton()
				}
			}
			#endif
			.task {
				await self.viewModel.fetchIfNeeded()
			}
		}
	}
}
