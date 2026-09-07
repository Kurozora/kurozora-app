//
//  ContentView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	// MARK: - Properties
	@State private var path: [WatchDestination] = [.home]
	@State private var upNextViewModel = UpNextViewModel()
	@State private var libraryViewModel = LibraryViewModel()

	// MARK: - Body
	var body: some View {
		NavigationStack(path: self.$path) {
			List {
				NavigationLink(value: WatchDestination.home) {
					DestinationRowLabel(destination: .home)
				}

				NavigationLink(value: WatchDestination.library) {
					DestinationRowLabel(destination: .library)
				}

				TextFieldLink(prompt: Text(L10n.searchPlaceholder)) {
					DestinationRowLabel(title: L10n.search, symbolName: "magnifyingglass")
				} onSubmit: { query in
					self.search(query)
				}
			}
			.themedNavigationTitle(L10n.kurozora)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						self.path.append(.profile)
					} label: {
						ProfileAvatarView()
					}
					.buttonStyle(.plain)
				}
			}
			.navigationDestination(for: WatchDestination.self) { destination in
				self.destinationView(for: destination)
			}
		}
	}

	// MARK: - Functions
	/// Pushes the results for the submitted text, ignoring blank input.
	///
	/// - Parameter query: The text entered on the system input sheet.
	private func search(_ query: String) {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }

		self.path.append(.searchResults(query: trimmed))
	}

	@ViewBuilder
	private func destinationView(for destination: WatchDestination) -> some View {
		switch destination {
		case .home:
			HomeView(viewModel: self.upNextViewModel)
		case .library:
			LibraryView(viewModel: self.libraryViewModel)
		case .searchResults(let query):
			SearchResultsView(query: query)
		case .profile:
			ProfileView()
		}
	}
}
