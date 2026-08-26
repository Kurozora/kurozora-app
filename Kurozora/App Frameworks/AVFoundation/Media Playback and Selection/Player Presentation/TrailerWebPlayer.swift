//
//  TrailerWebPlayer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit
import WebKit

#if targetEnvironment(macCatalyst)
import Obfuscation
#endif

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

	/// Tells the delegate the trailer's picture became visible.
	///
	/// - Parameter trailerWebPlayer: The web player reporting the change.
	func trailerWebPlayerDidRevealPicture(_ trailerWebPlayer: TrailerWebPlayer)

	/// Tells the delegate how far the trailer has played.
	///
	/// - Parameters:
	///    - trailerWebPlayer: The web player reporting the change.
	///    - currentTime: The seconds played so far.
	///    - duration: The trailer's length in seconds.
	func trailerWebPlayer(_ trailerWebPlayer: TrailerWebPlayer, didPlayTo currentTime: Double, duration: Double)
}

// MARK: - TrailerWebPlayerDelegate
extension TrailerWebPlayerDelegate {
	func trailerWebPlayer(_ trailerWebPlayer: TrailerWebPlayer, didPlayTo currentTime: Double, duration: Double) {}
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

	/// The selector matching everything in the embed that is neither the video nor an ancestor of it.
	private static let hiddenChromeSelector = "body *:not(video):not(:has(video.html5-main-video))"

