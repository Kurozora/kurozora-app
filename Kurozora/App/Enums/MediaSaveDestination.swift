//
//  MediaSaveDestination.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The place saved images are written to.
enum MediaSaveDestination: Int, CaseIterable {
	/// The system photo library.
	case photoLibrary = 0

	/// A folder on disk.
	case folder = 1

	// MARK: - Properties
	/// The destination used when the user hasn't picked one.
	static let `default`: MediaSaveDestination = .photoLibrary

	/// The name of the folder saved images are written to by default.
	static let folderName = "Kurozora"

	/// The destination chosen in Settings.
	static var current: MediaSaveDestination {
		return MediaSaveDestination(rawValue: UserSettings.mediaSaveDestination) ?? .default
	}

	/// The folder saved images are written to.
	static var chosenDirectory: URL? {
		guard let bookmark = UserSettings.mediaSaveDirectoryBookmark else {
			return self.defaultDirectory
		}

		return self.resolveDirectory(from: bookmark) ?? self.defaultDirectory
	}

	/// The folder saved images are written to when the user hasn't picked one.
	static var defaultDirectory: URL? {
		#if targetEnvironment(macCatalyst)
		let parent = URL.userHome.appendingPathComponent("Pictures", isDirectory: true)
		#else
		guard let parent = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
		#endif

		return parent.appendingPathComponent(self.folderName, isDirectory: true)
	}

	/// The localized name of the destination.
	var titleValue: String {
		switch self {
		case .photoLibrary:
			return L10n.savePhotoLibrary
		case .folder:
			return L10n.saveFolder
		}
	}

	// MARK: - Functions
	/// Returns the folder the given bookmark points at.
	///
	/// - Parameter bookmark: The bookmark to resolve.
	/// - Returns: The folder the bookmark points at.
	private static func resolveDirectory(from bookmark: Data) -> URL? {
		var isStale = false

		#if targetEnvironment(macCatalyst)
		let options: URL.BookmarkResolutionOptions = [.withSecurityScope, .withoutUI]
		#else
		let options: URL.BookmarkResolutionOptions = [.withoutUI]
		#endif

		guard let directory = try? URL(resolvingBookmarkData: bookmark, options: options, bookmarkDataIsStale: &isStale) else {
			return nil
		}

		return isStale ? nil : directory
	}
}
