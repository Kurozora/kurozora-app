//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum AccountSetting {
	case language
	case tvRating
	case timezone
}

class AccountTableViewController: SubSettingsViewController {
	// MARK: - Views
	private let profileImageView = ProfileImageView(frame: .zero)
	private let usernameLabel = KLabel()
	private let userEmailLabel = KSecondaryLabel()

	private let headerHeight: CGFloat = 170

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Properties
	var languages: [String: String] = [:]
	var tvRatings: [String: String] = [:]
	var timezones: [String: String] = [:]
	var selectedLanguage: [String: String].Element = ("", "")
	var selectedTVRating: [String: String].Element = ("", "")
	var selectedTimezone: [String: String].Element = ("", "")

	var selectedAccountSetting: AccountSetting?

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.configureUserDetails()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Kurozora Account"

		self.configureTableHeaderView()

		self.languages = self.loadOptions(from: "App Languages")
		self.tvRatings = self.loadOptions(from: "App TV Ratings")
		// If the user doesn't have `R18+` already enabled, then hide it along with the `All` option,
		// just to make sure underaged users, who are more likely to be using the app than the website,
		// don't have access to those options. Adults will figure out how to change it on the website...
		// probably...
		if (User.current?.attributes.preferredTVRating != 5 && User.current?.attributes.preferredTVRating != -1)
			|| User.current == nil {
			self.tvRatings.removeValue(forKey: "-1") // All
			self.tvRatings.removeValue(forKey: "5") // R18+
		}
		self.timezones = self.loadOptions(from: "App Timezones")

		self.configureUserDetails()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.updateTableHeaderWidth()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		guard let user = User.current else { return }

		// Configure username
		self.usernameLabel.text = user.attributes.username

		// Configure email address
		self.userEmailLabel.text = user.attributes.email

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure preferences
		self.selectedLanguage = self.languages.first(where: { $0.key == user.attributes.preferredLanguage }) ?? self.selectedLanguage
		self.selectedTVRating = self.tvRatings.first(where: {
			guard let preferredTVRating = user.attributes.preferredTVRating else { return false }
			return $0.key == String(preferredTVRating)
		}) ?? self.selectedTVRating
		self.selectedTimezone = self.timezones.first(where: { $0.key == user.attributes.preferredTimezone }) ?? self.selectedTimezone

