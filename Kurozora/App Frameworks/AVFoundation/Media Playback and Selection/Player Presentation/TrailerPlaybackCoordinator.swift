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
	private let minimumVisibleFraction = 0.99

	/// The share of a view the reader started that must stay on screen for it to keep playing.
	private let minimumPinnedVisibleFraction = 0.5

	/// The view holding the play slot in the reading order.
	private weak var currentView: KTrailerPlayerView?

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
	private(set) var isFullscreenActive = false

	// MARK: - Initializers
	private init() {
		NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.setNeedsReevaluation()
			}
		}
	}

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
		TrailerNativePlayerView.closeFloatingWindow()
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

		if let pinnedView = self.pinnedView, self.visibleFraction(of: pinnedView) < self.minimumPinnedVisibleFraction {
			self.pinnedView = nil
		}

		let candidates = self.candidates()
		let ordered = self.orderedCandidates(among: candidates)
		let previousView = self.currentView
		var granted: [KTrailerPlayerView] = []

		if let pinnedView = self.pinnedView {
			granted.append(pinnedView)
		}

		if granted.count < self.maximumConcurrentPlayers {
			if let currentView = self.currentView, ordered.contains(where: { $0.view === currentView }) {
				granted.append(currentView)
			} else if let first = ordered.first?.view {
				self.currentView = first
				granted.append(first)
			}
		}

		if let previousView = previousView, !granted.isEmpty, !granted.contains(where: { $0 === previousView }) {
			previousView.rest()
		}

		self.apply(granted: granted, among: candidates)
	}

	/// Moves the play slot to the trailer after the given one in the reading order.
	///
	/// - Parameter view: The view whose trailer started over.
	func advance(after view: KTrailerPlayerView) {
		guard !self.isFullscreenActive, self.currentView === view || self.pinnedView === view else { return }

		if self.pinnedView === view {
			self.pinnedView = nil
		}

		let candidates = self.candidates()
		let ordered = self.orderedCandidates(among: candidates)
		guard ordered.count > 1, let index = ordered.firstIndex(where: { $0.view === view }) else {
			self.currentView = view
			return
		}

		let next = ordered[(index + 1) % ordered.count].view
		self.currentView = next
		view.rest()
		self.apply(granted: [next], among: candidates)
	}

	/// Lets only the given views play.
	///
	/// - Parameters:
	///    - granted: The views holding the play slot.
	///    - candidates: Every registered view.
	private func apply(granted: [KTrailerPlayerView], among candidates: [Candidate]) {
		for candidate in candidates {
			let view = candidate.view

			if granted.contains(where: { $0 === view }) {
				view.setPlaybackAllowed(true)
			} else if view.isPlaying || view.hostedWebPlayer?.isPaused == false {
				view.rest()
			} else {
				view.setPlaybackAllowed(false)
			}
		}
	}

	/// Returns every registered view with its place on screen.
	///
	/// - Returns: The candidates for the play slot.
	private func candidates() -> [Candidate] {
		return self.registrations
			.compactMap(\.view)
			.map { view in Candidate(view: view, visibleFraction: self.visibleFraction(of: view), frame: self.windowFrame(of: view)) }
	}

	/// Returns the candidates that may autoplay, in reading order.
	///
	/// - Parameter candidates: The candidates to order.
	///
	/// - Returns: The fully visible eligible candidates from top to bottom and leading to trailing.
	private func orderedCandidates(among candidates: [Candidate]) -> [Candidate] {
		return candidates
			.filter { $0.view !== self.pinnedView }
			.filter { $0.visibleFraction >= self.minimumVisibleFraction }
			.filter { $0.view.isEligibleForAutoplay && self.isUncovered($0.view) }
			.sorted { first, second in
				if abs(first.frame.minY - second.frame.minY) >= 1.0 {
					return first.frame.minY < second.frame.minY
				}

				let isRightToLeft = first.view.effectiveUserInterfaceLayoutDirection == .rightToLeft
				return isRightToLeft ? first.frame.maxX > second.frame.maxX : first.frame.minX < second.frame.minX
			}
	}

	/// Returns whether the given view's screen is the one showing in its navigation stack.
	///
	/// - Parameter view: The view to check.
	///
	/// - Returns: `false` when another screen was pushed over the view's screen.
	private func isUncovered(_ view: KTrailerPlayerView) -> Bool {
		guard let viewController = view.owningViewController, let topViewController = viewController.navigationController?.topViewController else { return true }

		var candidate: UIViewController? = viewController

		while let current = candidate {
			if current === topViewController {
				return true
			}

			candidate = current.parent
		}

		return false
	}

	/// Returns the share of the given view that is currently on screen.
	///
	/// - Parameter view: The view to measure.
	///
	/// - Returns: A value between `0` and `1`.
	private func visibleFraction(of view: UIView) -> Double {
		// A trailer in Picture in Picture is visible wherever its player sits.
		if let floatingPlayerView = TrailerNativePlayerView.floatingPlayerView, floatingPlayerView.isFloating, floatingPlayerView.isDescendant(of: view) {
			return 1.0
		}

		guard let window = view.window, !view.isHidden, view.alpha > 0.0 else { return 0.0 }

		let frame = view.convert(view.bounds, to: window)
		let area = frame.width * frame.height
		guard area > 0.0 else { return 0.0 }

		var clip = window.bounds

		for scrollView in self.enclosingScrollViews(of: view) {
			clip = clip.intersection(scrollView.convert(scrollView.bounds, to: window))
		}

		let visible = frame.intersection(clip)
		guard !visible.isNull else { return 0.0 }

		return (visible.width * visible.height) / area
	}

	/// Returns the given view's frame in its window.
	///
	/// - Parameter view: The view to measure.
	///
	/// - Returns: The frame in window coordinates.
	private func windowFrame(of view: UIView) -> CGRect {
		guard let window = view.window else { return .null }

		return view.convert(view.bounds, to: window)
	}

	/// Returns every scroll view the given view sits in, nearest first.
	///
	/// - Parameter view: The view to walk up from.
	///
	/// - Returns: The enclosing scroll views.
	private func enclosingScrollViews(of view: UIView) -> [UIScrollView] {
		var scrollViews: [UIScrollView] = []
		var superview = view.superview

		while let candidate = superview {
			if let scrollView = candidate as? UIScrollView {
				scrollViews.append(scrollView)
			}

			superview = candidate.superview
		}

		return scrollViews
	}

	/// Starts watching every scroll view the given view sits in.
	///
	/// - Parameter view: The view whose scroll views to watch.
	private func observeScrollView(enclosing view: KTrailerPlayerView) {
		for scrollView in self.enclosingScrollViews(of: view) {
			let identifier = ObjectIdentifier(scrollView)
			guard self.scrollObservations[identifier] == nil else { continue }

			self.scrollObservations[identifier] = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
				Task { @MainActor in
					self?.setNeedsReevaluation()
				}
			}
		}
	}

	/// Drops the observations of scroll views that no longer hold a registered view.
	private func pruneScrollObservations() {
		let live = Set(self.registrations
			.compactMap(\.view)
			.flatMap { self.enclosingScrollViews(of: $0) }
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

		/// The view's frame in its window.
		let frame: CGRect
	}
}
