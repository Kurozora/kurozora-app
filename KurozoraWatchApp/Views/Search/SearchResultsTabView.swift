//
//  SearchResultsTabView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct SearchResultsTabView: View {
	// MARK: - Properties
	@Bindable var viewModel: SearchViewModel

	// MARK: - Body
	var body: some View {
		self.resultsList
	}

	// MARK: - Private
	@ViewBuilder
	private var resultsList: some View {
		switch self.viewModel.selectedTab {
		case .shows:
			self.showsList
		case .literatures:
			self.literaturesList
		case .games:
			self.gamesList
		case .episodes:
			self.episodesList
		case .characters:
			self.charactersList
		case .people:
			self.peopleList
		case .songs:
			self.songsList
		case .studios:
			self.studiosList
		case .users:
			self.usersList
		}
	}

	// MARK: Shows
	private var showsList: some View {
		self.typedList(
			identities: self.viewModel.showsBucket.identities,
			loadState: self.viewModel.showsBucket.loadState,
			isLoadingNextPage: self.viewModel.showsBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.showsBucket.nextPageCursor != nil,
			type: .shows
		) { identity in
			if let show = self.viewModel.show(for: identity) {
				SearchResultRowView(show: show)
			} else {
				SearchResultRowView.skeleton(for: .shows)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Literatures
	private var literaturesList: some View {
		self.typedList(
			identities: self.viewModel.literaturesBucket.identities,
			loadState: self.viewModel.literaturesBucket.loadState,
			isLoadingNextPage: self.viewModel.literaturesBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.literaturesBucket.nextPageCursor != nil,
			type: .literatures
		) { identity in
			if let literature = self.viewModel.literature(for: identity) {
				SearchResultRowView(literature: literature)
			} else {
				SearchResultRowView.skeleton(for: .literatures)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Games
	private var gamesList: some View {
		self.typedList(
			identities: self.viewModel.gamesBucket.identities,
			loadState: self.viewModel.gamesBucket.loadState,
			isLoadingNextPage: self.viewModel.gamesBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.gamesBucket.nextPageCursor != nil,
			type: .games
		) { identity in
			if let game = self.viewModel.game(for: identity) {
				SearchResultRowView(game: game)
			} else {
				SearchResultRowView.skeleton(for: .games)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Episodes
	private var episodesList: some View {
		self.typedList(
			identities: self.viewModel.episodesBucket.identities,
			loadState: self.viewModel.episodesBucket.loadState,
			isLoadingNextPage: self.viewModel.episodesBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.episodesBucket.nextPageCursor != nil,
			type: .episodes
		) { identity in
			if let episode = self.viewModel.episode(for: identity) {
				SearchResultRowView(episode: episode)
			} else {
				SearchResultRowView.skeleton(for: .episodes)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Characters
	private var charactersList: some View {
		self.typedList(
			identities: self.viewModel.charactersBucket.identities,
			loadState: self.viewModel.charactersBucket.loadState,
			isLoadingNextPage: self.viewModel.charactersBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.charactersBucket.nextPageCursor != nil,
			type: .characters
		) { identity in
			if let character = self.viewModel.character(for: identity) {
				SearchResultRowView(character: character)
			} else {
				SearchResultRowView.skeleton(for: .characters)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: People
	private var peopleList: some View {
		self.typedList(
			identities: self.viewModel.peopleBucket.identities,
			loadState: self.viewModel.peopleBucket.loadState,
			isLoadingNextPage: self.viewModel.peopleBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.peopleBucket.nextPageCursor != nil,
			type: .people
		) { identity in
			if let person = self.viewModel.person(for: identity) {
				SearchResultRowView(person: person)
			} else {
				SearchResultRowView.skeleton(for: .people)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Songs
	private var songsList: some View {
		self.typedList(
			identities: self.viewModel.songsBucket.identities,
			loadState: self.viewModel.songsBucket.loadState,
			isLoadingNextPage: self.viewModel.songsBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.songsBucket.nextPageCursor != nil,
			type: .songs
		) { identity in
			if let song = self.viewModel.song(for: identity) {
				SearchResultRowView(song: song)
			} else {
				SearchResultRowView.skeleton(for: .songs)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Studios
	private var studiosList: some View {
		self.typedList(
			identities: self.viewModel.studiosBucket.identities,
			loadState: self.viewModel.studiosBucket.loadState,
			isLoadingNextPage: self.viewModel.studiosBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.studiosBucket.nextPageCursor != nil,
			type: .studios
		) { identity in
			if let studio = self.viewModel.studio(for: identity) {
				SearchResultRowView(studio: studio)
			} else {
				SearchResultRowView.skeleton(for: .studios)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: Users
	private var usersList: some View {
		self.typedList(
			identities: self.viewModel.usersBucket.identities,
			loadState: self.viewModel.usersBucket.loadState,
			isLoadingNextPage: self.viewModel.usersBucket.isLoadingNextPage,
			hasNextPage: self.viewModel.usersBucket.nextPageCursor != nil,
			type: .users
		) { identity in
			if let user = self.viewModel.user(for: identity) {
				SearchResultRowView(user: user)
			} else {
				SearchResultRowView.skeleton(for: .users)
					.redacted(reason: .placeholder)
			}
		}
	}

	// MARK: - Tab Picker
	private var tabPicker: some View {
		Picker(L10n.type, selection: self.$viewModel.selectedTab) {
			ForEach(self.viewModel.availableTabs, id: \.self) { tab in
				Text(tab.watchLabel).tag(tab)
			}
		}
		.labelsHidden()
	}

	// MARK: - Generic List Builder
	private func typedList<Identity: Identifiable & Hashable>(
		identities: [Identity],
		loadState: LoadState,
		isLoadingNextPage: Bool,
		hasNextPage: Bool,
		type: SearchType,
		@ViewBuilder rowContent: @escaping (Identity) -> some View
	) -> some View {
		List {
			Section {
				self.tabPicker
			}

			Section {
				ForEach(identities, id: \.id) { identity in
					rowContent(identity)
						.onAppear {
							if identity.id == identities.last?.id, hasNextPage {
								Task { await self.viewModel.loadNextPage(for: type) }
							}
						}
				}

				if isLoadingNextPage {
					HStack {
						Spacer()
						ProgressView()
						Spacer()
					}
				}
			}
		}
	}
}
