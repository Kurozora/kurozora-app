//
//  TrailerVideoDownloader.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import Foundation

/// Downloads a trailer's stream into a video file.
final class TrailerVideoDownloader {
	/// The failures a download can end in.
	enum DownloadError: Error {
		/// The stream's playlist couldn't be read.
		case playlistUnreadable

		/// A part of the stream couldn't be fetched.
		case segmentFailed

		/// The stream couldn't be written into a video file.
		case exportFailed
	}

	// MARK: - Functions
	/// Downloads the stream at the given address into a video file.
	///
	/// - Parameters:
	///    - streamURL: The address of the stream to download.
	///    - name: The name the video file gets.
	///
	/// - Returns: The URL of the downloaded video file.
	func downloadVideo(from streamURL: URL, named name: String) async throws -> URL {
		let segmentURLs = try await self.fetchSegmentURLs(from: streamURL)

		let workDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try FileManager.default.createDirectory(at: workDirectory, withIntermediateDirectories: true)

		do {
			let streamFileURL = try await self.writeSegments(at: segmentURLs, into: workDirectory)
			let videoFileURL = workDirectory.appendingPathComponent("\(name).mp4")

			try await self.export(streamFileURL, to: videoFileURL)
			try? FileManager.default.removeItem(at: streamFileURL)
			return videoFileURL
		} catch {
			try? FileManager.default.removeItem(at: workDirectory)
			throw error
		}
	}

	/// Reads the addresses of the stream's parts out of its playlist.
	///
	/// - Parameter streamURL: The address of the stream to read.
	///
	/// - Returns: The addresses of the stream's parts, in playback order.
	private func fetchSegmentURLs(from streamURL: URL) async throws -> [URL] {
		let (playlistBody, response) = try await URLSession.shared.data(from: streamURL)

		guard
			(response as? HTTPURLResponse)?.statusCode == 200,
			let playlist = String(data: playlistBody, encoding: .utf8)
		else {
			throw DownloadError.playlistUnreadable
		}

		let segmentURLs = playlist
			.components(separatedBy: "\n")
			.map { $0.trimmingCharacters(in: .whitespaces) }
			.filter { $0.hasPrefix("http") }
			.compactMap(URL.init(string:))

		guard !segmentURLs.isEmpty else {
			throw DownloadError.playlistUnreadable
		}

		return segmentURLs
	}

	/// Fetches the stream's parts and writes them into one stream file.
	///
	/// - Parameters:
	///    - segmentURLs: The addresses of the stream's parts, in playback order.
	///    - workDirectory: The folder the stream file is written into.
	///
	/// - Returns: The URL of the stream file.
	private func writeSegments(at segmentURLs: [URL], into workDirectory: URL) async throws -> URL {
		let streamFileURL = workDirectory.appendingPathComponent("stream.ts")
		FileManager.default.createFile(atPath: streamFileURL.path, contents: nil)

		let fileHandle = try FileHandle(forWritingTo: streamFileURL)
		defer {
			try? fileHandle.close()
		}

		for segmentURL in segmentURLs {
			let (segment, response) = try await URLSession.shared.data(from: segmentURL)

			guard (response as? HTTPURLResponse)?.statusCode == 200 else {
				throw DownloadError.segmentFailed
			}

			try fileHandle.write(contentsOf: segment)
		}

		return streamFileURL
	}

	/// Rewraps the given stream file into a video file.
	///
	/// - Parameters:
	///    - streamFileURL: The URL of the stream file to rewrap.
	///    - videoFileURL: The URL the video file is written to.
	private func export(_ streamFileURL: URL, to videoFileURL: URL) async throws {
		let asset = AVURLAsset(url: streamFileURL)

		guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
			throw DownloadError.exportFailed
		}

		exportSession.outputURL = videoFileURL
		exportSession.outputFileType = .mp4
		await exportSession.export()

		guard exportSession.status == .completed else {
			throw exportSession.error ?? DownloadError.exportFailed
		}
	}
}
