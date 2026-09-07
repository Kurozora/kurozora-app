//
//  SearchLibraryResultsView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists every local library entry matching the query.
struct SearchLibraryResultsView: View {
	// MARK: - Properties
	let viewModel: SearchViewModel

	// MARK: - Body
	var body: some View {
		List(self.viewModel.libraryMatches) { item in
			NavigationLink {
				LibraryEntryDetailView(item: item)
			} label: {
				LibraryRowView(item: item)
			}
			.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
		}
		.themedNavigationTitle(L10n.library)
	}
}
