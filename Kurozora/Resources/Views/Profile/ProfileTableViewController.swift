//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ProfileTableViewController: KTableViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case achievementsSegue
		case followingSegue
		case followersSegue
		case reviewsSegue
		case feedMessageDetailsSegue
		case editProfileSegue
	}

	// MARK: - Views
	private var postMessageButton: UIBarButtonItem!
	private var moreBarButtonItem: UIBarButtonItem!

	private let headerView = UIView()
	private let bannerImageView = UIImageView()
	private let userDetailsHeaderView = UIView()
	private let profilePhotoWrapperView = UIView()
	private let circularView = CircularView()
	private let profileImageView = ProfileImageView(frame: .zero)
	private let onlineIndicatorContainerView = UIView()
	private let onlineIndicatorView = UIView()
	private let profileBadgeStackView = ProfileBadgeStackView()
	private let followButton = KTintedButton()
	private let editProfileButton = KTintedButton()
	private let displayNameLabel = KLabel()
	private let usernameLabel = KSecondaryLabel()
	private let userDetailsBodyView = UIView()
	private let bioTextView = KTextView()
	private let buttonsStackView = UIStackView()
	private let achievementsButton = KButton()
	private let followingButton = KButton()
	private let followersButton = KButton()
	private let reviewsButton = KButton()
	private let separatorView: SeparatorView = SeparatorView()

	var sidebarBottomProfileView: KSidebarBottomProfileView?

	// MARK: - Properties
	var userIdentity: UserIdentity?
	var user: User! = User.current {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.userIdentity = UserIdentity(id: self.user.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
            self.touchBar = nil
			#endif

			#if DEBUG
            #if !targetEnvironment(macCatalyst)
            self.refreshControl?.endRefreshing()
            #endif
			#endif
		}
	}

	var feedMessages: [FeedMessage] = []

	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// Styling
	var countValueAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign
		]
	}

	var countTitleAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign,
			NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2).bold
		]
	}

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	init() {
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Initialize a new instance of ProfileTableViewController with the given user id.
	///
	/// - Parameter userID: The user id to use when initializing the view.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
	func callAsFunction(with userID: KurozoraItemID) -> ProfileTableViewController {
		let profileTableViewController = ProfileTableViewController()
		profileTableViewController.userIdentity = UserIdentity(id: userID)
		return profileTableViewController
	}

	/// Initialize a new instance of ProfileTableViewController with the given user object.
	///
	/// - Parameter user: The `User` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ProfileTableViewController.
	func callAsFunction(with user: User) -> ProfileTableViewController {
		let profileTableViewController = ProfileTableViewController()
		profileTableViewController.user = user
		return profileTableViewController
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateAttributedText), name: .ThemeUpdateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif

		if self.userIdentity == nil {
			self.userIdentity = UserIdentity(id: self.user.id)
		}

		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.tableView.setTableHeaderView(headerView: self.headerView)

		self.configureNavigationItems()

		// Fetch user details
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchUserDetails()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.updateHeaderViewFrame()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)

		if self.isMovingFromParent || self.isBeingDismissed, self.user == User.current {
			self.sidebarBottomProfileView?.isSelected = false
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchUserDetails()
		}
	}

	override func configureEmptyDataView() {
		// MARK: Refactor
		let verticalOffset = (self.tableView.tableHeaderView?.frame.size.height ?? 0 - self.view.frame.size.height) / 2
		var detailString: String

		if self.userIdentity?.id == User.current?.id {
			detailString = "There are no messages on your feed!"
		} else {
			detailString = "There are no messages on this feed!"
		}

		emptyBackgroundView.configureImageView(image: .Empty.comment)
		emptyBackgroundView.configureLabels(title: "No Posts", detail: detailString)
		emptyBackgroundView.verticalOffset = verticalOffset

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Configure the views.
	private func configureViews() {
		self.mediaViewerDelegate = self

		// Banner image view
		self.bannerImageView.translatesAutoresizingMaskIntoConstraints = false
		self.bannerImageView.tag = 1
		self.bannerImageView.contentMode = .scaleAspectFill
		self.bannerImageView.clipsToBounds = true
		self.bannerImageView.backgroundColor = .kurozora
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.bannerImageView.addGestureRecognizer(bannerImageViewTapGesture)

		// Profile photo wrapper
		self.profilePhotoWrapperView.translatesAutoresizingMaskIntoConstraints = false

		// Circular view
		self.circularView.translatesAutoresizingMaskIntoConstraints = false
		self.circularView.clipsToBounds = true

		// Profile image view
		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.profileImageView.tag = 0
		self.profileImageView.isUserInteractionEnabled = true
		let profileImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.profileImageView.addGestureRecognizer(profileImageViewTapGesture)

		// Online indicator container
		self.onlineIndicatorContainerView.translatesAutoresizingMaskIntoConstraints = false

		// Online indicator
		self.onlineIndicatorView.translatesAutoresizingMaskIntoConstraints = false

		// Profile badge stack view
		self.profileBadgeStackView.translatesAutoresizingMaskIntoConstraints = false
		self.profileBadgeStackView.spacing = 4

		// Follow button
		self.followButton.translatesAutoresizingMaskIntoConstraints = false
		self.followButton.isHidden = true
		self.followButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
		self.followButton.setTitle(Trans.follow, for: .normal)
		self.followButton.highlightBackgroundColorEnabled = true
		self.followButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.followButtonPressed()
		}, for: .touchUpInside)

		// Edit profile button
		self.editProfileButton.translatesAutoresizingMaskIntoConstraints = false
		self.editProfileButton.isHidden = true
		self.editProfileButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
		self.editProfileButton.setTitle(Trans.edit, for: .normal)
		self.editProfileButton.layerCornerRadius = 12
		self.editProfileButton.highlightBackgroundColorEnabled = true
		self.editProfileButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.present(SegueIdentifiers.editProfileSegue, sender: self)
		}, for: .touchUpInside)

		// Display name label
		self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.displayNameLabel.font = .preferredFont(forTextStyle: .headline)
		self.displayNameLabel.numberOfLines = 2
		self.displayNameLabel.isHidden = true
		self.displayNameLabel.setContentCompressionResistancePriority(.defaultHigh - 2, for: .horizontal)

		// Username label
		self.usernameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.usernameLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.usernameLabel.isHidden = true
		self.usernameLabel.setContentCompressionResistancePriority(.defaultHigh - 2, for: .horizontal)

		// Bio text view
		self.bioTextView.translatesAutoresizingMaskIntoConstraints = false
		self.bioTextView.isEditable = false
		self.bioTextView.isScrollEnabled = false
		self.bioTextView.dataDetectorTypes = [.link, .address, .calendarEvent, .lookupSuggestion]
		self.bioTextView.delegate = self

		// Achievements button
		self.achievementsButton.translatesAutoresizingMaskIntoConstraints = false
		self.achievementsButton.isHidden = true
		self.achievementsButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.achievementsButton.titleLabel?.numberOfLines = 0
		self.achievementsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.show(SegueIdentifiers.achievementsSegue, sender: self)
		}, for: .touchUpInside)

		// Following button
		self.followingButton.translatesAutoresizingMaskIntoConstraints = false
		self.followingButton.isHidden = true
		self.followingButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.followingButton.titleLabel?.numberOfLines = 0
		self.followingButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.show(SegueIdentifiers.followingSegue, sender: self)
		}, for: .touchUpInside)

		// Followers button
		self.followersButton.translatesAutoresizingMaskIntoConstraints = false
		self.followersButton.isHidden = true
		self.followersButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.followersButton.titleLabel?.numberOfLines = 0
		self.followersButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.show(SegueIdentifiers.followersSegue, sender: self)
		}, for: .touchUpInside)

		// Reviews button
		self.reviewsButton.translatesAutoresizingMaskIntoConstraints = false
		self.reviewsButton.isHidden = true
		self.reviewsButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.reviewsButton.titleLabel?.numberOfLines = 0
		self.reviewsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.show(SegueIdentifiers.reviewsSegue, sender: self)
		}, for: .touchUpInside)

		// Buttons stack view
		self.buttonsStackView.addArrangedSubview(self.achievementsButton)
		self.buttonsStackView.addArrangedSubview(self.followingButton)
		self.buttonsStackView.addArrangedSubview(self.followersButton)
		self.buttonsStackView.addArrangedSubview(self.reviewsButton)

		self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		self.buttonsStackView.distribution = .fillEqually
		self.buttonsStackView.spacing = 5

		// Separator view
		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		// Header view
		self.headerView.translatesAutoresizingMaskIntoConstraints = false
		self.headerView.backgroundColor = .clear

		// User details header view
		self.userDetailsHeaderView.translatesAutoresizingMaskIntoConstraints = false
		self.userDetailsHeaderView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		// User details body view
		self.userDetailsBodyView.translatesAutoresizingMaskIntoConstraints = false
		self.userDetailsBodyView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	}

	/// Configure the view hierarchy.
	private func configureViewHierarchy() {
		// Profile photo wrapper contents
		self.circularView.addSubview(self.profileImageView)
		self.profilePhotoWrapperView.addSubview(self.circularView)
		self.profilePhotoWrapperView.addSubview(self.onlineIndicatorContainerView)
		self.profilePhotoWrapperView.addSubview(self.onlineIndicatorView)

		// User details header contents
		self.userDetailsHeaderView.addSubview(self.profilePhotoWrapperView)
		self.userDetailsHeaderView.addSubview(self.profileBadgeStackView)
		self.userDetailsHeaderView.addSubview(self.followButton)
		self.userDetailsHeaderView.addSubview(self.editProfileButton)
		self.userDetailsHeaderView.addSubview(self.displayNameLabel)
		self.userDetailsHeaderView.addSubview(self.usernameLabel)

		// User details body contents
		self.userDetailsBodyView.addSubview(self.bioTextView)
		self.userDetailsBodyView.addSubview(self.buttonsStackView)
		self.userDetailsBodyView.addSubview(self.separatorView)

		// Header view contents
		self.headerView.addSubview(self.bannerImageView)
		self.headerView.addSubview(self.userDetailsHeaderView)
		self.headerView.addSubview(self.userDetailsBodyView)
	}

	/// Configure the view constraints.
	private func configureViewConstraints() {
		let badgeWidthConstraint = self.profileBadgeStackView.widthAnchor.constraint(equalToConstant: 100)
		badgeWidthConstraint.priority = UILayoutPriority(1)
		self.headerView.preservesSuperviewLayoutMargins = true

		NSLayoutConstraint.activate([
			// Banner image view
			self.bannerImageView.topAnchor.constraint(equalTo: self.headerView.topAnchor),
			self.bannerImageView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
			self.bannerImageView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
			self.bannerImageView.heightAnchor.constraint(equalToConstant: 150),

			// User details header view
			self.userDetailsHeaderView.leadingAnchor.constraint(equalTo: self.headerView.readableContentGuide.leadingAnchor),
			self.userDetailsHeaderView.trailingAnchor.constraint(equalTo: self.headerView.readableContentGuide.trailingAnchor),

			// Profile photo wrapper
			self.profilePhotoWrapperView.topAnchor.constraint(equalTo: self.userDetailsHeaderView.topAnchor),
			self.profilePhotoWrapperView.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.leadingAnchor),
			self.profilePhotoWrapperView.centerYAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 8),

			// Circular view
			self.circularView.topAnchor.constraint(equalTo: self.profilePhotoWrapperView.topAnchor),
			self.circularView.leadingAnchor.constraint(equalTo: self.profilePhotoWrapperView.leadingAnchor),
			self.circularView.trailingAnchor.constraint(equalTo: self.profilePhotoWrapperView.trailingAnchor),
			self.circularView.bottomAnchor.constraint(equalTo: self.profilePhotoWrapperView.bottomAnchor),
			self.circularView.heightAnchor.constraint(equalToConstant: 72),
			self.circularView.widthAnchor.constraint(equalTo: self.circularView.heightAnchor),

			// Profile image view
			self.profileImageView.topAnchor.constraint(equalTo: self.circularView.topAnchor),
			self.profileImageView.leadingAnchor.constraint(equalTo: self.circularView.leadingAnchor),
			self.profileImageView.trailingAnchor.constraint(equalTo: self.circularView.trailingAnchor),
			self.profileImageView.bottomAnchor.constraint(equalTo: self.circularView.bottomAnchor),

			// Online indicator container
			self.onlineIndicatorContainerView.trailingAnchor.constraint(equalTo: self.profilePhotoWrapperView.trailingAnchor),
			self.onlineIndicatorContainerView.bottomAnchor.constraint(equalTo: self.profilePhotoWrapperView.bottomAnchor),
			self.onlineIndicatorContainerView.widthAnchor.constraint(equalToConstant: 25),
			self.onlineIndicatorContainerView.heightAnchor.constraint(equalTo: self.onlineIndicatorContainerView.widthAnchor),

			// Online indicator
			self.onlineIndicatorView.centerXAnchor.constraint(equalTo: self.onlineIndicatorContainerView.centerXAnchor),
			self.onlineIndicatorView.centerYAnchor.constraint(equalTo: self.onlineIndicatorContainerView.centerYAnchor),
			self.onlineIndicatorView.widthAnchor.constraint(equalToConstant: 15),
			self.onlineIndicatorView.heightAnchor.constraint(equalTo: self.onlineIndicatorView.widthAnchor),

			// Profile badge stack view
			self.profileBadgeStackView.leadingAnchor.constraint(equalTo: self.profilePhotoWrapperView.trailingAnchor, constant: 8),
			self.profileBadgeStackView.centerYAnchor.constraint(equalTo: self.followButton.centerYAnchor),
			self.profileBadgeStackView.heightAnchor.constraint(equalToConstant: 20),
			badgeWidthConstraint,

			// Follow button
			self.followButton.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 8),
			self.followButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.profileBadgeStackView.trailingAnchor, constant: 8),
			self.followButton.heightAnchor.constraint(equalToConstant: 32),
			self.userDetailsHeaderView.bottomAnchor.constraint(greaterThanOrEqualTo: self.followButton.bottomAnchor, constant: 8),

			// Edit profile button
			self.editProfileButton.topAnchor.constraint(equalTo: self.followButton.topAnchor),
			self.editProfileButton.centerYAnchor.constraint(equalTo: self.followButton.centerYAnchor),
			self.editProfileButton.trailingAnchor.constraint(equalTo: self.followButton.trailingAnchor),
			self.editProfileButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.profileBadgeStackView.trailingAnchor, constant: 8),
			self.editProfileButton.trailingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.trailingAnchor),
			self.editProfileButton.heightAnchor.constraint(equalToConstant: 32),

			// Follow button trailing (same as edit)
			self.followButton.trailingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.trailingAnchor),

			// Display name label
			self.displayNameLabel.topAnchor.constraint(equalTo: self.profilePhotoWrapperView.bottomAnchor, constant: 8),
			self.displayNameLabel.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.leadingAnchor),
			self.userDetailsHeaderView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.displayNameLabel.trailingAnchor),

			// Username label
			self.usernameLabel.topAnchor.constraint(equalTo: self.displayNameLabel.bottomAnchor),
			self.usernameLabel.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.leadingAnchor),
			self.userDetailsHeaderView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.usernameLabel.trailingAnchor),
			self.userDetailsHeaderView.bottomAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor),

			// Badge stack top
			self.profileBadgeStackView.topAnchor.constraint(greaterThanOrEqualTo: self.bannerImageView.bottomAnchor, constant: 8),

			// User details body view
			self.userDetailsBodyView.topAnchor.constraint(equalTo: self.userDetailsHeaderView.bottomAnchor, constant: 8),
			self.userDetailsBodyView.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.leadingAnchor),
			self.userDetailsBodyView.trailingAnchor.constraint(equalTo: self.userDetailsHeaderView.trailingAnchor),

			// Bio text view
			self.bioTextView.topAnchor.constraint(equalTo: self.userDetailsBodyView.topAnchor),
			self.bioTextView.leadingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.leadingAnchor),
			self.bioTextView.trailingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.trailingAnchor),

			// Buttons stack view
			self.buttonsStackView.topAnchor.constraint(equalTo: self.bioTextView.bottomAnchor, constant: 4),
			self.buttonsStackView.leadingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.leadingAnchor),
			self.buttonsStackView.trailingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.trailingAnchor),
			self.buttonsStackView.heightAnchor.constraint(equalToConstant: 40),

			// Separator view
			self.separatorView.topAnchor.constraint(equalTo: self.buttonsStackView.bottomAnchor, constant: 10),
			self.separatorView.leadingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.leadingAnchor),
			self.separatorView.trailingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.trailingAnchor),
			self.separatorView.heightAnchor.constraint(equalToConstant: 1),
			self.userDetailsBodyView.bottomAnchor.constraint(equalTo: self.separatorView.bottomAnchor),

			// Header view bottom
			self.headerView.bottomAnchor.constraint(equalTo: self.userDetailsBodyView.bottomAnchor, constant: 20),
		])
	}

	/// Configures the more bar button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem = UIBarButtonItem(title: Trans.more, image: UIImage(systemName: "ellipsis.circle"))
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// Configures the post message bar button item.
	private func configurePostMessageBarButtonItem() {
		self.postMessageButton = UIBarButtonItem(title: Trans.postMessage, image: UIImage(systemName: "pencil.circle"), primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.postNewMessage()
		})
		self.navigationItem.rightBarButtonItems?.append(self.postMessageButton)
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.configureMoreBarButtonItem()
		self.configurePostMessageBarButtonItem()
	}

	/// Handles the profile image view press.
	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self.view, didTapImage: view, at: view.tag)
	}

	/// Update the attributed text.
	@objc private func updateAttributedText() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.configureCountButtons()
		}
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// Start update process
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.tableView.reloadSections([indexPath.section], with: .none)
			}
		}
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// Start delete process
			self.tableView.performBatchUpdates({
				if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
					self.feedMessages.remove(at: indexPath.row)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}
			}, completion: nil)
		}
	}

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.user?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Fetches user detail.
	@MainActor
	private func fetchUserDetails() async {
		guard let userIdentity = self.userIdentity else { return }

		#if !targetEnvironment(macCatalyst)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing profile details...")
		#endif

		do {
			let userResponse = try await KService.getDetails(forUser: userIdentity).value

			self.user = userResponse.data.first
			self.configureProfile()

			// Donate suggestion to Siri
			self.userActivity = self.user.openDetailUserActivity
		} catch {
			print(error.localizedDescription)
		}

		await self.fetchFeedMessages()
	}

	func endFetch() {
		self.tableView.reloadData {
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		#if !targetEnvironment(macCatalyst)
        self.refreshControl?.endRefreshing()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!")
		#endif
	}

	/// Fetches posts for the user whose page is being viewed.
	@MainActor
	func fetchFeedMessages() async {
		guard
			!self.isRequestInProgress,
			let userIdentity = self.userIdentity
		else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			let feedMessageResponse = try await KService.getFeedMessages(forUser: userIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.feedMessages = []
			}

			// Save next page url and append new data
			self.nextPageURL = feedMessageResponse.next
			self.feedMessages.append(contentsOf: feedMessageResponse.data)
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()
	}

	fileprivate func configureCountButtons() {
		guard let user = self.user else { return }

		// Configure achievements button
		var achievementsCount = 0
		if let achievements = user.relationships?.achievements?.data {
			achievementsCount = achievements.count
		}

		let achievementsCountString = NSAttributedString(string: "\(achievementsCount)", attributes: self.countValueAttributes)
		let achievementsTitleString = NSAttributedString(string: "\n\(Trans.achievements)", attributes: self.countTitleAttributes)
		let achievementsButtonTitle = NSMutableAttributedString()
		achievementsButtonTitle.append(achievementsCountString)
		achievementsButtonTitle.append(achievementsTitleString)

		self.achievementsButton.setAttributedTitle(achievementsButtonTitle, for: .normal)
		self.achievementsButton.isHidden = false

		// Configure following & followers count
		let followingCount = user.attributes.followingCount
		let followingCountString = NSAttributedString(string: followingCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followingTitleString = NSAttributedString(string: "\nFollowing", attributes: self.countTitleAttributes)
		let followingButtonTitle = NSMutableAttributedString()
		followingButtonTitle.append(followingCountString)
		followingButtonTitle.append(followingTitleString)

		self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		self.followingButton.isHidden = false

		let followerCount = user.attributes.followerCount
		let followerCountString = NSAttributedString(string: followerCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followerTitleString = NSAttributedString(string: "\nFollowers", attributes: self.countTitleAttributes)
		let followersButtonTitle = NSMutableAttributedString()
		followersButtonTitle.append(followerCountString)
		followersButtonTitle.append(followerTitleString)

		self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		self.followersButton.isHidden = false

		// Configure reviews count
		let reviewsCount = user.attributes.ratingsCount
		let reviewsCountString = NSAttributedString(string: reviewsCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let reviewsTitleString = NSAttributedString(string: "\nReviews", attributes: self.countTitleAttributes)
		let reviewsButtonTitle = NSMutableAttributedString()
		reviewsButtonTitle.append(reviewsCountString)
		reviewsButtonTitle.append(reviewsTitleString)

		self.reviewsButton.setAttributedTitle(reviewsButtonTitle, for: .normal)
		self.reviewsButton.isHidden = false
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		guard let user = self.user else { return }
		self.configureNavBarButtons()

		// Configure display name
		self.displayNameLabel.text = user.attributes.username
		self.displayNameLabel.isHidden = false

		// Configure username
		self.usernameLabel.text = "@\(user.attributes.slug)"
		self.usernameLabel.isHidden = false

		// Configure online status
		self.onlineIndicatorContainerView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.onlineIndicatorContainerView.layerCornerRadius = self.onlineIndicatorContainerView.frame.size.height / 2

		self.onlineIndicatorView.backgroundColor = user.attributes.activityStatus.colorValue
		self.onlineIndicatorView.layerCornerRadius = self.onlineIndicatorView.frame.size.height / 2

		self.onlineIndicatorContainerView.isHidden = false
		self.onlineIndicatorView.isHidden = false

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure banner image
		self.bannerImageView.theme_backgroundColor = KThemePicker.tintColor.rawValue
		user.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure user bio
		self.bioTextView.setAttributedText(user.attributes.biographyMarkdown?.markdownAttributedString())

		// Configure count buttons
		self.configureCountButtons()

		// Configure edit button
		self.editProfileButton.isHidden = !(user.id == User.current?.id)

		// Configure follow button
		self.updateFollowButton()

		// Badges
		self.profileBadgeStackView.delegate = self
		self.profileBadgeStackView.configure(for: user)

		// Configure AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user?.attributes.followStatus ?? .disabled
		switch followStatus {
		case .followed:
			self.followButton.setTitle(Trans.following, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle(Trans.follow, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle(Trans.follow, for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	/// Shows the text editor for posting a new message.
	func postNewMessage() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let kFeedMessageTextEditorViewController = KFeedMessageTextEditorViewController.instantiate()
			kFeedMessageTextEditorViewController.delegate = self
			kFeedMessageTextEditorViewController.dmToUser = self.user

			let kurozoraNavigationController = KNavigationController(rootViewController: kFeedMessageTextEditorViewController)
			kurozoraNavigationController.presentationController?.delegate = kFeedMessageTextEditorViewController
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
			kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
			kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
			kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
			kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
			self.present(kurozoraNavigationController, animated: true)
		}
	}

	// MARK: - Actions
	private func followButtonPressed() {
		let userIdentity = UserIdentity(id: self.user.id)

		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			do {
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
				self.user?.attributes.update(using: followUpdateResponse.data)
				self.updateFollowButton()
			} catch {
				print("-----", error.localizedDescription)
			}
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .achievementsSegue: return AchievementsTableViewController()
		case .followingSegue: return UsersListCollectionViewController()
		case .followersSegue: return UsersListCollectionViewController()
		case .feedMessageDetailsSegue: return FMDetailsTableViewController()
		case .editProfileSegue: return KNavigationController(rootViewController: EditProfileViewController(user: self.user))
		case .reviewsSegue: return ReviewsListCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .achievementsSegue:
			guard let achievementsTableViewController = destination as? AchievementsTableViewController else { return }
			achievementsTableViewController.user = self.user
		case .followingSegue:
			guard let followTableViewController = destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .following
			followTableViewController.usersListFetchType = .follow
		case .followersSegue:
			guard let followTableViewController = destination as? UsersListCollectionViewController else { return }
			followTableViewController.user = self.user
			followTableViewController.usersListType = .followers
			followTableViewController.usersListFetchType = .follow
		case .feedMessageDetailsSegue:
			guard
				let fmDetailsTableViewController = destination as? FMDetailsTableViewController,
				let feedMessage = sender as? FeedMessage
			else { return }
			fmDetailsTableViewController.feedMessageID = feedMessage.id
			fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
		case .reviewsSegue:
			guard let reviewsListCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsListCollectionViewController.user = self.user
		case .editProfileSegue:
			break
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedMessages.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedMessageCell: BaseFeedMessageCell?
		let feedMessage = self.feedMessages[indexPath.row]

		if feedMessage.attributes.isReShare {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
		}

		feedMessageCell?.delegate = self
		feedMessageCell?.liveReplyEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.liveReShareEnabled = User.current?.id == self.userIdentity?.id
		feedMessageCell?.configureCell(using: feedMessage, isOnProfile: true)
		feedMessageCell?.moreButton.menu = feedMessage.makeContextMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReplyEnabled": feedMessageCell?.liveReplyEnabled ?? false,
			"liveReShareEnabled": feedMessageCell?.liveReShareEnabled ?? false
		], sourceView: feedMessageCell?.moreButton, barButtonItem: nil)
		return feedMessageCell ?? UITableViewCell()
	}
}

// MARK: - KTableViewDataSource
extension ProfileTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			FeedMessageCell.self,
			FeedMessageReShareCell.self
		]
	}
}

// MARK: - MediaTransitionDelegate
extension ProfileTableViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		return index == 0 ? self.profileImageView : self.bannerImageView
	}

	func scrollThumbnailIntoView(for index: Int) {
		// Scroll the collection view to make sure the cell at the given index is visible.
//		let indexPath = IndexPath(item: index, section: 0)
//		self.tableView.safeScrollToRow(at: indexPath, at: .middle, animated: true)
	}
}

