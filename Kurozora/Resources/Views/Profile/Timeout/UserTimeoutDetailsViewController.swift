//
//  UserTimeoutDetailsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class UserTimeoutDetailsViewController: KViewController {
	// MARK: - Views
	private let scrollView = UIScrollView()
	private let contentStackView = UIStackView()
	private let infoStackView = UIStackView()
	private let buttonsStackView = UIStackView()

	private let iconImageView = UIImageView()
	private let headlineLabel = KLabel()

	private let infoCardView = UIView()
	private let infoCardStackView = UIStackView()
	private let reasonValueLabel = KLabel()
	private let expiryValueLabel = KLabel()
	private let noteValueLabel = KLabel()
	private let noteDividerView = SeparatorView()
	private var noteRowView: UIView!

	private let appealCardView = UIView()
	private let appealCardStackView = UIStackView()
	private let appealHeaderLabel = KSecondaryLabel()
	private let appealMessageLabel = KLabel()
	private let appealFiledLabel = KSecondaryLabel()

	private let primaryActionButton = KTintedButton()
	private let guidelinesButton = KButton()
	private let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)

	// MARK: - Properties
	/// The user whose timeout is being shown.
	var user: User!

	/// The timeout being shown.
	var timeout: UserTimeout!

	/// Whether the viewer is a moderator inspecting another user's timeout.
	var isAdminView: Bool = false

	/// The timer refreshing the relative expiry copy.
	private var countdownTimer: Timer?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.isAdminView ? L10n.suspensionDetails : L10n.accountSuspended
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.cancelBarButtonItem.target = self
		self.cancelBarButtonItem.action = #selector(self.dismissTapped)
		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleTimeoutDidChange(_:)), name: .KUserTimeoutDidChange, object: nil)

		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureContent()
		self.startCountdown()
	}

	deinit {
		self.countdownTimer?.invalidate()
		self.countdownTimer = nil
	}

	// MARK: - Configuration
	private func configureViewHierarchy() {
		self.iconImageView.image = UIImage(systemName: "exclamationmark.octagon.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 48))
		self.iconImageView.contentMode = .left
		self.iconImageView.theme_tintColor = KThemePicker.tintColor.rawValue

		self.headlineLabel.font = .preferredFont(forTextStyle: .title1).bold
		self.headlineLabel.numberOfLines = 0

		self.configureInfoCard()
		self.configureAppealCard()

		self.primaryActionButton.addTarget(self, action: #selector(self.primaryActionTapped), for: .touchUpInside)

		self.guidelinesButton.setTitle(L10n.communityGuidelines, for: .normal)
		self.guidelinesButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		self.guidelinesButton.addTarget(self, action: #selector(self.guidelinesButtonTapped), for: .touchUpInside)

		self.infoStackView.axis = .vertical
		self.infoStackView.spacing = 16
		[
			self.iconImageView,
			self.headlineLabel,
			self.infoCardView,
			self.appealCardView,
		].forEach { self.infoStackView.addArrangedSubview($0) }
		self.infoStackView.setCustomSpacing(12, after: self.iconImageView)

		self.buttonsStackView.axis = .vertical
		self.buttonsStackView.spacing = 12
		self.buttonsStackView.addArrangedSubview(self.primaryActionButton)
		self.buttonsStackView.addArrangedSubview(self.guidelinesButton)

		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 28
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.addArrangedSubview(self.infoStackView)
		self.contentStackView.addArrangedSubview(self.buttonsStackView)

		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.addSubview(self.contentStackView)
		self.view.addSubview(self.scrollView)
	}

	private func configureInfoCard() {
		self.infoCardView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.infoCardView.layerCornerRadius = 14
		self.infoCardView.translatesAutoresizingMaskIntoConstraints = false

		let reasonEndsDivider = SeparatorView()
		reasonEndsDivider.translatesAutoresizingMaskIntoConstraints = false
		self.noteDividerView.translatesAutoresizingMaskIntoConstraints = false

		self.noteRowView = self.makeInfoRow(title: L10n.moderatorNote, valueLabel: self.noteValueLabel)

		self.infoCardStackView.axis = .vertical
		self.infoCardStackView.spacing = 12
		self.infoCardStackView.translatesAutoresizingMaskIntoConstraints = false
		self.infoCardStackView.addArrangedSubview(self.makeInfoRow(title: L10n.suspensionReasonLabel, valueLabel: self.reasonValueLabel))
		self.infoCardStackView.addArrangedSubview(reasonEndsDivider)
		self.infoCardStackView.addArrangedSubview(self.makeInfoRow(title: L10n.suspensionEndsLabel, valueLabel: self.expiryValueLabel))
		self.infoCardStackView.addArrangedSubview(self.noteDividerView)
		self.infoCardStackView.addArrangedSubview(self.noteRowView)

		self.infoCardView.addSubview(self.infoCardStackView)

		NSLayoutConstraint.activate([
			reasonEndsDivider.heightAnchor.constraint(equalToConstant: 1),
			self.noteDividerView.heightAnchor.constraint(equalToConstant: 1),

			self.infoCardStackView.topAnchor.constraint(equalTo: self.infoCardView.topAnchor, constant: 16),
			self.infoCardStackView.leadingAnchor.constraint(equalTo: self.infoCardView.leadingAnchor, constant: 16),
			self.infoCardStackView.trailingAnchor.constraint(equalTo: self.infoCardView.trailingAnchor, constant: -16),
			self.infoCardStackView.bottomAnchor.constraint(equalTo: self.infoCardView.bottomAnchor, constant: -16),
		])
	}

	private func configureAppealCard() {
		self.appealCardView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.appealCardView.layerCornerRadius = 14
		self.appealCardView.translatesAutoresizingMaskIntoConstraints = false

		self.appealHeaderLabel.font = .preferredFont(forTextStyle: .footnote)
		self.appealMessageLabel.font = .preferredFont(forTextStyle: .body)
		self.appealMessageLabel.numberOfLines = 0
		self.appealFiledLabel.font = .preferredFont(forTextStyle: .caption2)
		self.appealFiledLabel.numberOfLines = 0

		self.appealCardStackView.axis = .vertical
		self.appealCardStackView.spacing = 2
		self.appealCardStackView.translatesAutoresizingMaskIntoConstraints = false
		self.appealCardStackView.addArrangedSubview(self.appealHeaderLabel)
		self.appealCardStackView.addArrangedSubview(self.appealMessageLabel)
		self.appealCardStackView.addArrangedSubview(self.appealFiledLabel)
		self.appealCardStackView.setCustomSpacing(8, after: self.appealMessageLabel)

		self.appealCardView.addSubview(self.appealCardStackView)

		NSLayoutConstraint.activate([
			self.appealCardStackView.topAnchor.constraint(equalTo: self.appealCardView.topAnchor, constant: 16),
			self.appealCardStackView.leadingAnchor.constraint(equalTo: self.appealCardView.leadingAnchor, constant: 16),
			self.appealCardStackView.trailingAnchor.constraint(equalTo: self.appealCardView.trailingAnchor, constant: -16),
			self.appealCardStackView.bottomAnchor.constraint(equalTo: self.appealCardView.bottomAnchor, constant: -16),
		])
	}

	/// Builds a labeled info row pairing a caption with a value label.
	///
	/// - Parameters:
	///    - title: The leading caption describing the value.
	///    - valueLabel: The label that renders the value.
	///
	/// - Returns: A vertical stack containing the caption above the value.
	private func makeInfoRow(title: String, valueLabel: KLabel) -> UIView {
		let titleLabel = KSecondaryLabel()
		titleLabel.font = .preferredFont(forTextStyle: .footnote)
		titleLabel.text = title

		valueLabel.font = .preferredFont(forTextStyle: .body)
		valueLabel.numberOfLines = 0

		let rowStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
		rowStackView.axis = .vertical
		rowStackView.spacing = 2

		return rowStackView
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.contentStackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 24),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
			self.contentStackView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor, constant: -40),

			self.iconImageView.heightAnchor.constraint(equalToConstant: 50),
			self.primaryActionButton.heightAnchor.constraint(equalToConstant: 44),
		])
	}

	private func configureContent() {
		let attributes = self.timeout.attributes

		self.headlineLabel.text = attributes.suspensionHeadline(displayName: self.user.attributes.username, isAdminView: self.isAdminView)
		self.reasonValueLabel.text = attributes.reasonLabel
		self.refreshExpiryValue()

		if let note = attributes.note, !note.isEmpty {
			self.noteValueLabel.text = note
			self.noteRowView.isHidden = false
			self.noteDividerView.isHidden = false
		} else {
			self.noteRowView.isHidden = true
			self.noteDividerView.isHidden = true
		}

		let appeal = self.timeout.relationships?.appeal?.data.first

		if let appeal = appeal {
			self.appealHeaderLabel.text = self.isAdminView ? L10n.appealFrom(self.user.attributes.username) : L10n.yourAppeal
			self.appealMessageLabel.text = appeal.attributes.message
			self.appealFiledLabel.text = L10n.appealFiled(appeal.attributes.updatedAt.formatted(date: .abbreviated, time: .shortened))

			self.appealCardView.isHidden = false
		} else {
			self.appealCardView.isHidden = true
		}

		if self.isAdminView {
			self.primaryActionButton.setTitle(L10n.revokeTimeout, for: .normal)
			self.guidelinesButton.isHidden = true
		} else {
			self.primaryActionButton.setTitle(appeal != nil ? L10n.editAppealAction : L10n.contestSuspensionAction, for: .normal)
			self.guidelinesButton.isHidden = false
		}
	}

	private func refreshExpiryValue() {
		self.expiryValueLabel.text = self.timeout.attributes.suspensionExpiryValue()
	}

	private func startCountdown() {
		guard !self.timeout.attributes.isPermanent, self.timeout.attributes.expiresAt != nil else {
			return
		}

		self.countdownTimer?.invalidate()
		self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
			self?.refreshExpiryValue()
		}
	}

	// MARK: - Actions
	@objc private func handleTimeoutDidChange(_ notification: Notification) {
		guard let changedUserID = notification.object as? KurozoraItemID, changedUserID == self.user.id else {
			return
		}

		if self.isAdminView {
			self.dismiss(animated: true)
		}
	}

	@objc private func guidelinesButtonTapped() {
		UIApplication.shared.kOpen(URL(string: self.timeout.attributes.communityGuidelinesURL))
	}

	@objc private func primaryActionTapped() {
		if self.isAdminView {
			self.user.confirmRevokeTimeout(via: self)
		} else {
			let composeViewController = ContestTimeoutViewController()
			composeViewController.existingMessage = self.timeout.relationships?.appeal?.data.first?.attributes.message
			composeViewController.onAppealSubmitted = { [weak self] updatedTimeout in
				guard let self = self else { return }
				self.timeout = updatedTimeout
				self.configureContent()
			}
			let navigationController = UINavigationController(rootViewController: composeViewController)
			self.present(navigationController, animated: true)
		}
	}

	@objc private func dismissTapped() {
		self.dismiss(animated: true)
	}
}
