//
//  MiniPlayerWindowBridge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Obfuscation
import UIKit

/// A side of the screen the window can dock against.
@available(iOS 17.0, *)
enum DockEdge {
	/// The window is docked against the left edge, with its trailing sliver on screen.
	case left

	/// The window is docked against the right edge, with its leading sliver on screen.
	case right
}

/// Styles the MiniPlayer's AppKit window through the runtime.
@available(iOS 17.0, *)
final class MiniPlayerWindowBridge: NSObject {
	// MARK: - Properties
	/// The corner radius of the window shape.
	static let windowCornerRadius: CGFloat = 25.5

	/// The `NSFloatingWindowLevel` the window floats at while it stays above other apps.
	///
	/// Menus and Notification Center sit above this level.
	private let floatingWindowLevel = 3

	/// The `NSNormalWindowLevel` the window sits at once it no longer stays on top.
	private let normalWindowLevel = 0

	/// The `NSWindowCollectionBehavior` bits letting the window follow the user between Spaces
	/// and sit above another app's full screen window.
	///
	/// `canJoinAllSpaces` joins every Space, `stationary` holds the window's place while the
	/// Spaces slide past, `ignoresCycle` keeps it out of the window cycling order,
	/// `fullScreenAuxiliary` lets it share a Space with a full screen window, and
	/// `disallowsTiling` refuses the offer to fill half the screen at an edge.
	private let allSpacesCollectionBehavior: UInt = (1 << 0) | (1 << 4) | (1 << 6) | (1 << 8) | (1 << 12)

	/// The `NSWindowCollectionBehaviorManaged` bit AppKit gives an ordinary window, with tiling
	/// refused.
	private let managedCollectionBehavior: UInt = (1 << 2) | (1 << 12)

	/// The `NSWindowStyleMaskFullSizeContentView` bit.
	private let fullSizeContentViewMask: UInt = 1 << 15

	/// The identifiers of the close, miniaturize, and zoom buttons, matching `NSWindow.ButtonType`.
	private let standardButtonTypes = [0, 1, 2]

	/// The `NSEventTypeLeftMouseDown` identifier.
	private let leftMouseDownEventType: UInt = 1

	/// The `NSEventTypeLeftMouseUp` identifier.
	private let leftMouseUpEventType: UInt = 2

	/// The `NSEventTypeLeftMouseDragged` identifier.
	private let leftMouseDraggedEventType: UInt = 6

	/// The `NSEventTypeScrollWheel` identifier.
	private let scrollWheelEventType: UInt = 22

	/// The event identifiers that count as pointer activity, matching `NSEventType`.
	///
	/// The rerouted `sendEvent:` outlives every instance, so it reads these from the type.
	private static let pointerEventTypes: Set<UInt> = [1, 2, 5, 6, 22]

	/// The user defaults key AppKit stores the autosaved frame under.
	private let frameAutosaveDefaultsKey = "NSWindow Frame MiniPlayer"

	/// How long the window may sit still before a frame hanging off screen is corrected.
	private let frameSettleDelay: TimeInterval = 0.35

	/// How close the pointer has to come to a side edge of the screen before the window commits to
	/// docking there.
	private let dockPointerThreshold: CGFloat = 32

	/// How close the pointer has to come to the edge it picked the window up beside before that
	/// edge counts.
	private let grabbedEdgePointerThreshold: CGFloat = 1

	/// How close the pointer has to come to a side edge before the window begins veiling.
	///
	/// The veil is complete where docking commits.
	private let veilPointerStart: CGFloat = 96

	/// How far the pull tab reaches out of the window body, and so how much of the window is left
	/// on screen once it docks.
	static var dockedTabWidth: CGFloat {
		return MiniPlayerViewController.dockTabReach
	}

	/// How fast the window has to be travelling at an edge to park on a flick alone.
	private let flickVelocity: CGFloat = 900

	/// How stale a pair of drag samples may be before the velocity between them is meaningless.
	private let flickSampleWindow: CFTimeInterval = 0.1

	/// How long the window takes to settle into place, in seconds.
	private let settleResponse: CGFloat = 0.34

	/// How much the window overshoots on its way into place, where `1` overshoots not at all.
	private let settleDampingRatio: CGFloat = 0.86

	/// The distance and speed at which the window is close enough to be placed outright.
	private let settleTolerance: CGFloat = 0.5

	/// How long the window may be carried before it is placed outright.
	private let settleTimeout: CGFloat = 1.5

	/// The most recent sample of where the window was and when.
	private var latestDragSample: (origin: CGPoint, timestamp: CFTimeInterval)?

	/// The sample before ``latestDragSample``, giving the pair a velocity.
	private var previousDragSample: (origin: CGPoint, timestamp: CFTimeInterval)?

	/// The display link carrying the window into place.
	private var settleDisplayLink: CADisplayLink?

	/// Where the window is being carried.
	private var settleTarget: CGPoint = .zero

	/// Where the window has been carried so far.
	///
	/// The window rounds the positions it is given, so the spring advances a place of its own.
	private var settleOrigin: CGPoint = .zero

	/// How fast the window is travelling as it is carried into place.
	private var settleVelocity: CGPoint = .zero

	/// How long the window has been carried.
	private var settleElapsed: CGFloat = 0

	/// The pending correction of a frame left hanging off screen.
	private var frameSettleWorkItem: DispatchWorkItem?

	/// Whether a frame change is the bridge's own, so it does not read as the user dragging.
	private var isAdjustingFrame = false

	/// The window's frame when the pointer went down, used to tell a click from a drag.
	private var pointerDownFrame: CGRect?

	/// Where inside the window the pointer took hold of it, held for as long as the drag lasts.
	private var dragGrabOffset: CGPoint?

	/// The edge the pointer already stood within reach of when the drag began, which counts only
	/// once the pointer reaches it.
	private var grabbedNearEdge: DockEdge?

	/// The edge the pointer is currently holding the window against.
	private var armedEdge: DockEdge?

	/// The side edge the window is docked against.
	private(set) var dockedEdge: DockEdge?

	/// Called as the pointer carries the window toward a side edge, with the edge and how far the
	/// veil has come in.
	var onEdgeOverflowChange: ((DockEdge?, CGFloat) -> Void)?

	/// The window's behind-window material, which carries its shape and shadow.
	private var behindWindowMaterialView: NSObject?

	/// The pending recompute of the window's shadow.
	private var shadowInvalidationWorkItem: DispatchWorkItem?

