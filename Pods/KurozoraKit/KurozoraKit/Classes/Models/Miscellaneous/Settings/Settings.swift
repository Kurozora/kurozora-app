//
//  Settings.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2022.
//

/// A root object that stores information about a settings response.
public struct Settings: Codable, Sendable {
	// MARK: - Properties
	/// The Apple Music developer token used to authorize `MusicKit` requests.
	public var appleMusicDeveloperToken: String?

	/// The YouTube API key used to load YouTube videos in native video player.
	public var youtubeAPIKey: String?
}
