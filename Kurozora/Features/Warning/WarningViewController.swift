//
//  WarningViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

final class WarningViewController: KViewController {
	// MARK: - Views
	private lazy var primaryImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var primaryLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var secondaryLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var actionButton: KButton = {
		let button = KButton(type: .system)
		button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.actionButtonPressed(_:)), for: .touchUpInside)
		return button
	}()

	// MARK: - Properties
	/// The kind of warning being displayed.
	var warningType: WarningType = .noSignal

	/// The window on which the main view should be installed when the user resolves the warning.
	var window: UIWindow?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.primaryImageView)
		self.view.addSubview(self.primaryLabel)
		self.view.addSubview(self.secondaryLabel)
		self.view.addSubview(self.actionButton)

		NSLayoutConstraint.activate([
			self.primaryImageView.heightAnchor.constraint(equalToConstant: 96.0),
			self.primaryImageView.widthAnchor.constraint(equalTo: self.primaryImageView.heightAnchor),
			self.primaryImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),

			self.primaryLabel.topAnchor.constraint(equalTo: self.primaryImageView.bottomAnchor, constant: 20.0),
			self.primaryLabel.centerXAnchor.constraint(equalTo: self.primaryImageView.centerXAnchor),
			self.primaryLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			self.primaryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.view.safeAreaLayoutGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.primaryLabel.trailingAnchor),

			self.secondaryLabel.topAnchor.constraint(equalTo: self.primaryLabel.bottomAnchor, constant: 8.0),
			self.secondaryLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
			self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.secondaryLabel.trailingAnchor, constant: 20.0),
			self.secondaryLabel.centerXAnchor.constraint(equalTo: self.primaryLabel.centerXAnchor),

			self.actionButton.topAnchor.constraint(equalTo: self.secondaryLabel.bottomAnchor, constant: 20.0),
			self.actionButton.centerXAnchor.constraint(equalTo: self.secondaryLabel.centerXAnchor)
		])

		self.applyWarning()

		KNetworkManager.shared.reachability.whenReachable = { [weak self] _ in
			guard let self = self else { return }
			self.actionButtonPressed(nil)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// MARK: - Functions
	private func applyWarning() {
		self.primaryImageView.image = self.warningType.image
		self.primaryLabel.text = self.warningType.title
		self.secondaryLabel.text = self.warningType.message
		self.actionButton.setTitle(self.warningType.buttonTitle, for: .normal)
	}

	/// Handles the warning's action button tap, resolving each warning type via its dedicated flow.
	///
	/// - Parameter sender: The button that triggered the action, or `nil` when invoked from the reachability callback.
	@objc func actionButtonPressed(_ sender: UIButton?) {
		switch self.warningType {
		case .forceUpdate:
			UIApplication.shared.kOpen(nil, deepLink: .appStoreURL)
		case .maintenance:
			UIApplication.shared.kOpen(.twitterPageURL, deepLink: .twitterPageDeepLink)
		case .noSignal:
			KNetworkManager.isReachable { [weak self] _ in
				guard let self = self else { return }
				KurozoraDelegate.shared.showMainPage(for: self.window, viewController: self)
			}
		}
	}
}
