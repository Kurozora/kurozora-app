//
//  SearchResultsView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Shows one query's matches, the local library first and then each catalog kind, three rows each.
struct SearchResultsView: View {
	// MARK: - Properties
	@State private var viewModel: SearchViewModel

	// MARK: - Initializers
	/// Opens the results for a submitted query.
	///
	/// - Parameter query: The text the user searched for.
	init(query: String) {
		self._viewModel = State(initialValue: SearchViewModel(query: query))
	}

	// MARK: - Body
	var body: some View {
		Group {
			if self.viewModel.hasResults {
				List {
					SearchLibrarySection(viewModel: self.viewModel)

					ForEach(LibraryKind.allCases, id: \.rawValue) { kind in
						SearchKindSection(kind: kind, viewModel: self.viewModel)
					}
				}
			} else if self.viewModel.isSearching {
				LoadingView()
			} else {
				EmptyStateView(systemImage: "magnifyingglass", message: L10n.noResults(for: self.viewModel.query))
			}
		}
		.themedNavigationTitle(self.viewModel.query)
		.task {
			await self.viewModel.search()
		}
	}
}
