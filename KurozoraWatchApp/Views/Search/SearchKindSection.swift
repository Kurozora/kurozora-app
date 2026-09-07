//
//  SearchKindSection.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// The results section listing the first catalog matches of one kind, with a link to the rest.
struct SearchKindSection: View {
	// MARK: - Properties
	let kind: LibraryKind

	let viewModel: SearchViewModel

	// MARK: - Body
	var body: some View {
		let items = self.viewModel.items(for: self.kind)

		if !items.isEmpty {
			Section(self.kind.watchTitle) {
				ForEach(items.prefix(3)) { item in
					NavigationLink {
						LibraryEntryDetailView(item: item, details: self.viewModel.details(for: item))
					} label: {
						LibraryRowView(item: item)
					}
					.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
				}

				if items.count > 3 || self.viewModel.hasMorePages(for: self.kind) {
					NavigationLink(L10n.seeAll) {
						SearchKindResultsView(kind: self.kind, viewModel: self.viewModel)
					}
				}
			}
		}
	}
}
