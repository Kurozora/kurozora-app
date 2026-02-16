//
//  MediaAlbumViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaAlbumViewController: UIPageViewController {
	// MARK: - Orientation
	private let orientationManager = OrientationManager()
	private var currentForcedOrientation: UIInterfaceOrientationMask?
	private var rotateToastButton: UIButton?
	private var rotateToastConstraints: [NSLayoutConstraint] = []
	private var effectiveViewerOrientation: UIInterfaceOrientationMask = .portrait

	// MARK: - Data
	private(set) var items: [MediaItemV2]
	private(set) var currentIndex: Int
	let startIndex: Int

	// MARK: - Transition
	weak var transitionDelegateForThumbnail: MediaTransitionDelegate?
	private let interactionController = MediaInteractionController()

	// MARK: - UI
	private let actionBar = MediaActionBar()
	private let closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.tintColor = .white
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private let indexLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 15)
		label.textColor = .white
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	// MARK: - Callbacks
	var onClose: (() -> Void)?
	var onCopy: ((MediaItemV2) -> Void)?
	var onShare: ((MediaItemV2) -> [Any])?
	var onSave: ((MediaItemV2) -> Void)?
	var onMore: ((MediaItemV2) -> Void)?

	// MARK: - Guards
	private var isDismissing = false
	private var isApplyingRotation = false
	private var controlsAreVisible = true

	// MARK: - Init
	init(items: [MediaItemV2], startIndex: Int) {
		self.items = items
		self.currentIndex = startIndex
		self.startIndex = startIndex
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

		self.transitioningDelegate = self
		self.modalPresentationStyle = .custom
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black

		self.dataSource = self
		self.delegate = self

		let initial = MediaRendererFactory.makeRenderer(for: self.items[self.currentIndex])
		setViewControllers([initial], direction: .forward, animated: false)

		self.interactionController.wireToViewController(self)

		self.setupUI()
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

	// MARK: - Setup UI
	private func setupUI() {
		self.setupTopControls()
		self.setupActionBar()
		self.bindActions(for: self.items[self.currentIndex])
		self.setupToggleGesture()
		self.updateIndexLabel()
	}

	private func setupTopControls() {
		view.addSubview(self.closeButton)
		view.addSubview(self.indexLabel)

		NSLayoutConstraint.activate([
			self.closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
			self.closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			self.closeButton.widthAnchor.constraint(equalToConstant: 32),
			self.closeButton.heightAnchor.constraint(equalToConstant: 32),

			self.indexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			self.indexLabel.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),
		])

		self.closeButton.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
	}

	private func setupActionBar() {
		self.actionBar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.actionBar)

		NSLayoutConstraint.activate([
			self.actionBar.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
			self.actionBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			self.actionBar.leadingAnchor.constraint(lessThanOrEqualTo: view.leadingAnchor, constant: 20),
			self.actionBar.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
			self.actionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
		])
	}

	private func setupToggleGesture() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.toggleControls))
		singleTap.delegate = self
		view.addGestureRecognizer(singleTap)
	}

	// MARK: - Index Label
	private func updateIndexLabel() {
		self.indexLabel.text = "\(self.currentIndex + 1) of \(self.items.count)"
		self.indexLabel.isHidden = self.items.count <= 1
	}

	// MARK: - Actions
	private func bindActions(for item: MediaItemV2) {
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
			case .save: self.onSave?(item)
			case .more: break
			}
		}
	}

	private func makeMoreMenu(for item: MediaItemV2) -> UIMenu {
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

	private func share(_ item: MediaItemV2) {
		var objects: [Any] = []
		if let onShare = self.onShare {
			objects.append(onShare(item))
		} else {
			objects.append(item.url)
		}

		let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.actionBar.shareButton
		present(activityVC, animated: true)
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
			dismiss(animated: true) { [weak self] in
				self?.onClose?()
			}
		}
	}

	// MARK: - Toggle Controls
	@objc private func toggleControls() {
		self.controlsAreVisible.toggle()

		UIView.animate(withDuration: 0.25) { [weak self] in
			guard let self else { return }

			if self.controlsAreVisible {
				self.actionBar.transform = .identity
				self.closeButton.transform = .identity
				self.indexLabel.transform = .identity
			} else {
				self.actionBar.transform = CGAffineTransform(translationX: 0, y: self.actionBar.frame.height + 40 + self.view.safeAreaInsets.bottom)
				self.closeButton.transform = CGAffineTransform(translationX: 0, y: -(self.closeButton.frame.maxY + 40))
				self.indexLabel.transform = CGAffineTransform(translationX: 0, y: -(self.indexLabel.frame.maxY + 40))
			}
		}
	}

	// MARK: - Helpers
	func currentMediaView() -> UIView? {
		guard let currentVC = viewControllers?.first as? MediaRenderable else { return nil }
		return currentVC.mediaView
	}

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

	// MARK: - Gesture Conflict Resolution
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

	// MARK: - Orientation Overrides
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

		if let currentVC = viewControllers?.first as? MediaRenderable,
		   let idx = self.items.firstIndex(where: { $0.url == currentVC.mediaItem.url })
		{
			self.currentIndex = idx
		}

		self.updateIndexLabel()
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
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIInterfaceOrientationMask, downEdge: OrientationDownEdge) {
		guard UserSettings.isPortraitLockBuddyEnabled else {
			self.hideRotateToast()
			return
		}

		guard !self.isApplyingRotation else { return }

		let sysOrientation = view.window?.windowScene?.interfaceOrientation ?? .portrait
		let sysMask = self.mask(for: sysOrientation)

		// If system orientation matches device, autorotation is working — no button needed
		if self.orientationsAreAligned(deviceOrientation, sysMask) {
			self.effectiveViewerOrientation = sysMask
			self.hideRotateToast()
			return
		}

		// System lock is preventing autorotation.
		// Compare against our effective viewer orientation (survives timing gaps after forced rotation).
		if self.orientationsAreAligned(deviceOrientation, self.effectiveViewerOrientation) {
			self.hideRotateToast()
			return
		}

		// Device differs from viewer while lock is active — show button
		self.showRotateToast(for: deviceOrientation, downEdge: downEdge)
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

	private func orientationsAreAligned(_ a: UIInterfaceOrientationMask, _ b: UIInterfaceOrientationMask) -> Bool {
		if a == b { return true }
		let isALandscape = (a == .landscapeLeft || a == .landscapeRight)
		let isBLandscape = (b == .landscapeLeft || b == .landscapeRight)
		return isALandscape && isBLandscape
	}
}

