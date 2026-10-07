//
//  TrailerPlayerPool.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import WebKit

/// Keeps a small set of trailer players warm so returning to a trailer resumes without reloading.
@MainActor
final class TrailerPlayerPool {
	// MARK: - Views
	/// The offscreen host that keeps detached players loaded.
	private lazy var warmHostView: UIView = {
		let view = UIView(frame: CGRect(x: -30000.0, y: -30000.0, width: 4000.0, height: 4000.0))
		view.isUserInteractionEnabled = false
		return view
	}()

	// MARK: - Properties
	/// The shared pool.
	static let shared = TrailerPlayerPool()

	/// The number of players kept loaded at once.
	private let maximumWarmPlayers = 4

	/// The warm players, ordered from least to most recently used.
	private var players: [TrailerWebPlayer] = []

	/// The web view that starts WebKit's processes ahead of the first trailer.
	private var warmUpWebView: WKWebView?

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Starts WebKit's processes ahead of the first trailer.
	func warmUpWebKit() {
		guard self.warmUpWebView == nil else { return }

		let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
		webView.loadHTMLString("<html></html>", baseURL: nil)
		self.warmUpWebView = webView
	}

	/// Returns the warm player for the given video, creating one if needed.
	///
	/// - Parameter videoID: The identifier of the video to play.
	///
	/// - Returns: The player for the video.
	func player(forVideoID videoID: String) -> TrailerWebPlayer {
		if let index = self.players.firstIndex(where: { $0.videoID == videoID }) {
			let player = self.players.remove(at: index)
			self.players.append(player)
			return player
		}

		let player = TrailerWebPlayer(videoID: videoID)
		self.players.append(player)
		self.evictExcessPlayers()
		return player
	}

	/// Returns the already warm player for the given video, without starting a new one.
	///
	/// - Parameter videoID: The identifier of the video to look for.
	///
	/// - Returns: The warm player, when one is being kept for the video.
	func warmPlayer(forVideoID videoID: String) -> TrailerWebPlayer? {
		return self.players.first { $0.videoID == videoID }
	}

	/// Returns the offscreen host a detached player parks in to stay warm.
	///
	/// - Returns: The host, once there is a window to hold it.
	func warmHost() -> UIView? {
		if self.warmHostView.superview == nil {
			let windowScene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
			guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) ?? windowScene?.windows.first else { return nil }

			window.addSubview(self.warmHostView)
			window.sendSubviewToBack(self.warmHostView)
		}

		return self.warmHostView
	}

	/// Tears down the least recently used detached players beyond the warm limit.
	private func evictExcessPlayers() {
		var excess = self.players.count - self.maximumWarmPlayers

		for player in self.players where excess > 0 && !player.isAttached {
			self.players.removeAll { $0 === player }
			player.teardown()
			excess -= 1
		}
	}
}
