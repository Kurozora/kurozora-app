//
//  KDownloadButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The visible state of a `KDownloadButton`.
enum KDownloadButtonState: Equatable {
	case start(title: String)
	case pending
	case downloading(progress: Double)
	case downloaded(title: String, opensMenuOnTap: Bool)
}

final class KDownloadButton: UIControl {
	// MARK: - Views
	private let startButton = KTintedButton(type: .system)
	private let downloadedButton = KTintedButton(type: .system)
	private let pendingArc = KDownloadArcView()
	private let progressRing = KDownloadProgressView()

	// MARK: - Properties
	private let ringDiameter: CGFloat = 30

	var onTap: ((KDownloadButtonState) -> Void)?

	var menu: UIMenu? {
		get {
			return self.downloadedButton.menu
		}
		set {
			self.downloadedButton.menu = newValue
			self.applyChevronVisibility()
		}
	}

	private(set) var currentState: KDownloadButtonState = .start(title: L10n.themeButtonGet)

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override var intrinsicContentSize: CGSize {
		return CGSize(width: self.preferredWidth(for: self.currentState), height: self.ringDiameter)
	}

	// MARK: - Functions
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = .clear

		for child in [self.startButton, self.downloadedButton, self.pendingArc, self.progressRing] as [UIView] {
			child.translatesAutoresizingMaskIntoConstraints = false
			child.isUserInteractionEnabled = false

			self.addSubview(child)

			NSLayoutConstraint.activate([
				child.leadingAnchor.constraint(equalTo: self.leadingAnchor),
				child.trailingAnchor.constraint(equalTo: self.trailingAnchor),
				child.topAnchor.constraint(equalTo: self.topAnchor),
				child.bottomAnchor.constraint(equalTo: self.bottomAnchor)
			])
		}

		self.startButton.layerCornerRadius = self.ringDiameter / 2
		self.downloadedButton.layerCornerRadius = self.ringDiameter / 2
		self.startButton.setTitle(L10n.themeButtonGet, for: .normal)
		self.downloadedButton.setTitle(L10n.themeButtonUsing, for: .normal)

		self.addTarget(self, action: #selector(self.handleTouchUpInside), for: .touchUpInside)
		self.downloadedButton.addTarget(self, action: #selector(self.handleDownloadedButtonTap), for: .touchUpInside)

		self.applyState(.start(title: L10n.themeButtonGet), animated: false)
	}

	@objc private func handleTouchUpInside() {
		self.onTap?(self.currentState)
	}

	@objc private func handleDownloadedButtonTap() {
		if case .downloaded(_, let opensMenuOnTap) = self.currentState, !opensMenuOnTap {
			self.onTap?(self.currentState)
		}
	}

	/// Updates the displayed state.
	///
	/// - Parameters:
	///   - state: The new state to render.
	///   - animated: Whether to cross-fade and animate the width change.
	func setState(_ newState: KDownloadButtonState, animated: Bool) {
		if Self.sameKind(self.currentState, newState) {
			self.currentState = newState

			switch newState {
			case .start(let title):
				self.startButton.setTitle(title, for: .normal)
			case .downloaded(let title, let opensMenuOnTap):
				self.downloadedButton.setTitle(title, for: .normal)
				self.downloadedButton.showsMenuAsPrimaryAction = opensMenuOnTap
			case .pending:
				break
			case .downloading(let progress):
				self.progressRing.setProgress(progress, animated: animated)
			}

			self.invalidateIntrinsicContentSize()
			return
		}

		self.applyState(newState, animated: animated)
	}

	private static func sameKind(_ lhs: KDownloadButtonState, _ rhs: KDownloadButtonState) -> Bool {
		switch (lhs, rhs) {
		case (.start, .start), (.pending, .pending), (.downloading, .downloading), (.downloaded, .downloaded):
			return true
		default:
			return false
		}
	}

	private func applyState(_ newState: KDownloadButtonState, animated: Bool) {
		self.currentState = newState

		switch newState {
		case .start(let title):
			self.startButton.setTitle(title, for: .normal)
		case .downloaded(let title, let opensMenuOnTap):
			self.downloadedButton.setTitle(title, for: .normal)
			self.downloadedButton.showsMenuAsPrimaryAction = opensMenuOnTap
		case .pending, .downloading:
			break
		}

		self.applyChevronVisibility()

		self.downloadedButton.isUserInteractionEnabled = {
			if case .downloaded = newState {
				return true
			}
			return false
		}()

		let visibleViews = self.visibleViews(for: newState)

		let transition: () -> Void = { [weak self] in
			guard let self = self else { return }

			for view in [self.startButton, self.downloadedButton, self.pendingArc, self.progressRing] as [UIView] {
				view.alpha = visibleViews.contains { $0 === view } ? 1 : 0
			}

			self.invalidateIntrinsicContentSize()
			self.superview?.layoutIfNeeded()
		}

		if animated {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: transition, completion: nil)
		} else {
			transition()
		}

		if case .downloading(let progress) = newState {
			self.progressRing.setProgress(progress, animated: animated)
		}
	}

	private func visibleViews(for newState: KDownloadButtonState) -> [UIView] {
		switch newState {
		case .start:
			return [self.startButton]
		case .downloaded:
			return [self.downloadedButton]
		case .pending:
			return [self.pendingArc]
		case .downloading:
			return [self.progressRing]
		}
	}

	private func applyChevronVisibility() {
		switch self.currentState {
		case .downloaded where self.downloadedButton.menu != nil:
			let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
			self.downloadedButton.configuration?.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfiguration)
			self.downloadedButton.configuration?.imagePlacement = .trailing
			self.downloadedButton.configuration?.imagePadding = 4
		default:
			self.downloadedButton.configuration?.image = nil
		}
	}

	private func preferredWidth(for state: KDownloadButtonState) -> CGFloat {
		switch state {
		case .pending, .downloading:
			return self.ringDiameter
		case .start:
			return self.pillWidth(for: self.startButton)
		case .downloaded:
			return self.pillWidth(for: self.downloadedButton)
		}
	}

	private func pillWidth(for button: UIButton) -> CGFloat {
		let fitting = button.systemLayoutSizeFitting(
			UIView.layoutFittingCompressedSize,
			withHorizontalFittingPriority: .fittingSizeLevel,
			verticalFittingPriority: .required
		)
		return max(self.ringDiameter, ceil(fitting.width))
	}
}
