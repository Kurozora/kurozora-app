//
//  ProfileTableHeaderView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - ProfileTableHeaderViewDelegate
protocol ProfileTableHeaderViewDelegate: AnyObject {
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didTapImageView imageView: UIImageView, at index: Int)
	func profileTableHeaderViewDidPressFollowButton(_ headerView: ProfileTableHeaderView)
	func profileTableHeaderViewDidPressEditProfile(_ headerView: ProfileTableHeaderView)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressReputationButton button: UIButton)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressAchievementsButton button: UIButton)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressFollowingButton button: UIButton)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressFollowersButton button: UIButton)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressReviewsButton button: UIButton)
	func profileTableHeaderView(_ headerView: ProfileTableHeaderView, didPressBadge profileBadge: ProfileBadge, from button: UIButton)
	func profileTableHeaderViewDidPressTimeoutBanner(_ headerView: ProfileTableHeaderView)
}

// MARK: - ProfileTableHeaderView
class ProfileTableHeaderView: UIView {
	// MARK: - Properties
	weak var delegate: ProfileTableHeaderViewDelegate?

	weak var bioTextViewDelegate: UITextViewDelegate? {
		didSet {
			self.bioTextView.delegate = self.bioTextViewDelegate
		}
	}

	/// The user currently being displayed. Stored for theme-change reconfigurations.
	private var user: User?

	/// The live activity status driving the online indicator. Set by ``ProfileTableViewController`` from realtime events.
	private var activityStatus: ActivityStatus = .offline

	// MARK: - Views
	private(set) var bannerContainerView = UIView()
	private(set) var bannerImageView = UIImageView()
	private(set) var profileImageView = ProfileImageView(frame: .zero)

	private let headerContentView = UIView()
	private let userDetailsHeaderView = UIView()
	private let profilePhotoWrapperView = UIView()
	private let circularView = CircularView()
	private let onlineIndicatorContainerView = UIView()
	private let onlineIndicatorView = UIView()
	private let profileBadgeStackView = ProfileBadgeStackView()
	private let followButton = KTintedButton()
	private let editProfileButton = KTintedButton()
	private let displayNameLabel = KLabel()
	private let usernameLabel = KSecondaryLabel()
	private let userDetailsBodyView = UIView()
	private let bodyStackView = UIStackView()
	private let timeoutBannerButton = TimerButton()
	private let bioTextView = KTextView()
	private let buttonsScrollView = UIScrollView()
	private let buttonsStackView = UIStackView()
	private let reputationButton = KButton()
	private let achievementsButton = KButton()
	private let followingButton = KButton()
	private let followersButton = KButton()
	private let reviewsButton = KButton()
	private let separatorView = SeparatorView()
	private let leftMirrorImageView = UIImageView()
	private let rightMirrorImageView = UIImageView()

	private let blurCIContext = CIContext(options: [.useSoftwareRenderer: false])
	private var blurredBannerImage: UIImage?
	private var bannerCompactWidthConstraint: NSLayoutConstraint!
	private var bannerRegularWidthConstraint: NSLayoutConstraint!
	private var buttonsFillWidthConstraint: NSLayoutConstraint!
	private var bannerImageObservation: NSKeyValueObservation?

