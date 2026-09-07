//
//  HomeView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct HomeView: View {
	// MARK: - Properties
	let viewModel: UpNextViewModel

	@Environment(\.scenePhase) private var scenePhase

	// MARK: - Body
	var body: some View {
		Group {
			switch self.viewModel.loadState {
			case .idle, .loading:
				LoadingView()
			case .error(let message):
				ErrorView(systemImage: "exclamationmark.triangle", message: message) {
					Task { await self.viewModel.refresh() }
				}
			case .loaded:
				if self.viewModel.episodes.isEmpty {
					EmptyStateView(systemImage: "checkmark.circle", message: "Nothing left to watch.\nAdd a show to your library to get started!")
				} else {
					List(self.viewModel.episodes, id: \.id) { episode in
						VStack(alignment: .leading, spacing: 6) {
							NavigationLink {
								EpisodeDetailView(
									episode: episode,
									isWatched: false,
									onToggleWatched: {
										await self.viewModel.markAsWatched(episode)
									}
								)
							} label: {
								UpNextRowView(episode: episode)
							}
							.buttonStyle(.plain)

							HStack(spacing: 4) {
								Text(episode.seasonEpisodeLabel)
									.font(.caption)
									.foregroundStyle(.secondary)

								Spacer(minLength: 0)

								UpNextWatchedButton(isPending: self.viewModel.isPending(episode)) {
									Task { await self.viewModel.markAsWatched(episode) }
								}
							}
						}
						.listRowBackground(Color.clear)
					}
					.listStyle(.carousel)
				}
			}
		}
		.themedNavigationTitle(WatchDestination.home.title)
		.task {
			await self.viewModel.fetchIfNeeded()
		}
		.onChange(of: self.scenePhase) { _, newPhase in
			// Covers changes made while the Watch app was not running, which arrive with
			// no message because the iPhone had nothing reachable to notify.
			guard newPhase == .active else { return }

			Task { await self.viewModel.reloadQueue() }
		}
		.onReceive(NotificationCenter.default.publisher(for: .upNextDidChangeRemotely)) { _ in
			Task { await self.viewModel.reloadQueue() }
		}
	}
}