// MARK: - Rotate Toast
extension MediaAlbumViewController {
	private func showRotateToast(for deviceOrientation: UIInterfaceOrientationMask, downEdge: OrientationDownEdge) {
		if self.rotateToastButton != nil { return }

		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
		configuration.title = "Tap to Rotate"
		configuration.image = UIImage(systemName: "lock.open.rotation")
		configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in .label }
		configuration.imagePlacement = .leading
		configuration.imagePadding = 8
		configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.foregroundColor = .label
			outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
			return outgoing
		}

		let tapToRotateButton = UIButton(type: .system)
		tapToRotateButton.configuration = configuration
		tapToRotateButton.layerCornerRadius = 16
		tapToRotateButton.translatesAutoresizingMaskIntoConstraints = false
		tapToRotateButton.addBlurEffect()

		tapToRotateButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.applyForcedRotation(deviceOrientation)
		}, for: .touchUpInside)
		tapToRotateButton.alpha = 0

		view.addSubview(tapToRotateButton)
		self.rotateToastButton = tapToRotateButton

		NSLayoutConstraint.deactivate(self.rotateToastConstraints)
		self.rotateToastConstraints.removeAll()

		let safe = view.safeAreaLayoutGuide
		switch downEdge {
		case .bottom:
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				tapToRotateButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: 0),
			])
		case .top:
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				tapToRotateButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 0),
			])
		case .left:
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				tapToRotateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			])
		case .right:
			self.rotateToastConstraints.append(contentsOf: [
				tapToRotateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				tapToRotateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			])
		}

		NSLayoutConstraint.activate(self.rotateToastConstraints)

		let angle: CGFloat
		switch deviceOrientation {
		case .landscapeLeft:
			angle = CGFloat.pi / 2.0
		case .landscapeRight:
			angle = -CGFloat.pi / 2.0
		case .portraitUpsideDown:
			angle = CGFloat.pi
		default:
			angle = 0
		}

		let initialTransform: CGAffineTransform
		switch downEdge {
		case .bottom: initialTransform = CGAffineTransform(translationX: 0, y: 8)
		case .top: initialTransform = CGAffineTransform(translationX: 0, y: -8)
		case .left: initialTransform = CGAffineTransform(translationX: -8, y: 0)
		case .right: initialTransform = CGAffineTransform(translationX: 8, y: 0)
		}

		tapToRotateButton.transform = initialTransform.concatenating(CGAffineTransform(rotationAngle: angle))

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			tapToRotateButton.alpha = 1
			tapToRotateButton.transform = CGAffineTransform(rotationAngle: angle)
		}
	}

	private func hideRotateToast() {
		guard let btn = self.rotateToastButton else { return }
		self.rotateToastButton = nil
		NSLayoutConstraint.deactivate(self.rotateToastConstraints)
		self.rotateToastConstraints.removeAll()

		UIView.animate(withDuration: 0.22, animations: {
			btn.alpha = 0
			btn.transform = .identity
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
