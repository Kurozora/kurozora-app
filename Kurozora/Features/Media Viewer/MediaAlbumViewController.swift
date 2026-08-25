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
	private let closeButton = AdaptiveCornerButton()
	private let indexButton = AdaptiveCornerButton()

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
	private lazy var dragToDismissController = MediaDragToDismissController(albumViewController: self)
	private var closeMethod: MediaViewerCloseMethod = .button

	/// The view that dims the presenting screen.
	var dimmingView: UIView? {
		return (self.presentationController as? MediaViewerPresentationController)?.dimmingView
	}

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

		self.configureView()
		self.configureDismissGesture()
		self.configureShareGesture()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.isDismissing = false
		self.becomeFirstResponder()

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
		self.view.backgroundColor = .clear
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

	private func configureDismissGesture() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissPan(_:)))
		pan.delegate = self
		pan.maximumNumberOfTouches = 1
		self.view.addGestureRecognizer(pan)
	}

	private func configureShareGesture() {
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
		longPress.delegate = self
		self.view.addGestureRecognizer(longPress)

		#if targetEnvironment(macCatalyst)
		self.view.addInteraction(UIContextMenuInteraction(delegate: self))
		#endif
	}

	/// Sets the alpha of every control layered over the media.
	///
	/// - Parameter alpha: The alpha to apply, clamped to `0...1`.
	func setChromeAlpha(_ alpha: CGFloat) {
		let clampedAlpha = max(0, min(1, alpha))

		self.closeButton.alpha = clampedAlpha
		self.indexButton.alpha = clampedAlpha
		self.actionBar.alpha = clampedAlpha
		self.rotateToastButton?.alpha = clampedAlpha
	}

	/// Dismisses the viewer.
	///
	/// - Parameter closeMethod: The gesture or control that closed the viewer.
	func close(using closeMethod: MediaViewerCloseMethod) {
		guard !self.isDismissing else { return }
		self.isDismissing = true
		self.closeMethod = closeMethod

		guard self.currentForcedOrientation != nil else {
			self.dismiss(animated: true) { [weak self] in
				self?.onClose?()
			}
			return
		}

		self.applyForcedRotation(.portrait)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
			self?.dismiss(animated: true) {
				self?.onClose?()
			}
		}
	}

	@objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
		guard gesture.state == .began else { return }
		self.shareCurrentItem(at: gesture.location(in: self.view))
	}

	/// Presents the share sheet for the item on display.
	///
	/// - Parameter location: The point in the viewer the sheet points at.
	private func shareCurrentItem(at location: CGPoint) {
		guard self.items.indices.contains(self.currentIndex) else { return }
		self.share(self.items[self.currentIndex], from: self.view, at: CGRect(origin: location, size: .zero))
	}

	/// Returns whether the viewer owns the gesture at the given point.
	///
	/// - Parameter location: A point in the viewer's coordinate space.
	/// - Returns: `true` when no selectable content sits under `location`.
	private func canClaimGesture(at location: CGPoint) -> Bool {
		guard let renderer = self.currentMedia else { return true }
		guard !renderer.hasActiveTextSelection else { return false }

		return !renderer.hasInteractiveItem(at: renderer.mediaView.convert(location, from: self.view))
	}

	@objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			self.pageViewControllerScrollView?.isScrollEnabled = false
		case .ended, .cancelled, .failed:
			self.pageViewControllerScrollView?.isScrollEnabled = true
		default:
			break
		}

		self.dragToDismissController.handlePan(gesture)
	}

	private func updateIndexButton() {
		self.indexButton.setTitle(L10n.indexOfTotal(self.currentIndex + 1, self.items.count), for: .normal)
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
		self.actionBar.saveMenu = self.makeSaveMenu(for: item)

		self.actionBar.onShare = { [weak self] in
			self?.share(item)
		}

		self.actionBar.onSave = { [weak self] in
			self?.save(item)
		}

		self.actionBar.onPresentMenu = { [weak self] menu, sourceView in
			self?.presentMenu(menu, from: sourceView)
		}
	}

	/// Presents the given menu as an action sheet anchored to the given view.
	///
	/// - Parameters:
	///    - menu: The menu whose actions to display.
	///    - sourceView: The view the popover anchors to.
	private func presentMenu(_ menu: UIMenu, from sourceView: UIView) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for child in menu.children {
			guard let action = child as? UIAction else { continue }

			let dispatcher = UIControl()
			dispatcher.addAction(action, for: .primaryActionTriggered)

			let style: UIAlertAction.Style = action.attributes.contains(.destructive) ? .destructive : .default
			alert.addAction(UIAlertAction(title: action.title, style: style) { _ in
				dispatcher.sendActions(for: .primaryActionTriggered)
			})
		}

		alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))

		alert.popoverPresentationController?.sourceView = sourceView
		alert.popoverPresentationController?.permittedArrowDirections = .down

		self.present(alert, animated: true)
	}

	private func makeMoreMenu(for item: MediaItem) -> UIMenu {
		var options: [UIAction] = []

		options.append(UIAction(title: L10n.statsForNerds, image: UIImage(systemName: "info.circle")) { [weak self] _ in
			self?.presentStats(for: item)
		})

		options.append(UIAction(title: L10n.openInBrowser, image: UIImage(systemName: "safari")) { _ in
			UIApplication.shared.kOpen(item.url)
		})

		return UIMenu(title: "", children: options)
	}

	/// Returns the menu the save button reveals when held.
	///
	/// - Parameter item: The item on display.
	/// - Returns: The menu listing every way to keep the media.
	private func makeSaveMenu(for item: MediaItem) -> UIMenu {
		var options: [UIAction] = []

		options.append(UIAction(title: L10n.copyImage, image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
			self?.copyImage(for: item)
		})

		options.append(UIAction(title: L10n.saveImage, image: UIImage(systemName: "square.and.arrow.down")) { [weak self] _ in
			self?.save(item)
		})

		if self.items.count > 1 {
			options.append(UIAction(title: L10n.saveAlbum, image: UIImage(systemName: "square.and.arrow.down.on.square")) { [weak self] _ in
				self?.saveAlbum()
			})
		}

		options.append(UIAction(title: L10n.saveToFolder, image: UIImage(systemName: "folder")) { [weak self] _ in
			self?.exportImage(for: item)
		})

		return UIMenu(title: "", children: options)
	}

	/// Presents the technical details of the given item.
	///
	/// - Parameter item: The item to describe.
	private func presentStats(for item: MediaItem) {
		let statsViewController = MediaStatsViewController(mediaItem: item, image: self.currentMedia?.mediaImage)
		let navigationController = KNavigationController(rootViewController: statsViewController)
		navigationController.modalPresentationStyle = .formSheet

		self.present(navigationController, animated: true)
	}

	/// Copies the media's image to the pasteboard.
	///
	/// - Parameter item: The item to copy.
	private func copyImage(for item: MediaItem) {
		if let image = self.currentMedia?.mediaImage {
			self.write(image, for: item)
			return
		}

		Task {
			do {
				let image = try await MediaSaverManager.shared.downloadImage(from: item.url)
				self.write(image, for: item)
			} catch {
				self.showToast(L10n.imageDownloadFailed, systemImageName: "xmark.octagon", feedback: .error)
			}
		}
	}

	private func write(_ image: UIImage, for item: MediaItem) {
		UIPasteboard.general.image = image
		self.onCopy?(item)

		if UserSettings.hapticsAllowed {
			UINotificationFeedbackGenerator().notificationOccurred(.success)
		}
	}

	/// Presents the share sheet for the given item.
	///
	/// - Parameters:
	///    - item: The item to share.
	///    - sourceView: The view the popover points at.
	///    - sourceRect: The rect within `sourceView` the popover points at.
	private func share(_ item: MediaItem, from sourceView: UIView? = nil, at sourceRect: CGRect? = nil) {
		var objects: [Any] = []
		if let onShare = self.onShare {
			objects.append(contentsOf: onShare(item))
		} else {
			objects.append(item.url)
		}

		let activityViewController = UIActivityViewController(activityItems: objects, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = sourceView ?? self.actionBar.shareButton

		if let sourceRect = sourceRect {
			activityViewController.popoverPresentationController?.sourceRect = sourceRect
		}

		self.present(activityViewController, animated: true)
	}

	/// Saves the given item to the destination chosen in Settings.
	///
	/// - Parameter item: The item to save.
	func save(_ item: MediaItem) {
		Task {
			do {
				let destination = try await MediaSaverManager.shared.saveImage(from: item.url)
				self.handleSaveSuccess(at: destination, isAlbum: false)
			} catch let error as MediaSaverManager.SaverError {
				self.handleSaveError(error)
			}
		}
	}

	/// Saves every item in the album to the destination chosen in Settings.
	private func saveAlbum() {
		Task {
			do {
				let destination = try await MediaSaverManager.shared.saveImages(from: self.items.map(\.url))
				self.handleSaveSuccess(at: destination, isAlbum: true)
			} catch let error as MediaSaverManager.SaverError {
				self.handleSaveError(error)
			}
		}
	}

	/// Lets the user pick where to write the given item.
	///
	/// - Parameter item: The item to export.
	private func exportImage(for item: MediaItem) {
		Task {
			do {
				let fileURL = try await MediaSaverManager.shared.stageImage(from: item.url)
				let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
				documentPicker.popoverPresentationController?.sourceView = self.actionBar

				self.present(documentPicker, animated: true)
			} catch let error as MediaSaverManager.SaverError {
				self.handleSaveError(error)
			}
		}
	}

	private func createToast() -> UIButton {
		let button = AdaptiveCornerButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configuration?.imagePlacement = .leading
		button.configuration?.imagePadding = 8
		button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .preferredFont(forTextStyle: .subheadline)
			return outgoing
		}
		button.alpha = 0
		return button
	}

	/// Presents a message below the index button.
	///
	/// - Parameters:
	///    - message: The message to present.
	///    - systemImageName: The name of the symbol shown beside the message.
	///    - feedback: The haptic played as the message appears.
	private func showToast(_ message: String, systemImageName: String, feedback: UINotificationFeedbackGenerator.FeedbackType) {
		let button = self.createToast()
		button.configuration?.title = message
		button.configuration?.image = UIImage(systemName: systemImageName)

		self.view.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			button.topAnchor.constraint(equalTo: self.indexButton.bottomAnchor, constant: 8),
			button.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.layoutMarginsGuide.leadingAnchor),
			button.trailingAnchor.constraint(lessThanOrEqualTo: self.view.layoutMarginsGuide.trailingAnchor)
		])

		if UserSettings.hapticsAllowed {
			UINotificationFeedbackGenerator().notificationOccurred(feedback)
		}

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			button.alpha = 1
		} completion: { _ in
			UIView.animate(withDuration: 0.32, delay: 1.5, options: [.curveEaseIn]) {
				button.alpha = 0
			} completion: { _ in
				button.removeFromSuperview()
			}
		}
	}

	private func handleSaveSuccess(at destination: MediaSaveDestination, isAlbum: Bool) {
		switch (destination, isAlbum) {
		case (.photoLibrary, false):
			self.showToast(L10n.imageSavedToLibrary, systemImageName: "checkmark.circle", feedback: .success)
		case (.photoLibrary, true):
			self.showToast(L10n.albumSavedToLibrary, systemImageName: "checkmark.circle", feedback: .success)
		case (.folder, _):
			self.showToast(L10n.imageSavedToFolder, systemImageName: "checkmark.circle", feedback: .success)
		}
	}

	private func handleSaveError(_ error: MediaSaverManager.SaverError) {
		var message = L10n.imageSaveFailed

		switch error {
		case .accessDenied:
			message = L10n.photoLibraryAccessDenied
		case .invalidData, .downloadFailed:
			message = L10n.imageDownloadFailed
		case .saveFailed:
			message = L10n.imageSaveFailedRetry
		case .destinationUnavailable:
			message = L10n.imageSaveFailed
		}

		self.showToast(message, systemImageName: "xmark.octagon", feedback: .error)
	}

	@objc private func closeTapped() {
		self.close(using: .button)
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

	private var pageViewControllerScrollView: UIScrollView? {
		return self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
	}

	// Hardware Keyboard
	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		let close = UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(self.closeKeyCommandInvoked(_:)))
		let copy = UIKeyCommand(title: L10n.copy, action: #selector(self.copyKeyCommandInvoked(_:)), input: "c", modifierFlags: .command)

		return [close, copy]
	}

	@objc private func closeKeyCommandInvoked(_ sender: UIKeyCommand) {
		self.close(using: .keyboard)
	}

	@objc private func copyKeyCommandInvoked(_ sender: UIKeyCommand) {
		guard self.items.indices.contains(self.currentIndex) else { return }
		self.copyImage(for: self.items[self.currentIndex])
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
		self.transitionDelegateForThumbnail?.scrollThumbnailIntoView(for: self.currentIndex, animated: true)
	}
}