	// MARK: - Styling
	private var countValueAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign
		]
	}

	private var countTitleAttributes: [NSAttributedString.Key: Any] {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		return [
			NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
			NSAttributedString.Key.paragraphStyle: centerAlign,
			NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2).bold
		]
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.preservesSuperviewLayoutMargins = true
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle
	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateBannerEdges()
		self.updateButtonsRowInsets()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
			self.updateBannerWidthConstraints()
		}
	}

	// MARK: - Configuration
	/// Updates the user's activity indicator.
	///
	/// - Parameter status: The activity status to render.
	func updateActivityStatus(_ status: ActivityStatus) {
		self.activityStatus = status
		self.onlineIndicatorView.backgroundColor = status.colorValue
	}

	/// Configures all header elements with the given user's data.
	func configure(with user: User) {
		self.user = user
		// Configure display name
		self.displayNameLabel.text = user.attributes.username
		self.displayNameLabel.isHidden = false

		// Configure username
		self.usernameLabel.text = "@\(user.attributes.slug)"
		self.usernameLabel.isHidden = false

		// Configure online status
		self.onlineIndicatorContainerView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.onlineIndicatorContainerView.layerCornerRadius = self.onlineIndicatorContainerView.frame.size.height / 2

		self.onlineIndicatorView.backgroundColor = self.activityStatus.colorValue
		self.onlineIndicatorView.layerCornerRadius = self.onlineIndicatorView.frame.size.height / 2

		self.onlineIndicatorContainerView.isHidden = false
		self.onlineIndicatorView.isHidden = false

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure banner image
		if let bgColor = user.attributes.banner?.backgroundColor {
			self.bannerContainerView.backgroundColor = UIColor(hexString: bgColor)
		} else {
			self.bannerContainerView.backgroundColor = user.attributes.bannerPlaceholderColor
		}
		user.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure timeout banner
		let isSelfOrModerator = user.id == User.current?.id || User.current?.attributes.isModerator == true

		if isSelfOrModerator, let attributes = user.relationships?.timeout?.data.first?.attributes {
			self.timeoutBannerButton.isHidden = false
			self.timeoutBannerButton.startCountdown(to: attributes.expiresAt) { remaining in
				attributes.suspensionBannerTitle(forRemaining: remaining)
			}
		} else {
			self.timeoutBannerButton.stopCountdown()
			self.timeoutBannerButton.isHidden = true
		}

		// Configure user bio
		self.bioTextView.setAttributedText(user.attributes.biographyMarkdown?.markdownAttributedString())

		// Configure count buttons
		self.configureCountButtons(with: user)

		// Configure edit button
		self.editProfileButton.isHidden = !(user.id == User.current?.id)

		// Configure follow button
		self.updateFollowButton(for: user)

		// Badges
		self.profileBadgeStackView.delegate = self
		self.profileBadgeStackView.configure(for: user)
	}

	/// Updates the follow button state for the given user.
	func updateFollowButton(for user: User?) {
		if user?.attributes.blockStatus == .blocked {
			self.followButton.setTitle(L10n.blocked, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
			return
		}

		if user?.attributes.isBlockedBy == true {
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
			return
		}

		let followStatus = user?.attributes.followStatus ?? .disabled
		switch followStatus {
		case .followed:
			self.followButton.setTitle(L10n.following, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .notFollowed:
			self.followButton.setTitle(L10n.follow, for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle(L10n.follow, for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	/// Directly sets images on the image views, skipping nil values. Used to avoid placeholder flash after Kingfisher calls.
	func overrideImages(profileImage: UIImage?, bannerImage: UIImage?) {
		if let profileImage = profileImage {
			self.profileImageView.image = profileImage
		}
		if let bannerImage = bannerImage {
			self.bannerImageView.image = bannerImage
		}
	}

	// MARK: - Private
	/// Configure the views.
	private func configureViews() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleThemeUpdate), name: .ThemeUpdateNotification, object: nil)

		// Timeout banner button
		self.timeoutBannerButton.translatesAutoresizingMaskIntoConstraints = false
		self.timeoutBannerButton.isHidden = true
		self.timeoutBannerButton.configuration?.image = UIImage(systemName: "exclamationmark.octagon.fill")
		self.timeoutBannerButton.addTarget(self, action: #selector(self.timeoutBannerTapped), for: .touchUpInside)

		// Banner container view
		self.bannerContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.bannerContainerView.clipsToBounds = true

		// Banner image view
		self.bannerImageView.translatesAutoresizingMaskIntoConstraints = false
		self.bannerImageView.tag = 1
		self.bannerImageView.contentMode = .scaleAspectFill
		self.bannerImageView.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
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
		self.followButton.setTitle(L10n.follow, for: .normal)
		self.followButton.highlightBackgroundColorEnabled = true
		self.followButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		self.followButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderViewDidPressFollowButton(self)
		}, for: .touchUpInside)

		// Edit profile button
		self.editProfileButton.translatesAutoresizingMaskIntoConstraints = false
		self.editProfileButton.isHidden = true
		self.editProfileButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
		self.editProfileButton.setTitle(L10n.edit, for: .normal)
		self.editProfileButton.layerCornerRadius = 12
		self.editProfileButton.highlightBackgroundColorEnabled = true
		self.editProfileButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		self.editProfileButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderViewDidPressEditProfile(self)
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

		// Reputation button
		self.reputationButton.translatesAutoresizingMaskIntoConstraints = false
		self.reputationButton.isHidden = true
		self.reputationButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.reputationButton.titleLabel?.numberOfLines = 0
		self.reputationButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderView(self, didPressReputationButton: self.reputationButton)
		}, for: .touchUpInside)

		// Achievements button
		self.achievementsButton.translatesAutoresizingMaskIntoConstraints = false
		self.achievementsButton.isHidden = true
		self.achievementsButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.achievementsButton.titleLabel?.numberOfLines = 0
		self.achievementsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderView(self, didPressAchievementsButton: self.achievementsButton)
		}, for: .touchUpInside)

		// Following button
		self.followingButton.translatesAutoresizingMaskIntoConstraints = false
		self.followingButton.isHidden = true
		self.followingButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.followingButton.titleLabel?.numberOfLines = 0
		self.followingButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderView(self, didPressFollowingButton: self.followingButton)
		}, for: .touchUpInside)

		// Followers button
		self.followersButton.translatesAutoresizingMaskIntoConstraints = false
		self.followersButton.isHidden = true
		self.followersButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.followersButton.titleLabel?.numberOfLines = 0
		self.followersButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderView(self, didPressFollowersButton: self.followersButton)
		}, for: .touchUpInside)

		// Reviews button
		self.reviewsButton.translatesAutoresizingMaskIntoConstraints = false
		self.reviewsButton.isHidden = true
		self.reviewsButton.titleLabel?.lineBreakMode = .byCharWrapping
		self.reviewsButton.titleLabel?.numberOfLines = 0
		self.reviewsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.profileTableHeaderView(self, didPressReviewsButton: self.reviewsButton)
		}, for: .touchUpInside)

		// Buttons stack view
		self.buttonsStackView.addArrangedSubview(self.reputationButton)
		self.buttonsStackView.addArrangedSubview(self.achievementsButton)
		self.buttonsStackView.addArrangedSubview(self.followingButton)
		self.buttonsStackView.addArrangedSubview(self.followersButton)
		self.buttonsStackView.addArrangedSubview(self.reviewsButton)

		self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		self.buttonsStackView.distribution = .fillEqually
		self.buttonsStackView.spacing = 5

		// Buttons scroll view
		self.buttonsScrollView.translatesAutoresizingMaskIntoConstraints = false
		self.buttonsScrollView.showsHorizontalScrollIndicator = false
		self.buttonsScrollView.showsVerticalScrollIndicator = false
		self.buttonsScrollView.contentInsetAdjustmentBehavior = .never

		// Separator view
		self.separatorView.translatesAutoresizingMaskIntoConstraints = false

		// Body stack view
		self.bodyStackView.translatesAutoresizingMaskIntoConstraints = false
		self.bodyStackView.axis = .vertical
		self.bodyStackView.spacing = 8

		// Self (replaces old headerView)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = .clear

		// User details header view
		self.userDetailsHeaderView.translatesAutoresizingMaskIntoConstraints = false
		self.userDetailsHeaderView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		// User details body view
		self.userDetailsBodyView.translatesAutoresizingMaskIntoConstraints = false
		self.userDetailsBodyView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		// Left mirror image view
		self.leftMirrorImageView.translatesAutoresizingMaskIntoConstraints = false
		self.leftMirrorImageView.contentMode = .scaleAspectFill
		self.leftMirrorImageView.clipsToBounds = true
		self.leftMirrorImageView.isUserInteractionEnabled = false
		self.leftMirrorImageView.isHidden = true
		self.leftMirrorImageView.transform = CGAffineTransform(scaleX: -1, y: 1)

		// Right mirror image view
		self.rightMirrorImageView.translatesAutoresizingMaskIntoConstraints = false
		self.rightMirrorImageView.contentMode = .scaleAspectFill
		self.rightMirrorImageView.clipsToBounds = true
		self.rightMirrorImageView.isUserInteractionEnabled = false
		self.rightMirrorImageView.isHidden = true
		self.rightMirrorImageView.transform = CGAffineTransform(scaleX: -1, y: 1)

		// Generate blurred mirror whenever Kingfisher (or anything else) sets the banner image
		self.bannerImageObservation = self.bannerImageView.observe(\.image, options: [.new]) { [weak self] _, change in
			guard let self else { return }
			self.generateBlurredBannerImage(from: change.newValue ?? nil)
		}
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
		self.bodyStackView.addArrangedSubview(self.timeoutBannerButton)
		self.bodyStackView.addArrangedSubview(self.bioTextView)
		self.userDetailsBodyView.addSubview(self.bodyStackView)
		self.userDetailsBodyView.addSubview(self.separatorView)
		self.buttonsScrollView.addSubview(self.buttonsStackView)

		// Root contents
		self.bannerContainerView.addSubview(self.bannerImageView)
		self.bannerContainerView.addSubview(self.leftMirrorImageView)
		self.bannerContainerView.addSubview(self.rightMirrorImageView)
		self.addSubview(self.bannerContainerView)
		self.addSubview(self.userDetailsHeaderView)
		self.addSubview(self.userDetailsBodyView)
		self.addSubview(self.buttonsScrollView)
	}

	/// Configure the view constraints.
	private func configureViewConstraints() {
		let badgeWidthConstraint = self.profileBadgeStackView.widthAnchor.constraint(equalToConstant: 100)
		badgeWidthConstraint.priority = UILayoutPriority(1)

		self.bannerCompactWidthConstraint = self.bannerImageView.widthAnchor.constraint(equalTo: self.widthAnchor)
		self.bannerRegularWidthConstraint = self.bannerImageView.widthAnchor.constraint(equalTo: self.readableContentGuide.widthAnchor)

		NSLayoutConstraint.activate([
			// Banner container view
			self.bannerContainerView.topAnchor.constraint(equalTo: self.topAnchor),
			self.bannerContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.bannerContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.bannerContainerView.bottomAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor),

			// Banner image view
			self.bannerImageView.topAnchor.constraint(equalTo: self.bannerContainerView.topAnchor),
			self.bannerImageView.centerXAnchor.constraint(equalTo: self.bannerContainerView.centerXAnchor),
			self.bannerImageView.widthAnchor.constraint(greaterThanOrEqualTo: self.readableContentGuide.widthAnchor),
			self.bannerImageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor),
			self.bannerImageView.heightAnchor.constraint(equalTo: self.bannerImageView.widthAnchor, multiplier: 1 / 3),

			// Left mirror image view
			self.leftMirrorImageView.topAnchor.constraint(equalTo: self.bannerImageView.topAnchor),
			self.leftMirrorImageView.bottomAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor),
			self.leftMirrorImageView.trailingAnchor.constraint(equalTo: self.bannerImageView.leadingAnchor),
			self.leftMirrorImageView.widthAnchor.constraint(equalTo: self.bannerImageView.widthAnchor),

			// Right mirror image view
			self.rightMirrorImageView.topAnchor.constraint(equalTo: self.bannerImageView.topAnchor),
			self.rightMirrorImageView.bottomAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor),
			self.rightMirrorImageView.leadingAnchor.constraint(equalTo: self.bannerImageView.trailingAnchor),
			self.rightMirrorImageView.widthAnchor.constraint(equalTo: self.bannerImageView.widthAnchor),

			// User details header view
			self.userDetailsHeaderView.leadingAnchor.constraint(equalTo: self.readableContentGuide.leadingAnchor),
			self.userDetailsHeaderView.trailingAnchor.constraint(equalTo: self.readableContentGuide.trailingAnchor),

			// Profile photo wrapper
			self.profilePhotoWrapperView.topAnchor.constraint(equalTo: self.userDetailsHeaderView.topAnchor),
			self.profilePhotoWrapperView.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.layoutMarginsGuide.leadingAnchor),
			self.profilePhotoWrapperView.centerYAnchor.constraint(equalTo: self.bannerContainerView.bottomAnchor, constant: 8),

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
			self.followButton.topAnchor.constraint(equalTo: self.bannerContainerView.bottomAnchor, constant: 8),
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
			self.profileBadgeStackView.topAnchor.constraint(greaterThanOrEqualTo: self.bannerContainerView.bottomAnchor, constant: 8),

			// User details body view
			self.userDetailsBodyView.topAnchor.constraint(equalTo: self.userDetailsHeaderView.bottomAnchor, constant: 8),
			self.userDetailsBodyView.leadingAnchor.constraint(equalTo: self.userDetailsHeaderView.leadingAnchor),
			self.userDetailsBodyView.trailingAnchor.constraint(equalTo: self.userDetailsHeaderView.trailingAnchor),

			// Body stack view
			self.bodyStackView.topAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.topAnchor),
			self.bodyStackView.leadingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.leadingAnchor),
			self.bodyStackView.trailingAnchor.constraint(equalTo: self.userDetailsBodyView.layoutMarginsGuide.trailingAnchor),

			// Buttons scroll view
			self.buttonsScrollView.topAnchor.constraint(equalTo: self.bodyStackView.bottomAnchor, constant: 8),
			self.buttonsScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.buttonsScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.buttonsScrollView.heightAnchor.constraint(equalToConstant: 40),

			// Buttons stack view
			self.buttonsStackView.topAnchor.constraint(equalTo: self.buttonsScrollView.contentLayoutGuide.topAnchor),
			self.buttonsStackView.leadingAnchor.constraint(equalTo: self.buttonsScrollView.contentLayoutGuide.leadingAnchor),
			self.buttonsStackView.trailingAnchor.constraint(equalTo: self.buttonsScrollView.contentLayoutGuide.trailingAnchor),
			self.buttonsStackView.bottomAnchor.constraint(equalTo: self.buttonsScrollView.contentLayoutGuide.bottomAnchor),
			self.buttonsStackView.heightAnchor.constraint(equalTo: self.buttonsScrollView.frameLayoutGuide.heightAnchor),

			// Separator view
			self.separatorView.topAnchor.constraint(equalTo: self.buttonsScrollView.bottomAnchor, constant: 8),
			self.separatorView.leadingAnchor.constraint(equalTo: self.bodyStackView.leadingAnchor),
			self.separatorView.trailingAnchor.constraint(equalTo: self.bodyStackView.trailingAnchor),
			self.separatorView.heightAnchor.constraint(equalToConstant: 1),
			self.userDetailsBodyView.bottomAnchor.constraint(equalTo: self.separatorView.bottomAnchor),

			// Bottom
			self.bottomAnchor.constraint(equalTo: self.userDetailsBodyView.bottomAnchor, constant: 20),
		])

		// Fill the content width when there's room
		self.buttonsFillWidthConstraint = self.buttonsStackView.widthAnchor.constraint(equalTo: self.buttonsScrollView.frameLayoutGuide.widthAnchor)
		self.buttonsFillWidthConstraint.priority = .defaultLow
		self.buttonsFillWidthConstraint.isActive = true

		// Floor each button's width so the row scrolls once the five no longer fit
		for button in [self.reputationButton, self.achievementsButton, self.followingButton, self.followersButton, self.reviewsButton] {
			button.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
		}

		self.updateBannerWidthConstraints()
	}

	/// Generates a downsampled, blurred version of the banner image for the mirror edge views.
	private func generateBlurredBannerImage(from image: UIImage?) {
		guard let image else {
			self.blurredBannerImage = nil
			self.leftMirrorImageView.image = nil
			self.rightMirrorImageView.image = nil
			self.leftMirrorImageView.isHidden = true
			self.rightMirrorImageView.isHidden = true
			return
		}

		let context = self.blurCIContext

		Task.detached(priority: .userInitiated) {
			// Downsample to ~100pt width — blur destroys detail anyway
			let targetWidth: CGFloat = 100
			let scale = targetWidth / image.size.width
			let targetSize = CGSize(width: targetWidth, height: image.size.height * scale)

			let format = UIGraphicsImageRendererFormat()
			format.scale = 1
			let downsampledImage = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
				image.draw(in: CGRect(origin: .zero, size: targetSize))
			}

			guard let ciInput = CIImage(image: downsampledImage) else { return }
			let blurFilter = CIFilter(name: "CIGaussianBlur")!
			blurFilter.setValue(ciInput, forKey: kCIInputImageKey)
			blurFilter.setValue(5, forKey: kCIInputRadiusKey)

			guard let ciOutput = blurFilter.outputImage else { return }

			// Crop to original extent (blur expands edges)
			let croppedOutput = ciOutput.cropped(to: ciInput.extent)
			guard let cgImage = context.createCGImage(croppedOutput, from: croppedOutput.extent) else { return }
			let blurred = UIImage(cgImage: cgImage)

			await MainActor.run {
				self.blurredBannerImage = blurred
				self.leftMirrorImageView.image = blurred
				self.rightMirrorImageView.image = blurred
				self.updateBannerEdges()
			}
		}
	}

	/// Activates the correct banner width constraint for the current horizontal size class.
	private func updateBannerWidthConstraints() {
		let isCompact = self.traitCollection.horizontalSizeClass == .compact

		self.bannerCompactWidthConstraint.isActive = isCompact
		self.bannerRegularWidthConstraint.isActive = !isCompact
	}

	/// Updates mirror visibility based on the gap between banner and container edges.
	private func updateBannerEdges() {
		let headerWidth = self.bounds.width
		let bannerHeight = self.bannerImageView.bounds.height
		guard headerWidth > 0, bannerHeight > 0 else { return }

		let gap = (headerWidth - self.bannerImageView.bounds.width) / 2.0

		if gap > 1, self.blurredBannerImage != nil {
			self.leftMirrorImageView.isHidden = false
			self.rightMirrorImageView.isHidden = false
		} else {
			self.leftMirrorImageView.isHidden = true
			self.rightMirrorImageView.isHidden = true
		}
	}

	/// Insets the full-bleed buttons row so its content rests at the body's content margins while
	/// remaining free to scroll out to the view's edges.
	private func updateButtonsRowInsets() {
		let marginsGuide = self.userDetailsBodyView.layoutMarginsGuide
		let contentFrame = self.convert(marginsGuide.layoutFrame, from: self.userDetailsBodyView)
		guard contentFrame.width > 0 else { return }

		let leftInset = max(contentFrame.minX, 0)
		let rightInset = max(self.bounds.width - contentFrame.maxX, 0)

		let insets = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
		if self.buttonsScrollView.contentInset != insets {
			self.buttonsScrollView.contentInset = insets
		}

		let fillConstant = -(leftInset + rightInset)
		if self.buttonsFillWidthConstraint.constant != fillConstant {
			self.buttonsFillWidthConstraint.constant = fillConstant
		}
	}

	/// Configures the count buttons with the given user's stats.
	private func configureCountButtons(with user: User) {
		let reputationCount = user.attributes.reputationCount
		let reputationCountString = NSAttributedString(string: reputationCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let reputationTitleString = NSAttributedString(string: L10n.profileReputationLabel, attributes: self.countTitleAttributes)
		let reputationButtonTitle = NSMutableAttributedString()
		reputationButtonTitle.append(reputationCountString)
		reputationButtonTitle.append(reputationTitleString)

		self.reputationButton.setAttributedTitle(reputationButtonTitle, for: .normal)
		self.reputationButton.isHidden = false

		let achievementsCount = user.attributes.achievementsCount ?? 0
		let achievementsCountString = NSAttributedString(string: achievementsCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let achievementsTitleString = NSAttributedString(string: "\n\(L10n.achievements)", attributes: self.countTitleAttributes)
		let achievementsButtonTitle = NSMutableAttributedString()
		achievementsButtonTitle.append(achievementsCountString)
		achievementsButtonTitle.append(achievementsTitleString)

		self.achievementsButton.setAttributedTitle(achievementsButtonTitle, for: .normal)
		self.achievementsButton.isHidden = false

		let followingCount = user.attributes.followingCount
		let followingCountString = NSAttributedString(string: followingCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followingTitleString = NSAttributedString(string: L10n.profileFollowingLabel, attributes: self.countTitleAttributes)
		let followingButtonTitle = NSMutableAttributedString()
		followingButtonTitle.append(followingCountString)
		followingButtonTitle.append(followingTitleString)

		self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		self.followingButton.isHidden = false

		let followerCount = user.attributes.followerCount
		let followerCountString = NSAttributedString(string: followerCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let followerTitleString = NSAttributedString(string: L10n.profileFollowersLabel, attributes: self.countTitleAttributes)
		let followersButtonTitle = NSMutableAttributedString()
		followersButtonTitle.append(followerCountString)
		followersButtonTitle.append(followerTitleString)

		self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		self.followersButton.isHidden = false

		let reviewsCount = user.attributes.ratingsCount
		let reviewsCountString = NSAttributedString(string: reviewsCount.kkFormatted(precision: 0), attributes: self.countValueAttributes)
		let reviewsTitleString = NSAttributedString(string: L10n.profileReviewsLabel, attributes: self.countTitleAttributes)
		let reviewsButtonTitle = NSMutableAttributedString()
		reviewsButtonTitle.append(reviewsCountString)
		reviewsButtonTitle.append(reviewsTitleString)

		self.reviewsButton.setAttributedTitle(reviewsButtonTitle, for: .normal)
		self.reviewsButton.isHidden = false
	}

	// MARK: - Actions
	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let imageView = sender.view as? UIImageView else { return }
		self.delegate?.profileTableHeaderView(self, didTapImageView: imageView, at: imageView.tag)
	}

	@objc private func handleThemeUpdate() {
		Task { @MainActor [weak self] in
			guard let self = self, let user = self.user else { return }
			self.configureCountButtons(with: user)
		}
	}

	@objc fileprivate func timeoutBannerTapped() {
    		self.delegate?.profileTableHeaderViewDidPressTimeoutBanner(self)
    	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension ProfileTableHeaderView: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		self.delegate?.profileTableHeaderView(self, didPressBadge: profileBadge, from: button)
	}
}
