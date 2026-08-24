//
//  TrailerWebPlayer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import WebKit

/// Reports playback state changes from a trailer web player.
@MainActor
protocol TrailerWebPlayerDelegate: AnyObject {
	/// Tells the delegate the trailer began playing.
	///
	/// - Parameter trailerWebPlayer: The web player reporting the change.
	func trailerWebPlayerDidStartPlaying(_ trailerWebPlayer: TrailerWebPlayer)

	/// Tells the delegate the trailer paused.
	///
	/// - Parameter trailerWebPlayer: The web player reporting the change.
	func trailerWebPlayerDidPause(_ trailerWebPlayer: TrailerWebPlayer)

	/// Tells the delegate the trailer failed to play.
	///
	/// - Parameter trailerWebPlayer: The web player reporting the change.
	func trailerWebPlayerDidFail(_ trailerWebPlayer: TrailerWebPlayer)
}

/// A reusable web view that plays one YouTube trailer through the IFrame Player API.
///
/// The player keeps its page loaded across hosts, so reattaching resumes playback in place.
@MainActor
final class TrailerWebPlayer: NSObject {
	// MARK: - Properties
	/// The identifier of the video this player renders.
	let videoID: String

	/// The name of the script message channel the page posts events on.
	private static let messageHandlerName = "trailer"

	/// The origin the embed reports to YouTube.
	private static let embedOriginURL = URL(string: "https://\(Bundle.main.bundleIdentifier ?? "app.kurozora.kurozora")")

	/// A script that hides YouTube's player chrome inside the embed.
	private static let chromeHidingScript: WKUserScript = {
		let source = """
		(function() {
		  var selector = '.ytp-chrome-top,.ytp-gradient-top,.ytp-gradient-bottom,.ytp-pause-overlay,.ytp-ce-element,.ytp-ce-covering-overlay,.ytp-watermark,.ytp-show-cards-title,.ytp-title,.ytp-large-play-button,.ytp-cued-thumbnail-overlay,.ytp-spinner';
		  function hide() {
		    var nodes = document.querySelectorAll(selector);
		    for (var index = 0; index < nodes.length; index++) {
		      nodes[index].style.setProperty('display', 'none', 'important');
		    }
		  }
		  var scheduled = false;
		  function schedule() {
		    if (scheduled) { return; }
		    scheduled = true;
		    requestAnimationFrame(function() { scheduled = false; hide(); });
		  }
		  hide();
		  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['class', 'style'] });
		})();
		"""
		return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
	}()

	/// The view currently hosting the web view.
	private weak var host: UIView?

	/// The delegate notified of playback state changes.
	private weak var delegate: TrailerWebPlayerDelegate?

	/// A Boolean value indicating whether the player finished loading.
	private var isPlayerReady = false

	/// A Boolean value indicating whether playback is paused.
	private var isPaused = false

	/// A Boolean value indicating whether the trailer's sound is off.
	private var isMuted = true

	/// A Boolean value indicating whether the web view has been revealed at least once.
	private var hasRevealed = false

	/// The task that reveals the web view if no playing event arrives.
	private var revealTask: Task<Void, Never>?

	/// The web view that renders the trailer.
	private lazy var webView: WKWebView = self.makeWebView()

	// MARK: - Initializers
	init(videoID: String) {
		self.videoID = videoID
		super.init()
	}

	// MARK: - Functions
	/// Moves the web view into the given host and prepares playback.
	///
	/// - Parameters:
	///    - host: The view that hosts the web view.
	///    - isMuted: Whether the trailer's sound is off.
	///    - delegate: The object notified of playback state changes.
	func attach(to host: UIView, isMuted: Bool, delegate: TrailerWebPlayerDelegate) {
		self.host = host
		self.delegate = delegate
		self.isMuted = isMuted

		self.webView.frame = host.bounds
		self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.webView.alpha = self.hasRevealed ? 1.0 : 0.0
		host.insertSubview(self.webView, at: 0)

		if self.webView.url == nil {
			self.webView.loadHTMLString(self.playerHTML(isMuted: isMuted), baseURL: Self.embedOriginURL)
		} else {
			self.setMuted(isMuted)
		}
	}

	/// Removes the web view from its host while keeping the page loaded.
	func detach() {
		self.revealTask?.cancel()
		self.revealTask = nil

		self.pause()

		self.webView.removeFromSuperview()

		self.host = nil
		self.delegate = nil
	}

	/// Resumes playback.
	func play() {
		self.isPaused = false
		guard self.isPlayerReady else { return }
		self.evaluate("player && player.playVideo();")
		self.scheduleRevealFallback()
	}

	/// Pauses playback.
	func pause() {
		self.isPaused = true
		guard self.isPlayerReady else { return }
		self.evaluate("player && player.pauseVideo();")
	}

	/// Mutes or unmutes the trailer.
	///
	/// - Parameter isMuted: Whether the sound is off.
	func setMuted(_ isMuted: Bool) {
		self.isMuted = isMuted
		guard self.isPlayerReady else { return }
		self.evaluate(isMuted ? "player && player.mute();" : "player && player.unMute();")
	}

	/// Stops playback and releases the page.
	func teardown() {
		self.detach()
		self.webView.stopLoading()
		self.webView.loadHTMLString("", baseURL: nil)
	}

	/// Returns a Boolean value indicating whether the given host currently holds the web view.
	///
	/// - Parameter host: The host to check.
	///
	/// - Returns: `true` if the host holds the web view.
	func isHosting(_ host: UIView) -> Bool {
		return self.host === host
	}

