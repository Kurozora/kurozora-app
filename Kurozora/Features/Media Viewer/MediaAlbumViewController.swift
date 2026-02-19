//
//  MediaAlbumViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaAlbumViewController: UIPageViewController {
	// MARK: - Views
	private let actionBar = MediaActionBar()
	private let closeButton = CircularButton()
	private let indexButton = CircularButton()

	// MARK: - Properties
	// Orientation
	private let orientationManager = OrientationManager()
	private var currentForcedOrientation: UIInterfaceOrientationMask?
	private var rotateToastButton: UIButton?
	private var rotateToastConstraints: [NSLayoutConstraint] = []
	private var effectiveViewerOrientation: UIInterfaceOrientationMask = .portrait

	// Data
	private(set) var items: [MediaItem]
	private(set) var currentIndex: Int
	let startIndex: Int

	var currentMedia: MediaRenderable? {
		return self.viewControllers?.first as? MediaRenderable
	}

	// Transition
	weak var transitionDelegateForThumbnail: MediaTransitionDelegate?
	private let interactionController = MediaInteractionController()

	// Callbacks
	var onClose: (() -> Void)?
	var onCopy: ((MediaItem) -> Void)?
	var onShare: ((MediaItem) -> [Any])?
	var onSave: ((MediaItem) -> Void)?
	var onMore: ((MediaItem) -> Void)?

	// Guards
	private var isDismissing = false
	private var isApplyingRotation = false
	private var controlsAreVisible = true

	// MARK: - Initializers
	init(items: [MediaItem], startIndex: Int) {
		self.items = items
		self.currentIndex = items.indices.contains(startIndex) ? startIndex : 0
		self.startIndex = startIndex
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

		self.transitioningDelegate = self
		self.modalPresentationStyle = .custom
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		let initial = MediaRendererFactory.makeRenderer(for: self.items[self.currentIndex])
		self.setViewControllers([initial], direction: .forward, animated: false)

		self.interactionController.wireToViewController(self)

		self.configureView()
		self.configureGestureConflictResolution()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.isDismissing = false

		if let sysOrientation = view.window?.windowScene?.interfaceOrientation {
			self.effectiveViewerOrientation = self.mask(for: sysOrientation)
		}

		self.orientationManager.delegate = self
		self.orientationManager.startMonitoring()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		guard self.isBeingDismissed || self.isMovingFromParent else { return }

		if self.currentForcedOrientation != nil {
			self.applyForcedRotation(.portrait)
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.orientationManager.stopMonitoring()
		self.hideRotateToast()
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: nil) { [weak self] _ in
			guard let self else { return }
			if let sysOrientation = self.view.window?.windowScene?.interfaceOrientation {
				self.effectiveViewerOrientation = self.mask(for: sysOrientation)
			}
			self.isApplyingRotation = false
		}
	}

	// MARK: - Functions
	private func configureView() {
		self.view.backgroundColor = .black
		self.dataSource = self
		self.delegate = self

		self.configureToggleGesture()
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureCloseButton()
		self.configureActionBar()
		self.configureIndexButton()
		self.bindActions(for: self.items[self.currentIndex])
		self.updateIndexButton()
	}

	private func configureCloseButton() {
		self.closeButton.translatesAutoresizingMaskIntoConstraints = false
		self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		self.closeButton.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
	}

	private func configureActionBar() {
		self.actionBar.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureIndexButton() {
		self.indexButton.translatesAutoresizingMaskIntoConstraints = false
		self.indexButton.titleLabel?.textColor = .white
		self.indexButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
		self.indexButton.titleLabel?.textAlignment = .center
	}

	private func configureViewHierarchy() {
		self.view.addSubview(self.closeButton)
		self.view.addSubview(self.indexButton)
		self.view.addSubview(self.actionBar)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.closeButton.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.closeButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.closeButton.widthAnchor.constraint(equalToConstant: 44),
			self.closeButton.heightAnchor.constraint(equalToConstant: 44),

			self.indexButton.topAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.topAnchor),
			self.indexButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.indexButton.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),

			self.actionBar.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
			self.actionBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.actionBar.leadingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.actionBar.trailingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.actionBar.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
		])
	}

	private func configureToggleGesture() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.toggleControls))
		singleTap.delegate = self
		self.view.addGestureRecognizer(singleTap)
	}

	private func updateIndexButton() {
		self.indexButton.setTitle("\(self.currentIndex + 1) of \(self.items.count)", for: .normal)
		self.indexButton.isHidden = self.items.count <= 1
	}

	// Actions
	private func bindActions(for item: MediaItem) {
		var actions: [MediaAction] = []
		actions.append(.share)
		actions.append(.save)

		let moreMenu = self.makeMoreMenu(for: item)
		if !moreMenu.children.isEmpty {
			actions.append(.more(moreMenu))
		}

		self.actionBar.configure(with: actions)

		self.actionBar.onAction = { [weak self] action in
			guard let self = self else { return }
			switch action {
			case .copy: self.onCopy?(item)
			case .share: self.share(item)
			case .save: self.save(item)
			case .more: break
			}
		}
	}

	private func makeMoreMenu(for item: MediaItem) -> UIMenu {
		var options: [UIAction] = []

		if self.onCopy != nil {
			options.append(UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
				self.onCopy?(item)
			})
		}

		options.append(UIAction(title: "Open in Browser", image: UIImage(systemName: "safari")) { _ in
			UIApplication.shared.kOpen(item.url)
		})

		return UIMenu(title: "", children: options)
	}

	private func share(_ item: MediaItem) {
		var objects: [Any] = []
		if let onShare = self.onShare {
			objects.append(onShare(item))
		} else {
			objects.append(item.url)
		}

		let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.actionBar.shareButton
		self.present(activityVC, animated: true)
	}

	public func save(_ item: MediaItem) {
		Task {
			do {
				try await MediaSaverManager.shared.saveImage(from: item.url)
				self.handleSaveSuccess()
			} catch let error as MediaSaverManager.SaverError {
				self.handleSaveError(error)
			}
		}
	}

	private func createToast() -> UIButton {
		let button = CircularButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration?.imagePlacement = .leading
		button.configuration?.imagePadding = 8
		button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .preferredFont(forTextStyle: .subheadline)
			return outgoing
		}
		button.isHidden = true
		return button
	}

	/// Presents a toast at the top of the viewer indicating that the media has been saved successfully.
	private func handleSaveSuccess() {
		let button = self.createToast()
		button.configuration?.title = "Image saved to your library!"
		button.configuration?.image = UIImage(systemName: "checkmark.circle")

		self.view.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			button.topAnchor.constraint(equalTo: self.indexButton.bottomAnchor, constant: 8),
			button.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.leadingAnchor),
			button.trailingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor)
		])

		if UserSettings.hapticsAllowed {
			UINotificationFeedbackGenerator().notificationOccurred(.success)
		}

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			button.isHidden = false
		} completion: { _ in
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseIn]) {
					button.isHidden = true
				} completion: { _ in
					button.removeFromSuperview()
				}
			}
		}
	}

	private func handleSaveError(_ error: MediaSaverManager.SaverError) {
		var message = "Image could not be saved."
		let button = self.createToast()

		switch error {
		case .accessDenied:
			message = "Access to photo library denied."
		case .invalidData, .downloadFailed:
			message = "Failed to download image."
		case .saveFailed:
			message = "Failed to save image."
		}

		button.configuration?.title = message
		button.configuration?.image = UIImage(systemName: "xmark.octagon")

		self.view.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			button.topAnchor.constraint(equalTo: self.indexButton.bottomAnchor, constant: 8),
			button.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.leadingAnchor),
			button.trailingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor)
		])

		if UserSettings.hapticsAllowed {
			UINotificationFeedbackGenerator().notificationOccurred(.error)
		}

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			button.isHidden = false
		} completion: { _ in
			UIView.animate(withDuration: 0.32, delay: 1.5, options: [.curveEaseIn]) {
				button.isHidden = true
			} completion: { _ in
				button.removeFromSuperview()
			}
		}
	}

	@objc private func closeTapped() {
		guard !self.isDismissing else { return }
		self.isDismissing = true

		if self.currentForcedOrientation != nil {
			self.applyForcedRotation(.portrait)

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
				self?.dismiss(animated: true) {
					self?.onClose?()
				}
			}
		} else {
			self.dismiss(animated: true) { [weak self] in
				self?.onClose?()
			}
		}
	}

	@objc private func toggleControls() {
		self.controlsAreVisible.toggle()

		UIView.animate(withDuration: 0.25) { [weak self] in
			guard let self else { return }

			if self.controlsAreVisible {
				self.actionBar.transform = .identity
				self.closeButton.transform = .identity
				self.indexButton.transform = .identity
			} else {
				self.actionBar.transform = CGAffineTransform(translationX: 0, y: self.actionBar.frame.height + 40 + self.view.safeAreaInsets.bottom)
				self.closeButton.transform = CGAffineTransform(translationX: 0, y: -(self.closeButton.frame.maxY + 40))
				self.indexButton.transform = CGAffineTransform(translationX: 0, y: -(self.indexButton.frame.maxY + 40))
			}
		}
	}

	// Helpers
	private func index(of vc: UIViewController) -> Int? {
		guard let renderable = vc as? MediaRenderable else { return nil }
		return self.items.firstIndex(where: { $0.url == renderable.mediaItem.url })
	}

	private func currentChildScrollView() -> UIScrollView? {
		guard let currentVC = viewControllers?.first else { return nil }
		return self.findFirstScrollView(in: currentVC.view)
	}

	private func findFirstScrollView(in view: UIView) -> UIScrollView? {
		if let sv = view as? UIScrollView { return sv }
		for sub in view.subviews {
			if let found = self.findFirstScrollView(in: sub) { return found }
		}
		return nil
	}

	private var pageViewControllerScrollView: UIScrollView? {
		return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
	}

	// Gesture Conflict Resolution
	private func configureGestureConflictResolution() {
		guard let gestureRecognizers = self.view.gestureRecognizers else { return }
		let pageScrollPan = self.pageViewControllerScrollView?.panGestureRecognizer

		for gesture in gestureRecognizers {
			if let pan = gesture as? UIPanGestureRecognizer, pan !== pageScrollPan {
				pan.delegate = self
				break
			}
		}
	}

	// Orientation Overrides
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if let currentForcedOrientation = self.currentForcedOrientation {
			return currentForcedOrientation
		}

		return super.supportedInterfaceOrientations
	}

	override var shouldAutorotate: Bool {
		if UserSettings.isPortraitLockBuddyEnabled {
			return true
		}
		return UserSettings.isSmartRotationLockEnabled
	}
}

