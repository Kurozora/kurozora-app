//
//  MediaAlbumViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class MediaAlbumViewController: UIPageViewController {
	private let orientationManager = OrientationManager()
	private var rotateToastButton: UIButton?
	private var rotateToastConstraints: [NSLayoutConstraint] = []
	private var isViewerForcedLandscape: Bool = false

	private(set) var items: [MediaItemV2]
	private(set) var currentIndex: Int
	let startIndex: Int

	// Attach the feed's transition delegate (set before presenting)
	weak var transitionDelegateForThumbnail: MediaTransitionDelegate?

	// Interactive controller
	private let interactionController = MediaInteractionController()

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

	var onClose: (() -> Void)?
	var onCopy: ((MediaItemV2) -> Void)?
	var onShare: ((MediaItemV2) -> [Any])?
	var onSave: ((MediaItemV2) -> Void)?
	var onMore: ((MediaItemV2) -> Void)?

	init(items: [MediaItemV2], startIndex: Int) {
		self.items = items
		self.currentIndex = startIndex
		self.startIndex = startIndex
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

		// use custom transitions
		transitioningDelegate = self
		modalPresentationStyle = .custom

		// monitor device orientation for smart rotation lock
		self.orientationManager.delegate = self
		self.orientationManager.startMonitoring()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black

		dataSource = self
		delegate = self

		// prepare initial page
		let initial = MediaRendererFactory.makeRenderer(for: self.items[self.currentIndex])
		setViewControllers([initial], direction: .forward, animated: false)

		// wire interactive dismiss
		self.interactionController.wireToViewController(self)

		// setup UI
		self.setupUI()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.orientationManager.stopMonitoring()
	}

	private func setupUI() {
		self.setupTopControls()
		self.setupActionBar()
		self.bindActions(for: self.items[self.currentIndex])
		self.setupToggleGesture()
		self.updateIndexLabel()
	}

	private func updateIndexLabel() {
		self.indexLabel.text = "\(self.currentIndex + 1) of \(self.items.count)"
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

	private func bindActions(for item: MediaItemV2) {
		var actions: [MediaAction] = []
		actions.append(.share)
		actions.append(.save)

		// Build the "More" menu dynamically
		let moreMenu = self.makeMoreMenu(for: item)
		if moreMenu.children.isEmpty == false {
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

	@objc private func closeTapped() {
		dismiss(animated: true) { [weak self] in
			self?.onClose?()
		}
	}

	private func share(_ item: MediaItemV2) {
		var objects: [Any] = []
		if let onShare = self.onShare {
			objects.append(onShare(self.items[self.currentIndex]))
		} else {
			objects.append(item.url)
		}

		let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.actionBar.shareButton
		present(activityVC, animated: true)
	}

	@objc private func saveTapped() {
		self.onSave?(self.items[self.currentIndex])
	}

	@objc private func moreTapped() {
		self.onMore?(self.items[self.currentIndex])
	}

	private func setupToggleGesture() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.toggleActionBar))
		singleTap.require(toFail: self.closeButton.gestureRecognizers?.first ?? singleTap)
		view.addGestureRecognizer(singleTap)
	}

	@objc private func toggleActionBar() {
		let isHidden = self.actionBar.transform == .identity

		UIView.animate(withDuration: 0.25, animations: { [weak self] in
			guard let self else { return }

			if isHidden {
				// slide out
				self.actionBar.transform = CGAffineTransform(translationX: 0, y: self.actionBar.frame.height + 40 + self.view.safeAreaInsets.bottom)
				self.closeButton.transform = CGAffineTransform(translationX: 0, y: -(self.closeButton.frame.maxY + 40))
				self.indexLabel.transform = CGAffineTransform(translationX: 0, y: -(self.indexLabel.frame.maxY + 40))
			} else {
				// reset to visible
				self.actionBar.transform = .identity
				self.closeButton.transform = .identity
				self.indexLabel.transform = .identity
			}
		})
	}

	// Expose the current media view so animators can snapshot it
	func currentMediaView() -> UIView? {
		guard let currentVC = viewControllers?.first as? MediaRenderable else { return nil }
		return currentVC.mediaView
	}

	// Update current index on page change
	func updateCurrentIndexFromCurrentVC() {
		if let currentVC = viewControllers?.first as? MediaRenderable {
			if let idx = items.firstIndex(where: { $0.url == currentVC.mediaItem.url }) {
				self.currentIndex = idx
			}
		}
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UserSettings.isSmartRotationLockEnabled {
			return [.portrait, .landscapeLeft, .landscapeRight]
		} else {
			return UIApplication.shared.supportedInterfaceOrientations(for: self.view.window)
		}
	}

	override var shouldAutorotate: Bool {
		return UserSettings.isSmartRotationLockEnabled
	}
}