		if self.isViewLoaded {
			self.tableView.reloadData()
		}
	}

	func loadOptions(from file: String) -> [String: String] {
		if let path = Bundle.main.path(forResource: file, ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			return (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
		} else {
			return [:]
		}
	}

	func updateInformation() async {
		let selectedLanguage = self.selectedLanguage.key
		let selectedTVRating = Int(self.selectedTVRating.key)
		let selectedTimezone = self.selectedTimezone.key

		do {
			let profileUpdateRequest = ProfileUpdateRequest(
				username: nil,
				nickname: nil,
				biography: nil,
				profileImageRequest: nil,
				bannerImageRequest: nil,
				preferredLanguage: selectedLanguage,
				preferredTVRating: selectedTVRating,
				preferredTimezone: selectedTimezone
			)

			// Perform update request.
			let userUpdateResponse = try await KService.updateInformation(profileUpdateRequest).value
			User.current?.attributes.update(using: userUpdateResponse.data)
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// The shared settings used to initialize the table view.
	private func sharedInit() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.tableView.sectionHeaderHeight = 18
	}

	private func configureTableHeaderView() {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.headerHeight))
		headerView.preservesSuperviewLayoutMargins = true
		headerView.backgroundColor = .clear
		headerView.layoutMargins = UIEdgeInsets(top: 20, left: self.tableView.layoutMargins.left, bottom: 10, right: self.tableView.layoutMargins.right)

		let stackView = UIStackView(arrangedSubviews: [self.profileImageView, self.usernameLabel, self.userEmailLabel])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.profileImageView.contentMode = .scaleAspectFill
		self.usernameLabel.textAlignment = .center
		self.userEmailLabel.textAlignment = .center
		self.userEmailLabel.numberOfLines = 2
		self.usernameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.userEmailLabel.font = UIFont.preferredFont(forTextStyle: .caption1)

		headerView.addSubview(stackView)

		NSLayoutConstraint.activate([
			self.profileImageView.heightAnchor.constraint(equalToConstant: 80),
			self.profileImageView.widthAnchor.constraint(equalToConstant: 80),

			stackView.topAnchor.constraint(equalTo: headerView.layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: headerView.layoutMarginsGuide.bottomAnchor),
			stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: headerView.layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.layoutMarginsGuide.trailingAnchor)
		])

		stackView.setCustomSpacing(8, after: self.profileImageView)

		self.tableView.tableHeaderView = headerView
	}

	private func updateTableHeaderWidth() {
		guard let headerView = self.tableView.tableHeaderView else { return }
		let width = self.tableView.bounds.width
		guard width > 0 else { return }

		if headerView.frame.width != width {
			headerView.frame.size.width = width
			self.tableView.tableHeaderView = headerView
		}
	}

	private func rows(for section: Section) -> [Rows] {
		switch section {
		case .account:
			return [.language, .tvRating, .timezone]
		case .library:
			return [.importLibrary, .deleteLibrary]
		case .signInWithApple:
			return User.current?.attributes.siwaIsEnabled ?? false ? [] : [.signInWithApple]
		case .session:
			return [.activeSessions]
		case .danger:
			return [.signOut, .deleteAccount]
		}
	}

	private func configureSettingsCell(_ cell: SettingsCell, for row: Rows) {
		switch row {
		case .language:
			self.configureSettingsCell(
				cell,
				title: Trans.language,
				detail: self.selectedLanguage.value,
				icon: .Icons.language
			)
		case .tvRating:
			self.configureSettingsCell(
				cell,
				title: Trans.tvRating,
				detail: self.selectedTVRating.value.replacingOccurrences(of: " - .*", with: "", options: .regularExpression),
				icon: .Icons.tvRating
			)
		case .timezone:
			self.configureSettingsCell(
				cell,
				title: Trans.timezone,
				detail: self.selectedTimezone.value.replacingOccurrences(of: ".*\\/|\\s*\\(.*\\)", with: "", options: .regularExpression),
				icon: .Icons.globe
			)
		case .importLibrary:
			self.configureSettingsCell(
				cell,
				title: Trans.importLibrary,
				icon: .Icons.Brands.myAnimeList
			)
		case .deleteLibrary:
			self.configureSettingsCell(
				cell,
				title: Trans.deleteLibrary,
				icon: .Icons.libraryTrash
			)
		case .signInWithApple:
			self.configureSettingsCell(
				cell,
				title: Trans.signInWithAppleHeadline,
				icon: .Icons.Brands.apple
			)
		case .activeSessions:
			self.configureSettingsCell(
				cell,
				title: Trans.manageActiveSessions,
				icon: .Icons.session
			)
		case .signOut, .deleteAccount:
			break
		}
	}

	private func configureSettingsCell(_ cell: SettingsCell, title: String, detail: String? = nil, icon: UIImage?) {
		let hasSecondary = !(detail?.isEmpty ?? true)

		cell.configure(title: title, detail: detail, icon: icon)
		cell.secondaryLabel?.isHidden = !hasSecondary
		cell.chevronImageView?.isHidden = false
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		return self.rows(for: section).count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section) else {
			return UITableViewCell(style: .default, reuseIdentifier: nil)
		}

		let row = self.rows(for: section)[indexPath.row]
		switch row {
		case .signOut, .deleteAccount:
			guard let destructiveSettingsCell = tableView.dequeueReusableCell(withIdentifier: DestructiveSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(DestructiveSettingsCell.reuseID)")
			}
			let title = row == .signOut ? Trans.signOut : Trans.deleteAccount
			destructiveSettingsCell.configure(title: title)
			return destructiveSettingsCell
		default:
			guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			self.configureSettingsCell(settingsCell, for: row)
			return settingsCell
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		guard let section = Section(rawValue: indexPath.section) else { return }
		let row = self.rows(for: section)[indexPath.row]

		switch row {
		case .language:
			self.selectedAccountSetting = .language

			let viewController = SettingsPickerTableViewController(items: self.languages, selectedKey: self.selectedLanguage.key)
			viewController.title = "Language"
			viewController.delegate = self
			self.show(viewController, sender: nil)
		case .tvRating:
			self.selectedAccountSetting = .tvRating

			let viewController = SettingsPickerTableViewController(items: self.tvRatings, selectedKey: self.selectedTVRating.key)
			viewController.title = "TV Rating"
			viewController.delegate = self
			self.show(viewController, sender: nil)
		case .timezone:
			self.selectedAccountSetting = .timezone

			let viewController = SettingsPickerTableViewController(items: self.timezones, selectedKey: self.selectedTimezone.key)
			viewController.title = "Time Zone"
			viewController.delegate = self
			self.show(viewController, sender: nil)
		case .importLibrary:
			let viewController = LibraryImportTableViewController()
			self.show(viewController, sender: nil)
		case .deleteLibrary:
			let viewController = LibraryDeleteTableViewController()
			self.show(viewController, sender: nil)
		case .signInWithApple:
			let viewController = SignInWithAppleTableViewController()
			self.show(viewController, sender: nil)
		case .activeSessions:
			let viewController = ManageActiveSessionsController()
			self.show(viewController, sender: nil)
		case .signOut:
			let alertController = self.presentAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", defaultActionButtonTitle: "No, keep me signed in 😅")
			alertController.addAction(UIAlertAction(title: "Yes, sign me out 🤨", style: .destructive) { [weak self] _ in
				guard let self = self else { return }

				Task {
					await WorkflowController.shared.signOut()
					self.dismiss(animated: true, completion: nil)
				}
			})
		case .deleteAccount:
			let alertController = self.presentAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? Once your account is deleted, all of its resources and data will be permanently deleted. Please enter your password to confirm you would like to permanently delete your account.", defaultActionButtonTitle: Trans.cancel)
			alertController.addTextField { textField in
				textField.textType = .password
				textField.placeholder = Trans.password
			}
			alertController.addAction(UIAlertAction(title: Trans.deletePermanently, style: .destructive) { [weak self] _ in
				guard let self = self else { return }
				guard let passwordTextField = alertController.textFields?.first else { return }
				guard let password = passwordTextField.text else { return }

				Task {
					if await WorkflowController.shared.deleteUser(password: password) {
						self.dismiss(animated: true, completion: nil)
					}
				}
			})
		}
	}
}

