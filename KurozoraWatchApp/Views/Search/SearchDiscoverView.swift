//
//  SearchDiscoverView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct SearchDiscoverView: View {
	// MARK: - Properties
	let viewModel: SearchViewModel

	// MARK: - Body
	var body: some View {
		List {
			if !self.viewModel.suggestions.isEmpty {
				Section("Discover") {
					ForEach(self.viewModel.suggestions, id: \.self) { suggestion in
						Button {
							self.viewModel.searchText = suggestion
							Task { await self.viewModel.submitSearch() }
						} label: {
							Label(suggestion, systemImage: "magnifyingglass")
								.font(.caption)
						}
					}
				}
			}

			Section("Browse") {
				ForEach(self.viewModel.browseCategories, id: \.label) { category in
					Label(category.label, systemImage: category.systemImage)
						.font(.caption)
				}
			}
		}
	}
}
