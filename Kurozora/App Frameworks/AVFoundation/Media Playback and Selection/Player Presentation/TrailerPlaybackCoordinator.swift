//
//  TrailerPlaybackCoordinator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Grants the right to play to the trailer the user is most likely looking at.
@MainActor
final class TrailerPlaybackCoordinator {
	// MARK: - Properties
	/// The shared coordinator.
	static let shared = TrailerPlaybackCoordinator()

	/// The number of trailers allowed to play at the same time.
	private let maximumConcurrentPlayers = 1

	/// The share of a view that must be on screen before it may play.
	private let minimumVisibleFraction = 0.6

	/// The delay, in nanoseconds, before the play slot is granted.
	private let settleDelay: UInt64 = 200_000_000

	/// The registered trailer views.
	private var registrations: [Registration] = []

	/// The scroll-view observations.
	private var scrollObservations: [ObjectIdentifier: NSKeyValueObservation] = [:]

	/// The view the user asked to play.
	private weak var pinnedView: KTrailerPlayerView?

	/// The re-evaluation waiting for scrolling to settle.
	private var settleTask: Task<Void, Never>?

	/// A Boolean value indicating whether a trailer is playing fullscreen.
	private var isFullscreenActive = false

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Adds the given view to the views competing for the play slot.
	///
	/// - Parameter view: The view to consider.
	func register(_ view: KTrailerPlayerView) {
		if !self.registrations.contains(where: { $0.view === view }) {
			self.registrations.append(Registration(view: view))
		}

		self.observeScrollView(enclosing: view)
		self.setNeedsReevaluation()
	}

	/// Removes the given view from the views competing for the play slot.
	///
	/// - Parameter view: The view to drop.
	func unregister(_ view: KTrailerPlayerView) {
		self.registrations.removeAll { $0.view === view || $0.view == nil }

		if self.pinnedView === view {
			self.pinnedView = nil
		}

		self.setNeedsReevaluation()
	}

	/// Grants the play slot to the given view regardless of the autoplay policy.
	///
	/// - Parameter view: The view the user asked to play.
	func pin(_ view: KTrailerPlayerView) {
		self.pinnedView = view
		self.reevaluate()
	}

	/// Suspends inline playback while a trailer plays fullscreen.
	func beginFullscreen() {
		self.isFullscreenActive = true
		self.registrations.compactMap(\.view).forEach { $0.setPlaybackAllowed(false) }
	}

	/// Resumes inline playback after fullscreen ends.
	func endFullscreen() {
		self.isFullscreenActive = false
		self.setNeedsReevaluation()
	}

	/// Schedules a re-evaluation once scrolling settles.
	func setNeedsReevaluation() {
		self.settleTask?.cancel()
		self.settleTask = Task { [weak self] in
			try? await Task.sleep(nanoseconds: self?.settleDelay ?? 200_000_000)
			guard !Task.isCancelled else { return }
			self?.reevaluate()
		}
	}

	/// Grants the play slot to the most visible eligible views and revokes it from the rest.
	private func reevaluate() {
		guard !self.isFullscreenActive else { return }

		self.registrations.removeAll { $0.view == nil }
		self.pruneScrollObservations()

		if let pinnedView = self.pinnedView, self.visibleFraction(of: pinnedView) < self.minimumVisibleFraction {
			self.pinnedView = nil
		}

		let candidates = self.registrations
			.compactMap(\.view)
			.map { view in Candidate(view: view, visibleFraction: self.visibleFraction(of: view)) }

		var granted: [KTrailerPlayerView] = []

		if let pinnedView = self.pinnedView {
			granted.append(pinnedView)
		}

		let eligible = candidates
			.filter { $0.view !== self.pinnedView }
			.filter { $0.visibleFraction >= self.minimumVisibleFraction }
			.filter { $0.view.isEligibleForAutoplay }
			.sorted { $0.visibleFraction > $1.visibleFraction }

		for candidate in eligible where granted.count < self.maximumConcurrentPlayers {
			granted.append(candidate.view)
		}

		for candidate in candidates {
			candidate.view.setPlaybackAllowed(granted.contains { $0 === candidate.view })
		}
	}

	/// Returns the share of the given view that is currently on screen.
	///
	/// - Parameter view: The view to measure.
	///
	/// - Returns: A value between `0` and `1`.
	private func visibleFraction(of view: UIView) -> Double {
		guard let window = view.window, !view.isHidden, view.alpha > 0.0 else { return 0.0 }

		let frame = view.convert(view.bounds, to: window)
		let area = frame.width * frame.height
		guard area > 0.0 else { return 0.0 }

		var clip = window.bounds

		if let scrollView = self.enclosingScrollView(of: view) {
			clip = clip.intersection(scrollView.convert(scrollView.bounds, to: window))
		}

		let visible = frame.intersection(clip)
		guard !visible.isNull else { return 0.0 }

		return (visible.width * visible.height) / area
	}

	/// Returns the closest scroll view the given view sits in.
	///
	/// - Parameter view: The view to walk up from.
	///
	/// - Returns: The enclosing scroll view.
	private func enclosingScrollView(of view: UIView) -> UIScrollView? {
		var superview = view.superview

		while let candidate = superview {
			if let scrollView = candidate as? UIScrollView {
				return scrollView
			}

			superview = candidate.superview
		}

		return nil
	}

	/// Starts watching the scroll view the given view sits in.
	///
	/// - Parameter view: The view whose scroll view to watch.
	private func observeScrollView(enclosing view: KTrailerPlayerView) {
		guard let scrollView = self.enclosingScrollView(of: view) else { return }

		let identifier = ObjectIdentifier(scrollView)
		guard self.scrollObservations[identifier] == nil else { return }

		self.scrollObservations[identifier] = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
			MainActor.assumeIsolated {
				self?.setNeedsReevaluation()
			}
		}
	}

	/// Drops the observations of scroll views that no longer hold a registered view.
	private func pruneScrollObservations() {
		let live = Set(self.registrations
			.compactMap(\.view)
			.compactMap { self.enclosingScrollView(of: $0) }
			.map(ObjectIdentifier.init))

		self.scrollObservations = self.scrollObservations.filter { live.contains($0.key) }
	}
}

// MARK: - Registration
extension TrailerPlaybackCoordinator {
	/// A weak hold on a view competing for the play slot.
	private struct Registration {
		/// The registered view.
		weak var view: KTrailerPlayerView?
	}

	/// A view paired with the share of it that is on screen.
	private struct Candidate {
		/// The view being considered.
		let view: KTrailerPlayerView

		/// The share of the view that is on screen.
		let visibleFraction: Double
	}
}
