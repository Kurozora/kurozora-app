//
//  SearchKindResultsView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists every catalog match of one kind, paging in more as the user reaches the end.
struct SearchKindResultsView: View {
	// MARK: - Properties
	let kind: LibraryKind

	let viewModel: SearchViewModel

	@Environment(WatchTheme.self) private var theme

	@State private var isFilterPresented = false

	// MARK: - Body
	var body: some View {
		let items = self.viewModel.items(for: self.kind)

		List {
			ForEach(items) { item in
				NavigationLink {
					LibraryEntryDetailView(item: item, details: self.viewModel.details(for: item))
				} label: {
					LibraryRowView(item: item)
				}
				.listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
				.onAppear {
					if item.id == items.last?.id {
						Task { await self.viewModel.loadNextPage(for: self.kind) }
					}
				}
			}

			if self.viewModel.isLoadingNextPage(for: self.kind) {
				HStack {
					Spacer()
					ProgressView()
					Spacer()
				}
			}
		}
		.themedNavigationTitle(self.kind.watchTitle)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					self.isFilterPresented = true
				} label: {
					Image(systemName: "line.3.horizontal.decrease")
						.foregroundStyle(self.theme.tintedButtonText)
				}
				.accessibilityLabel(L10n.filter)
			}
		}
		.sheet(isPresented: self.$isFilterPresented) {
			SearchFilterView(kind: self.kind, filter: self.viewModel.filter(for: self.kind), isPresented: self.$isFilterPresented) { filter in
				Task { await self.viewModel.applyFilter(filter, for: self.kind) }
			}
		}
	}
}