	/// The script that strips the embed down to its video and takes presses for the app's controls.
	private static let chromeHidingScript: WKUserScript = {
		let css = """
		\(TrailerWebPlayer.hiddenChromeSelector){opacity:0!important;pointer-events:none!important;}
		.html5-video-player,.html5-video-container{background:transparent!important;}
		.html5-main-video,video{object-fit:cover!important;pointer-events:none!important;cursor:none!important;}
		html,body{background:transparent!important;-webkit-user-select:none!important;-webkit-touch-callout:none!important;}
		/* Identifiers outweigh the hiding rule above. */
		#kurozora-press-pip,#kurozora-press-airplay{opacity:0!important;pointer-events:auto!important;}
		"""
		let source = """
		(function() {
		  // The paused frame's native stand-in offers the system menu instead.
		  document.addEventListener('contextmenu', function(event) { event.preventDefault(); }, true);
		  // The page never learns the window went away, or the embed would pause itself over it.
		  try {
		    Object.defineProperty(document, 'hidden', { get: function() { return false; } });
		    Object.defineProperty(document, 'visibilityState', { get: function() { return 'visible'; } });
		  } catch (error) {}
		  document.addEventListener('visibilitychange', function(event) { event.stopImmediatePropagation(); }, true);
		  if (location.hostname.indexOf('youtube') === -1) { return; }
		  // Only the embed's own frame may answer for the video; nested frames carry none.
		  var isEmbedRoot = false;
		  try { isEmbedRoot = (window.parent === window.top); } catch (error) {}
		  var STYLE_ID = 'kurozora-embed-clean';
		  function ensureStyle() {
		    if (document.getElementById(STYLE_ID)) { return; }
		    var style = document.createElement('style');
		    style.id = STYLE_ID;
		    style.textContent = `\(css)`;
		    (document.head || document.documentElement).appendChild(style);
		  }
		  function skipAds() {
		    var skipButton = document.querySelector('.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-skip-ad-button');
		    if (skipButton) { skipButton.click(); }
		    var moviePlayer = document.querySelector('.html5-video-player');
		    var video = document.querySelector('video');
		    if (moviePlayer && moviePlayer.classList.contains('ad-showing') && video) {
		      video.muted = true;
		      if (isFinite(video.duration) && video.duration > 0) { video.currentTime = video.duration; }
		    }
		  }
		  function reportPictureInPictureError(error) {
		    try { window.webkit.messageHandlers.trailer.postMessage({ event: 'pictureInPictureError', message: String(error) }); } catch (postError) {}
		  }
		  window.kurozoraRequestPictureInPicture = function() {
		    var video = document.querySelector('video');
		    if (!video) { reportPictureInPictureError('no video'); return; }
		    // The support flag misreports, so the call is simply attempted.
		    if (video.webkitSetPresentationMode) {
		      var mode = video.webkitPresentationMode === 'picture-in-picture' ? 'inline' : 'picture-in-picture';
		      try {
		        video.webkitSetPresentationMode(mode);
		        setTimeout(function() {
		          try { window.webkit.messageHandlers.trailer.postMessage({ event: 'pictureInPictureState', requested: mode, mode: video.webkitPresentationMode }); } catch (postError) {}
		        }, 500);
		        return;
		      } catch (error) { reportPictureInPictureError(error); }
		    }
		    if (!document.pictureInPictureEnabled) { reportPictureInPictureError('disabled'); return; }
		    if (document.pictureInPictureElement) { document.exitPictureInPicture(); return; }
		    var request = video.requestPictureInPicture();
		    if (request && request.catch) { request.catch(reportPictureInPictureError); }
		  };
		  // A floating window is only granted to a press inside this page, so transparent targets
		  // take those presses for the app's own controls.
		  window.kurozoraPositionPressTarget = function(name, left, top, width, height) {
		    var identifier = 'kurozora-press-' + name;
		    var target = document.getElementById(identifier);
		    if (!target) {
		      target = document.createElement('div');
		      target.id = identifier;
		      target.className = 'kurozora-press-target';
		      target.style.position = 'fixed';
		      target.style.zIndex = '2147483647';
		      target.style.background = 'transparent';
		      target.addEventListener('click', function(event) {
		        event.preventDefault();
		        target.style.display = 'none';
		        // The player's own button when it exists; the media API otherwise.
		        var playerButton = document.querySelector('.ytp-pip-button, button[class*="pip-button"]');
		        try { window.webkit.messageHandlers.trailer.postMessage({ event: 'pressTarget', name: name, path: playerButton ? 'player-button' : 'api' }); } catch (postError) {}
		        if (playerButton) { playerButton.click(); return; }
		        window.kurozoraRequestPictureInPicture();
		      });
		      (document.body || document.documentElement).appendChild(target);
		    }
		    if (width <= 0 || height <= 0) { target.style.display = 'none'; return; }
		    target.style.display = 'block';
		    target.style.left = left + 'px';
		    target.style.top = top + 'px';
		    target.style.width = width + 'px';
		    target.style.height = height + 'px';
		  };
		  // The embed must never act on a press itself; only the targets above take theirs.
		  ['pointerdown', 'mousedown', 'mouseup', 'click', 'dblclick'].forEach(function(name) {
		    document.addEventListener(name, function(event) {
		      var target = event.target;
		      if (target && target.id && target.id.indexOf('kurozora-press-') === 0) { return; }
		      event.stopImmediatePropagation();
		    }, true);
		  });
		  // Pinning a playlist on the element holds the chosen quality.
		  window.kurozoraPinStream = function(streamURL) {
		    var v = document.querySelector('video');
		    if (!v || !streamURL || v.currentSrc === streamURL) { return; }
		    var wasTime = v.currentTime;
		    var wasPaused = v.paused;
		    var wasRate = v.playbackRate;
		    v.src = streamURL;
		    try { v.currentTime = wasTime; } catch (error) {}
		    v.playbackRate = wasRate;
		    if (!wasPaused) {
		      var request = v.play();
		      if (request && request.catch) { request.catch(function(error) {}); }
		    }
		  };
		  if (isEmbedRoot) {
		    try { window.webkit.messageHandlers.trailer.postMessage({ event: 'frameReady' }); } catch (error) {}
		    setInterval(function() {
		      var video = document.querySelector('video');
		      if (!video || !video.getVideoPlaybackQuality) { return; }
		      var quality = video.getVideoPlaybackQuality();
		      if (!quality || !quality.totalVideoFrames) { return; }
		      try { window.webkit.messageHandlers.trailer.postMessage({ event: 'frames', decodedFrames: quality.totalVideoFrames, mediaTime: video.currentTime || 0 }); } catch (error) {}
		    }, 1000);
		  }
		  ensureStyle();
		  var scheduled = false;
		  function schedule() {
		    if (scheduled) { return; }
		    scheduled = true;
		    requestAnimationFrame(function() { scheduled = false; ensureStyle(); skipAds(); });
		  }
		  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['class'] });
		})();
		"""
		return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
	}()

	/// The view currently hosting the web view.
	private weak var host: UIView?

	/// The delegate notified of playback state changes.
	private weak var delegate: TrailerWebPlayerDelegate?

	/// A Boolean value indicating whether the player finished loading.
	private var isPlayerReady = false

	/// A Boolean value indicating whether playback is paused.
	private(set) var isPaused = false

	/// The frames the trailer shows each second, once known.
	private(set) var framesPerSecond: Double?

	/// A Boolean value indicating whether the trailer's sound is off.
	private(set) var isMuted = true

	/// How loud the trailer plays, from silent at `0` to full at `1`.
	private(set) var volume = 1.0

	/// The quality levels the current video offers, highest first.
	private(set) var availableQualityLevels: [String] = []

