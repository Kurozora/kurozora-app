//
//  ProfileToolbarModifier.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

// MARK: - ProfileToolbarButton
/// A toolbar button that displays the current user's profile image or a placeholder.
private struct ProfileToolbarButton: View {
	// MARK: - Properties
	let onTap: () -> Void

	// MARK: - Body
	var body: some View {
		Button(action: self.onTap) {
			if let user = User.current,
			   let urlString = user.attributes.profile?.url,
			   let url = URL(string: urlString)
			{
				CachedAsyncImage(url: url) {
					Image(systemName: "person.crop.circle.fill")
						.foregroundStyle(.secondary)
				}
				.frame(width: 24, height: 24)
				.clipShape(Circle())
			} else {
				Image(systemName: "person.crop.circle.fill")
					.foregroundStyle(.secondary)
			}
		}
	}
}

// MARK: - ProfileToolbarModifier
/// A view modifier that injects a profile navigation bar button into the toolbar.
private struct ProfileToolbarModifier: ViewModifier {
	// MARK: - Properties
	@State private var isProfilePresented = false

	// MARK: - Body
	func body(content: Content) -> some View {
		content
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					ProfileToolbarButton {
						self.isProfilePresented = true
					}
				}
			}
			.navigationDestination(isPresented: self.$isProfilePresented) {
				ProfileView()
			}
	}
}

// MARK: - View+ProfileToolbar
extension View {
	/// Adds a profile navigation bar button that pushes `ProfileView` when tapped.
	func profileToolbar() -> some View {
		self.modifier(ProfileToolbarModifier())
	}
}