// MARK: - Page view data source/delegate
extension MediaAlbumViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
		guard self.currentIndex > 0 else { return nil }
		let idx = self.currentIndex - 1
		return MediaRendererFactory.makeRenderer(for: self.items[idx])
	}

	func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
		guard self.currentIndex < self.items.count - 1 else { return nil }
		let idx = self.currentIndex + 1
		return MediaRendererFactory.makeRenderer(for: self.items[idx])
	}

	func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			self.updateCurrentIndexFromCurrentVC()
			self.updateIndexLabel()
			self.bindActions(for: self.items[self.currentIndex])
		}

		self.transitionDelegateForThumbnail?.scrollThumbnailIntoView(for: self.currentIndex)
	}
}

// MARK: - UIViewControllerTransitioningDelegate
extension MediaAlbumViewController: UIViewControllerTransitioningDelegate {
	// Present: animate from the tapped thumbnail (startIndex)
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaPresentAnimator(startIndex: self.startIndex, transitionDelegate: self.transitionDelegateForThumbnail)
	}

	// Provide the interaction controller only if gesture has started
	func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactionController.hasStarted ? self.interactionController : nil
	}

	// Dismiss: animate from current page to thumbnail
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaDismissAnimator(transitionDelegate: self.transitionDelegateForThumbnail)
	}

	// Provide the interaction controller only if gesture has started
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactionController.hasStarted ? self.interactionController : nil
	}
}