	/// A Boolean value indicating whether the stream ladder has been read.
	private var hasCollectedQualityLevels = false

	/// The stream address the trailer adapts freely on.
	private var masterManifestURL: String?

	/// The pinned stream address for each quality level.
	private var qualityVariantURLs: [String: String] = [:]

	/// The quality level playback is held at, with `auto` letting the video adapt.
	private(set) var preferredQualityLevel = (KNetworkManager.isOnCellular ? UserSettings.cellularVideoQuality : UserSettings.wifiVideoQuality).preferredLevel

	/// The embed's own frame, which scripts have to run in to reach the video.
	private var embedFrameInfo: WKFrameInfo?

	/// A Boolean value indicating whether the web view has been revealed at least once.
	private var hasRevealed = false

	/// The task that reveals the web view if no playing event arrives.
	private var revealTask: Task<Void, Never>?

	/// The web view that renders the trailer.
	private lazy var webView: WKWebView = self.makeWebView()

	/// The fixed size the page lays out at.
	private static let referenceSize = CGSize(width: 1280.0, height: 720.0)

	/// The view rendering the video at its aspect ratio.
	private var videoView: TrailerVideoScalingView?

	/// The observers redrawing a paused trailer when its window comes back into view.
	private var visibilityObservers: [NSObjectProtocol] = []

	/// The task waiting for a run of paused seeks to settle before keeping the frame.
	private var frameCaptureTask: Task<Void, Never>?

	/// The still standing in for the video while it is paused.
	private var pausedFrameView: TrailerPausedFrameView?

	/// A Boolean value indicating whether the picture is visible in a host.
	var isShowingPicture: Bool {
		return self.host != nil && self.hasRevealed
	}

	// MARK: - Initializers
	init(videoID: String) {
		self.videoID = videoID
		super.init()
		self.observeWindowVisibility()
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

		if #available(iOS 26.0, *) {
			let videoView = self.videoView ?? TrailerVideoScalingView(webView: self.webView, referenceSize: Self.referenceSize)
			self.videoView = videoView

			videoView.frame = host.bounds
			videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			videoView.alpha = self.hasRevealed ? 1.0 : 0.0
			host.insertSubview(videoView, at: 0)
		} else {
			self.webView.frame = host.bounds
			self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.webView.alpha = self.hasRevealed ? 1.0 : 0.0
			host.insertSubview(self.webView, at: 0)
		}

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

		// Parked offscreen instead of leaving the window, so the video stays loaded and ready.
		let hostedView: UIView = self.videoView ?? self.webView

		if let warmHost = TrailerPlayerPool.shared.warmHost() {
			hostedView.autoresizingMask = []
			warmHost.addSubview(hostedView)
		} else {
			hostedView.removeFromSuperview()
		}

