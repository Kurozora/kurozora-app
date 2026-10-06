//
//  TrailerStreamResourceLoader.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import UniformTypeIdentifiers

/// Serves a trailer's stream manifest with the page's subtitle tracks added as renditions.
nonisolated final class TrailerStreamResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
	// MARK: - Properties
	/// The scheme the served addresses use.
	private static let scheme = "kurozora-trailer"

	/// The address the manifest is served at.
	static let manifestURL = URL(string: "\(TrailerStreamResourceLoader.scheme)://stream/manifest.m3u8")

	/// The queue the requests are answered on.
	static let queue = DispatchQueue(label: "app.kurozora.trailer.stream-resources")

	/// The manifest with the subtitle renditions.
	private let manifest: String

	/// The subtitle tracks listed in the manifest.
	private let captionTracks: [TrailerCaptionTrack]

	/// The published subtitle documents by track address.
	private var documents: [String: (text: String, duration: Double, url: URL)] = [:]

	/// The lock guarding the documents.
	private let lock = NSLock()

	// MARK: - Initializers
	/// Creates a loader serving the given manifest limited to the given variants.
	///
	/// - Parameters:
	///    - manifest: The stream's own manifest.
	///    - variantURLs: The variant addresses the served manifest keeps.
	///    - captionTracks: The subtitle tracks to add as renditions.
	init(manifest: String, variantURLs: Set<String>, captionTracks: [TrailerCaptionTrack]) {
		self.manifest = Self.rewrite(manifest, keeping: variantURLs, adding: captionTracks)
		self.captionTracks = captionTracks
		super.init()
	}

	// MARK: - Functions
	/// Keeps the given subtitle document for the given track.
	///
	/// - Parameters:
	///    - document: The track's text as a WebVTT document.
	///    - track: The track the document belongs to.
	///    - duration: The trailer's length in seconds.
	///    - url: The address the document is served at over HTTP.
	func store(_ document: String, for track: TrailerCaptionTrack, spanning duration: Double, at url: URL) {
		self.lock.lock()
		self.documents[track.address] = (document, duration, url)
		self.lock.unlock()
	}

	func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
		guard let url = loadingRequest.request.url, url.scheme == Self.scheme else { return false }

		guard let resource = self.resource(at: url) else {
			print("----- [Trailer] No stream resource at \(url.absoluteString)")
			loadingRequest.finishLoading(with: URLError(.fileDoesNotExist))
			return true
		}

		let body = Data(resource.body.utf8)
		loadingRequest.contentInformationRequest?.contentType = resource.contentType
		loadingRequest.contentInformationRequest?.contentLength = Int64(body.count)
		loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true

		if let dataRequest = loadingRequest.dataRequest {
			let start = min(Int(dataRequest.requestedOffset), body.count)
			let end = dataRequest.requestsAllDataToEndOfResource ? body.count : min(start + dataRequest.requestedLength, body.count)
			dataRequest.respond(with: body.subdata(in: start ..< end))
		}

		loadingRequest.finishLoading()
		return true
	}

	/// Returns the kept document for the given track.
	///
	/// - Parameter track: The track to look up.
	///
	/// - Returns: The track's WebVTT document with the seconds it spans and its address.
	private func document(for track: TrailerCaptionTrack) -> (text: String, duration: Double, url: URL)? {
		self.lock.lock()
		defer { self.lock.unlock() }

		return self.documents[track.address]
	}

	/// Returns the resource served at the given address.
	///
	/// - Parameter url: The address being requested.
	///
	/// - Returns: The resource's text and content type.
	private func resource(at url: URL) -> (body: String, contentType: String)? {
		switch url.host {
		case "stream":
			return (self.manifest, UTType.m3uPlaylist.identifier)
		case "captions":
			let components = url.pathComponents.filter { $0 != "/" }
			guard components.count == 2, let index = Int(components[0]), self.captionTracks.indices.contains(index) else { return nil }
			guard let document = self.document(for: self.captionTracks[index]) else { return nil }

			let duration = max(document.duration, TrailerCaptionTrack.duration(ofWebVTT: document.text)) + 2.0
			let playlist = """
			#EXTM3U
			#EXT-X-VERSION:3
			#EXT-X-TARGETDURATION:\(Int(duration.rounded(.up)))
			#EXT-X-MEDIA-SEQUENCE:0
			#EXT-X-PLAYLIST-TYPE:VOD
			#EXTINF:\(duration),
			\(document.url.absoluteString)
			#EXT-X-ENDLIST
			"""
			return (playlist, UTType.m3uPlaylist.identifier)
		default:
			return nil
		}
	}

	/// Returns the manifest limited to the given variants with the given tracks added as renditions.
	///
	/// - Parameters:
	///    - manifest: The stream's own manifest.
	///    - variantURLs: The variant addresses to keep.
	///    - captionTracks: The subtitle tracks to add.
	///
	/// - Returns: The rewritten manifest.
	private static func rewrite(_ manifest: String, keeping variantURLs: Set<String>, adding captionTracks: [TrailerCaptionTrack]) -> String {
		let lines = manifest.components(separatedBy: "\n")
		var output: [String] = []
		var index = 0

		while index < lines.count {
			let line = lines[index]
			index += 1

			if line.hasPrefix("#EXT-X-STREAM-INF") {
				guard index < lines.count else { continue }

				let variantURL = lines[index].trimmingCharacters(in: .whitespaces)
				index += 1
				guard variantURLs.contains(variantURL) else { continue }

				output.append(captionTracks.isEmpty ? line : line + ",SUBTITLES=\"kurozora\"")
				output.append(variantURL)
				continue
			}

			output.append(line)

			if line.hasPrefix("#EXTM3U") {
				for (trackIndex, track) in captionTracks.enumerated() {
					output.append(Self.rendition(for: track, at: trackIndex))
				}
			}
		}

		return output.joined(separator: "\n")
	}

	/// Returns the rendition line listing the given track.
	///
	/// - Parameters:
	///    - track: The track to list.
	///    - index: The track's position among the listed tracks.
	///
	/// - Returns: The rendition line.
	private static func rendition(for track: TrailerCaptionTrack, at index: Int) -> String {
		let name = track.title.replacingOccurrences(of: "\"", with: "")
		var attributes = ["TYPE=SUBTITLES", "GROUP-ID=\"kurozora\"", "NAME=\"\(name)\"", "LANGUAGE=\"\(track.languageCode)\"", "AUTOSELECT=NO", "DEFAULT=NO", "FORCED=NO"]

		if track.isAutoGenerated {
			attributes.append("CHARACTERISTICS=\"public.accessibility.transcribes-spoken-dialog\"")
		}

		attributes.append("URI=\"\(Self.scheme)://captions/\(index)/index.m3u8\"")
		return "#EXT-X-MEDIA:" + attributes.joined(separator: ",")
	}
}