// MARK: - MediaViewerCellViewDelegate
extension ProfileTableViewController: MediaViewerViewDelegate {
	func mediaViewerViewDelegate(_ view: UIView, didTapImage imageView: UIImageView, at index: Int) {
		guard let user = self.user else { return }

		let profileURL = URL(string: user.attributes.profile?.url ?? "")
		let bannerURL = URL(string: user.attributes.banner?.url ?? "")
		var items: [MediaItem] = []

		if let profileURL = profileURL {
			items.append(MediaItem(
				url: profileURL,
				type: .image,
				title: user.attributes.username,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}
		if let bannerURL = bannerURL {
			items.append(MediaItem(
				url: bannerURL,
				type: .image,
				title: user.attributes.username,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}

		guard items.indices.contains(index) else { return }
		let albumVC = MediaAlbumViewController(items: items, startIndex: index)
		albumVC.transitionDelegateForThumbnail = self

		self.present(albumVC, animated: true)
	}
}

// MARK: - BaseFeedMessageCellDelegate
extension ProfileTableViewController: BaseFeedMessageCellDelegate {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].heartMessage(via: self, userInfo: ["indexPath": indexPath])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			await self.feedMessages[indexPath.row].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.row]

			guard let feedMessageUser = feedMessage.relationships.users.data.first else { return }
			guard feedMessageUser != self.user else {
				self.view.animateShake()
				return
			}

			feedMessage.visitOriginalPosterProfile(from: self)
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didLoadGIF sender: AnyObject) {
		self.tableView.beginUpdates()
		self.tableView.endUpdates()
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first

			guard let feedMessageUser = feedMessage?.relationships.users.data.first else { return }
			guard feedMessageUser != self.user else {
				self.view.animateShake()
				return
			}

			feedMessage?.visitOriginalPosterProfile(from: self)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let feedMessage = self.feedMessages[indexPath.row].relationships.parent?.data.first else { return }

		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ProfileTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.insert(feedMessage, at: 0)
		}

		self.tableView.reloadData()
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.show(SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - UITextViewDelegate
extension ProfileTableViewController: UITextViewDelegate {
	func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(for: username).value
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if url.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = url.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = url.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")

				UIApplication.shared.kOpen(nil, deepLink: URL(string: deeplink))
			}

			return false
		}

		return true
	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension ProfileTableViewController: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge

		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}
}

// MARK: - FMDetailsTableViewControllerDelegate
extension ProfileTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: KurozoraItemID) {
		self.feedMessages.removeFirst { feedMessage in
			feedMessage.id == messageID
		}
		self.tableView.reloadData()
	}
}
