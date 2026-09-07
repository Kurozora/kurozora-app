//
//  ThemedNavigationTitle.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

// MARK: - ThemedNavigationTitleModifier
private struct ThemedNavigationTitleModifier: ViewModifier {
	// MARK: - Properties
	let title: String

	@Environment(WatchTheme.self) private var theme

	// MARK: - Body
	func body(content: Content) -> some View {
		content
			.navigationTitle {
				Text(self.title)
					.foregroundStyle(self.theme.tint)
			}
			.navigationBarTitleDisplayMode(.inline)
	}
}

// MARK: - View+ThemedNavigationTitle
extension View {
	/// Sets the navigation title in the tint color of the theme selected on the iPhone.
	///
	/// - Parameter title: The title to display.
	func themedNavigationTitle(_ title: String) -> some View {
		// The plain navigationTitle(_:) overload renders in the system's chrome color, which
		// tint(_:) does not reach. Only the view builder overload accepts a styled Text.
		self.modifier(ThemedNavigationTitleModifier(title: title))
	}
}
