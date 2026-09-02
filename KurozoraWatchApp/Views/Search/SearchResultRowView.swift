//
//  SearchResultRowView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

// MARK: - SearchResultRowView
struct SearchResultRowView: View {
	// MARK: - Properties
	let type: SearchType

	let title: String?
	let subtitle: String?
	let imageURL: URL?
	let isCircular: Bool

	// MARK: - Body
	var body: some View {
		HStack(spacing: 8) {
			if self.type == .songs {
				self.songLayout
			} else {
				self.imageView
				self.textContent
			}
		}
	}

	// MARK: - Private
	private var imageView: some View {
		CachedAsyncImage(url: self.imageURL) {
			RoundedRectangle(cornerRadius: self.isCircular ? self.imageSize / 2 : 4)
				.fill(Color.gray.opacity(0.3))
		}
		.frame(width: self.imageWidth, height: self.imageHeight)
		.clipShape(
			self.isCircular
				? AnyShape(Circle())
				: AnyShape(RoundedRectangle(cornerRadius: 4))
		)
	}

	private var textContent: some View {
		VStack(alignment: .leading, spacing: 2) {
			if let title {
				Text(title)
					.font(.caption)
					.lineLimit(2)
			}
			if let subtitle {
				Text(subtitle)
					.font(.caption2)
					.foregroundStyle(.secondary)
					.lineLimit(1)
			}
		}
	}

	private var songLayout: some View {
		VStack(alignment: .leading, spacing: 2) {
			if let title {
				Text(title)
					.font(.caption)
					.lineLimit(2)
			}
			if let subtitle {
				Text(subtitle)
					.font(.caption2)
					.foregroundStyle(.secondary)
					.lineLimit(1)
			}
		}
	}

	private var imageSize: CGFloat { 36 }

	private var imageWidth: CGFloat {
		switch self.type {
		case .episodes:
			return 52
		default:
			return self.isPortrait ? 36 : self.imageSize
		}
	}

	private var imageHeight: CGFloat {
		switch self.type {
		case .episodes:
			return 36
		default:
			return self.isPortrait ? 52 : self.imageSize
		}
	}

	private var isPortrait: Bool {
		switch self.type {
		case .shows, .literatures, .games:
			return true
		default:
			return false
		}
	}
}

// MARK: - Convenience Initializers
extension SearchResultRowView {
	init(show: Show) {
		self.type = .shows
		self.title = show.attributes.title
		self.subtitle = show.attributes.status.name
		self.imageURL = Self.makeURL(show.attributes.poster?.url)
		self.isCircular = false
	}

	init(literature: Literature) {
		self.type = .literatures
		self.title = literature.attributes.title
		self.subtitle = literature.attributes.status.name
		self.imageURL = Self.makeURL(literature.attributes.poster?.url)
		self.isCircular = false
	}

	init(game: Game) {
		self.type = .games
		self.title = game.attributes.title
		self.subtitle = game.attributes.status.name
		self.imageURL = Self.makeURL(game.attributes.poster?.url)
		self.isCircular = false
	}

	init(episode: Episode) {
		self.type = .episodes
		self.title = episode.attributes.title
		self.subtitle = episode.attributes.synopsis
		self.imageURL = Self.makeURL(episode.attributes.banner?.url)
		self.isCircular = false
	}

	init(character: Character) {
		self.type = .characters
		self.title = character.attributes.name
		self.subtitle = nil
		self.imageURL = Self.makeURL(character.attributes.profile?.url)
		self.isCircular = true
	}

	init(person: Person) {
		self.type = .people
		self.title = person.attributes.fullName
		self.subtitle = nil
		self.imageURL = Self.makeURL(person.attributes.profile?.url)
		self.isCircular = true
	}

	init(song: Song) {
		self.type = .songs
		self.title = song.attributes.title
		self.subtitle = song.attributes.artist
		self.imageURL = Self.makeURL(song.attributes.artwork?.url)
		self.isCircular = false
	}

	init(studio: Studio) {
		self.type = .studios
		self.title = studio.attributes.name
		self.subtitle = nil
		self.imageURL = Self.makeURL(studio.attributes.logo?.url) ?? Self.makeURL(studio.attributes.profile?.url)
		self.isCircular = false
	}

	init(user: User) {
		self.type = .users
		self.title = user.attributes.username
		self.subtitle = nil
		self.imageURL = Self.makeURL(user.attributes.profile?.url)
		self.isCircular = true
	}

	private static func makeURL(_ string: String?) -> URL? {
		guard let string else { return nil }
		return URL(string: string)
	}
}

// MARK: - Skeleton Row
extension SearchResultRowView {
	/// Creates a skeleton placeholder row for the given type.
	static func skeleton(for type: SearchType) -> SearchResultRowView {
		SearchResultRowView(
			type: type,
			title: "Placeholder Title",
			subtitle: "Subtitle",
			imageURL: nil,
			isCircular: type == .characters || type == .people || type == .users
		)
	}
}