// MARK: - OrientationManagerDelegate
extension MediaAlbumViewController: OrientationManagerDelegate {
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIDeviceOrientation, downEdge: OrientationDownEdge) {
		// Only show toast if iOS system-wide orientation lock is *preventing* rotation.
		// There isn't an official API to know the CC lock state, but the app's autorotation
		// is blocked if UIApplication.shared.windows.first?.windowScene?.interfaceOrientation == .portrait
		// while device reports landscape. Use your app's best detection; here we assume portrait lock active.
		guard UserSettings.isPortraitLockBuddyEnabled else {
			self.hideRotateToast()
			return
		}

//		// Decide if we should show the toast: show only for landscape attempts.
//		switch deviceOrientation {
//		case .landscapeLeft:
//			self.showRotateToast(for: deviceOrientation, downEdge: downEdge)
//		case .landscapeRight:
//			self.showRotateToast(for: deviceOrientation, downEdge: downEdge)
//		default:
//			self.hideRotateToast()
//		}

		let sysOrientation = view.window?.windowScene?.interfaceOrientation ?? .portrait
		if deviceOrientation.isLandscape, sysOrientation.isPortrait {
			// user tilting while lock is active → show "Rotate" button
			self.showRotateToast(for: deviceOrientation, downEdge: downEdge)
		} else if deviceOrientation.isPortrait, self.isViewerForcedLandscape {
			// user tilted back to portrait while viewer is rotated
			self.showRotateToast(for: deviceOrientation, downEdge: downEdge)
		} else {
			self.hideRotateToast()
		}
	}

	private func showRotateToast(for deviceOrientation: UIDeviceOrientation, downEdge: OrientationDownEdge) {
		// If already visible, don't re-add
		if self.rotateToastButton != nil { return }

		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
		configuration.title = "Tap to Rotate"
		configuration.image = UIImage(systemName: "lock.open.rotation")
		configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in
			.label
		}
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

		tapToRotateButton.addTarget(self, action: #selector(self.handleRotateTapped), for: .touchUpInside)
		tapToRotateButton.alpha = 0

		view.addSubview(tapToRotateButton)
		self.rotateToastButton = tapToRotateButton

		// Remove old constraints if any
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

		// Determine rotation angle so the label is upright in device orientation
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

		// initial offset for slide-in depending on edge
		let initialTransform: CGAffineTransform
		switch downEdge {
		case .bottom: initialTransform = CGAffineTransform(translationX: 0, y: 8)
		case .top: initialTransform = CGAffineTransform(translationX: 0, y: 8)
		case .left: initialTransform = CGAffineTransform(translationX: 0, y: 8)
		case .right: initialTransform = CGAffineTransform(translationX: 0, y: 8)
		}

		// apply angle so text reads correctly relative to device
		tapToRotateButton.transform = initialTransform.concatenating(CGAffineTransform(rotationAngle: angle))

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			tapToRotateButton.alpha = 1
			tapToRotateButton.transform = CGAffineTransform(rotationAngle: angle)
		}
	}

	private func hideRotateToast() {
		guard let btn = self.rotateToastButton else { return }
		UIView.animate(withDuration: 0.22, animations: {
			btn.alpha = 0
			btn.transform = .identity
		}, completion: { _ in
			btn.removeFromSuperview()
			self.rotateToastButton = nil
			NSLayoutConstraint.deactivate(self.rotateToastConstraints)
			self.rotateToastConstraints.removeAll()
		})
	}

	@objc private func handleRotateTapped() {
		let orientation = self.orientationManager.lastDetectedOrientation
		self.applyRotation(orientation)
		self.hideRotateToast()
	}

	private func applyRotation(_ orientation: UIDeviceOrientation) {
		// If the media view contains a scroll view that is zoomable, reset zoom first.
		if let scroll = findFirstScrollView(in: self.view), scroll.zoomScale > 1.0 {
			scroll.setZoomScale(1.0, animated: true)
			// Wait for zoom animation to finish before rotating (slightly longer than zoom animation)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
				self.performRotation(on: self.view, orientation: orientation)
			}
		} else {
			self.performRotation(on: self.view, orientation: orientation)
		}

		self.view.bounds = UIScreen.main.bounds
		self.view.setNeedsLayout()
	}

	private func performRotation(on viewToRotate: UIView, orientation: UIDeviceOrientation) {
		let sysOrientation = view.window?.windowScene?.interfaceOrientation ?? .portrait

		let angle: CGFloat
		switch orientation {
		case .landscapeLeft:
			angle = CGFloat.pi / 2.0
			self.isViewerForcedLandscape = sysOrientation != .landscapeLeft
		case .landscapeRight:
			angle = -CGFloat.pi / 2.0
			self.isViewerForcedLandscape = sysOrientation != .landscapeRight
		case .portraitUpsideDown:
			angle = CGFloat.pi
			self.isViewerForcedLandscape = sysOrientation != .portraitUpsideDown
		default:
			angle = 0
			self.isViewerForcedLandscape = sysOrientation != .portrait
		}

		UIView.animate(withDuration: 0.30, delay: 0, options: [.curveEaseInOut], animations: {
			viewToRotate.transform = CGAffineTransform(rotationAngle: angle)
		}, completion: nil)
	}

	private func findFirstScrollView(in view: UIView) -> UIScrollView? {
		if let sv = view as? UIScrollView { return sv }
		for sub in view.subviews {
			if let found = findFirstScrollView(in: sub) { return found }
		}
		return nil
	}
}
