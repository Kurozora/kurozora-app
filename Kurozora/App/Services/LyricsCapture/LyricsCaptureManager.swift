//
//  LyricsCaptureManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation
import StoreKit

/// Captures Apple Music's syllable lyrics response for a song.
final class LyricsCaptureManager {
	// MARK: - Properties
	/// The shared `LyricsCaptureManager` instance.
	static let shared = LyricsCaptureManager()

	/// The directory the captured files are written to.
	let captureDirectoryURL: URL = {
		let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documents.appendingPathComponent("LyricsCapture", isDirectory: true)
	}()

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Captures the syllable lyrics for the given Apple Music identifier and save it to disk.
	///
	/// - Parameters:
	///    - appleMusicID: The Apple Music catalog identifier to capture.
	///    - title: The Kurozora song title, recorded in the capture index.
	///    - artist: The Kurozora song artist, recorded in the capture index.
	///    - kkSongID: The Kurozora song identifier, recorded in the capture index.
	///
	/// - Returns: The outcome of the capture.
	func capture(appleMusicID: Int, title: String, artist: String, kkSongID: String) async -> CaptureOutcome {
		let token = UserSettings.appleMusicPrivilegedToken
		guard !token.isEmpty else { return .missingToken }

		let storefront = MusicManager.shared.countryCode

		// `extend=ttmlLocalizations` adds line-keyed translations and transliterations
		let query = "l%5Blyrics%5D=en-us&l%5Bscript%5D=en-Latn&extend=ttmlLocalizations"
		guard let url = URL(string: "https://amp-api.music.apple.com/v1/catalog/\(storefront)/songs/\(appleMusicID)/syllable-lyrics?\(query)") else {
			return .failed("Could not build the lyrics endpoint URL.")
		}

		let userToken: String
		do {
			userToken = try await SKCloudServiceController().requestUserToken(forDeveloperToken: token)
		} catch {
			return .failed("Could not obtain the Music User Token: \(error.localizedDescription)")
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.setValue(userToken, forHTTPHeaderField: "Media-User-Token")
		request.setValue("https://music.apple.com", forHTTPHeaderField: "Origin")

		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

			guard !data.isEmpty else { return .empty }

			if statusCode == 401 || statusCode == 403 {
				return .forbidden(statusCode: statusCode, body: String(data: data, encoding: .utf8) ?? "")
			}

			if let errorResponse = try? JSONDecoder().decode(LyricsErrorEnvelope.self, from: data), !errorResponse.errors.isEmpty {
				let first = errorResponse.errors[0]
				return .failed("\(first.status) \(first.code): \(first.detail)")
			}

			let attributes = (try? JSONDecoder().decode(LyricsEnvelope.self, from: data))?.data.first?.attributes
			let ttml = attributes?.ttmlLocalizations ?? attributes?.ttml

			try self.write(rawJSON: data, ttml: ttml, appleMusicID: appleMusicID, title: title, artist: artist, kkSongID: kkSongID)

			return .success(appleMusicID: appleMusicID, jsonBytes: data.count, ttmlBytes: ttml?.utf8.count ?? 0)
		} catch {
			return .failed(error.localizedDescription)
		}
	}

	/// Writes the raw JSON, extracted TTML, and an index row to the capture directory.
	///
	/// - Parameters:
	///    - rawJSON: The pristine JSON envelope.
	///    - ttml: The extracted TTML string.
	///    - appleMusicID: The Apple Music catalog identifier the capture belongs to.
	///    - title: The Kurozora song title.
	///    - artist: The Kurozora song artist.
	///    - kkSongID: The Kurozora song identifier.
	private func write(rawJSON: Data, ttml: String?, appleMusicID: Int, title: String, artist: String, kkSongID: String) throws {
		try FileManager.default.createDirectory(at: self.captureDirectoryURL, withIntermediateDirectories: true)

		let jsonURL = self.captureDirectoryURL.appendingPathComponent("\(appleMusicID).json")
		try rawJSON.write(to: jsonURL, options: .atomic)

		if let ttml = ttml, let ttmlData = ttml.data(using: .utf8) {
			let ttmlURL = self.captureDirectoryURL.appendingPathComponent("\(appleMusicID).ttml")
			try ttmlData.write(to: ttmlURL, options: .atomic)
		}

		let indexEntry = CaptureIndexEntry(
			kkSongID: kkSongID,
			appleMusicID: appleMusicID,
			title: title,
			artist: artist,
			jsonBytes: rawJSON.count,
			hasTTML: ttml != nil,
			capturedAt: ISO8601DateFormatter().string(from: Date())
		)
		try self.appendIndex(indexEntry)

		print("----- LyricsCapture: wrote \(jsonURL.path) (\(rawJSON.count) bytes, ttml: \(ttml != nil))")
	}

	/// Appends a JSON line describing a capture to the index file.
	///
	/// - Parameter entry: The index entry to append.
	private func appendIndex(_ entry: CaptureIndexEntry) throws {
		let indexURL = self.captureDirectoryURL.appendingPathComponent("index.jsonl")
		let line = try JSONEncoder().encode(entry)

		guard var lineString = String(data: line, encoding: .utf8) else { return }
		lineString.append("\n")
		guard let lineData = lineString.data(using: .utf8) else { return }

		if let handle = try? FileHandle(forWritingTo: indexURL) {
			defer { try? handle.close() }
			try handle.seekToEnd()
			try handle.write(contentsOf: lineData)
		} else {
			try lineData.write(to: indexURL, options: .atomic)
		}
	}
}

// MARK: - CaptureOutcome
extension LyricsCaptureManager {
	/// The outcome of a lyrics capture attempt.
	enum CaptureOutcome {
		/// The capture succeeded and the files were written.
		case success(appleMusicID: Int, jsonBytes: Int, ttmlBytes: Int)

		/// No privileged token is configured.
		case missingToken

		/// The endpoint returned an empty response.
		case empty

		/// The endpoint rejected the request.
		case forbidden(statusCode: Int, body: String)

		/// The capture failed.
		case failed(String)
	}
}

// MARK: - Decoding
extension LyricsCaptureManager {
	/// A partial decoding of the lyrics response.
	private struct LyricsEnvelope: Decodable {
		let data: [Datum]

		struct Datum: Decodable {
			let attributes: Attributes

			struct Attributes: Decodable {
				/// The base TTML.
				let ttml: String?

				/// The TTML with translations and transliterations.
				let ttmlLocalizations: String?
			}
		}
	}

	/// A partial decoding of the error response.
	private struct LyricsErrorEnvelope: Decodable {
		let errors: [APIError]

		struct APIError: Decodable {
			let status: String
			let code: String
			let detail: String
		}
	}

	/// A row in the capture index.
	private struct CaptureIndexEntry: Encodable {
		let kkSongID: String
		let appleMusicID: Int
		let title: String
		let artist: String
		let jsonBytes: Int
		let hasTTML: Bool
		let capturedAt: String
	}
}
#endif
