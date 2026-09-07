//
//  ProfileAvatarView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Displays the signed in user's profile image, falling back to a placeholder symbol.
struct ProfileAvatarView: View {
	// MARK: - Body
	var body: some View {
		if let user = User.current,
		   let urlString = user.attributes.profile?.url,
		   let url = URL(string: urlString)
		{
			CachedAsyncImage(url: url, targetWidth: 24) {
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
