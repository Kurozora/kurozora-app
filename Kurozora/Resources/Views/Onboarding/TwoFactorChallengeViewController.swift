//
//  TwoFactorChallengeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A type that receives the outcome of a two-factor authentication challenge.
protocol TwoFactorChallengeDelegate: AnyObject {
	/// Tells the delegate that the user supplied a valid code and the API returned an authentication token.
	///
	/// - Parameter authToken: The authentication token returned by the API.
	func twoFactorChallengeDidSucceed(authToken: String)

	/// Tells the delegate that the challenge token expired or the retry limit was exceeded.
	func twoFactorChallengeDidExpire()
}

/// The kinds of code accepted by ``TwoFactorChallengeViewController``.
enum TwoFactorInputMode {
	case totp
	case recovery
}

final class TwoFactorChallengeViewController: AccountOnboardingTableViewController {
	// MARK: - Types
	/// API error IDs surfaced by the two-factor challenge endpoint.
	private enum TwoFactorError {
		static let invalidCodeID = 40022
		static let challengeExpiredID = 40001
	}

	// MARK: - Properties
	private let challengeToken: String
	private weak var twoFactorDelegate: TwoFactorChallengeDelegate?
	private var inputMode: TwoFactorInputMode = .totp

	// MARK: - Initializers
	init(challengeToken: String, delegate: TwoFactorChallengeDelegate) {
		self.challengeToken = challengeToken
		self.twoFactorDelegate = delegate
		super.init()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.accountOnboardingType = .twoFactor
		self.tableView.keyboardDismissMode = .interactive
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.textFieldArray.first??.becomeFirstResponder()
	}

