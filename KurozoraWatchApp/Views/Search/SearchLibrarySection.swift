//
//  SearchLibrarySection.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// The results section listing the first local library matches, with a link to the rest.
struct SearchLibrarySection: View {
	// MARK: - Properties
	let viewModel: SearchViewModel

	// MARK: - Body
	var body: some View {
		if !self.viewModel.libraryMatches.isEmpty {
			Section(L10n.library) {
				ForEach(self.viewModel.libraryMatches.prefix(3)) { item in
					NavigationLink {
						LibraryEntryDetailView(item: item)
					} label: {
						LibraryRowView(item: item)
					}
					.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
				}

				if self.viewModel.libraryMatches.count > 3 {
					NavigationLink(L10n.seeAll) {
						SearchLibraryResultsView(viewModel: self.viewModel)
					}
				}
			}
		}
	}
}
