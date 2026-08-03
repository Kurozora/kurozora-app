//
//  NotificationRowView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct NotificationRowView: View {
	// MARK: - Properties
	let notification: UserNotification

	// MARK: - Body
	var body: some View {
		HStack(alignment: .top, spacing: 6) {
			self.leadingIcon

			VStack(alignment: .leading, spacing: 2) {
				HStack(spacing: 4) {
					Text(self.notification.attributes.type.watchLabel.uppercased())
						.font(.system(size: 9, weight: .semibold))
						.foregroundStyle(.secondary)

					Spacer(minLength: 0)

					Text(self.notification.attributes.createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))
						.font(.system(size: 9))
						.foregroundStyle(.secondary)

					if self.notification.attributes.readStatus == .unread {
						Circle()
							.fill(Color.accentColor)
							.frame(width: 6, height: 6)
					}
				}

				if let username = self.notification.attributes.payload.username,
				   self.notification.attributes.type.hasProfileImage
				{
					Text(username)
						.font(.caption2.bold())
						.lineLimit(1)
				}

				Text(self.notification.attributes.description)
					.font(.caption2)
					.lineLimit(3)
			}
		}
	}

	// MARK: - Private
	@ViewBuilder
	private var leadingIcon: some View {
		if self.notification.attributes.type.hasProfileImage {
			CachedAsyncImage(url: self.profileImageURL) {
				Image(systemName: "person.crop.circle.fill")
					.resizable()
					.foregroundStyle(.secondary)
			}
			.frame(width: 28, height: 28)
			.clipShape(Circle())
		} else {
			Image(self.notification.attributes.type.watchIcon)
				.renderingMode(.template)
				.resizable()
				.scaledToFit()
				.frame(width: 16, height: 16)
				.foregroundStyle(Color.accentColor)
				.frame(width: 28, height: 28)
				.background(Color.accentColor.opacity(0.15))
				.clipShape(RoundedRectangle(cornerRadius: 6))
		}
	}

	private var profileImageURL: URL? {
		guard let urlString = self.notification.attributes.payload.profileImageURL else { return nil }
		return URL(string: urlString)
	}
}
