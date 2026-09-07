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
	@Environment(WatchTheme.self) private var theme

	@State private var path: [WatchDestination] = [.home]
	@State private var upNextViewModel = UpNextViewModel()
	@State private var libraryViewModel = LibraryViewModel()

	// MARK: - Body
	var body: some View {
		NavigationStack(path: self.$path) {
			List(WatchDestination.rows) { destination in
				NavigationLink(value: destination) {
					Label {
						Text(destination.title)
					} icon: {
						Image(systemName: destination.symbolName)
							.foregroundStyle(self.theme.tint)
					}
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
	@ViewBuilder
	private func destinationView(for destination: WatchDestination) -> some View {
		switch destination {
		case .home:
			HomeView(viewModel: self.upNextViewModel)
		case .library:
			LibraryView(viewModel: self.libraryViewModel)
		case .search:
			SearchView()
		case .profile:
			ProfileView()
		}
	}
}
