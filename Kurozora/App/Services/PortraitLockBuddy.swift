//
//  PortraitLockBuddy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Offers a rotate button when the device turns while the system keeps the interface upright.
@MainActor
final class PortraitLockBuddy {
	// MARK: - Views
	/// The button that rotates the interface to match the device.
	private var rotateButton: UIButton?

	/// The constraints anchoring the rotate button to the device's bottom edge.
	private var rotateButtonConstraints: [NSLayoutConstraint] = []

	// MARK: - Properties
	/// The view controller whose interface the buddy rotates.
	private weak var viewController: UIViewController?

	/// The detector of the device's physical orientation.
	private let orientationManager = OrientationManager()

	/// The orientation the reader rotated the interface to.
	private(set) var forcedOrientation: UIInterfaceOrientationMask?

	/// The orientation the interface shows.
	private var effectiveOrientation: UIInterfaceOrientationMask = .portrait

	/// A Boolean value indicating whether a forced rotation is in flight.
	private var isApplyingRotation = false

	/// The wait that lets the system rotate the interface before the button is offered.
	private var offerTask: Task<Void, Never>?

	/// The wait that takes an untouched rotate button away.
	private var hideTask: Task<Void, Never>?

	/// The distance between the rotate button and the safe area's edge.
	private static let edgeGap: CGFloat = 16.0

	// MARK: - Initializers
	/// Creates a buddy for the given view controller.
	///
	/// - Parameter viewController: The view controller whose interface the buddy rotates.
	init(viewController: UIViewController) {
		self.viewController = viewController
		self.orientationManager.delegate = self
	}

	// MARK: - Functions
	/// Starts following the device.
	func start() {
		if let interfaceOrientation = self.viewController?.view.window?.windowScene?.interfaceOrientation {
			self.effectiveOrientation = Self.mask(for: interfaceOrientation)
		}

		self.orientationManager.startMonitoring()
	}

	/// Stops following the device.
	func stop() {
		self.offerTask?.cancel()
		self.offerTask = nil
		self.orientationManager.stopMonitoring()
		self.hideRotateButton()
	}