// MARK: - UIPageViewControllerDataSource
extension MediaAlbumViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
		guard let idx = self.index(of: vc), idx > 0 else { return nil }
		return MediaRendererFactory.makeRenderer(for: self.items[idx - 1])
	}

	func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
		guard let idx = self.index(of: vc), idx < self.items.count - 1 else { return nil }
		return MediaRendererFactory.makeRenderer(for: self.items[idx + 1])
	}
}

// MARK: - UIPageViewControllerDelegate
extension MediaAlbumViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed else { return }

		if let currentVC = self.viewControllers?.first as? MediaRenderable,
		   let idx = self.items.firstIndex(where: { $0.url == currentVC.mediaItem.url }) {
			self.currentIndex = idx
		}

		self.updateIndexButton()
		self.bindActions(for: self.items[self.currentIndex])
		self.transitionDelegateForThumbnail?.scrollThumbnailIntoView(for: self.currentIndex)
	}
}

// MARK: - UIViewControllerTransitioningDelegate
extension MediaAlbumViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaPresentAnimator(startIndex: self.startIndex, transitionDelegate: self.transitionDelegateForThumbnail)
	}

	func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactionController.hasStarted ? self.interactionController : nil
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaDismissAnimator(transitionDelegate: self.transitionDelegateForThumbnail)
	}

	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactionController.hasStarted ? self.interactionController : nil
	}
}