	// MARK: - KTableViewControllerDataSource
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			OnboardingHeaderTableViewCell.self,
			OnboardingTextFieldTableViewCell.self,
			TwoFactorToggleTableViewCell.self
		]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = self.accountOnboardingType.sections[indexPath.section]

		switch section {
		case .options:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: TwoFactorToggleTableViewCell.self, for: indexPath) else {
				return UITableViewCell()
			}
			let title = self.inputMode == .totp
				? L10n.Onboarding.twoFactorUseRecoveryCode
				: L10n.Onboarding.twoFactorUseTOTP
			cell.configure(title: title, delegate: self)
			return cell
		default:
			let cell = super.tableView(tableView, cellForRowAt: indexPath)
			if section == .header, let headerCell = cell as? OnboardingHeaderTableViewCell {
				headerCell.secondaryLabel.text = self.inputMode == .totp
					? L10n.Onboarding.twoFactorSubheadlineTOTP
					: L10n.Onboarding.twoFactorSubheadlineRecovery
			} else if section == .textFields, let textFieldCell = cell as? OnboardingTextFieldTableViewCell {
				self.applyMode(to: textFieldCell.textField)
			}
			return cell
		}
	}

	// MARK: - Functions
	/// Applies the active input mode to the OTP text field.
	///
	/// - Parameter textField: The text field to configure.
	private func applyMode(to textField: UITextField) {
		switch self.inputMode {
		case .totp:
			textField.placeholder = L10n.Onboarding.twoFactorTOTPPlaceholder
			textField.keyboardType = .numberPad
			textField.textContentType = .oneTimeCode
		case .recovery:
			textField.placeholder = L10n.Onboarding.twoFactorRecoveryPlaceholder
			textField.keyboardType = .asciiCapable
			textField.textContentType = nil
		}
	}

	/// Returns the trimmed contents of the input field in API-ready form, or `nil` when empty.
	private func currentInputText() -> String? {
		guard let text = self.textFieldArray.first??.text else { return nil }
		let raw: String
		switch self.inputMode {
		case .totp:
			raw = text.replacingOccurrences(of: " ", with: "")
		case .recovery:
			raw = text
		}
		let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}

	/// Returns a Boolean value indicating whether the current input matches the active mode's pattern.
	private func isCurrentInputValid() -> Bool {
		guard let text = self.currentInputText() else { return false }
		switch self.inputMode {
		case .totp:
			return text.range(of: #"^\d{6}$"#, options: .regularExpression) != nil
		case .recovery:
			return text.range(of: #"^[A-Za-z0-9]{10}-[A-Za-z0-9]{10}$"#, options: .regularExpression) != nil
		}
	}

	/// Submits the entered code to the API and forwards the result to the delegate.
	///
	/// - Parameter code: The code to verify.
	private func submit(code: String) async {
		do {
			let request = self.inputMode == .totp
				? KService.submitTwoFactorChallenge(token: self.challengeToken).otp(code)
				: KService.submitTwoFactorChallenge(token: self.challengeToken).recoveryCode(code)
			let response = try await request.response()
			self.twoFactorDelegate?.twoFactorChallengeDidSucceed(authToken: response.authenticationToken)
		} catch let error as APIError {
			self.disableUserInteraction(false)
			self.handle(error)
		} catch {
			self.disableUserInteraction(false)
			self.presentAlertController(title: L10n.error, message: L10n.Onboarding.twoFactorNetworkError)
		}
	}

	/// Routes an API error to an alert or signals expiry to the delegate.
	///
	/// - Parameter error: The error returned by the verification request.
	private func handle(_ error: APIError) {
		guard let firstID = error.errors.first?.id else {
			self.presentAlertController(title: L10n.error, message: error.message)
			return
		}

		switch firstID {
		case TwoFactorError.invalidCodeID:
			self.presentAlertController(title: L10n.error, message: L10n.Onboarding.twoFactorInvalidCode)
		case TwoFactorError.challengeExpiredID:
			self.twoFactorDelegate?.twoFactorChallengeDidExpire()
		default:
			self.presentAlertController(title: L10n.error, message: error.message)
		}
	}

	/// Toggles between TOTP and recovery input modes and refreshes the table.
	private func toggleInputMode() {
		self.inputMode = self.inputMode == .totp ? .recovery : .totp
		self.textFieldArray.removeAll()
		self.tableView.reloadData()
		DispatchQueue.main.async { [weak self] in
			self?.textFieldArray.first??.becomeFirstResponder()
		}
	}

	// MARK: - Actions
	override func editingChanged(_ textField: UITextField) {
		let raw = self.stripSeparators(textField.text ?? "")
		let bounded = String(raw.prefix(self.maxRawLength()))
		let formatted = self.formatted(bounded)

		if textField.text != formatted {
			textField.text = formatted

			if let end = textField.position(from: textField.beginningOfDocument, offset: formatted.count) {
				textField.selectedTextRange = textField.textRange(from: end, to: end)
			}
		}

		self.rightNavigationBarButton.isEnabled = self.isCurrentInputValid()
	}

	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		guard let text = self.currentInputText(), self.isCurrentInputValid() else {
			if self.inputMode == .recovery {
				self.presentAlertController(title: L10n.error, message: L10n.Onboarding.twoFactorInvalidFormat)
			}
			return
		}

		super.rightNavigationBarButtonPressed(sender: sender)

		Task { [weak self] in
			guard let self = self else { return }
			await self.submit(code: text)
		}
	}
}

// MARK: - TwoFactorToggleTableViewCellDelegate
extension TwoFactorChallengeViewController: TwoFactorToggleTableViewCellDelegate {
	func twoFactorToggleDidTapToggle() {
		self.toggleInputMode()
	}
}

// MARK: - Formatting helpers
private extension TwoFactorChallengeViewController {
	/// Returns the maximum number of separator-free characters accepted in the active mode.
	func maxRawLength() -> Int {
		switch self.inputMode {
		case .totp:
			return 6
		case .recovery:
			return 20
		}
	}

	/// Returns `value` with the active mode's display separator removed.
	///
	/// - Parameter value: The string to strip.
	func stripSeparators(_ value: String) -> String {
		switch self.inputMode {
		case .totp:
			return value.replacingOccurrences(of: " ", with: "")
		case .recovery:
			return value.replacingOccurrences(of: "-", with: "")
		}
	}

	/// Returns `raw` with the active mode's display formatting applied.
	///
	/// - Parameter raw: A separator-free string.
	func formatted(_ raw: String) -> String {
		switch self.inputMode {
		case .totp:
			guard raw.count > 3 else { return raw }
			let head = raw.prefix(3)
			let tail = raw.dropFirst(3)
			return "\(head) \(tail)"
		case .recovery:
			guard raw.count > 10 else { return raw }
			let head = raw.prefix(10)
			let tail = raw.dropFirst(10)
			return "\(head)-\(tail)"
		}
	}
}