	/// Called as the pointer reaches or leaves a side edge of the screen, with the edge the window
	/// would dock against were it let go.
	var onDockArmChange: ((DockEdge?) -> Void)?

	/// Called when the window docks against a side edge or comes back on screen.
	var onDockedEdgeChange: ((DockEdge?) -> Void)?

	/// The close button's center, in points from the window's top-leading corner.
	private let trafficLightCenter = CGPoint(x: 25.5, y: 25.5)

	/// The center-to-center spacing of the traffic lights.
	private let trafficLightSpacing: CGFloat = 20

	/// Called when the user starts a live window resize.
	var onLiveResizeStart: (() -> Void)?

	/// Called when the user finishes a live window resize.
	var onLiveResizeEnd: (() -> Void)?

	/// Called when the pointer enters or exits the window.
	var onHoverChange: ((Bool) -> Void)?

	/// Called for every scroll wheel event the window receives, before AppKit dispatches it.
	///
	/// The location is in the window's bottom-left based coordinates. Return `true` to consume it.
	var onScrollWheel: ((_ locationInWindow: CGPoint, _ deltaY: CGFloat) -> Bool)?

	/// Called to ask whether a press at the given point drags the window.
	///
	/// The location is in the window's bottom-left based coordinates.
	var shouldDragWindow: ((_ locationInWindow: CGPoint) -> Bool)?

	/// Called whenever the pointer moves, presses, or scrolls anywhere in the window.
	var onPointerActivity: (() -> Void)?

	/// Whether a press is currently being held anywhere in the window.
	private(set) var isPointerDown = false

	/// The key equivalents to stamp onto bridged menu items, keyed by title.
	private var menuShortcuts: [String: (key: String, modifiers: UInt)] = [:]

	/// Whether menu tracking is already being observed.
	private var isObservingMenus = false

	/// Whether an autosaved frame existed and was restored on attach.
	private(set) var hasRestoredFrame = false

	/// The AppKit window backing the MiniPlayer scene.
	private weak var appKitWindow: NSObject?

	/// A Boolean value that indicates whether the AppKit window has been resolved.
	var isAttached: Bool {
		return self.appKitWindow != nil
	}

	/// A Boolean value that indicates whether the user is live-resizing the window.
	var isInLiveResize: Bool {
		return (self.appKitWindow?.value(forKey: "inLiveResize") as? Bool) ?? false
	}

	/// A Boolean value that indicates whether the pointer currently lies inside the window.
	var isPointerInsideWindow: Bool {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue,
			let eventClass = NSClassFromString("NSEvent"),
			let locationMethod = class_getClassMethod(eventClass, NSSelectorFromString("mouseLocation"))
		else { return false }

		typealias MouseLocationFunction = @convention(c) (AnyClass, Selector) -> CGPoint
		let location = unsafeBitCast(method_getImplementation(locationMethod), to: MouseLocationFunction.self)(eventClass, NSSelectorFromString("mouseLocation"))
		return frameValue.cgRectValue.contains(location)
	}

	/// The associated object key the event relay is stored under.
	private static var eventRelayKey: UInt8 = 0

	/// Whether `sendEvent:` has been rerouted for this process.
	private static var didInterceptSendEvent = false