// MARK: - UIGestureRecognizerDelegate
extension MediaAlbumViewController: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		// Tap gesture: exclude taps on UIControl (buttons, menus, etc.)
		if gestureRecognizer is UITapGestureRecognizer {
			let location = gestureRecognizer.location(in: self.view)
			if let hitView = self.view.hitTest(location, with: nil), hitView is UIControl {
				return false
			}
			return true
		}

		// Dismiss pan: require primarily vertical velocity AND zoom scale at 1.0
		if let pan = gestureRecognizer as? UIPanGestureRecognizer {
			let velocity = pan.velocity(in: self.view)

			guard abs(velocity.y) > abs(velocity.x) else { return false }

			if let scrollView = self.currentChildScrollView(), scrollView.zoomScale > 1.0 {
				return false
			}

			return true
		}

		return true
	}
}

// MARK: - OrientationManagerDelegate
extension MediaAlbumViewController: OrientationManagerDelegate {
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIInterfaceOrientationMask) {
		// Hide existing toast and reevaluate showing a new one based on the latest orientation
		self.hideRotateToast()

		guard UserSettings.isPortraitLockBuddyEnabled else {
			return
		}

		guard !self.isApplyingRotation else { return }

		let systemOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .portrait
		let systemOrientationMask = self.mask(for: systemOrientation)
		let deviceOrientation = !UIDevice.current.isPortraitUpsideDownSupported && deviceOrientation == .portraitUpsideDown ? systemOrientationMask : deviceOrientation

		// System orientation matches device: no button is needed
		if deviceOrientation == systemOrientationMask {
			self.effectiveViewerOrientation = systemOrientationMask
			return
		}

		// Device orientation matches effective viewer orientation: no button is needed
		if deviceOrientation == self.effectiveViewerOrientation {
			return
		}

		// Device differs from viewer while lock is active: show button
		self.showRotateToast(for: deviceOrientation)
	}

	private func mask(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask {
		switch orientation {
		case .portrait: return .portrait
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		case .portraitUpsideDown: return .portraitUpsideDown
		default: return .portrait
		}
	}

	private func fromMask(_ orientation: UIInterfaceOrientationMask) -> UIInterfaceOrientation {
		switch orientation {
		case .portrait: return .portrait
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		case .portraitUpsideDown: return .portraitUpsideDown
		default: return .portrait
		}
	}

	private func orientationAngle(for mask: UIInterfaceOrientationMask) -> CGFloat {
		switch mask {
		case .landscapeLeft: return .pi / 2
		case .landscapeRight: return -.pi / 2
		case .portraitUpsideDown: return 0
		default: return .pi
		}
	}
}

