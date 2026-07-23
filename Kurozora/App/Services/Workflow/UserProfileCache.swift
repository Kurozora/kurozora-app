//
//  UserProfileCache.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import os.log

private let profileCacheLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "UserProfileCache")

/// Stores the last fetched profile per account for offline session restore.
enum UserProfileCache {
	// MARK: - Functions
	/// Saves the user's profile for the given account slug.
	///
	/// - Parameters:
	///    - user: The user profile to cache.
	///    - slug: The account slug the profile belongs to.
	static func save(_ user: User, forSlug slug: String) {
		do {
			let profileData = try JSONEncoder().encode(user)
			let fileURL = try Self.fileURL(forSlug: slug, creatingDirectory: true)
			try profileData.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
		} catch {
			profileCacheLogger.error("Save failed: \(error.localizedDescription)")
		}
	}

	/// Returns the cached profile for the given account slug, if present.
	///
	/// - Parameter slug: The account slug to look up.
	///
	/// - Returns: The cached `User`.
	static func load(forSlug slug: String) -> User? {
		do {
			let fileURL = try Self.fileURL(forSlug: slug, creatingDirectory: false)
			let profileData = try Data(contentsOf: fileURL)
			return try JSONDecoder().decode(User.self, from: profileData)
		} catch {
			return nil
		}
	}

	/// Removes the cached profile for the given account slug.
	///
	/// - Parameter slug: The account slug whose cache to remove.
	static func remove(forSlug slug: String) {
		guard let fileURL = try? Self.fileURL(forSlug: slug, creatingDirectory: false) else { return }
		try? FileManager.default.removeItem(at: fileURL)
	}

	// MARK: - Helpers
	/// Returns the on-disk location of the cached profile for the given account slug.
	private static func fileURL(forSlug slug: String, creatingDirectory: Bool) throws -> URL {
		let applicationSupportURL = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: creatingDirectory
		)
		let directoryURL = applicationSupportURL.appendingPathComponent("UserProfiles", isDirectory: true)
		if creatingDirectory {
			try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
		}

		let safeSlug = slug.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? slug
		return directoryURL.appendingPathComponent("\(safeSlug).json", isDirectory: false)
	}
}