	// MARK: - Initializers
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Functions
	/// Styles the AppKit window backing the given window.
	///
	/// - Parameter window: The window hosted by the MiniPlayer scene.
	func attach(to window: UIWindow?) {
		guard self.appKitWindow == nil, let window = window else { return }
		guard let appKitWindow = Self.resolveAppKitWindow(for: window) else { return }

		self.appKitWindow = appKitWindow

		if let styleMask = appKitWindow.value(forKey: "styleMask") as? UInt {
			appKitWindow.setValue(styleMask | self.fullSizeContentViewMask, forKey: "styleMask")
		}
		appKitWindow.setValue(true, forKey: "titlebarAppearsTransparent")

		// A transparent window would otherwise drag by its body.
		appKitWindow.setValue(false, forKey: "movableByWindowBackground")

		// Windows drop mouse-moved events by default.
		appKitWindow.setValue(true, forKey: "acceptsMouseMovedEvents")

		// The material installed below carries the shape and shadow.
		appKitWindow.setValue(false, forKey: "opaque")
		if let colorClass = NSClassFromString("NSColor") as? NSObject.Type,
		   let clearColor = colorClass.perform(NSSelectorFromString("clearColor"))?.takeUnretainedValue() {
			appKitWindow.setValue(clearColor, forKey: "backgroundColor")
		}
		self.installBehindWindowMaterial(in: appKitWindow)

		self.hasRestoredFrame = UserDefaults.standard.object(forKey: self.frameAutosaveDefaultsKey) != nil
		appKitWindow.perform(NSSelectorFromString("setFrameAutosaveName:"), with: "MiniPlayer" as NSString)

		self.applyWindowBehavior()

		self.installHoverTracking(in: appKitWindow)
		self.neutralizeTitlebarHitTesting(in: appKitWindow)
		self.installFirstMouseAcceptance(in: appKitWindow)
		self.installEventIntercept(on: appKitWindow)

		self.setTrafficLightsHidden(true)
		self.applyTrafficLightPosition()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
			self?.applyTrafficLightPosition()
		}

		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidMove(_:)), name: Notification.Name("NSWindowDidMoveNotification"), object: appKitWindow)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowWillStartLiveResize(_:)), name: Notification.Name("NSWindowWillStartLiveResizeNotification"), object: appKitWindow)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidEndLiveResize(_:)), name: Notification.Name("NSWindowDidEndLiveResizeNotification"), object: appKitWindow)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidResize(_:)), name: Notification.Name("NSWindowDidResizeNotification"), object: appKitWindow)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidResize(_:)), name: Notification.Name("NSWindowDidBecomeKeyNotification"), object: appKitWindow)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidResize(_:)), name: Notification.Name("NSWindowDidResignKeyNotification"), object: appKitWindow)
	}

	/// Whether the window is on screen and on the Space the user is looking at.
	var isVisibleOnActiveSpace: Bool {
		guard let appKitWindow = self.appKitWindow else { return false }

		let isVisible = appKitWindow.value(forKey: "isVisible") as? Bool ?? false
		let isOnActiveSpace = appKitWindow.value(forKey: "isOnActiveSpace") as? Bool ?? false

		return isVisible && isOnActiveSpace
	}

	/// Applies the user's floating and Spaces preferences to the window.
	///
	/// A window that does not float above other apps cannot usefully follow the user between
	/// Spaces, so the all Spaces behavior waits on the on-top preference.
	func applyWindowBehavior() {
		guard let appKitWindow = self.appKitWindow else { return }

		let staysOnTop = UserSettings.miniPlayerStaysOnTop
		let followsSpaces = staysOnTop && UserSettings.miniPlayerShowsOnAllSpaces

		appKitWindow.setValue(staysOnTop ? self.floatingWindowLevel : self.normalWindowLevel, forKey: "level")
		appKitWindow.setValue(followsSpaces ? self.allSpacesCollectionBehavior : self.managedCollectionBehavior, forKey: "collectionBehavior")
	}

	/// Resizes the window, keeping its top edge fixed.
	///
	/// A window growing past the bottom of the screen slides up by just enough to fit, so the
	/// lyrics pane always opens somewhere the user can see it.
	///
	/// - Parameters:
	///    - size: The size to apply.
	///    - animated: Whether the window animates to the new frame.
	func setWindowSize(_ size: CGSize, animated: Bool) {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else { return }

		// AppKit frames are bottom-left based, so the origin shifts to keep the top edge in place.
		var frame = frameValue.cgRectValue
		frame.origin.y += frame.height - size.height
		frame.size = size

		self.setWindowFrame(self.frameWithinScreen(frame), animated: animated)
	}

	/// Applies a frame to the window.
	///
	/// - Parameters:
	///    - frame: The frame to apply, in AppKit's bottom-left based coordinates.
	///    - animated: Whether the window animates to the new frame.
	private func setWindowFrame(_ frame: CGRect, animated: Bool) {
		guard let appKitWindow = self.appKitWindow else { return }

		let selector = NSSelectorFromString("setFrame:display:animate:")
		guard appKitWindow.responds(to: selector), let method = appKitWindow.method(for: selector) else { return }

		self.isAdjustingFrame = true
		defer { self.isAdjustingFrame = false }

		typealias SetFrameFunction = @convention(c) (NSObject, Selector, CGRect, Bool, Bool) -> Void
		unsafeBitCast(method, to: SetFrameFunction.self)(appKitWindow, selector, frame, true, animated)
	}

	/// The usable bounds of the screen the window sits on, excluding the menu bar and Dock.
	private var screenVisibleFrame: CGRect? {
		guard
			let appKitWindow = self.appKitWindow,
			let screen = appKitWindow.value(forKey: "screen") as? NSObject,
			let visibleFrame = screen.value(forKey: "visibleFrame") as? NSValue
		else { return nil }

		return visibleFrame.cgRectValue
	}

	/// Pulls a frame back inside the screen it sits on.
	///
	/// - Parameter frame: The frame to correct.
	///
	/// - Returns: The frame, moved the shortest distance that puts it fully on screen.
	private func frameWithinScreen(_ frame: CGRect) -> CGRect {
		guard let visibleFrame = self.screenVisibleFrame else { return frame }

		// A parked window is meant to hang off the edge, so its place on screen is its parked one.
		if let edge = self.dockedEdge {
			return Self.dockedFrame(for: edge, frame: frame, in: visibleFrame)
		}

		var origin = frame.origin

		// A window wider or taller than the screen pins to the top-leading corner rather than
		// inverting, so the lower bound wins each clamp.
		origin.x = min(max(origin.x, visibleFrame.minX), max(visibleFrame.maxX - frame.width, visibleFrame.minX))
		origin.y = min(max(origin.y, visibleFrame.minY), max(visibleFrame.maxY - frame.height, visibleFrame.minY))

		return CGRect(origin: origin, size: frame.size)
	}

	/// Settles the window once it comes to rest, either docking it against a side edge or
	/// sliding it fully back on screen.
	private func settleFrameWithinScreen() {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue,
			let visibleFrame = self.screenVisibleFrame
		else { return }

		let frame = frameValue.cgRectValue

		// The pointer reaching the edge parks the window, and so does a flick toward one.
		if let armed = self.armedEdge {
			// The tab is already out and stays out, so it is forgotten without retracting.
			self.armedEdge = nil
			self.grabbedNearEdge = nil
			self.dock(to: armed, frame: frame, in: visibleFrame)
			return
		}

		if let overflow = Self.horizontalOverflow(for: frame, in: visibleFrame) {
			let velocity = self.dragVelocity.x
			let flickedOut = (overflow.edge == .left && velocity <= -self.flickVelocity)
				|| (overflow.edge == .right && velocity >= self.flickVelocity)

			if flickedOut {
				self.grabbedNearEdge = nil
				self.dock(to: overflow.edge, frame: frame, in: visibleFrame)
				return
			}
		}

		// A window resting where docking put it has already settled; only one dragged off its
		// parked place is asking to come back on screen.
		if let edge = self.dockedEdge {
			guard frame.origin != Self.dockedFrame(for: edge, frame: frame, in: visibleFrame).origin else { return }
		}

		self.clearDockArm()
		self.setDockedEdge(nil)
		self.onEdgeOverflowChange?(nil, 0)

		let corrected = self.frameWithinScreen(frame)
		guard corrected.origin != frame.origin else { return }
		self.animateWindowOrigin(to: corrected.origin)
	}

	/// Forgets the edge the pointer was holding the window against.
	private func clearDockArm() {
		self.grabbedNearEdge = nil

		guard self.armedEdge != nil else { return }
		self.armedEdge = nil
		self.onDockArmChange?(nil)
	}

	/// How far the window has cleared the nearest side edge.
	///
	/// - Parameters:
	///    - frame: The window's frame.
	///    - visibleFrame: The usable bounds of the screen.
	///
	/// - Returns: The edge being crossed and the fraction of the window past it.
	private static func horizontalOverflow(for frame: CGRect, in visibleFrame: CGRect) -> (edge: DockEdge, fraction: CGFloat)? {
		guard frame.width > 0 else { return nil }

		let leftOverflow = visibleFrame.minX - frame.minX
		let rightOverflow = frame.maxX - visibleFrame.maxX

		if leftOverflow > 0, leftOverflow >= rightOverflow {
			return (.left, min(leftOverflow / frame.width, 1))
		}

		if rightOverflow > 0 {
			return (.right, min(rightOverflow / frame.width, 1))
		}

		return nil
	}

	/// Parks the window against a side edge, leaving a tab on screen to pull it back by.
	///
	/// - Parameters:
	///    - edge: The edge to dock against.
	///    - frame: The window's current frame.
	///    - visibleFrame: The usable bounds of the screen.
	private func dock(to edge: DockEdge, frame: CGRect, in visibleFrame: CGRect) {
		// Parking is the last word on where the window goes, ahead of any pending correction.
		self.frameSettleWorkItem?.cancel()
		self.frameSettleWorkItem = nil

		let target = Self.dockedFrame(for: edge, frame: frame, in: visibleFrame)

		self.setDockedEdge(edge)
		self.onEdgeOverflowChange?(edge, 1)
		self.animateWindowOrigin(to: target.origin)
	}

	/// Where a window rests once parked against a side edge.
	///
	/// - Parameters:
	///    - edge: The edge the window is parked against.
	///    - frame: The window's frame.
	///    - visibleFrame: The usable bounds of the screen.
	///
	/// - Returns: The frame leaving nothing but the pull tab on screen.
	private static func dockedFrame(for edge: DockEdge, frame: CGRect, in visibleFrame: CGRect) -> CGRect {
		// The body parks fully off screen and the tab is what stays behind.
		let visible = MiniPlayerViewController.dockedVisibleWidth
		var target = frame

		switch edge {
		case .left:
			target.origin.x = visibleFrame.minX - (frame.width - visible)
		case .right:
			target.origin.x = visibleFrame.maxX - visible
		}
		target.origin.y = min(max(target.origin.y, visibleFrame.minY), max(visibleFrame.maxY - target.height, visibleFrame.minY))

		return target
	}

	/// Shapes the window's material to the player's silhouette.
	///
	/// The material draws the window's border and casts its shadow, so the silhouette is cut out of
	/// it. The shape is vertically symmetric, so the same path serves AppKit's flipped geometry.
	///
	/// - Parameters:
	///    - path: The player's outline, in the window's coordinates.
	///    - duration: How long the change takes.
	func setSilhouette(_ path: CGPath, duration: TimeInterval) {
		guard
			let materialView = self.behindWindowMaterialView,
			let layer = materialView.value(forKey: "layer") as? CALayer
		else { return }

		let shape = (layer.mask as? CAShapeLayer) ?? CAShapeLayer()
		shape.fillRule = .nonZero
		shape.frame = layer.bounds
		layer.mask = shape

		Self.setSilhouette(path, in: shape, duration: duration)
		self.invalidateShadow(after: duration)
	}

	/// Recomputes the window's shadow once its shape has settled.
	///
	/// The shadow is derived from what the window draws, so it can only be recomputed after the new
	/// shape reaches the screen.
	///
	/// - Parameter delay: How long the shape takes to settle.
	private func invalidateShadow(after delay: TimeInterval) {
		self.shadowInvalidationWorkItem?.cancel()

		let workItem = DispatchWorkItem { [weak self] in
			self?.appKitWindow?.perform(NSSelectorFromString("invalidateShadow"))
		}
		self.shadowInvalidationWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
	}

	/// Draws a silhouette in a shape layer, growing out of the shape it already draws.
	///
	/// A layer standing outside a view takes no part in a view animation, so the change is animated
	/// in its own right.
	///
	/// - Parameters:
	///    - path: The outline to draw.
	///    - layer: The layer drawing it.
	///    - duration: How long the change takes.
	static func setSilhouette(_ path: CGPath, in layer: CAShapeLayer, duration: TimeInterval) {
		// A change in flight continues from where it stands, anything else from the layer's own
		// shape, which the render tree may not have caught up with.
		let inFlight = layer.animation(forKey: "path") != nil
		let current = inFlight ? layer.presentation()?.path ?? layer.path : layer.path

		guard duration > 0, let current = current, current != path else {
			layer.removeAnimation(forKey: "path")
			layer.path = path
			return
		}

		let animation = CABasicAnimation(keyPath: "path")
		animation.fromValue = current
		animation.toValue = path
		animation.duration = duration
		animation.timingFunction = CAMediaTimingFunction(name: .easeOut)

		layer.path = path
		layer.add(animation, forKey: "path")
	}

	/// Brings a docked window fully back on screen.
	///
	/// - Parameter animated: Whether the window animates back.
	func undock(animated: Bool) {
		guard
			self.dockedEdge != nil,
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else { return }

		self.clearDockArm()
		self.setDockedEdge(nil)
		self.onEdgeOverflowChange?(nil, 0)

		let frame = self.frameWithinScreen(frameValue.cgRectValue)

		guard animated else {
			self.setWindowFrame(frame, animated: false)
			return
		}
		self.animateWindowOrigin(to: frame.origin)
	}

	/// Records the docked edge and reports the change.
	///
	/// - Parameter edge: The edge the window is docked against.
	private func setDockedEdge(_ edge: DockEdge?) {
		guard self.dockedEdge != edge else { return }
		self.dockedEdge = edge
		self.onDockedEdgeChange?(edge)
	}


	/// Enables or disables dragging the window by its title bar and background.
	///
	/// - Parameter movable: Whether the window can be dragged.
	func setWindowMovable(_ movable: Bool) {
		self.appKitWindow?.setValue(movable, forKey: "movable")
	}

	/// Shows or hides the window's close, miniaturize, and zoom buttons.
	///
	/// - Parameter hidden: Whether the buttons are hidden.
	func setTrafficLightsHidden(_ hidden: Bool) {
		guard let appKitWindow = self.appKitWindow else { return }

		for buttonType in self.standardButtonTypes {
			self.standardWindowButton(buttonType, of: appKitWindow)?.setValue(hidden, forKey: "hidden")
		}

		if !hidden {
			self.applyTrafficLightPosition()
		}
	}

	/// Handles the start of a live window resize.
	@objc private func windowWillStartLiveResize(_ notification: Notification) {
		self.onLiveResizeStart?()
	}

	/// Handles the end of a live window resize.
	@objc private func windowDidEndLiveResize(_ notification: Notification) {
		self.onLiveResizeEnd?()
		self.settleFrameWithinScreen()
	}

	/// Handles the window coming to rest after a drag.
	///
	/// The move notification arrives continuously while dragging, so the correction waits for the
	/// window to stop rather than fighting the pointer.
	@objc private func windowDidMove(_ notification: Notification) {
		guard !self.isAdjustingFrame else { return }

		// A parked window only moves again when the user picks it up, so nothing else gets to
		// drag it back on screen.
		guard self.dockedEdge == nil || self.isPointerDown else { return }

		self.recordDragSample()
		self.scheduleFrameSettle()
	}

	/// Notes where the window is right now, so a flick can be told from a slow drag.
	private func recordDragSample() {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else { return }

		self.previousDragSample = self.latestDragSample
		self.latestDragSample = (origin: frameValue.cgRectValue.origin, timestamp: CACurrentMediaTime())
	}

	/// How fast the window is travelling, in points per second.
	private var dragVelocity: CGPoint {
		guard
			let latest = self.latestDragSample,
			let previous = self.previousDragSample
		else { return .zero }

		let elapsed = latest.timestamp - previous.timestamp
		guard
			elapsed > 0,
			elapsed < self.flickSampleWindow,
			CACurrentMediaTime() - latest.timestamp < self.flickSampleWindow
		else { return .zero }

		return CGPoint(
			x: (latest.origin.x - previous.origin.x) / elapsed,
			y: (latest.origin.y - previous.origin.y) / elapsed
		)
	}

	/// Carries the window to a resting place, keeping the speed it already had.
	///
	/// - Parameter target: The window's new bottom-left corner, in screen coordinates.
	private func animateWindowOrigin(to target: CGPoint) {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else { return }

		self.settleTarget = target
		guard self.settleDisplayLink == nil else { return }
		guard frameValue.cgRectValue.origin != target else { return }

		self.settleOrigin = frameValue.cgRectValue.origin
		self.settleVelocity = self.dragVelocity
		self.settleElapsed = 0

		let displayLink = CADisplayLink(target: self, selector: #selector(self.stepWindowSettle(_:)))
		displayLink.add(to: .main, forMode: .common)
		self.settleDisplayLink = displayLink
	}

	/// Advances the window one frame toward where it is being carried.
	@objc private func stepWindowSettle(_ displayLink: CADisplayLink) {
		guard self.appKitWindow != nil else {
			self.cancelWindowSettle()
			return
		}

		// A long frame would otherwise integrate into a leap.
		let step = CGFloat(min(displayLink.targetTimestamp - displayLink.timestamp, 1 / 30))
		let stiffness = pow(2 * .pi / self.settleResponse, 2)
		let damping = 4 * .pi * self.settleDampingRatio / self.settleResponse

		let displacement = CGPoint(x: self.settleOrigin.x - self.settleTarget.x, y: self.settleOrigin.y - self.settleTarget.y)

		self.settleVelocity.x += (-stiffness * displacement.x - damping * self.settleVelocity.x) * step
		self.settleVelocity.y += (-stiffness * displacement.y - damping * self.settleVelocity.y) * step
		self.settleOrigin.x += self.settleVelocity.x * step
		self.settleOrigin.y += self.settleVelocity.y * step
		self.settleElapsed += step

		// Arriving places the window outright, never short of the target.
		let arrived = abs(displacement.x) < self.settleTolerance && abs(displacement.y) < self.settleTolerance
			&& abs(self.settleVelocity.x) < self.settleTolerance && abs(self.settleVelocity.y) < self.settleTolerance
		let settled = arrived || self.settleElapsed >= self.settleTimeout

		self.isAdjustingFrame = true
		self.setWindowOrigin(settled ? self.settleTarget : self.settleOrigin)
		self.isAdjustingFrame = false

		guard settled else { return }
		self.cancelWindowSettle()
	}

	/// Stops carrying the window, leaving it where it is.
	private func cancelWindowSettle() {
		self.settleDisplayLink?.invalidate()
		self.settleDisplayLink = nil
		self.settleVelocity = .zero
	}

	/// Restarts the countdown to correcting the window's frame.
	private func scheduleFrameSettle() {
		self.frameSettleWorkItem?.cancel()

		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }

			guard !self.isPointerDown, !self.isInLiveResize else {
				self.scheduleFrameSettle()
				return
			}

			self.settleFrameWithinScreen()
		}
		self.frameSettleWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + self.frameSettleDelay, execute: workItem)
	}

	/// Handles a change to the window's frame or key state.
	@objc private func windowDidResize(_ notification: Notification) {
		self.applyTrafficLightPosition()
	}

	/// Repositions the traffic lights.
	func applyTrafficLightPosition() {
		guard let appKitWindow = self.appKitWindow else { return }

		for (index, buttonType) in self.standardButtonTypes.enumerated() {
			guard
				let button = self.standardWindowButton(buttonType, of: appKitWindow),
				let superview = button.value(forKey: "superview") as? NSObject,
				let superviewFrame = (superview.value(forKey: "frame") as? NSValue)?.cgRectValue,
				let buttonFrame = (button.value(forKey: "frame") as? NSValue)?.cgRectValue
			else { continue }

			var frame = buttonFrame
			frame.origin.x = MiniPlayerViewController.dockTabReach + self.trafficLightCenter.x + CGFloat(index) * self.trafficLightSpacing - frame.width / 2
			frame.origin.y = superviewFrame.height - self.trafficLightCenter.y - frame.height / 2
			button.setValue(NSValue(cgRect: frame), forKey: "frame")
		}
	}

	/// Limits the title bar to the traffic lights.
	///
	/// - Parameter window: The window carrying the title bar.
	private func neutralizeTitlebarHitTesting(in window: NSObject) {
		guard
			let contentView = window.value(forKey: "contentView") as? NSObject,
			let themeFrame = contentView.value(forKey: "superview") as? NSObject,
			let themeFrameSubviews = themeFrame.value(forKey: "subviews") as? [NSObject],
			let containerView = themeFrameSubviews.first(where: { String(describing: type(of: $0)).contains("NSTitlebarContainerView") })
		else {
			print("----- MiniPlayer: titlebar container not found; chrome row clicks stay blocked.")
			return
		}

		let subclassName = "KZMiniPlayerTitlebarContainerView"
		if let subclass = NSClassFromString(subclassName) {
			if object_getClass(containerView) != subclass {
				object_setClass(containerView, subclass)
			}
			return
		}

		guard
			let baseClass = object_getClass(containerView),
			let buttonClass = NSClassFromString("NSButton")
		else { return }

		let hitTestSelector = NSSelectorFromString("hitTest:")
		guard
			let hitTestMethod = class_getInstanceMethod(baseClass, hitTestSelector),
			let subclass = objc_allocateClassPair(baseClass, subclassName, 0)
		else { return }

		typealias HitTestFunction = @convention(c) (NSObject, Selector, CGPoint) -> NSObject?
		let baseHitTest = unsafeBitCast(method_getImplementation(hitTestMethod), to: HitTestFunction.self)

		let hitTestOverride: @convention(block) (NSObject, CGPoint) -> NSObject? = { receiver, point in
			guard let hitView = baseHitTest(receiver, hitTestSelector, point) else { return nil }

			var candidate: NSObject? = hitView
			while let view = candidate, view !== receiver {
				if view.isKind(of: buttonClass) {
					return hitView
				}
				candidate = view.value(forKey: "superview") as? NSObject
			}
			return nil
		}

		class_addMethod(subclass, hitTestSelector, imp_implementationWithBlock(hitTestOverride), method_getTypeEncoding(hitTestMethod))
		objc_registerClassPair(subclass)
		object_setClass(containerView, subclass)
		print("----- MiniPlayer: titlebar hit-testing neutralized.")
	}

	/// Lets the window's content respond to the first click while the window is inactive.
	///
	/// - Parameter window: The window whose content accepts the first click.
	private func installFirstMouseAcceptance(in window: NSObject) {
		guard
			let contentView = window.value(forKey: "contentView") as? NSObject,
			let contentSubviews = contentView.value(forKey: "subviews") as? [NSObject]
		else { return }

		let firstMouseSelector = NSSelectorFromString("acceptsFirstMouse:")
		let canMoveWindowSelector = NSSelectorFromString("mouseDownCanMoveWindow")

		for hostView in contentSubviews {
			guard let baseClass = object_getClass(hostView) else { continue }

			let baseClassName = NSStringFromClass(baseClass)
			if baseClassName.contains("VisualEffect") || baseClassName.hasPrefix("KZFirstMouse_") {
				continue
			}

			let subclassName = "KZFirstMouse_" + baseClassName
			if let subclass = NSClassFromString(subclassName) {
				object_setClass(hostView, subclass)
				continue
			}

			guard
				let firstMouseMethod = class_getInstanceMethod(baseClass, firstMouseSelector),
				let canMoveWindowMethod = class_getInstanceMethod(baseClass, canMoveWindowSelector),
				let subclass = objc_allocateClassPair(baseClass, subclassName, 0)
			else { continue }

			let firstMouseOverride: @convention(block) (NSObject, NSObject?) -> Bool = { _, _ in
				return true
			}
			class_addMethod(subclass, firstMouseSelector, imp_implementationWithBlock(firstMouseOverride), method_getTypeEncoding(firstMouseMethod))

			let canMoveWindowOverride: @convention(block) (NSObject) -> Bool = { _ in
				return false
			}
			class_addMethod(subclass, canMoveWindowSelector, imp_implementationWithBlock(canMoveWindowOverride), method_getTypeEncoding(canMoveWindowMethod))

			objc_registerClassPair(subclass)
			object_setClass(hostView, subclass)
			print("----- MiniPlayer: first-mouse acceptance installed on \(baseClassName).")
		}
	}

	/// Relays a window's events to the bridge that intercepted them.
	private final class WindowEventRelay {
		/// The closure invoked for each intercepted event.
		let handler: (_ event: NSObject, _ type: UInt) -> Bool

		init(handler: @escaping (_ event: NSObject, _ type: UInt) -> Bool) {
			self.handler = handler
		}
	}

	/// Intercepts scroll wheel and press events before view routing.
	///
	/// The method is rerouted on the window's class, never by re-classing the instance.
	///
	/// - Parameter window: The window to intercept.
	private func installEventIntercept(on window: NSObject) {
		let relay = WindowEventRelay { [weak self] event, type in
			guard let self = self else { return false }

			switch type {
			case self.leftMouseDownEventType:
				self.isPointerDown = true
				self.pointerDownFrame = (window.value(forKey: "frame") as? NSValue)?.cgRectValue
				self.latestDragSample = nil
				self.previousDragSample = nil
				self.cancelWindowSettle()
			case self.leftMouseUpEventType:
				self.isPointerDown = false
				self.dragGrabOffset = nil

				let startFrame = self.pointerDownFrame
				self.pointerDownFrame = nil

				// Releasing the window is the moment the user expects it to settle, so the
				// debounced pass is only a net for moves the pointer never touched.
				self.frameSettleWorkItem?.cancel()
				self.frameSettleWorkItem = nil
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }

					// A press that never moved the window is a click on the docked tab.
					let currentFrame = (self.appKitWindow?.value(forKey: "frame") as? NSValue)?.cgRectValue
					if self.dockedEdge != nil, let startFrame = startFrame, currentFrame == startFrame {
						self.undock(animated: true)
						return
					}

					self.settleFrameWithinScreen()
				}
			default:
				break
			}

			self.onPointerActivity?()

			if type == self.leftMouseDraggedEventType, let grabOffset = self.dragGrabOffset {
				self.dragWindow(with: event, grabOffset: grabOffset)
				return true
			}

			guard
				type == self.scrollWheelEventType || type == self.leftMouseDownEventType,
				let locationValue = event.value(forKey: "locationInWindow") as? NSValue
			else { return false }

			let location = locationValue.cgPointValue

			guard type == self.scrollWheelEventType else {
				guard
					self.shouldDragWindow?(location) == true,
					!self.pressLandsOnWindowButton(at: location)
				else { return false }
				return self.beginWindowDrag(with: event)
			}

			guard let onScrollWheel = self.onScrollWheel, let deltaY = event.value(forKey: "scrollingDeltaY") as? CGFloat else { return false }

			let hasPreciseDeltas = (event.value(forKey: "hasPreciseScrollingDeltas") as? Bool) ?? true
			return onScrollWheel(location, hasPreciseDeltas ? deltaY : deltaY * 10)
		}
		objc_setAssociatedObject(window, &Self.eventRelayKey, relay, .OBJC_ASSOCIATION_RETAIN)

		guard !Self.didInterceptSendEvent else { return }

		let sendEventSelector = NSSelectorFromString("sendEvent:")
		guard
			let windowClass = object_getClass(window),
			let sendEventMethod = class_getInstanceMethod(windowClass, sendEventSelector)
		else { return }

		typealias SendEventFunction = @convention(c) (NSObject, Selector, NSObject) -> Void
		let baseSendEvent = unsafeBitCast(method_getImplementation(sendEventMethod), to: SendEventFunction.self)

		let sendEventOverride: @convention(block) (NSObject, NSObject) -> Void = { receiver, event in
			if let type = event.value(forKey: "type") as? UInt,
			   MiniPlayerWindowBridge.pointerEventTypes.contains(type),
			   let relay = objc_getAssociatedObject(receiver, &MiniPlayerWindowBridge.eventRelayKey) as? WindowEventRelay,
			   relay.handler(event, type) {
				return
			}
			baseSendEvent(receiver, sendEventSelector, event)
		}
		method_setImplementation(sendEventMethod, imp_implementationWithBlock(sendEventOverride))
		Self.didInterceptSendEvent = true
	}

	/// Labels menu items with their keyboard shortcuts.
	///
	/// - Parameter shortcuts: The key and modifier mask for each item title.
	func setMenuShortcuts(_ shortcuts: [String: (key: String, modifiers: UInt)]) {
		self.menuShortcuts = shortcuts

		guard !self.isObservingMenus else { return }
		self.isObservingMenus = true
		NotificationCenter.default.addObserver(self, selector: #selector(self.menuDidBeginTracking(_:)), name: Notification.Name("NSMenuDidBeginTrackingNotification"), object: nil)
	}

	/// Labels a menu's items as it opens.
	@objc private func menuDidBeginTracking(_ notification: Notification) {
		guard
			let menu = notification.object as? NSObject,
			let items = menu.value(forKey: "itemArray") as? [NSObject]
		else { return }

		for item in items {
			guard
				let title = item.value(forKey: "title") as? String,
				let shortcut = self.menuShortcuts[title]
			else { continue }

			item.setValue(shortcut.key, forKey: "keyEquivalent")
			item.setValue(shortcut.modifiers, forKey: "keyEquivalentModifierMask")
		}
	}

	/// Takes the window's drag over from AppKit.
	///
	/// AppKit's own drag offers to tile the window against either side of the screen, claiming the
	/// gesture docking needs.
	///
	/// - Parameter event: The press that starts the drag.
	///
	/// - Returns: Whether the drag was started.
	private func beginWindowDrag(with event: NSObject) -> Bool {
		guard
			let appKitWindow = self.appKitWindow,
			// The press belongs to the content while a slider owns the pointer.
			(appKitWindow.value(forKey: "movable") as? Bool) ?? true,
			let locationValue = event.value(forKey: "locationInWindow") as? NSValue,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else { return false }

		// Taking hold of the window brings it forward, so no click is spent on focusing it first.
		if (appKitWindow.value(forKey: "keyWindow") as? Bool) != true {
			appKitWindow.perform(NSSelectorFromString("makeKeyAndOrderFront:"), with: nil)
		}

		let grabOffset = locationValue.cgPointValue
		let frame = frameValue.cgRectValue

		let pointer = CGPoint(x: frame.minX + grabOffset.x, y: frame.minY + grabOffset.y)
		let nearest = self.nearestEdge(to: pointer)

		self.dragGrabOffset = grabOffset

		// A parked window starts armed against its edge, so the ordinary threshold governs the way
		// back out.
		self.armedEdge = self.dockedEdge

		if self.dockedEdge == nil, let nearest = nearest, nearest.distance <= self.dockPointerThreshold {
			self.grabbedNearEdge = nearest.edge
		} else {
			self.grabbedNearEdge = nil
		}

		return true
	}

	/// Moves the window so the point it was taken hold of stays under the pointer.
	///
	/// - Parameters:
	///    - event: The drag carrying the pointer's new position.
	///    - grabOffset: Where inside the window the pointer took hold of it.
	private func dragWindow(with event: NSObject, grabOffset: CGPoint) {
		guard
			let appKitWindow = self.appKitWindow,
			let frameValue = appKitWindow.value(forKey: "frame") as? NSValue,
			let locationValue = event.value(forKey: "locationInWindow") as? NSValue
		else { return }

		// The window and the screen share an orientation, so the pointer's place on screen is its
		// place in the window offset by the window's own.
		let frame = frameValue.cgRectValue
		let location = locationValue.cgPointValue
		let origin = CGPoint(x: frame.minX + location.x - grabOffset.x, y: frame.minY + location.y - grabOffset.y)

		self.updateDockGesture(for: CGPoint(x: frame.minX + location.x, y: frame.minY + location.y))

		guard origin != frame.origin else { return }
		self.setWindowOrigin(origin)
	}

	/// Veils the window and commits to docking as the pointer nears a side edge of the screen.
	///
	/// - Parameter pointer: Where the pointer is on screen.
	private func updateDockGesture(for pointer: CGPoint) {
		guard let nearest = self.nearestEdge(to: pointer) else { return }

		let span = self.veilPointerStart - self.dockPointerThreshold
		let veil = min(max((self.veilPointerStart - nearest.distance) / span, 0), 1)
		self.onEdgeOverflowChange?(veil > 0 ? nearest.edge : nil, veil)

		// Once the pointer has carried the window clear of the edge it was picked up beside, that
		// edge behaves like any other again.
		if nearest.distance > self.dockPointerThreshold {
			self.grabbedNearEdge = nil
		}

		// The edge the window was picked up beside only arms once the pointer reaches it outright.
		let threshold = nearest.edge == self.grabbedNearEdge ? self.grabbedEdgePointerThreshold : self.dockPointerThreshold
		let armed = nearest.distance <= threshold ? nearest.edge : nil

		guard armed != self.armedEdge else { return }
		self.armedEdge = armed

		// A parked window carried back past the threshold is on its way onto the screen again.
		if armed == nil, self.dockedEdge != nil {
			self.setDockedEdge(nil)
			return
		}

		self.onDockArmChange?(armed)
	}

	/// The side edge of the screen the pointer stands nearest.
	///
	/// - Parameter pointer: Where the pointer is on screen.
	///
	/// - Returns: The nearest edge and how far the pointer is from it.
	private func nearestEdge(to pointer: CGPoint) -> (edge: DockEdge, distance: CGFloat)? {
		guard let visibleFrame = self.screenVisibleFrame else { return nil }

		let leftDistance = pointer.x - visibleFrame.minX
		let rightDistance = visibleFrame.maxX - pointer.x

		return leftDistance <= rightDistance ? (.left, leftDistance) : (.right, rightDistance)
	}

	/// Moves the window without resizing it.
	///
	/// - Parameter origin: The window's new bottom-left corner, in screen coordinates.
	private func setWindowOrigin(_ origin: CGPoint) {
		guard let appKitWindow = self.appKitWindow else { return }

		let selector = NSSelectorFromString("setFrameOrigin:")
		guard appKitWindow.responds(to: selector), let method = appKitWindow.method(for: selector) else { return }

		typealias SetOriginFunction = @convention(c) (NSObject, Selector, CGPoint) -> Void
		unsafeBitCast(method, to: SetOriginFunction.self)(appKitWindow, selector, origin)
	}

	/// Whether the given window point lands on one of the window's own buttons.
	///
	/// - Parameter locationInWindow: The point in the window's bottom-left based coordinates.
	///
	/// - Returns: Whether a window button takes the press.
	private func pressLandsOnWindowButton(at locationInWindow: CGPoint) -> Bool {
		guard
			let contentView = self.appKitWindow?.value(forKey: "contentView") as? NSObject,
			let frameView = contentView.value(forKey: "superview") as? NSObject,
			let buttonClass = NSClassFromString("NSButton")
		else { return false }

		let selector = NSSelectorFromString("hitTest:")
		guard frameView.responds(to: selector), let method = frameView.method(for: selector) else { return false }

		// The frame view spans the whole window, so its hit-testing space is the window's.
		typealias HitTestFunction = @convention(c) (NSObject, Selector, CGPoint) -> NSObject?
		var view = unsafeBitCast(method, to: HitTestFunction.self)(frameView, selector, locationInWindow)

		while let candidate = view {
			if candidate.isKind(of: buttonClass) {
				return true
			}
			view = candidate.value(forKey: "superview") as? NSObject
		}

		return false
	}

	/// Installs a tracking area reporting pointer entry and exit over the whole window.
	///
	/// - Parameter window: The window to track.
	private func installHoverTracking(in window: NSObject) {
		guard
			let contentView = window.value(forKey: "contentView") as? NSObject,
			let trackingAreaClass = NSClassFromString("NSTrackingArea") as? NSObject.Type,
			let allocated = trackingAreaClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject
		else { return }

		let initSelector = NSSelectorFromString("initWithRect:options:owner:userInfo:")
		guard allocated.responds(to: initSelector), let initMethod = allocated.method(for: initSelector) else { return }

		// NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect
		let options: UInt = 0x01 | 0x80 | 0x200

		typealias InitFunction = @convention(c) (NSObject, Selector, CGRect, UInt, NSObject?, NSObject?) -> NSObject?
		guard let trackingArea = unsafeBitCast(initMethod, to: InitFunction.self)(allocated, initSelector, .zero, options, self, nil) else { return }

		let addSelector = NSSelectorFromString("addTrackingArea:")
		guard contentView.responds(to: addSelector) else { return }
		contentView.perform(addSelector, with: trackingArea)
	}

	@objc(mouseEntered:) private func mouseEntered(_ event: NSObject) {
		self.onHoverChange?(true)
	}

	@objc(mouseExited:) private func mouseExited(_ event: NSObject) {
		self.onHoverChange?(false)
	}

	/// Installs the window's background material.
	///
	/// - Parameter window: The window to install the material in.
	private func installBehindWindowMaterial(in window: NSObject) {
		guard
			let contentView = window.value(forKey: "contentView") as? NSObject,
			let effectClass = NSClassFromString("NSVisualEffectView") as? NSObject.Type,
			let allocated = effectClass.perform(NSSelectorFromString("alloc"))?.takeUnretainedValue() as? NSObject,
			let effectView = allocated.perform(NSSelectorFromString("init"))?.takeUnretainedValue() as? NSObject
		else { return }

		// behindWindow blending, popover material, always active.
		effectView.setValue(0, forKey: "blendingMode")
		effectView.setValue(6, forKey: "material")
		effectView.setValue(1, forKey: "state")
		// width and height sizable
		effectView.setValue(18, forKey: "autoresizingMask")
		effectView.setValue(true, forKey: "wantsLayer")

		if let bounds = (contentView.value(forKey: "bounds") as? NSValue)?.cgRectValue {
			effectView.setValue(NSValue(cgRect: bounds), forKey: "frame")
		}

		if let layer = effectView.value(forKey: "layer") as? CALayer {
			layer.cornerRadius = Self.windowCornerRadius
			layer.cornerCurve = .continuous
			layer.masksToBounds = true
		}

		let selector = NSSelectorFromString("addSubview:positioned:relativeTo:")
		guard contentView.responds(to: selector), let method = contentView.method(for: selector) else { return }

		// NSWindowBelow = -1
		typealias AddSubviewFunction = @convention(c) (NSObject, Selector, NSObject, Int, NSObject?) -> Void
		unsafeBitCast(method, to: AddSubviewFunction.self)(contentView, selector, effectView, -1, nil)
		self.behindWindowMaterialView = effectView
	}

	/// Returns the AppKit window hosting the given window.
	///
	/// - Parameter window: The window to match.
	///
	/// - Returns: The AppKit window.
	private static func resolveAppKitWindow(for window: UIWindow) -> NSObject? {
		guard
			let applicationClass = NSClassFromString("NSApplication") as? NSObject.Type,
			let application = applicationClass.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? NSObject,
			let windows = application.value(forKey: "windows") as? [NSObject]
		else { return nil }

		let uiWindowsKey = #obfuscated("uiWindows")

		return windows.first { appKitWindow in
			guard appKitWindow.responds(to: NSSelectorFromString(uiWindowsKey)) else { return false }
			let uiWindows = appKitWindow.value(forKey: uiWindowsKey) as? [UIWindow]
			return uiWindows?.contains(window) == true
		}
	}

	/// Returns the window's standard button of the given type.
	///
	/// - Parameters:
	///    - buttonType: The button identifier, matching `NSWindow.ButtonType`.
	///    - window: The window carrying the button.
	///
	/// - Returns: The button.
	private func standardWindowButton(_ buttonType: Int, of window: NSObject) -> NSObject? {
		let selector = NSSelectorFromString("standardWindowButton:")
		guard window.responds(to: selector), let method = window.method(for: selector) else { return nil }

		typealias StandardButtonFunction = @convention(c) (NSObject, Selector, Int) -> NSObject?
		return unsafeBitCast(method, to: StandardButtonFunction.self)(window, selector, buttonType)
	}
}
#endif