// MARK: - Rotate Toast
extension MediaAlbumViewController {
	private func showRotateToast(for deviceOrientation: UIInterfaceOrientationMask) {
		if self.rotateToastButton != nil { return }

		let tapToRotateButton = CircularButton()
		tapToRotateButton.translatesAutoresizingMaskIntoConstraints = false
		tapToRotateButton.configuration?.title = "Tap to Rotate"
		tapToRotateButton.configuration?.image = UIImage(systemName: "lock.open.rotation")
		tapToRotateButton.configuration?.imagePlacement = .leading
		tapToRotateButton.configuration?.imagePadding = 8
		tapToRotateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .preferredFont(forTextStyle: .subheadline)
			return outgoing
		}

		tapToRotateButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.applyForcedRotation(deviceOrientation)
		}, for: .touchUpInside)
		tapToRotateButton.alpha = 0

		self.view.addSubview(tapToRotateButton)
		self.rotateToastButton = tapToRotateButton

		NSLayoutConstraint.deactivate(self.rotateToastConstraints)
		self.rotateToastConstraints.removeAll()

		let orientationFromMask = self.fromMask(deviceOrientation)

		self.anchorRotateButton(tapToRotateButton: tapToRotateButton, deviceOrientation: orientationFromMask)

		NSLayoutConstraint.activate(self.rotateToastConstraints)

		var angle = switch (deviceOrientation, self.effectiveViewerOrientation) {
		case (.landscapeLeft, .landscapeRight), (.landscapeRight, .landscapeLeft):
			self.orientationAngle(for: deviceOrientation) * 2
		default: self.orientationAngle(for: deviceOrientation) + self.orientationAngle(for: self.effectiveViewerOrientation)
		}

		angle = switch deviceOrientation {
		case .landscapeLeft: self.effectiveViewerOrientation == .landscapeRight ? -angle : angle
		case .landscapeRight: self.effectiveViewerOrientation == .landscapeLeft ? -angle : angle
		case .portraitUpsideDown: angle
		default: -angle
		}

		tapToRotateButton.transform = CGAffineTransform(rotationAngle: angle)

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			tapToRotateButton.alpha = 1
		}
	}

	private func anchorRotateButton(tapToRotateButton: UIButton, deviceOrientation: UIInterfaceOrientation) {
		guard
			let interfaceOrientation = view.window?.windowScene?.interfaceOrientation
		else {
			return
		}

		// Convert both to a numeric representation so we can compute delta.
		func index(for orientation: UIInterfaceOrientation) -> Int {
			switch orientation {
			case .portrait: return 0
			case .landscapeRight: return 1
			case .portraitUpsideDown: return 2
			case .landscapeLeft: return 3
			default: return 0
			}
		}

		func index(for device: UIDeviceOrientation) -> Int {
			switch device {
			case .portrait: return 0
			case .landscapeRight: return 1
			case .portraitUpsideDown: return 2
			case .landscapeLeft: return 3
			default: return 0
			}
		}

		let interfaceIndex = index(for: interfaceOrientation)
		let deviceIndex = index(for: deviceOrientation)

		// Difference tells us where the physical bottom edge lies
		let delta = (deviceIndex - interfaceIndex + 4) % 4

		switch delta {
		case 0:
			// Physical bottom aligns with view bottom
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
				tapToRotateButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor)
			])
		case 1:
			// Physical bottom is view.leading
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
				tapToRotateButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor)
			])
		case 2:
			// Physical bottom is view.top
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
				tapToRotateButton.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor)
			])
		case 3:
			// Physical bottom is view.trailing
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
				tapToRotateButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor)
			])
		default:
			break
		}
	}

	private func hideRotateToast() {
		guard let btn = self.rotateToastButton else { return }

		UIView.animate(withDuration: 0.22, animations: {
			self.rotateToastButton?.alpha = 0
			self.rotateToastButton = nil
			NSLayoutConstraint.deactivate(self.rotateToastConstraints)
			self.rotateToastConstraints.removeAll()
		}, completion: { _ in
			btn.removeFromSuperview()
		})
	}
}