// MARK: - UIViewControllerTransitioningDelegate
extension MediaAlbumViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return MediaViewerPresentationController(presentedViewController: presented, presenting: presenting)
	}

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaPresentAnimator(startIndex: self.startIndex, transitionDelegate: self.transitionDelegateForThumbnail)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return MediaDismissAnimator(closeMethod: self.closeMethod, transitionDelegate: self.transitionDelegateForThumbnail)
	}
}

// MARK: - UIGestureRecognizerDelegate
extension MediaAlbumViewController: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let location = gestureRecognizer.location(in: self.view)
		let isOverControl = self.view.hitTest(location, with: nil) is UIControl

		// Share long press: yield to text and subjects the system claims.
		if gestureRecognizer is UILongPressGestureRecognizer {
			guard !isOverControl else { return false }
			return self.canClaimGesture(at: location)
		}

		if gestureRecognizer is UITapGestureRecognizer {
			return !isOverControl
		}

		// Dismiss pan: require a primarily vertical velocity and an unzoomed scroll view.
		if let pan = gestureRecognizer as? UIPanGestureRecognizer {
			guard !self.isDismissing else { return false }

			let velocity = pan.velocity(in: self.view)
			guard abs(velocity.y) > abs(velocity.x) else { return false }

			if let renderer = self.currentMedia, renderer.hasActiveTextSelection {
				return false
			}

			if let scrollView = self.currentMedia?.scrollView, scrollView.zoomScale > scrollView.minimumZoomScale {
				return false
			}

			return true
		}

		return true
	}
}

// MARK: - UIContextMenuInteractionDelegate
#if targetEnvironment(macCatalyst)
extension MediaAlbumViewController: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard self.items.indices.contains(self.currentIndex) else { return nil }
		guard self.canClaimGesture(at: location) else { return nil }

		let item = self.items[self.currentIndex]

		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return nil }

			let share = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
				self?.shareCurrentItem(at: location)
			}

			return UIMenu(children: [share] + self.makeSaveMenu(for: item).children)
		}
	}
}
#endif

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

		let tapToRotateButton = AdaptiveCornerButton()
		tapToRotateButton.translatesAutoresizingMaskIntoConstraints = false
		tapToRotateButton.configuration?.title = L10n.tapToRotate
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
