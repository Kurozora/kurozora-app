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
	@State private var exploreViewModel = ExploreViewModel()
	@State private var libraryViewModel = LibraryViewModel()

	// MARK: - Body
	var body: some View {
		TabView {
			ExploreView(viewModel: self.exploreViewModel)
				.tabItem {
					Label("Explore", systemImage: "house.fill")
				}

			LibraryView(viewModel: self.libraryViewModel)
				.tabItem {
					Label("Library", systemImage: "rectangle.stack.fill")
				}

			ProfileView()
				.tabItem {
					Label("Profile", systemImage: "person.crop.circle.fill")
				}
		}
	}
}
