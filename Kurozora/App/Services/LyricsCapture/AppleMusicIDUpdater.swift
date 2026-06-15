//
//  AppleMusicIDUpdater.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation
import KurozoraKit

/// Persists a song's resolved Apple Music identifier to the Kurozora backend.
final class AppleMusicIDUpdater {
	// MARK: - Properties
	/// The User-Agent string the Kurozora API validates against the registered iOS app client.
	private static let userAgent: String = {
		let info = Bundle.main.infoDictionary
		let executable = info?["CFBundleExecutable"] as? String ?? "Unknown"
		let bundle = info?["CFBundleIdentifier"] as? String ?? "Unknown"
		let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
		let appBuild = info?["CFBundleVersion"] as? String ?? "Unknown"
		let version = ProcessInfo.processInfo.operatingSystemVersion
		let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		#if targetEnvironment(macCatalyst)
		let osNameVersion = "macOS(Catalyst) \(versionString)"
		#else
		let osNameVersion = "iOS \(versionString)"
		#endif
		return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) LyricsCapture/1.0.0"
	}()

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Saves the given Apple Music identifier on the song with the given Kurozora identifier.
	///
	/// - Parameters:
	///    - appleMusicID: The Apple Music catalog identifier to store.
	///    - songID: The Kurozora song identifier whose mapping is updated.
	///
	/// - Returns: `true` if the backend accepted the update, otherwise `false`.
	static func save(appleMusicID: Int, forSongID songID: String) async -> Bool {
		let baseURL = KService.apiEndpoint.baseURL

		guard let endpointURL = URL(string: baseURL + "songs/\(songID)/apple-music-id") else {
			print("----- AppleMusicIDUpdater: invalid endpoint URL from base", baseURL)
			return false
		}

		var request = URLRequest(url: endpointURL)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(KService.apiKey, forHTTPHeaderField: "X-API-Key")
		request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

		let token = KService.authenticationKey

		if !token.isEmpty {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		do {
			request.httpBody = try JSONEncoder().encode(Payload(amID: appleMusicID))
			let (_, response) = try await URLSession.shared.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
				print("----- AppleMusicIDUpdater: backend rejected the update")
				return false
			}

			return true
		} catch {
			print("----- AppleMusicIDUpdater: save failed:", error.localizedDescription)
			return false
		}
	}
}

// MARK: - Payload
extension AppleMusicIDUpdater {
	/// The request body for the Apple Music identifier update.
	private struct Payload: Encodable {
		let amID: Int

		private enum CodingKeys: String, CodingKey {
			case amID = "am_id"
		}
	}
}
#endif
