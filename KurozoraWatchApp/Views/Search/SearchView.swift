//
//  SearchView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct SearchView: View {
	// MARK: - Properties
	@State private var viewModel = SearchViewModel()
	@State private var isFilterPresented = false
	@Environment(AuthenticationManager.self) private var authManager

	// MARK: - Body
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				self.searchBar

				if self.viewModel.hasSearched {
					self.searchResultsContent
				} else {
					SearchDiscoverView(viewModel: self.viewModel)
				}
			}
			.navigationTitle("Search")
			.profileToolbar()
			.toolbar {
				if self.viewModel.hasSearched, self.hasFiltersForCurrentTab {
					ToolbarItem(placement: .bottomBar) {
						Button {
							self.isFilterPresented = true
						} label: {
							Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
						}
					}
				}
			}
			.sheet(isPresented: self.$isFilterPresented) {
				SearchFilterView(
					viewModel: self.viewModel,
					isPresented: self.$isFilterPresented
				)
			}
			.task {
				await self.viewModel.fetchSuggestions()
			}
		}
	}

	// MARK: - Private
	private var searchBar: some View {
		HStack(spacing: 4) {
			TextField("Search…", text: self.$viewModel.searchText)
				.font(.caption)
				.onSubmit {
					Task { await self.viewModel.submitSearch() }
				}

			if !self.viewModel.searchText.isEmpty {
				Button {
					self.viewModel.searchText = ""
					self.viewModel.resetSearch()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.foregroundStyle(.secondary)
						.font(.caption)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
	}

	@ViewBuilder
	private var searchResultsContent: some View {
		if !self.viewModel.availableTabs.isEmpty {
			SearchResultsTabView(viewModel: self.viewModel)
		} else if self.isAnyBucketLoading {
			LoadingView()
		} else {
			EmptyStateView(
				systemImage: "magnifyingglass",
				message: "No results for \"\(self.viewModel.activeSearchText)\"."
			)
		}
	}

	private var isAnyBucketLoading: Bool {
		self.viewModel.showsBucket.loadState == .loading
			|| self.viewModel.literaturesBucket.loadState == .loading
			|| self.viewModel.gamesBucket.loadState == .loading
			|| self.viewModel.episodesBucket.loadState == .loading
			|| self.viewModel.charactersBucket.loadState == .loading
			|| self.viewModel.peopleBucket.loadState == .loading
			|| self.viewModel.songsBucket.loadState == .loading
			|| self.viewModel.studiosBucket.loadState == .loading
			|| self.viewModel.usersBucket.loadState == .loading
	}

	private var hasFiltersForCurrentTab: Bool {
		switch self.viewModel.selectedTab {
		case .songs, .users:
			return false
		default:
			return true
		}
	}
}