		self.host = nil
		self.delegate = nil
	}

	/// Resumes playback.
	func play() {
		self.isPaused = false
		self.updateAudioSession()

		guard self.isPlayerReady else { return }
		self.evaluate("player && player.playVideo();")
		self.scheduleRevealFallback()
	}

	/// Pauses playback.
	func pause() {
		self.isPaused = true
		self.updateAudioSession()

		guard self.isPlayerReady else { return }
		self.evaluate("player && player.pauseVideo();")
	}

	/// Mutes or unmutes the trailer.
	///
	/// - Parameter isMuted: Whether the sound is off.
	func setMuted(_ isMuted: Bool) {
		self.isMuted = isMuted
		self.updateAudioSession()

		guard self.isPlayerReady else { return }
		self.evaluate(isMuted ? "player && player.mute();" : "player && player.unMute();")
	}

	/// Claims the audio session while the trailer is audible and releases it otherwise.
	private func updateAudioSession() {
		let isAudible = !self.isMuted && !self.isPaused

		do {
			if isAudible {
				try AVAudioSession.sharedInstance().setCategory(.playback)
				try AVAudioSession.sharedInstance().setActive(true)
			} else {
				try AVAudioSession.sharedInstance().setCategory(.ambient)
				try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
			}
		} catch {
			print("----- [Trailer] Failed to update the audio session: \(error.localizedDescription)")
		}
	}

	/// Moves playback to the given point.
	///
	/// - Parameter seconds: The point to play from.
	func seek(to seconds: Double) {
		guard self.isPlayerReady else { return }
		self.evaluate("player && player.seekTo(\(max(0.0, seconds)), true);")

		// The stand-in steps aside for the live seek and comes back once the new frame has painted.
		guard self.isPaused else { return }
		self.pausedFrameView?.hideFrame()
		self.frameCaptureTask?.cancel()
		self.frameCaptureTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 600_000_000)
			guard !Task.isCancelled, let self = self, let embedFrameInfo = self.embedFrameInfo else { return }

			let script = """
			(function(){
			  var v = document.querySelector('video');
			  if (!v || !v.paused) { return; }
			  var reported = false;
			  function report() {
			    if (reported) { return; }
			    reported = true;
			    try { window.webkit.messageHandlers.trailer.postMessage({ event: 'pausedSeekSettled' }); } catch (error) {}
			  }
			  v.addEventListener('seeked', function handler() {
			    v.removeEventListener('seeked', handler);
			    requestAnimationFrame(function() { requestAnimationFrame(report); });
			  });
			  setTimeout(report, 1200);
			  if (!v.seeking) { v.currentTime = v.currentTime; }
			})();
			"""
			self.webView.evaluateJavaScript(script, in: embedFrameInfo, in: .page, completionHandler: nil)
		}
	}

	/// Sets how fast the trailer plays.
	///
	/// - Parameter rate: The multiple of normal speed to play at.
	func setPlaybackRate(_ rate: Double) {
		guard self.isPlayerReady else { return }
		self.evaluate("player && player.setPlaybackRate(\(rate));")
	}

	/// Sets how loud the trailer plays.
	///
	/// - Parameter volume: The loudness, from silent at `0` to full at `1`.
	func setVolume(_ volume: Double) {
		self.volume = volume
		guard self.isPlayerReady else { return }
		self.evaluate("player && player.setVolume(\(Int((min(max(0.0, volume), 1.0) * 100.0).rounded())));")
	}

	/// Sets the quality level to hold playback at.
	///
	/// - Parameter level: The quality level to hold, with `auto` letting the video adapt.
	func setPreferredQualityLevel(_ level: String) {
		self.preferredQualityLevel = level
		self.pinPreferredStream()
	}

	/// Reads the quality levels the trailer's stream offers once playback starts.
	private func collectQualityLevelsIfNeeded() {
		guard !self.hasCollectedQualityLevels, let embedFrameInfo = self.embedFrameInfo else { return }
		self.hasCollectedQualityLevels = true

		let script = "(function(){ var v = document.querySelector('video'); return v ? (v.currentSrc || '') : ''; })()"
		self.webView.evaluateJavaScript(script, in: embedFrameInfo, in: .page) { [weak self] result in
			MainActor.assumeIsolated {
				guard let self = self else { return }

				switch result {
				case .success(let value):
					guard let source = value as? String, source.contains("/hls_variant/"), let manifestURL = URL(string: source) else {
						self.hasCollectedQualityLevels = false
						return
					}

					self.masterManifestURL = source
					self.fetchQualityLevels(from: manifestURL)
				case .failure:
					self.hasCollectedQualityLevels = false
				}
			}
		}
	}

	/// Reads the quality levels out of the stream's manifest.
	///
	/// - Parameter manifestURL: The address of the manifest to read.
	private func fetchQualityLevels(from manifestURL: URL) {
		Task { @MainActor [weak self] in
			do {
				let (manifestBody, _) = try await URLSession.shared.data(from: manifestURL)
				guard let self = self, let manifest = String(data: manifestBody, encoding: .utf8) else { return }
				self.adoptQualityLevels(fromManifest: manifest)
			} catch {
				print("----- [Trailer] Stream manifest fetch failed: \(error.localizedDescription)")
				self?.hasCollectedQualityLevels = false
			}
		}
	}

	/// Adopts the quality levels listed in the given manifest.
	///
	/// - Parameter manifest: The manifest listing the stream's variants.
	private func adoptQualityLevels(fromManifest manifest: String) {
		let lines = manifest.components(separatedBy: "\n")
		var variants: [(height: Int, url: String)] = []

		for (index, line) in lines.enumerated() where line.hasPrefix("#EXT-X-STREAM-INF") {
			guard index + 1 < lines.count else { continue }

			let variantURL = lines[index + 1].trimmingCharacters(in: .whitespaces)
			guard variantURL.hasPrefix("http") else { continue }
			guard
				let resolution = line.components(separatedBy: "RESOLUTION=").dropFirst().first,
				let height = resolution.components(separatedBy: ",").first?.components(separatedBy: "x").last.flatMap({ Int($0) })
			else { continue }

			variants.append((height, variantURL))
		}

		variants.sort { $0.height > $1.height }

		var orderedLevels: [String] = []
		var variantURLs: [String: String] = [:]

		for variant in variants where variantURLs["\(variant.height)p"] == nil {
			orderedLevels.append("\(variant.height)p")
			variantURLs["\(variant.height)p"] = variant.url
		}

		self.availableQualityLevels = orderedLevels
		self.qualityVariantURLs = variantURLs
		print("----- [Trailer] Stream ladder: \(orderedLevels)")

		if self.preferredQualityLevel != "auto" {
			self.pinPreferredStream()
		}
	}

	/// Returns the offered level closest to the held one, preferring the first below it.
	///
	/// - Returns: The level to pin the stream at.
	func resolvedQualityLevel() -> String? {
		if self.qualityVariantURLs[self.preferredQualityLevel] != nil {
			return self.preferredQualityLevel
		}

		let preferredHeight = Int(self.preferredQualityLevel.dropLast()) ?? 0
		let offeredHeights = self.availableQualityLevels.compactMap { Int($0.dropLast()) }
		let resolvedHeight = offeredHeights.first { $0 <= preferredHeight } ?? offeredHeights.last
		return resolvedHeight.map { "\($0)p" }
	}

	/// Points the trailer at the stream matching the held quality level.
	private func pinPreferredStream() {
		var streamURL = self.masterManifestURL

		if self.preferredQualityLevel != "auto", let resolvedLevel = self.resolvedQualityLevel() {
			streamURL = self.qualityVariantURLs[resolvedLevel]
		}

		guard let streamURL, let embedFrameInfo = self.embedFrameInfo else { return }
		self.webView.evaluateJavaScript("window.kurozoraPinStream && kurozoraPinStream('\(streamURL)');", in: embedFrameInfo, in: .page, completionHandler: nil)
	}

	#if targetEnvironment(macCatalyst)
	/// Opens the trailer in a floating window.
	func requestPictureInPicture() {
		self.pressThroughTarget(named: "pip")
	}

	/// Presses the named in-page target over an open stretch of the picture.
	///
	/// - Parameter name: The control the target stands in for.
	private func pressThroughTarget(named name: String) {
		guard let embedFrameInfo = self.embedFrameInfo, let window = self.webView.window else {
			print("----- [Trailer] No page to press target '\(name)' in")
			return
		}

		// The stand-in steps out of hit testing so the press falls through to the page.
		self.pausedFrameView?.isUserInteractionEnabled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
			self?.pausedFrameView?.isUserInteractionEnabled = true
		}

		// The first spot no other view covers takes the press.
		let pagePoints = [
			CGPoint(x: 640.0, y: 360.0),
			CGPoint(x: 640.0, y: 180.0),
			CGPoint(x: 640.0, y: 540.0),
			CGPoint(x: 320.0, y: 360.0),
			CGPoint(x: 960.0, y: 360.0)
		]

		for pagePoint in pagePoints {
			let windowPoint = self.webView.convert(pagePoint, to: window)
			guard let coveringView = window.hitTest(windowPoint, with: nil), coveringView.isDescendant(of: self.webView) else { continue }

			let script = "window.kurozoraPositionPressTarget && window.kurozoraPositionPressTarget('\(name)', \(pagePoint.x - 60.0), \(pagePoint.y - 60.0), 120.0, 120.0);"
			self.webView.evaluateJavaScript(script, in: embedFrameInfo, in: .page) { result in
				switch result {
				case .success:
					// A beat after the reader's own press, so the two never interleave.
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
						MouseEventSynthesizer.click(at: windowPoint)
					}
				case .failure(let error):
					print("----- [Trailer] Failed to place press target '\(name)': \(error.localizedDescription)")
				}
			}
			return
		}

		print("----- [Trailer] No open spot for press target '\(name)'")
	}
	#endif

	/// Sets whether presses reach the embed.
	///
	/// - Parameter isEnabled: Whether the embed takes presses.
	func setInteractionEnabled(_ isEnabled: Bool) {
		self.webView.isUserInteractionEnabled = isEnabled
	}

	/// Watches the window's visibility, repainting and rescuing the page around its changes.
	private func observeWindowVisibility() {
		let center = NotificationCenter.default

		self.visibilityObservers.append(center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.refreshPausedPicture()
			}
		})

		#if targetEnvironment(macCatalyst)
		self.visibilityObservers.append(center.addObserver(forName: NSNotification.Name("NSWindowDidChangeOcclusionStateNotification"), object: nil, queue: .main) { [weak self] notification in
			// Visible is the 1 << 1 bit of the window's occlusion state.
			let occlusionState = ((notification.object as? NSObject)?.value(forKey: "occlusionState") as? UInt) ?? 0

			MainActor.assumeIsolated {
				guard let self = self else { return }
				self.logRenderingState(occlusionVisible: occlusionState & 2 != 0)
				guard occlusionState & 2 != 0 else { return }

				// Repeated, because a repaint can be dropped while the switch is still settling.
				self.refreshPausedPicture()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
					self?.refreshPausedPicture()
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
					self?.refreshPausedPicture()
				}
			}
		})

		self.visibilityObservers.append(center.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] notification in
			let sceneObject = notification.object

			MainActor.assumeIsolated {
				self?.counterBackgrounding(of: sceneObject)
			}
		})

		self.visibilityObservers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				guard let self = self else { return }
				self.counterBackgrounding(of: self.webView.window?.windowScene)
			}
		})
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// A Boolean value indicating whether a synthetic foreground notice is on its rounds.
	private static var isPostingSyntheticForeground = false

	/// A Boolean value indicating whether the backgrounding bookkeeper steps aside for synthetic
	/// notices.
	private static let backgroundingBookkeeperLooksAway: Bool = {
		let selector = NSSelectorFromString(#obfuscated("_uiAppWillForeground:"))
		guard
			let controllerClass = NSClassFromString(#obfuscated("UINSUIKitBackgroundingController")),
			let method = class_getInstanceMethod(controllerClass, selector)
		else { return false }

		typealias Handler = @convention(c) (NSObject, Selector, NSNotification) -> Void
		let original = unsafeBitCast(method_getImplementation(method), to: Handler.self)

		let replacement: @convention(block) (NSObject, NSNotification) -> Void = { receiver, notification in
			guard !TrailerWebPlayer.isPostingSyntheticForeground else { return }
			original(receiver, selector, notification)
		}

		method_setImplementation(method, imp_implementationWithBlock(replacement))
		return true
	}()

	/// Walks the page back to the front the moment its scene turns away.
	///
	/// - Parameter sceneObject: The scene that turned away.
	private func counterBackgrounding(of sceneObject: Any?) {
		guard self.host != nil, self.hasRevealed else { return }

		// After the real notice has finished its rounds.
		DispatchQueue.main.async { [weak self] in
			self?.walkPageToForeground(sceneObject: sceneObject)
		}
	}

	/// Keeps the page in the foreground while the scene is away.
	///
	/// - Parameter sceneObject: The scene that turned away.
	private func walkPageToForeground(sceneObject: Any?) {
		guard self.isPageBackground else { return }

		if let sceneObject = sceneObject {
			NotificationCenter.default.post(name: UIScene.willEnterForegroundNotification, object: sceneObject)

			if !self.isPageBackground {
				print("----- [Trailer] Walked the page back to the front (scene)")
				return
			}
		}

		guard Self.backgroundingBookkeeperLooksAway else {
			print("----- [Trailer] The page cannot be walked back to the front; it may suspend off screen")
			return
		}

		Self.isPostingSyntheticForeground = true
		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
		Self.isPostingSyntheticForeground = false

		print("----- [Trailer] Walked the page back to the front (app; page now \(self.isPageBackground ? "background" : "foreground"))")
	}

	/// A Boolean value indicating whether WebKit put the page in the background.
	private var isPageBackground: Bool {
		let selector = NSSelectorFromString(#obfuscated("_isBackground"))
		guard self.webView.responds(to: selector) else { return false }

		typealias StateGetter = @convention(c) (NSObject, Selector) -> Bool
		return unsafeBitCast(self.webView.method(for: selector), to: StateGetter.self)(self.webView, selector)
	}

	/// Prints where rendering stands.
	///
	/// - Parameter occlusionVisible: Whether the window just became visible.
	private func logRenderingState(occlusionVisible: Bool) {
		let sceneState: String
		switch self.webView.window?.windowScene?.activationState {
		case .foregroundActive: sceneState = "foreground active"
		case .foregroundInactive: sceneState = "foreground inactive"
		case .background: sceneState = "background"
		case .unattached: sceneState = "unattached"
		default: sceneState = "unknown"
		}

		print("----- [Trailer] Window \(occlusionVisible ? "visible" : "occluded"); scene \(sceneState); page \(self.isPageBackground ? "background" : "foreground")")
	}
	#endif

	/// Puts the paused frame up in front of the video.
	private func capturePausedFrame() {
		guard self.isPaused, self.hasRevealed else { return }

		self.webView.takeSnapshot(with: nil) { [weak self] image, error in
			if let error = error {
				print("----- [Trailer] Failed to keep the paused frame: \(error.localizedDescription)")
			}

			guard let self = self, let image = image, self.isPaused else { return }

			let pausedFrameView = self.pausedFrameView ?? TrailerPausedFrameView()
			self.pausedFrameView = pausedFrameView

			pausedFrameView.frame = self.webView.bounds
			pausedFrameView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.webView.addSubview(pausedFrameView)
			pausedFrameView.showFrame(image)
		}
	}

	/// Asks the paused video behind the stand-in for its current frame again.
	private func refreshPausedPicture() {
		guard self.isPlayerReady, self.isPaused, let embedFrameInfo = self.embedFrameInfo else { return }

		let script = "(function(){ var v = document.querySelector('video'); if (v && v.paused && v.currentTime > 0) { v.currentTime = v.currentTime; } })();"
		self.webView.evaluateJavaScript(script, in: embedFrameInfo, in: .page, completionHandler: nil)
	}

	/// Stops playback and releases the page.
	func teardown() {
		for visibilityObserver in self.visibilityObservers {
			NotificationCenter.default.removeObserver(visibilityObserver)
		}
		self.visibilityObservers = []

		self.detach()
		(self.videoView ?? self.webView).removeFromSuperview()
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

	/// Reveals the web view after a delay, once the video is genuinely playing.
	private func scheduleRevealFallback() {
		guard !self.hasRevealed else { return }
		self.revealTask?.cancel()
		self.revealTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			guard !Task.isCancelled, let self = self, self.host != nil, self.isPlayerReady, !self.hasRevealed else { return }

			let state = try? await self.webView.evaluateJavaScript("player && player.getPlayerState ? player.getPlayerState() : -1")
			guard (state as? Int) == 1 else { return }

			self.reveal()
		}
	}

	/// Fades the web view in.
	private func reveal() {
		self.revealTask?.cancel()
		self.revealTask = nil
		self.hasRevealed = true

		let revealingView: UIView = self.videoView ?? self.webView

		UIView.animate(withDuration: 0.4) {
			revealingView.alpha = 1.0
		}

		self.delegate?.trailerWebPlayerDidRevealPicture(self)
	}

	/// Evaluates the given JavaScript in the web view.
	///
	/// - Parameter script: The script to run.
	private func evaluate(_ script: String) {
		self.webView.evaluateJavaScript(script, completionHandler: nil)
	}

	/// Works out the trailer's frame rate from one decoded-frame reading.
	///
	/// - Parameters:
	///    - decodedFrames: The frames decoded so far.
	///    - mediaTime: The seconds played so far.
	private func estimateFramesPerSecond(decodedFrames: Int, mediaTime: Double) {
		guard self.framesPerSecond == nil, mediaTime > 2.0, decodedFrames > 0 else { return }

		let estimate = (Double(decodedFrames) / mediaTime).rounded()
		guard estimate >= 10.0, estimate <= 120.0 else { return }

		self.framesPerSecond = estimate
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
			self.pausedFrameView?.hideFrame()
			self.isPaused = false
			self.collectQualityLevelsIfNeeded()

			// Looping restores the adaptive stream; the held level goes back on.
			if self.preferredQualityLevel != "auto" {
				self.pinPreferredStream()
			}

			self.delegate?.trailerWebPlayerDidStartPlaying(self)
		case "paused":
			self.capturePausedFrame()
			self.delegate?.trailerWebPlayerDidPause(self)
		case "pausedSeekSettled":
			self.capturePausedFrame()
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
		// Without Safari's own tokens, the embed withholds its adaptive streams and caps out at 360p.
		#if targetEnvironment(macCatalyst)
		configuration.applicationNameForUserAgent = "Version/26.0 Safari/605.1.15"
		#else
		configuration.applicationNameForUserAgent = "Version/26.0 Mobile/15E148 Safari/604.1"
		#endif
		configuration.allowsInlineMediaPlayback = true
		configuration.mediaTypesRequiringUserActionForPlayback = []
		configuration.allowsPictureInPictureMediaPlayback = true
		configuration.allowsAirPlayForMediaPlayback = true
		configuration.userContentController = userContentController
		configuration.websiteDataStore = .nonPersistent()

		#if targetEnvironment(macCatalyst)
		Self.keepRenderingWhileHidden(configuration)
		#endif

		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.isOpaque = false
		webView.backgroundColor = .clear
		webView.scrollView.backgroundColor = .clear
		webView.scrollView.isScrollEnabled = false
		webView.scrollView.contentInsetAdjustmentBehavior = .never
		webView.isUserInteractionEnabled = false
		return webView
	}

	#if targetEnvironment(macCatalyst)
	/// Keeps the page rendering while its window is out of sight.
	///
	/// - Parameter configuration: The configuration of the web view to keep rendering.
	private static func keepRenderingWhileHidden(_ configuration: WKWebViewConfiguration) {
		let preferences = configuration.preferences

		if #available(iOS 17.0, macCatalyst 17.0, *) {
			preferences.inactiveSchedulingPolicy = .none
		}

		let prioritySelector = NSSelectorFromString(#obfuscated("_setAlwaysRunsAtForegroundPriority:"))
		if configuration.responds(to: prioritySelector) {
			typealias PrioritySetter = @convention(c) (NSObject, Selector, Bool) -> Void
			let setPriority = unsafeBitCast(configuration.method(for: prioritySelector), to: PrioritySetter.self)
			setPriority(configuration, prioritySelector, true)
		}

		let featuresSelector = NSSelectorFromString(#obfuscated("_features"))
		let setEnabledSelector = NSSelectorFromString(#obfuscated("_setEnabled:forFeature:"))

		guard
			let preferencesClass = NSClassFromString("WKPreferences") as? NSObject.Type,
			preferencesClass.responds(to: featuresSelector),
			preferences.responds(to: setEnabledSelector),
			let features = preferencesClass.perform(featuresSelector)?.takeUnretainedValue() as? [NSObject]
		else {
			print("----- [Trailer] WebKit's feature list is out of reach; the trailer may suspend off screen")
			return
		}

		typealias FeatureSetter = @convention(c) (NSObject, Selector, Bool, NSObject) -> Void
		let setEnabled = unsafeBitCast(preferences.method(for: setEnabledSelector), to: FeatureSetter.self)

		let featureStates: [String: Bool] = [
			"PageVisibilityBasedProcessSuppressionEnabled": false,
			"HiddenPageDOMTimerThrottlingEnabled": false,
			"HiddenPageDOMTimerThrottlingAutoIncreases": false,
			"HiddenPageCSSAnimationSuspensionEnabled": false,
			"ShouldDropNearSuspendedAssertionAfterDelay": false
		]

		var missingKeys = Set(featureStates.keys)
		for feature in features {
			guard let key = feature.value(forKey: "key") as? String, let isEnabled = featureStates[key] else { continue }
			setEnabled(preferences, setEnabledSelector, isEnabled, feature)
			missingKeys.remove(key)
		}

		if !missingKeys.isEmpty {
			print("----- [Trailer] WebKit features out of reach: \(missingKeys.sorted())")
		}
	}
	#endif

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
		  html, body { width: 100%; height: 100%; background: transparent; overflow: hidden; -webkit-user-select: none; -webkit-touch-callout: none; }
		  #player { width: 100%; height: 100%; border: 0; }
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
		  function postProgress() {
		    if (!player || !player.getCurrentTime || !player.getDuration) { return; }
		    var duration = player.getDuration();
		    if (!isFinite(duration) || duration <= 0) { return; }
		    try {
		      window.webkit.messageHandlers.trailer.postMessage({ event: 'progress', currentTime: player.getCurrentTime(), duration: duration });
		    } catch (error) {}
		  }
		  setInterval(postProgress, 250);
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
		        cc_load_policy: 0,
		        color: 'white',
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

		if event == "frameReady" {
			let frameInfo = message.frameInfo

			MainActor.assumeIsolated {
				self.embedFrameInfo = frameInfo
			}
			return
		}

		if event == "pressTarget" {
			print("----- [Trailer] Press target clicked: \(body["name"] as? String ?? "unknown") via \(body["path"] as? String ?? "unknown")")
			return
		}

		if event == "pictureInPictureError" {
			print("----- [Trailer] Picture in picture refused: \(body["message"] as? String ?? "unknown")")
			return
		}

		if event == "pictureInPictureState" {
			print("----- [Trailer] Picture in picture asked for \(body["requested"] as? String ?? "unknown"), now \(body["mode"] as? String ?? "unknown")")
			return
		}

		if event == "progress" {
			guard let currentTime = body["currentTime"] as? Double, let duration = body["duration"] as? Double else { return }

			MainActor.assumeIsolated {
				self.delegate?.trailerWebPlayer(self, didPlayTo: currentTime, duration: duration)
			}
			return
		}

		if event == "frames" {
			guard let decodedFrames = body["decodedFrames"] as? Int, let mediaTime = body["mediaTime"] as? Double else { return }

			MainActor.assumeIsolated {
				self.estimateFramesPerSecond(decodedFrames: decodedFrames, mediaTime: mediaTime)
			}
			return
		}

		MainActor.assumeIsolated {
			self.handle(event: event)
		}
	}
}