	/// Extracts the video identifier from the given YouTube URL.
	///
	/// Recognizes `watch?v=`, `youtu.be/`, `embed/`, `shorts/`, `live/` and `v/` URL forms.
	///
	/// - Parameter urlString: The YouTube URL to inspect.
	///
	/// - Returns: The video identifier carried by the URL.
	static func videoID(fromURL urlString: String) -> String? {
		guard let urlComponents = URLComponents(string: urlString) else { return nil }

		if let videoID = urlComponents.queryItems?.first(where: { $0.name == "v" })?.value, !videoID.isEmpty {
			return videoID
		}

		let pathComponents = urlComponents.path.split(separator: "/").map(String.init)

		if urlComponents.host?.lowercased().hasSuffix("youtu.be") == true {
			return pathComponents.first
		}

		let pathMarkers: Set<String> = ["embed", "shorts", "live", "v"]

		if let markerIndex = pathComponents.firstIndex(where: { pathMarkers.contains($0) }), pathComponents.indices.contains(markerIndex + 1) {
			return pathComponents[markerIndex + 1]
		}

		return nil
	}

	/// Reveals the web view after a delay if no playing event arrives.
	private func scheduleRevealFallback() {
		guard !self.hasRevealed else { return }
		self.revealTask?.cancel()
		self.revealTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			guard !Task.isCancelled, let self = self, self.host != nil, self.isPlayerReady, !self.hasRevealed else { return }
			self.reveal()
		}
	}

	/// Fades the web view in.
	private func reveal() {
		self.revealTask?.cancel()
		self.revealTask = nil
		self.hasRevealed = true

		UIView.animate(withDuration: 0.4) {
			self.webView.alpha = 1.0
		}
	}

	/// Evaluates the given JavaScript in the web view.
	///
	/// - Parameter script: The script to run.
	private func evaluate(_ script: String) {
		self.webView.evaluateJavaScript(script, completionHandler: nil)
	}

	/// Handles a playback event posted by the page.
	///
	/// - Parameter event: The event name.
	private func handle(event: String) {
		switch event {
		case "ready":
			self.isPlayerReady = true
			self.setMuted(self.isMuted)

			if self.isPaused {
				self.evaluate("player && player.pauseVideo();")
			}
		case "playing":
			self.reveal()
			self.delegate?.trailerWebPlayerDidStartPlaying(self)
		case "paused":
			self.delegate?.trailerWebPlayerDidPause(self)
		case "error":
			self.delegate?.trailerWebPlayerDidFail(self)
		default:
			break
		}
	}

	/// Builds the web view configured for inline, autoplaying media.
	///
	/// - Returns: A configured web view.
	private func makeWebView() -> WKWebView {
		let userContentController = WKUserContentController()
		userContentController.add(self, name: Self.messageHandlerName)
		userContentController.addUserScript(Self.chromeHidingScript)

		let configuration = WKWebViewConfiguration()
		configuration.allowsInlineMediaPlayback = true
		configuration.mediaTypesRequiringUserActionForPlayback = []
		configuration.allowsPictureInPictureMediaPlayback = true
		configuration.userContentController = userContentController
		configuration.websiteDataStore = .nonPersistent()

		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.isOpaque = false
		webView.backgroundColor = .clear
		webView.scrollView.backgroundColor = .clear
		webView.scrollView.isScrollEnabled = false
		webView.scrollView.contentInsetAdjustmentBehavior = .never
		webView.isUserInteractionEnabled = false
		return webView
	}

	/// The HTML page hosting the IFrame player.
	///
	/// - Parameter isMuted: Whether the trailer starts muted.
	///
	/// - Returns: The page markup.
	private func playerHTML(isMuted: Bool) -> String {
		"""
		<!DOCTYPE html>
		<html>
		<head>
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
		<meta name="referrer" content="strict-origin-when-cross-origin">
		<style>
		  * { margin: 0; padding: 0; }
		  html, body { width: 100%; height: 100%; background: transparent; overflow: hidden; }
		  #player { width: 100%; height: 100%; pointer-events: none; }
		</style>
		</head>
		<body>
		<div id="player"></div>
		<script>
		  var player;
		  function post(event) {
		    try {
		      window.webkit.messageHandlers.trailer.postMessage({ event: event });
		    } catch (error) {}
		  }
		  function onYouTubeIframeAPIReady() {
		    player = new YT.Player('player', {
		      width: '100%',
		      height: '100%',
		      playerVars: {
		        playsinline: 1,
		        controls: 0,
		        autoplay: 1,
		        mute: \(isMuted ? 1 : 0),
		        rel: 0,
		        modestbranding: 1,
		        fs: 0,
		        disablekb: 1,
		        iv_load_policy: 3,
		        origin: window.location.origin
		      },
		      events: {
		        onReady: function() {
		          if (\(isMuted ? "true" : "false")) { player.mute(); } else { player.unMute(); }
		          player.loadPlaylist('\(self.videoID)');
		          player.setLoop(true);
		          post('ready');
		        },
		        onStateChange: onStateChange,
		        onError: function(event) { post('error'); }
		      }
		    });
		  }
		  function onStateChange(event) {
		    if (event.data === YT.PlayerState.PLAYING) {
		      post('playing');
		    } else if (event.data === YT.PlayerState.PAUSED) {
		      post('paused');
		    }
		  }
		  var tag = document.createElement('script');
		  tag.src = 'https://www.youtube.com/iframe_api';
		  document.head.appendChild(tag);
		</script>
		</body>
		</html>
		"""
	}
}

// MARK: - WKScriptMessageHandler
extension TrailerWebPlayer: WKScriptMessageHandler {
	nonisolated func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard message.name == TrailerWebPlayer.messageHandlerName else { return }
		guard let body = message.body as? [String: Any], let event = body["event"] as? String else { return }

		MainActor.assumeIsolated {
			self.handle(event: event)
		}
	}
}
