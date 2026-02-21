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
	private enum Section: Int, CaseIterable {
		case preview
		case options
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

		self.title = Trans.splashScreen

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.reduceMotionStatusObserver = NotificationCenter.default.addObserver(
			forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			guard let self = self else { return }
			self.previewCell?.configure(animation: self.selectedAnimation, playbackConfiguration: self.previewPlaybackConfiguration)
			self.restartPreview(forceResume: true)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.isViewVisible = true
		self.restartPreview()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.restartPreview()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.isViewVisible = false
		self.stopPreview()
	}

	deinit {
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
}

// MARK: - UITableViewDataSource
extension MotionOptionsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }

		switch section {
		case .preview:
			return 1
		case .options:
			return SplashScreenAnimation.allCases.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

		switch section {
		case .preview:
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
		case .options:
			guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
				fatalError("Couldn't dequeue cell with identifier \(IconTableViewCell.reuseID)")
			}
			let animation = SplashScreenAnimation.allCases[indexPath.row]
			let currentAnimation = self.selectedAnimation

			iconTableViewCell.setSelected(animation.titleValue == currentAnimation.titleValue)
			iconTableViewCell.configureCell(using: animation)

			return iconTableViewCell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }
		switch section {
		case .preview:
			return "Preview"
		case .options:
			return Trans.animations
		}
	}
}

// MARK: - UITableViewDelegate
extension MotionOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let section = Section(rawValue: indexPath.section),
			section == .options
		else { return }

		let animation = SplashScreenAnimation.allCases[indexPath.row]

		self.changeAnimation(animation)
	}

	private func changeAnimation(_ animation: SplashScreenAnimation) {
		Animation.shared.changeAnimation(to: animation)

		self.selectedAnimation = animation
		self.delegate?.motionOptionsViewController(self, didChangeAnimationTo: animation)

		self.stopPreview()
		self.restartPreview(forceResume: true)
		self.tableView.reloadSections(IndexSet(integer: Section.options.rawValue), with: .none)
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
