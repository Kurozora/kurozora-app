//
//  MotionOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

protocol MotionOptionsViewControllerDelegate: AnyObject {
	func motionOptionsViewController(_ vc: MotionOptionsViewController, didChangeAnimationTo animation: SplashScreenAnimation)
}

class MotionOptionsViewController: SubSettingsViewController {
	private enum Section: Int {
		case preview
	}

	// MARK: - Properties
	weak var delegate: MotionOptionsViewControllerDelegate?
	private var selectedAnimation: SplashScreenAnimation = UserSettings.currentSplashScreenAnimation
	private let previewPlaybackID = UUID()
	private var reduceMotionStatusObserver: NSObjectProtocol?
	private var isViewVisible = false

	private var previewCell: MotionAnimationPreviewCell? {
		return self.tableView.cellForRow(at: IndexPath(row: 0, section: Section.preview.rawValue)) as? MotionAnimationPreviewCell
	}

	private var isReduceMotionPreviewEnabled: Bool {
		return UserSettings.isReduceMotionEnabled || UIAccessibility.isReduceMotionEnabled
	}

	private var previewPlaybackConfiguration: AnimationPlaybackConfiguration {
		return AnimationPlaybackConfiguration(
			loopMode: self.isReduceMotionPreviewEnabled ? .once : .infinite,
			delayBetweenLoops: self.isReduceMotionPreviewEnabled ? 0.0 : 1.25,
			initialDelay: 0.0,
			isInterruptible: true,
			playbackID: self.previewPlaybackID
		)
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.splashScreen

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.reduceMotionStatusObserver = NotificationCenter.default.addObserver(
			forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			MainActor.assumeIsolated {
				guard let self = self else { return }
				self.previewCell?.configure(animation: self.selectedAnimation, playbackConfiguration: self.previewPlaybackConfiguration)
				self.restartPreview(forceResume: true)
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.isViewVisible = true
		self.restartPreview()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.isViewVisible = false
		self.stopPreview()
	}

	isolated deinit {
		if let reduceMotionStatusObserver {
			NotificationCenter.default.removeObserver(reduceMotionStatusObserver)
		}
		self.stopPreview()
	}

	private func restartPreview(forceResume: Bool = false) {
		guard self.isViewVisible else { return }
		guard self.selectedAnimation != .none else {
			self.stopPreview()
			return
		}
		guard let previewCell = self.previewCell else { return }

		previewCell.configure(animation: self.selectedAnimation, playbackConfiguration: self.previewPlaybackConfiguration)
		previewCell.restartPlayback(forceResume: forceResume)
	}

	private func stopPreview() {
		self.previewCell?.stopPlayback()
		Animation.shared.cancelPlayback(with: self.previewPlaybackID)
	}

	/// Returns the animation group shown in the given section.
	///
	/// - Parameter section: The section to resolve.
	///
	/// - Returns: The group, or `nil` for the preview section.
	private func group(forSection section: Int) -> SplashScreenAnimationGroup? {
		let index = section - 1

		guard index >= 0, index < SplashScreenAnimationGroup.allCases.count else { return nil }

		return SplashScreenAnimationGroup.allCases[index]
	}
}

// MARK: - UITableViewDataSource
extension MotionOptionsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1 + SplashScreenAnimationGroup.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let group = self.group(forSection: section) else { return 1 }

		return group.animations.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let group = self.group(forSection: indexPath.section) else {
			guard let cell = tableView.dequeueReusableCell(withIdentifier: MotionAnimationPreviewCell.self, for: indexPath) else {
				fatalError("Couldn't dequeue cell with identifier \(MotionAnimationPreviewCell.reuseID)")
			}
			cell.configure(animation: self.selectedAnimation, playbackConfiguration: self.previewPlaybackConfiguration)

			if self.isViewVisible {
				cell.startPlayback()
			} else {
				cell.stopPlayback()
			}

			return cell
		}

		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Couldn't dequeue cell with identifier \(IconTableViewCell.reuseID)")
		}
		let animation = group.animations[indexPath.row]

		iconTableViewCell.setSelected(animation == self.selectedAnimation)
		iconTableViewCell.configureCell(using: animation)

		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let group = self.group(forSection: section) else { return L10n.preview }

		guard !group.animations.isEmpty else { return nil }

		return group.titleValue
	}
}

// MARK: - UITableViewDelegate
extension MotionOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let group = self.group(forSection: indexPath.section) else { return }

		let animation = group.animations[indexPath.row]

		guard group.isPremium else {
			self.changeAnimation(animation)
			return
		}

		Task { [weak self] in
			guard let self = self else { return }

			if await WorkflowController.shared.isProOrSubscribed(on: self) {
				self.changeAnimation(animation)
			}
		}
	}

	private func changeAnimation(_ animation: SplashScreenAnimation) {
		Animation.shared.changeAnimation(to: animation)

		self.selectedAnimation = animation
		self.delegate?.motionOptionsViewController(self, didChangeAnimationTo: animation)

		self.stopPreview()
		self.restartPreview(forceResume: true)
		self.tableView.reloadSections(IndexSet(1 ..< self.tableView.numberOfSections), with: .none)
	}
}

// MARK: - KTableViewDataSource
extension MotionOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			IconTableViewCell.self,
			MotionAnimationPreviewCell.self
		]
	}
}
