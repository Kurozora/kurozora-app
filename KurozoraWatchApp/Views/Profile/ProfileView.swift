//
//  ProfileView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct ProfileView: View {
	// MARK: - Properties
	@Environment(AuthenticationManager.self) private var authManager

	// MARK: - Body
	var body: some View {
		if let user = User.current {
			List {
				Section {
					VStack(spacing: 8) {
						CachedAsyncImage(url: self.profileImageURL(for: user), targetWidth: 50) {
							Image(systemName: "person.circle.fill")
								.resizable()
								.foregroundStyle(.secondary)
						}
						.frame(width: 50, height: 50)
						.clipShape(Circle())

						Text(user.attributes.username)
							.font(.headline)
					}
					.frame(maxWidth: .infinity)
					.listRowBackground(Color.clear)
				}

				Section {
					HStack {
						Label(L10n.followers, systemImage: "person.2")
							.font(.caption)
						Spacer()
						Text(user.attributes.followerCount, format: .number)
							.font(.caption)
							.foregroundStyle(.secondary)
					}

					HStack {
						Label(L10n.following, systemImage: "person.2.fill")
							.font(.caption)
						Spacer()
						Text(user.attributes.followingCount, format: .number)
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}

				Section {
					Button(role: .destructive) {
						self.authManager.signOut()
					} label: {
						Label(L10n.signOut, systemImage: "rectangle.portrait.and.arrow.right")
							.font(.caption)
					}
				}
			}
			.navigationTitle(L10n.profile)
			#if DEBUG
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					DebugAPIEndpointButton()
					Spacer()
					DebugConsoleButton()
				}
			}
			#endif
		} else {
			ErrorView(systemImage: "person.crop.circle.badge.questionmark", message: "Unable to load profile.")
		}
	}

	// MARK: - Functions
	private func profileImageURL(for user: User) -> URL? {
		guard let urlString = user.attributes.profile?.url else { return nil }
		return URL(string: urlString)
	}
}