	/// Records the interface orientation once the given size transition settles.
	///
	/// - Parameter coordinator: The coordinator of the size transition.
	func settle(with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: nil) { [weak self] _ in
			guard let self = self else { return }

			if let interfaceOrientation = self.viewController?.view.window?.windowScene?.interfaceOrientation {
				self.effectiveOrientation = Self.mask(for: interfaceOrientation)
			}

			self.isApplyingRotation = false
		}
	}

	/// Returns the interface to portrait when the reader rotated it.
	///
	/// - Returns: `true` when a rotation was issued.
	@discardableResult
	func restorePortrait() -> Bool {
		guard self.forcedOrientation != nil else { return false }

		self.applyForcedRotation(.portrait)
		return true
	}

	/// Sets the rotate button's opacity.
	///
	/// - Parameter alpha: The opacity, from `0` to `1`.
	func setButtonAlpha(_ alpha: CGFloat) {
		self.rotateButton?.alpha = alpha
	}

	/// Rotates the interface to the given orientation.
	///
	/// - Parameter orientation: The orientation to rotate to.
	private func applyForcedRotation(_ orientation: UIInterfaceOrientationMask) {
		guard !self.isApplyingRotation else { return }
		self.isApplyingRotation = true

		self.effectiveOrientation = orientation
		self.forcedOrientation = orientation == .portrait ? nil : orientation
		self.hideRotateButton()

		guard let viewController = self.viewController, let windowScene = viewController.view.window?.windowScene else {
			self.isApplyingRotation = false
			return
		}

		if #available(iOS 16.0, *) {
			viewController.setNeedsUpdateOfSupportedInterfaceOrientations()

			windowScene.requestGeometryUpdate(UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)) { [weak self] error in
				print("----- [Orientation] Rotation request failed: \(error)")

				guard let self = self else { return }
				let actualOrientation = Self.mask(for: windowScene.interfaceOrientation)
				self.effectiveOrientation = actualOrientation
				self.forcedOrientation = actualOrientation == .portrait ? nil : actualOrientation
				self.isApplyingRotation = false
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isApplyingRotation = false
		}
	}

	/// Shows the rotate button for the given device orientation.
	///
	/// - Parameter deviceOrientation: The orientation the device is held in.
	private func showRotateButton(for deviceOrientation: UIInterfaceOrientationMask) {
		guard self.rotateButton == nil, let view = self.viewController?.view else { return }

		let rotateButton = AdaptiveCornerButton()
		rotateButton.translatesAutoresizingMaskIntoConstraints = false
		rotateButton.configuration?.title = L10n.tapToRotate
		rotateButton.configuration?.image = UIImage(systemName: "lock.open.rotation")
		rotateButton.configuration?.imagePlacement = .leading
		rotateButton.configuration?.imagePadding = 8
		rotateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .preferredFont(forTextStyle: .subheadline)
			return outgoing
		}
		rotateButton.addAction(UIAction { [weak self] _ in
			self?.applyForcedRotation(deviceOrientation)
		}, for: .touchUpInside)
		rotateButton.alpha = 0

		view.addSubview(rotateButton)
		self.rotateButton = rotateButton

		NSLayoutConstraint.deactivate(self.rotateButtonConstraints)
		self.rotateButtonConstraints = Self.constraints(anchoring: rotateButton, in: view, toBottomEdgeOf: Self.interfaceOrientation(from: deviceOrientation))
		NSLayoutConstraint.activate(self.rotateButtonConstraints)

		var angle = switch (deviceOrientation, self.effectiveOrientation) {
		case (.landscapeLeft, .landscapeRight), (.landscapeRight, .landscapeLeft):
			Self.angle(for: deviceOrientation) * 2
		default:
			Self.angle(for: deviceOrientation) + Self.angle(for: self.effectiveOrientation)
		}

		angle = switch deviceOrientation {
		case .landscapeLeft: self.effectiveOrientation == .landscapeRight ? -angle : angle
		case .landscapeRight: self.effectiveOrientation == .landscapeLeft ? -angle : angle
		case .portraitUpsideDown: angle
		default: -angle
		}

		rotateButton.transform = CGAffineTransform(rotationAngle: angle)

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			rotateButton.alpha = 1
		}

		self.hideTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 5_000_000_000)
			guard !Task.isCancelled else { return }

			self?.hideRotateButton()
		}
	}

	/// Hides the rotate button.
	private func hideRotateButton() {
		self.hideTask?.cancel()
		self.hideTask = nil

		guard let rotateButton = self.rotateButton else { return }

		self.rotateButton = nil
		NSLayoutConstraint.deactivate(self.rotateButtonConstraints)
		self.rotateButtonConstraints.removeAll()

		UIView.animate(withDuration: 0.22, animations: {
			rotateButton.alpha = 0
		}, completion: { _ in
			rotateButton.removeFromSuperview()
		})
	}

	/// Returns the constraints placing the button along the edge the device rests on.
	///
	/// - Parameters:
	///    - button: The button to place.
	///    - view: The view the button sits in.
	///    - deviceOrientation: The orientation the device is held in.
	///
	/// - Returns: The constraints to activate.
	private static func constraints(anchoring button: UIButton, in view: UIView, toBottomEdgeOf deviceOrientation: UIInterfaceOrientation) -> [NSLayoutConstraint] {
		guard let interfaceOrientation = view.window?.windowScene?.interfaceOrientation else { return [] }

		let delta = (Self.quarterTurns(of: deviceOrientation) - Self.quarterTurns(of: interfaceOrientation) + 4) % 4
		let halfHeight = button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height / 2.0
		let safeArea = view.safeAreaLayoutGuide

		switch delta {
		case 1:
			return [
				button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				button.centerXAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Self.edgeGap + halfHeight)
			]
		case 2:
			return [
				button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				button.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Self.edgeGap)
			]
		case 3:
			return [
				button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				button.centerXAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -(Self.edgeGap + halfHeight))
			]
		default:
			return [
				button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -Self.edgeGap)
			]
		}
	}

	/// Returns the number of quarter turns from portrait to the given orientation.
	///
	/// - Parameter orientation: The orientation to measure.
	///
	/// - Returns: The quarter turns, clockwise.
	private static func quarterTurns(of orientation: UIInterfaceOrientation) -> Int {
		switch orientation {
		case .landscapeRight: return 1
		case .portraitUpsideDown: return 2
		case .landscapeLeft: return 3
		default: return 0
		}
	}

	/// Returns the mask for the given orientation.
	///
	/// - Parameter orientation: The orientation to convert.
	///
	/// - Returns: The matching mask.
	private static func mask(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask {
		switch orientation {
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		case .portraitUpsideDown: return .portraitUpsideDown
		default: return .portrait
		}
	}

	/// Returns the orientation for the given mask.
	///
	/// - Parameter mask: The mask to convert.
	///
	/// - Returns: The matching orientation.
	private static func interfaceOrientation(from mask: UIInterfaceOrientationMask) -> UIInterfaceOrientation {
		switch mask {
		case .landscapeLeft: return .landscapeLeft
		case .landscapeRight: return .landscapeRight
		case .portraitUpsideDown: return .portraitUpsideDown
		default: return .portrait
		}
	}

	/// Returns the rotation of the given orientation relative to upright.
	///
	/// - Parameter mask: The orientation to measure.
	///
	/// - Returns: The rotation in radians.
	private static func angle(for mask: UIInterfaceOrientationMask) -> CGFloat {
		switch mask {
		case .landscapeLeft: return .pi / 2
		case .landscapeRight: return -.pi / 2
		case .portraitUpsideDown: return 0
		default: return .pi
		}
	}
}

// MARK: - OrientationManagerDelegate
extension PortraitLockBuddy: OrientationManagerDelegate {
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIInterfaceOrientationMask) {
		self.offerTask?.cancel()
		self.hideRotateButton()

		guard UserSettings.isPortraitLockBuddyEnabled, !self.isApplyingRotation else { return }

		self.offerTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 700_000_000)
			guard !Task.isCancelled else { return }

			self?.offerRotation(to: deviceOrientation)
		}
	}

	/// Offers the rotate button when the system left the interface turned away from the device.
	///
	/// - Parameter deviceOrientation: The orientation the device is held in.
	private func offerRotation(to deviceOrientation: UIInterfaceOrientationMask) {
		guard !self.isApplyingRotation, let view = self.viewController?.view else { return }

		let interfaceOrientation = Self.mask(for: view.window?.windowScene?.interfaceOrientation ?? .portrait)
		let deviceOrientation = !UIDevice.current.isPortraitUpsideDownSupported && deviceOrientation == .portraitUpsideDown ? interfaceOrientation : deviceOrientation

		if deviceOrientation == interfaceOrientation {
			self.effectiveOrientation = interfaceOrientation
			return
		}

		guard deviceOrientation != self.effectiveOrientation else { return }

		self.showRotateButton(for: deviceOrientation)
	}
}