// MARK: - Forced Rotation
extension MediaAlbumViewController {
	private func applyForcedRotation(_ orientation: UIInterfaceOrientationMask) {
		guard !self.isApplyingRotation else { return }
		self.isApplyingRotation = true

		// Sync effective orientation immediately — before next OM callback
		self.effectiveViewerOrientation = orientation

		// Clear force when returning to portrait to restore auto-rotation
		if orientation == .portrait {
			self.currentForcedOrientation = nil
		} else {
			self.currentForcedOrientation = orientation
		}

		self.hideRotateToast()

		guard let windowScene = view.window?.windowScene else {
			self.isApplyingRotation = false
			return
		}

		if #available(iOS 16.0, *) {
			self.setNeedsUpdateOfSupportedInterfaceOrientations()

			let geometryUpdate = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)

			windowScene.requestGeometryUpdate(geometryUpdate) { [weak self] error in
				print("----- Orientation update error: \(error)")

				guard let self else { return }
				// Revert to actual system orientation on failure
				let actualMask = self.mask(for: windowScene.interfaceOrientation)
				self.effectiveViewerOrientation = actualMask
				self.currentForcedOrientation = (actualMask == .portrait) ? nil : actualMask
				self.isApplyingRotation = false
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isApplyingRotation = false
		}
	}
}