// MARK: - UITableViewDelegate
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let section = Section(rawValue: section) else {
			return super.tableView(tableView, heightForHeaderInSection: section)
		}

		if self.rows(for: section).isEmpty {
			return .leastNormalMagnitude
		}

		return super.tableView(tableView, heightForHeaderInSection: section.rawValue)
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		guard let section = Section(rawValue: section) else {
			return super.tableView(tableView, heightForFooterInSection: section)
		}

		if self.rows(for: section).isEmpty {
			return .leastNormalMagnitude
		}

		return super.tableView(tableView, heightForFooterInSection: section.rawValue)
	}
}

extension AccountTableViewController {
	/// List of account table section layout kind.
	enum Section: Int, CaseIterable {
		/// The section for account settings.
		case account

		/// The section for library settings.
		case library

		/// The section for Sign in with Apple.
		case signInWithApple

		/// The section for the session view.
		case session

		/// The section for dangerous actions.
		case danger
	}

	enum Rows: Int, CaseIterable {
		/// The row for the language settings.
		case language
		/// The row for the tv rating settings.
		case tvRating
		/// The row for the timezone settings.
		case timezone
		/// The row for the import library settings.
		case importLibrary
		/// The row for the delete library settings.
		case deleteLibrary
		/// The row for the Sign in with Apple settings.
		case signInWithApple
		/// The row for the active sessions settings.
		case activeSessions
		/// The row for the sign out settings.
		case signOut
		/// The row for the delete account settings.
		case deleteAccount
	}
}

// MARK: - KTableViewDataSource
extension AccountTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			DestructiveSettingsCell.self,
			SettingsCell.self
		]
	}
}

extension AccountTableViewController: SettingsPickerTableViewControllerDelegate {
	func settingsPickerTableViewController(_ controller: SettingsPickerTableViewController, didSelectKey key: String) async {
		switch self.selectedAccountSetting {
		case .language:
			self.selectedLanguage = self.selectedLanguage.key == key ? self.selectedLanguage : (key, self.languages[key] ?? "")
			await self.updateInformation()
		case .tvRating:
			self.selectedTVRating = self.selectedTVRating.key == key ? self.selectedTVRating : (key, self.tvRatings[key] ?? "")
			await self.updateInformation()
		case .timezone:
			self.selectedTimezone = self.selectedTimezone.key == key ? self.selectedTimezone : (key, self.timezones[key] ?? "")
			await self.updateInformation()
		default: break
		}

		self.configureUserDetails()
	}
}
