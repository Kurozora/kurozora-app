//
//  NotificationsView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct NotificationsView: View {
	// MARK: - Properties
	let viewModel: NotificationsViewModel
	@Environment(AuthenticationManager.self) private var authManager
	@Environment(WatchNotificationSettings.self) private var notificationSettings
	@State private var isMarkAllPresented = false

	// MARK: - Body
	var body: some View {
		NavigationStack {
			Group {
				if !self.authManager.isSignedIn {
					EmptyStateView(systemImage: "bell.slash", message: "Sign in on your iPhone to view notifications.")
				} else {
					switch self.viewModel.loadState {
					case .idle, .loading:
						LoadingView()
					case .error(let message):
						ErrorView(systemImage: "exclamationmark.triangle", message: message) {
							Task { await self.viewModel.refresh(groupStyle: self.notificationSettings.effectiveGroupStyle) }
						}
					case .loaded:
						if self.viewModel.sections.isEmpty {
							EmptyStateView(systemImage: "bell.slash", message: "No notifications yet.")
						} else {
							self.notificationsList
						}
					}
				}
			}
			.navigationTitle("Notifications")
			.profileToolbar()
			.toolbar {
				if self.authManager.isSignedIn, !self.viewModel.sections.isEmpty {
					ToolbarItem(placement: .bottomBar) {
						Button {
							self.isMarkAllPresented = true
						} label: {
							Label("Mark All", systemImage: "checkmark.circle")
						}
					}
				}
			}
			.confirmationDialog("Mark All", isPresented: self.$isMarkAllPresented) {
				Button("Mark All as Read") {
					Task {
						await self.viewModel.markAll(
							withStatus: .read,
							groupStyle: self.notificationSettings.effectiveGroupStyle
						)
					}
				}
				Button("Mark All as Unread") {
					Task {
						await self.viewModel.markAll(
							withStatus: .unread,
							groupStyle: self.notificationSettings.effectiveGroupStyle
						)
					}
				}
			}
			.task {
				await self.viewModel.fetchIfNeeded(groupStyle: self.notificationSettings.effectiveGroupStyle)
			}
			.refreshable {
				await self.viewModel.refresh(groupStyle: self.notificationSettings.effectiveGroupStyle)
			}
			.onChange(of: self.notificationSettings.effectiveGroupStyle) { _, newStyle in
				self.viewModel.rebuildSections(groupStyle: newStyle)
			}
		}
	}

	// MARK: - Private
	private var notificationsList: some View {
		List {
			ForEach(self.viewModel.sections) { section in
				Section {
					ForEach(section.notifications, id: \.id) { notification in
						NotificationRowView(notification: notification)
							.contextMenu {
								Button {
									Task {
										await self.viewModel.toggleReadStatus(
											for: notification,
											groupStyle: self.notificationSettings.effectiveGroupStyle
										)
									}
								} label: {
									Label(
										notification.attributes.readStatus == .read ? "Mark as Unread" : "Mark as Read",
										systemImage: notification.attributes.readStatus == .read ? "envelope.badge" : "envelope.open"
									)
								}

								Button(role: .destructive) {
									Task {
										await self.viewModel.delete(
											notification: notification,
											groupStyle: self.notificationSettings.effectiveGroupStyle
										)
									}
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
					}
				} header: {
					if !section.title.isEmpty {
						Text(section.title)
					}
				}
			}
		}
	}

}
