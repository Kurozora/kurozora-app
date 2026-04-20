//
//  L10n+Common.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

extension L10n {
	// MARK: - Image Picker
	/// The action sheet button for capturing a new photo from the camera.
	///
	/// - Tag: L10n-takePhoto
	static let takePhoto: String = String(
		localized: "Take Photo 📷",
		comment: "The action sheet button for capturing a new photo from the camera."
	)
	/// The action sheet button for picking an existing photo from the library.
	///
	/// - Tag: L10n-photoLibrary
	static let photoLibrary: String = String(
		localized: "Photo Library 🏛",
		comment: "The action sheet button for picking an existing photo from the library."
	)
	/// The action sheet button for generating a new image with Image Playground.
	///
	/// - Tag: L10n-imagePlayground
	static let imagePlayground: String = String(
		localized: "Image Playground ✨",
		comment: "The action sheet button for generating a new image with Image Playground."
	)

	// MARK: - Sign Out Confirmation
	/// The destructive confirmation button for the sign-out alert.
	///
	/// - Tag: L10n-signOutConfirm
	static let signOutConfirm: String = String(
		localized: "Yes, sign me out 🤨",
		comment: "The destructive confirmation button for the sign-out alert."
	)

	// MARK: - Library
	/// The string for the phrase 'View Options', used as a submenu title in the library table layout.
	///
	/// - Tag: L10n-viewOptions
	static let viewOptions: String = String(
		localized: "View Options",
		comment: "The submenu title for toggling view options in the library table layout."
	)
	/// The string for the phrase 'Show Poster', used as a view option in the library table layout.
	///
	/// - Tag: L10n-showPoster
	static let showPoster: String = String(
		localized: "Show Poster",
		comment: "The view option that toggles whether the title cell shows a poster."
	)
	/// The string for the phrase 'Always Show Title', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleAlways
	static let compactTitleAlways: String = String(
		localized: "Always Show Title",
		comment: "The view option that always shows the series title beneath the poster in the library compact layout."
	)
	/// The string for the phrase 'Hide Title', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleNever
	static let compactTitleNever: String = String(
		localized: "Hide Title",
		comment: "The view option that hides the series title in the library compact layout."
	)
	/// The string for the word 'Smart', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleSmart
	static let compactTitleSmart: String = String(
		localized: "Smart",
		comment: "The view option that hides the series title when real poster art is available in the library compact layout."
	)
	/// The string for the subtitle accompanying the 'Smart' compact title-visibility option.
	///
	/// - Tag: L10n-compactTitleSmartSubtitle
	static let compactTitleSmartSubtitle: String = String(
		localized: "Shows title only when poster art isn't available",
		comment: "The subtitle explaining the 'Smart' compact title-visibility option."
	)
	/// The string for the phrase 'Reset to Default', used inside the library table's View Options menu.
	///
	/// - Tag: L10n-resetToDefault
	static let resetToDefault: String = String(
		localized: "Reset to Default",
		comment: "The destructive action that restores the default set of library table view options."
	)
	/// The string for the word 'Title', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnTitle
	static let columnTitle: String = String(
		localized: "Title",
		comment: "The column header for the item's title in the library table layout."
	)
	/// The string for the word 'Type', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnType
	static let columnType: String = String(
		localized: "Type",
		comment: "The column header for the item's media type in the library table layout."
	)
	/// The string for the word 'Status', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnStatus
	static let columnStatus: String = String(
		localized: "Status",
		comment: "The column header for the item's airing or publishing status in the library table layout."
	)
	/// The string for the word 'Genres', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnGenres
	static let columnGenres: String = String(
		localized: "Genres",
		comment: "The column header for the item's genres in the library table layout."
	)
	/// The string for the word 'Year', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnYear
	static let columnYear: String = String(
		localized: "Year",
		comment: "The column header for the item's release year in the library table layout."
	)
	/// The string for the phrase 'Date Added', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnDateAdded
	static let columnDateAdded: String = String(
		localized: "Date Added",
		comment: "The column header for the date the item was added to the library."
	)
	/// The string for the word 'Progress', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnProgress
	static let columnProgress: String = String(
		localized: "Progress",
		comment: "The column header for the item's progress indicator in the library table layout."
	)
	/// The string for the word 'Chapters', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnChapters
	static let columnChapters: String = String(
		localized: "Chapters",
		comment: "The column header for the literature item's chapter count in the library table layout."
	)
	/// The string for the word 'Volumes', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnVolumes
	static let columnVolumes: String = String(
		localized: "Volumes",
		comment: "The column header for the literature item's volume count in the library table layout."
	)
	/// The string for the word 'Editions', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnEditions
	static let columnEditions: String = String(
		localized: "Editions",
		comment: "The column header for the game item's edition count in the library table layout."
	)

	// MARK: - Library Table Accessibility
	/// The string for the word 'Favorite', used as an accessibility label for the library table's favorite control.
	///
	/// - Tag: L10n-favorite
	static let favorite: String = String(
		localized: "Favorite",
		comment: "The accessibility label for the favorite column or control in the library table layout."
	)
	/// The string for the word 'Reminder', used as an accessibility label for the library table's reminder control.
	///
	/// - Tag: L10n-reminder
	static let reminder: String = String(
		localized: "Reminder",
		comment: "The accessibility label for the reminder column or control in the library table layout."
	)
	/// The string for the phrase 'Remove from favorites', used as an accessibility label when a library item is favorited.
	///
	/// - Tag: L10n-removeFromFavorites
	static let removeFromFavorites: String = String(
		localized: "Remove from favorites",
		comment: "The accessibility label for the favorite button when the item is already favorited."
	)
	/// The string for the phrase 'Add to favorites', used as an accessibility label when a library item is not favorited.
	///
	/// - Tag: L10n-addToFavorites
	static let addToFavorites: String = String(
		localized: "Add to favorites",
		comment: "The accessibility label for the favorite button when the item is not favorited."
	)
	/// The string for the phrase 'Remove reminder', used as an accessibility label when a library item has a reminder set.
	///
	/// - Tag: L10n-removeReminder
	static let removeReminder: String = String(
		localized: "Remove reminder",
		comment: "The accessibility label for the reminder button when a reminder is set."
	)
	/// The string for the phrase 'Add reminder', used as an accessibility label when a library item has no reminder.
	///
	/// - Tag: L10n-addReminder
	static let addReminder: String = String(
		localized: "Add reminder",
		comment: "The accessibility label for the reminder button when no reminder is set."
	)

	// MARK: - Misc
	/// The string for the word 'Error'.
	///
	/// - Tag: L10n-error
	static let error: String = String(
		localized: "Error",
		comment: "The string for the word 'Error'."
	)
	/// The string for the word 'Default'.
	///
	/// - Tag: L10n-default
	static let `default`: String = String(
		localized: "Default",
		comment: "The string for the word 'Default'."
	)
	/// The string for the word 'Premium'.
	///
	/// - Tag: L10n-premium
	static let premium: String = String(
		localized: "Premium",
		comment: "The string for the word 'Premium'."
	)
	/// The string for the word 'today'.
	///
	/// - Tag: L10n-today
	static let today: String = String(
		localized: "Today",
		comment: "The string for the word 'today'."
	)
	/// The string for the word 'submitted'.
	///
	/// - Tag: L10n-submitted
	static let submitted: String = String(
		localized: "Submitted",
		comment: "The string for the word 'submitted'."
	)
	/// The string for the word 'rated'.
	///
	/// - Tag: L10n-rated
	static let rated: String = String(
		localized: "Rated",
		comment: "The string for the word 'rated'."
	)
	/// The string for the word 'add'.
	///
	/// - Tag: L10n-add
	static let add: String = String(
		localized: "Add",
		comment: "The string for the word 'add'."
	)
	/// The string for the word 'apply'.
	///
	/// - Tag: L10n-apply
	static let apply: String = String(
		localized: "Apply",
		comment: "The string for the word 'apply'."
	)
	/// The string for the word 'reset'.
	///
	/// - Tag: L10n-reset
	static let reset: String = String(
		localized: "Reset",
		comment: "The string for the word 'reset'."
	)
	/// The string for the word 'discover'.
	///
	/// - Tag: L10n-discover
	static let discover: String = String(
		localized: "Discover",
		comment: "The string for the word 'discover'."
	)
	/// The string for the word 'browse'.
	///
	/// - Tag: L10n-browse
	static let browse: String = String(
		localized: "Browse",
		comment: "The string for the word 'browse'."
	)
	/// The string for the word 'browse genres'.
	///
	/// - Tag: L10n-browseGenres
	static let browseGenres: String = String(
		localized: "Browse Genres",
		comment: "The string for the word 'browse genres'."
	)
	/// The string for the word 'browse themes'.
	///
	/// - Tag: L10n-browseThemes
	static let browseThemes: String = String(
		localized: "Browse Themes",
		comment: "The string for the word 'browse themes'."
	)
	/// The string for the word 'header'.
	///
	/// - Tag: L10n-header
	static let header: String = String(
		localized: "Header",
		comment: "The string for the word 'header'."
	)
	/// The string for the word 'about'.
	///
	/// - Tag: L10n-about
	static let about: String = String(
		localized: "About",
		comment: "The string for the word 'about'."
	)
	/// The string for the word 'information'.
	///
	/// - Tag: L10n-information
	static let information: String = String(
		localized: "Information",
		comment: "The string for the word 'information'."
	)
	/// The string for the word 'number'.
	///
	/// - Tag: L10n-number
	static let number: String = String(
		localized: "Number",
		comment: "The string for the word 'number'."
	)
	/// The string for the word 'duration'.
	///
	/// - Tag: L10n-duration
	static let duration: String = String(
		localized: "Duration",
		comment: "The string for the word 'duration'."
	)
	/// The string for the word 'aired'.
	///
	/// - Tag: L10n-aired
	static let aired: String = String(
		localized: "Aired",
		comment: "The string for the word 'aired'."
	)
	/// The string for the word 'tba'.
	///
	/// - Tag: L10n-tba
	static let tba: String = String(
		localized: "TBA",
		comment: "The string for the word 'tba'."
	)
	/// The string for the word 'shows'.
	///
	/// - Tag: L10n-shows
	static let shows: String = String(
		localized: "Shows",
		comment: "The string for the word 'shows'."
	)
	/// The string for the word 'characters'.
	///
	/// - Tag: L10n-characters
	static let characters: String = String(
		localized: "Characters",
		comment: "The string for the word 'characters'."
	)
	/// The string for the word 'episodes'.
	///
	/// - Tag: L10n-episodes
	static let episodes: String = String(
		localized: "Episodes",
		comment: "The string for the word 'episodes'."
	)
	/// The string for the word 'people'.
	///
	/// - Tag: L10n-people
	static let people: String = String(
		localized: "People",
		comment: "The string for the word 'people'."
	)
	/// The string for the word 'more'.
	///
	/// - Tag: L10n-more
	static let more: String = String(
		localized: "More",
		comment: "The string for the word 'more'."
	)
	/// The string for the word 'debut'.
	///
	/// - Tag: L10n-debut
	static let debut: String = String(
		localized: "Debut",
		comment: "The string for the word 'debut'."
	)
	/// The string for the word 'age'.
	///
	/// - Tag: L10n-age
	static let age: String = String(
		localized: "Age",
		comment: "The string for the word 'age'."
	)
	/// The string for the word 'measurements'.
	///
	/// - Tag: L10n-measurements
	static let measurements: String = String(
		localized: "Measurements",
		comment: "The string for the word 'measurements'."
	)
	/// The string for the word 'characteristics'.
	///
	/// - Tag: L10n-characteristics
	static let characteristics: String = String(
		localized: "Characteristics",
		comment: "The string for the word 'characteristics'."
	)
	/// The string for the word 'aliases'.
	///
	/// - Tag: L10n-aliases
	static let aliases: String = String(
		localized: "Aliases",
		comment: "The string for the word 'aliases'."
	)
	/// The string for the word 'socials'.
	///
	/// - Tag: L10n-socials
	static let socials: String = String(
		localized: "Socials",
		comment: "The string for the word 'socials'."
	)
	/// The string for the word 'websites'.
	///
	/// - Tag: L10n-websites
	static let websites: String = String(
		localized: "Websites",
		comment: "The string for the word 'websites'."
	)
	/// The string for the word 'new'.
	///
	/// - Tag: L10n-new
	static let new: String = String(
		localized: "New",
		comment: "The string for the word 'new'."
	)
	/// The string for the word 'off'.
	///
	/// - Tag: L10n-off
	static let off: String = String(
		localized: "Off",
		comment: "The string for the word 'off'."
	)
	/// The string for the word 'automatic'.
	///
	/// - Tag: L10n-automatic
	static let automatic: String = String(
		localized: "Automatic",
		comment: "The string for the word 'automatic'."
	)
	/// The string for the word 'by type'.
	///
	/// - Tag: L10n-byType
	static let byType: String = String(
		localized: "By Type",
		comment: "The string for the word 'by type'."
	)
	/// The string for the word 'other'.
	///
	/// - Tag: L10n-other
	static let other: String = String(
		localized: "Other",
		comment: "The string for the word 'other'."
	)
	/// The string for the word 'follower'.
	///
	/// - Tag: L10n-follower
	static let follower: String = String(
		localized: "Follower",
		comment: "The string for the word 'follower'."
	)
	/// The string for the word 'following'.
	///
	/// - Tag: L10n-following
	static let following: String = String(
		localized: "Following",
		comment: "The string for the word 'following'."
	)
	/// The string for the word 'follow'.
	///
	/// - Tag: L10n-follow
	static let follow: String = String(
		localized: "Follow",
		comment: "The string for the word 'follow'."
	)
	/// The string for the word 'message'.
	///
	/// - Tag: L10n-message
	static let message: String = String(
		localized: "Message",
		comment: "The string for the word 'message'."
	)
	/// The string for the word 'catalog'.
	///
	/// - Tag: L10n-catalog
	static let catalog: String = String(
		localized: "Catalog",
		comment: "The string for the word 'catalog'."
	)
	/// The string for the word 'library'.
	///
	/// - Tag: L10n-library
	static let library: String = String(
		localized: "Library",
		comment: "The string for the word 'library'."
	)
	/// The string for the word 'Sorting'.
	///
	/// - Tag: L10n-sorting
	static let sorting: String = String(
		localized: "Sorting",
		comment: "The string for the word 'Sorting'."
	)
	/// The string for the word 'Library Type'.
	///
	/// - Tag: L10n-libraryType
	static let libraryType: String = String(
		localized: "Library Type",
		comment: "The string for the word 'Library Type'."
	)
	/// The string for the word 'your library'.
	///
	/// - Tag: L10n-yourLibrary
	static let yourLibrary: String = String(
		localized: "Your Library",
		comment: "The string for the word 'your library'."
	)
	/// The string for the word 'add to library'.
	///
	/// - Tag: L10n-addToLibrary
	static let addToLibrary: String = String(
		localized: "Add to Library",
		comment: "The string for the word 'add to library'."
	)
	/// The string for the word 'update library status'.
	///
	/// - Tag: L10n-updateLibraryStatus
	static let updateLibraryStatus: String = String(
		localized: "Update Library Status",
		comment: "The string for the word 'update library status'."
	)
	/// The string for the word 'remove from library'.
	///
	/// - Tag: L10n-removeFromLibrary
	static let removeFromLibrary: String = String(
		localized: "Remove from Library",
		comment: "The string for the word 'remove from library'."
	)
	/// The string for the sentence 'Can’t delete library 😔'.
	///
	/// - Tag: L10n-cantDeleteLibrary
	static let cantDeleteLibrary: String = String(
		localized: "Can’t delete library 😔",
		comment: "The string for the sentence 'Can’t delete library 😔'."
	)
	/// The string for the phrase 'Delete Permanently'.
	///
	/// - Tag: L10n-deletePermanently
	static let deletePermanently: String = String(
		localized: "Delete Permanently",
		comment: "The string for the phrase 'Delete Permanently'."
	)
	/// The string for the phrase 'hide from public'.
	///
	/// - Tag: L10n-hideFromPublic
	static let hideFromPublic: String = String(
		localized: "Hide from Public",
		comment: "The string for the phrase 'hide from public'."
	)
	/// The string for the phrase 'show to public'.
	///
	/// - Tag: L10n-showToPublic
	static let showToPublic: String = String(
		localized: "Show to Public",
		comment: "The string for the phrase 'show to public'."
	)
	/// The string for the word 'watched'.
	///
	/// - Tag: L10n-watched
	static let watched: String = String(
		localized: "Watched",
		comment: "The string for the word 'watched'."
	)
	/// The string for the phrase 'mark as watched'.
	///
	/// - Tag: L10n-markAsWatched
	static let markAsWatched: String = String(
		localized: "Mark as Watched",
		comment: "The string for the phrase 'mark as watched'."
	)
	/// The string for the phrase 'mark as unwatched'.
	///
	/// - Tag: L10n-markAsUnwatched
	static let markAsUnwatched: String = String(
		localized: "Mark as Unwatched",
		comment: "The string for the phrase 'mark as unwatched'."
	)
	/// The string for the phrase 'mark all watched'.
	///
	/// - Tag: L10n-markAllWatched
	static let markAllWatched: String = String(
		localized: "Mark All Watched",
		comment: "The string for the phrase 'mark all watched'."
	)
	/// The string for the phrase 'mark all unwatched'.
	///
	/// - Tag: L10n-markAllUnwatched
	static let markAllUnwatched: String = String(
		localized: "Mark All Unwatched",
		comment: "The string for the phrase 'mark all unwatched'."
	)
	/// The string for the phrase 'Mark all'.
	///
	/// - Tag: L10n-markAll
	static let markAll: String = String(
		localized: "Mark all",
		comment: "The string for the phrase 'Mark all'."
	)
	/// The string for the phrase 'Mark all as read'.
	///
	/// - Tag: L10n-markAllAsRead
	static let markAllAsRead: String = String(
		localized: "Mark all as read",
		comment: "The string for the phrase 'Mark all as read'."
	)
	/// The string for the phrase 'Mark all as unread'.
	///
	/// - Tag: L10n-markAllAsUnread
	static let markAllAsUnread: String = String(
		localized: "Mark all as unread",
		comment: "The string for the phrase 'Mark all as unread'."
	)
	/// The string for the phrase 'Mark as read'.
	///
	/// - Tag: L10n-markAsRead
	static let markAsRead: String = String(
		localized: "Mark as read",
		comment: "The string for the phrase 'Mark as read'."
	)
	/// The string for the phrase 'Mark as unread'.
	///
	/// - Tag: L10n-markAsUnread
	static let markAsUnread: String = String(
		localized: "Mark as unread",
		comment: "The string for the phrase 'Mark as unread'."
	)
	/// The string for the word 'next'.
	///
	/// - Tag: L10n-next
	static let next: String = String(
		localized: "Next",
		comment: "The string for the word 'next'."
	)
	/// The string for the word 'previous'.
	///
	/// - Tag: L10n-previous
	static let previous: String = String(
		localized: "Previous",
		comment: "The string for the word 'previous'."
	)
	/// The string for the word 'chart'.
	///
	/// - Tag: L10n-chart
	static let chart: String = String(
		localized: "Chart",
		comment: "The string for the word 'chart'."
	)
	/// The string for the word 'anime'.
	///
	/// - Tag: L10n-anime
	static let anime: String = String(
		localized: "Anime",
		comment: "The string for the word 'anime'."
	)
	/// The string for the word 'literatures'.
	///
	/// - Tag: L10n-literatures
	static let literatures: String = String(
		localized: "Literatures",
		comment: "The string for the word 'literatures'."
	)
	/// The string for the word 'games'.
	///
	/// - Tag: L10n-games
	static let games: String = String(
		localized: "Games",
		comment: "The string for the word 'games'."
	)
	/// The string for the word 'user'.
	///
	/// - Tag: L10n-user
	static let user: String = String(
		localized: "User",
		comment: "The string for the word 'user'."
	)
	/// The string for the word 'users'.
	///
	/// - Tag: L10n-users
	static let users: String = String(
		localized: "Users",
		comment: "The string for the word 'users'."
	)
	/// The string for the word 'account'.
	///
	/// - Tag: L10n-account
	static let account: String = String(
		localized: "Account",
		comment: "The string for the word 'account'."
	)
	/// The string for the word 'debug'.
	///
	/// - Tag: L10n-debug
	static let debug: String = String(
		localized: "Debug",
		comment: "The string for the word 'debug'."
	)
	/// The string for the word 'pro'.
	///
	/// - Tag: L10n-pro
	static let pro: String = String(
		localized: "Pro",
		comment: "The string for the word 'pro'."
	)
	/// The string for the word 'alerts'.
	///
	/// - Tag: L10n-alerts
	static let alerts: String = String(
		localized: "Alerts",
		comment: "The string for the word 'alerts'."
	)
	/// The string for the word 'general'.
	///
	/// - Tag: L10n-general
	static let general: String = String(
		localized: "General",
		comment: "The string for the word 'general'."
	)
	/// The string for the word 'Guest'.
	///
	/// - Tag: L10n-guest
	static let guest: String = String(
		localized: "Guest",
		comment: "The string for the word 'Guest'."
	)
	/// The string for the word 'notifications'.
	///
	/// - Tag: L10n-notifications
	static let notifications: String = String(
		localized: "Notifications",
		comment: "The string for the word 'notifications'."
	)
	/// The string for the word 'profile'.
	///
	/// - Tag: L10n-profile
	static let profile: String = String(
		localized: "Profile",
		comment: "The string for the word 'profile'."
	)
	/// The string for the word 'stickers'.
	///
	/// - Tag: L10n-stickers
	static let stickers: String = String(
		localized: "Stickers",
		comment: "The string for the word 'stickers'."
	)
	/// The string for the word 'security'.
	///
	/// - Tag: L10n-security
	static let security: String = String(
		localized: "Security",
		comment: "The string for the word 'security'."
	)
	/// The string for the word 'support us'.
	///
	/// - Tag: L10n-supportUs
	static let supportUs: String = String(
		localized: "Support Us",
		comment: "The string for the word 'support us'."
	)
	/// The string for the word 'social'.
	///
	/// - Tag: L10n-social
	static let social: String = String(
		localized: "Social",
		comment: "The string for the word 'social'."
	)
	/// The string for the word 'theme'.
	///
	/// - Tag: L10n-theme
	static let theme: String = String(
		localized: "Theme",
		comment: "The string for the word 'theme'."
	)
	/// The string for the word 'icon'.
	///
	/// - Tag: L10n-icon
	static let icon: String = String(
		localized: "Icon",
		comment: "The string for the word 'icon'."
	)
	/// The string for the word 'motion'.
	///
	/// - Tag: L10n-motion
	static let motion: String = String(
		localized: "Motion",
		comment: "The string for the word 'motion'."
	)
	/// The string for the word 'browser'.
	///
	/// - Tag: L10n-browser
	static let browser: String = String(
		localized: "Browser",
		comment: "The string for the word 'browser'."
	)
	/// The string for the word 'passcode'.
	///
	/// - Tag: L10n-passcode
	static let passcode: String = String(
		localized: "Passcode",
		comment: "The string for the word 'passcode'."
	)
	/// The string for the word 'cache'.
	///
	/// - Tag: L10n-cache
	static let cache: String = String(
		localized: "Cache",
		comment: "The string for the word 'cache'."
	)
	/// The string for the word 'images'.
	///
	/// - Tag: L10n-images
	static let images: String = String(
		localized: "Images",
		comment: "The string for the word 'images'."
	)
	/// The string for the phrase 'rich links'.
	///
	/// - Tag: L10n-richLinks
	static let richLinks: String = String(
		localized: "Rich Links",
		comment: "The string for the phrase 'rich links'."
	)
	/// The string for the word 'privacy'.
	///
	/// - Tag: L10n-privacy
	static let privacy: String = String(
		localized: "Privacy",
		comment: "The string for the word 'privacy'."
	)
	/// The string for the word 'founded'.
	///
	/// - Tag: L10n-founded
	static let founded: String = String(
		localized: "Founded",
		comment: "The string for the word 'founded'."
	)
	/// The string for the word 'defunct'.
	///
	/// - Tag: L10n-defunct
	static let defunct: String = String(
		localized: "Defunct",
		comment: "The string for the word 'defunct'."
	)
	/// The string for the word 'headquarters'.
	///
	/// - Tag: L10n-headquarters
	static let headquarters: String = String(
		localized: "Headquarters",
		comment: "The string for the word 'headquarters'."
	)
	/// The string for the word 'synopsis'.
	///
	/// - Tag: L10n-synopsis
	static let synopsis: String = String(
		localized: "Synopsis",
		comment: "The string for the word 'synopsis'."
	)
	/// The string for the word 'explore'.
	///
	/// - Tag: L10n-explore
	static let explore: String = String(
		localized: "Explore",
		comment: "The string for the word 'explore'."
	)
	/// The string for the word 'schedule'.
	///
	/// - Tag: L10n-schedule
	static let schedule: String = String(
		localized: "Schedule",
		comment: "The string for the word 'schedule'."
	)
	/// The string for the word 'feed'.
	///
	/// - Tag: L10n-feed
	static let feed: String = String(
		localized: "Feed",
		comment: "The string for the word 'feed'."
	)
	/// The string for the word 'reviews'.
	///
	/// - Tag: L10n-reviews
	static let reviews: String = String(
		localized: "Reviews",
		comment: "The string for the word 'reviews'."
	)
	/// The string for the word 'search'.
	///
	/// - Tag: L10n-search
	static let search: String = String(
		localized: "Search",
		comment: "The string for the word 'search'."
	)
	/// The string for the phrase 'Search Library'.
	///
	/// - Tag: L10n-searchLibrary
	static let searchLibrary: String = String(
		localized: "Search Library",
		comment: "The title and placeholder for the library search screen."
	)
	/// The string for the word 'sort'.
	///
	/// - Tag: L10n-sort
	static let sort: String = String(
		localized: "Sort",
		comment: "The string for the word 'sort'."
	)
	/// The string for the word 'filter'.
	///
	/// - Tag: L10n-filter
	static let filter: String = String(
		localized: "Filter",
		comment: "The string for the word 'filter'."
	)
	/// The string for the word 'filters'.
	///
	/// - Tag: L10n-filters
	static let filters: String = String(
		localized: "Filters",
		comment: "The string for the word 'filters'."
	)
	/// The string for the word 'settings'.
	///
	/// - Tag: L10n-settings
	static let settings: String = String(
		localized: "Settings",
		comment: "The string for the word 'settings'."
	)
	/// The string for the word 'subscribe'.
	///
	/// - Tag: L10n-subscribe
	static let subscribe: String = String(
		localized: "Subscribe",
		comment: "The string for the word 'subscribe'."
	)
	/// The string for the word 'send'.
	///
	/// - Tag: L10n-send
	static let send: String = String(
		localized: "Send",
		comment: "The string for the word 'send'."
	)
	/// The string for the phrase 'save draft'.
	///
	/// - Tag: L10n-saveDraft
	static let saveDraft: String = String(
		localized: "Save Draft",
		comment: "The string for the phrase 'save draft'."
	)
	/// The string for the word 'drafts'.
	///
	/// - Tag: L10n-drafts
	static let drafts: String = String(
		localized: "Drafts",
		comment: "The string for the word 'drafts'."
	)
	/// The string for the 'no drafts' empty state title.
	///
	/// - Tag: L10n-noDraftsTitle
	static let noDraftsTitle: String = String(
		localized: "No Drafts",
		comment: "The string for the 'no drafts' empty state title."
	)
	/// The string for the 'no drafts' empty state detail.
	///
	/// - Tag: L10n-noDraftsDetail
	static let noDraftsDetail: String = String(
		localized: "Your saved drafts will appear here.",
		comment: "The string for the 'no drafts' empty state detail."
	)
	/// The string for the 'empty draft' placeholder.
	///
	/// - Tag: L10n-emptyDraft
	static let emptyDraft: String = String(
		localized: "Empty draft",
		comment: "The string for the 'empty draft' placeholder."
	)
	/// The string for the word 'discard'.
	///
	/// - Tag: L10n-discard
	static let discard: String = String(
		localized: "Discard",
		comment: "The string for the word 'discard'."
	)
	/// The string for the word 'done'.
	///
	/// - Tag: L10n-done
	static let done: String = String(
		localized: "Done",
		comment: "The string for the word 'done'."
	)
	/// The string for the word 'cancel'.
	///
	/// - Tag: L10n-cancel
	static let cancel: String = String(
		localized: "Cancel",
		comment: "The string for the word 'cancel'."
	)
	/// The string for the word 'remove'.
	///
	/// - Tag: L10n-remove
	static let remove: String = String(
		localized: "Remove",
		comment: "The string for the word 'remove'."
	)
	/// The string for the word 'share'.
	///
	/// - Tag: L10n-share
	static let share: String = String(
		localized: "Share",
		comment: "The string for the word 'share'."
	)
	/// The string for the word 'copy'.
	///
	/// - Tag: L10n-copy
	static let copy: String = String(
		localized: "Copy",
		comment: "The string for the word 'copy'."
	)
	/// The string for the word 'Copy Review'.
	///
	/// - Tag: L10n-copyReview
	static let copyReview: String = String(
		localized: "Copy Review",
		comment: "The string for the word 'Copy Review'."
	)
	/// The string for the word 'Copy Title'.
	///
	/// - Tag: L10n-copyTitle
	static let copyTitle: String = String(
		localized: "Copy Title",
		comment: "The string for the word 'Copy Title'."
	)
	/// The string for the word 'Copy Link'.
	///
	/// - Tag: L10n-copyLink
	static let copyLink: String = String(
		localized: "Copy Link",
		comment: "The string for the word 'Copy Link'."
	)
	/// The string for the word 'update'.
	///
	/// - Tag: L10n-update
	static let update: String = String(
		localized: "Update!",
		comment: "The string for the word 'update'."
	)
	/// The string for the word 'reconnect'.
	///
	/// - Tag: L10n-reconnect
	static let reconnect: String = String(
		localized: "Reconnect!",
		comment: "The string for the word 'reconnect'."
	)
	/// The string for the word 'Lyrics'.
	///
	/// - Tag: L10n-lyrics
	static let lyrics: String = String(
		localized: "Lyrics",
		comment: "The string for the word 'Lyrics'."
	)
	/// The string for the phrase 'As Heard On'.
	///
	/// - Tag: L10n-asHeardOn
	static let asHeardOn: String = String(
		localized: "As Heard On",
		comment: "The string for the word 'As Heard On'."
	)
	/// The string for the phrase 'View on Amazon Music'.
	///
	/// - Tag: L10n-viewOnAmazonMusic
	static let viewOnAmazonMusic: String = String(
		localized: "View on Amazon Music",
		comment: "The string for the word 'View on Amazon Music'."
	)
	/// The string for the phrase 'View on Apple Music'.
	///
	/// - Tag: L10n-viewOnAppleMusic
	static let viewOnAppleMusic: String = String(
		localized: "View on Apple Music",
		comment: "The string for the word 'View on Apple Music'."
	)
	/// The string for the phrase 'View on Deezer'.
	///
	/// - Tag: L10n-viewOnDeezer
	static let viewOnDeezer: String = String(
		localized: "View on Deezer",
		comment: "The string for the word 'View on Deezer'."
	)
	/// The string for the phrase 'View on Spotify'.
	///
	/// - Tag: L10n-viewOnSpotify
	static let viewOnSpotify: String = String(
		localized: "View on Spotify",
		comment: "The string for the word 'View on Spotify'."
	)
	/// The string for the phrase 'View on YouTube'.
	///
	/// - Tag: L10n-viewOnYouTube
	static let viewOnYouTube: String = String(
		localized: "View on YouTube",
		comment: "The string for the word 'View on YouTube'."
	)
	/// The string for the word 'preview'.
	///
	/// - Tag: L10n-preview
	static let preview: String = String(
		localized: "Preview",
		comment: "The string for the word 'preview'."
	)
	/// The string for the word 'Play'.
	///
	/// - Tag: L10n-play
	static let play: String = String(
		localized: "Play",
		comment: "The string for the word 'Play'."
	)
	/// The string for the word 'pause'.
	///
	/// - Tag: L10n-pause
	static let pause: String = String(
		localized: "Pause",
		comment: "The string for the word 'Pause'."
	)
	/// The string for the word 'stop'.
	///
	/// - Tag: L10n-stop
	static let stop: String = String(
		localized: "Stop",
		comment: "The string for the word 'stop'."
	)
	/// The string for the word 'password'.
	///
	/// - Tag: L10n-password
	static let password: String = String(
		localized: "Password",
		comment: "The string for the word 'password'."
	)
	/// The string for the word 'download'.
	///
	/// - Tag: L10n-download
	static let download: String = String(
		localized: "Download",
		comment: "The string for the word 'download'."
	)
	/// The string for the phrase 'coming soon'.
	///
	/// - Tag: L10n-comingSoon
	static let comingSoon: String = String(
		localized: "Coming Soon",
		comment: "The string for the word 'coming soon'."
	)
	/// The string for the word 'expected'.
	///
	/// - Tag: L10n-expected
	static let expected: String = String(
		localized: "Expected",
		comment: "The string for the word 'expected'."
	)
	/// The string for the word 'achievements'.
	///
	/// - Tag: L10n-achievements
	static let achievements: String = String(
		localized: "Achievements",
		comment: "The string for the word 'achievements'."
	)
	/// The string for the word 'badges'.
	///
	/// - Tag: L10n-badges
	static let badges: String = String(
		localized: "Badges",
		comment: "The string for the word 'badges'."
	)
	/// The string for the word 'rank'.
	///
	/// - Tag: L10n-rank
	static let rank: String = String(
		localized: "Rank",
		comment: "The string for the word 'rank'."
	)
	/// The string for the word 'languages'.
	///
	/// - Tag: L10n-language
	static let language: String = String(
		localized: "Languages",
		comment: "The string for the word 'language'."
	)
	/// The string for the word 'country'.
	///
	/// - Tag: L10n-country
	static let country: String = String(
		localized: "Country",
		comment: "The string for the word 'country'."
	)
	/// The string for the phrase 'TV Rating'.
	///
	/// - Tag: L10n-tvRating
	static let tvRating: String = String(
		localized: "TV Rating",
		comment: "The string for the word 'TV rating'."
	)
	/// The string for the word 'seasons'.
	///
	/// - Tag: L10n-seasons
	static let seasons: String = String(
		localized: "Seasons",
		comment: "The string for the word 'seasons'."
	)
	/// The string for the word 'season'.
	///
	/// - Tag: L10n-season
	static let season: String = String(
		localized: "Season",
		comment: "The string for the word 'season'."
	)
	/// The string for the word 'studios'.
	///
	/// - Tag: L10n-studios
	static let studios: String = String(
		localized: "Studios",
		comment: "The string for the word 'studios'."
	)
	/// The string for the word 'studio'.
	///
	/// - Tag: L10n-studio
	static let studio: String = String(
		localized: "Studio",
		comment: "The string for the word 'studio'."
	)
	/// The string for the phrase 'Founded on [date]'.
	///
	/// - Tag: L10n-foundedOn
	static func foundedOn(date: String) -> String {
		String(
			localized: "Founded on \(date)",
			comment: "The string for the word 'Founded on [date]'."
		)
	}

	/// The string for the word 'successor'.
	///
	/// - Tag: L10n-successor
	static let successor: String = String(
		localized: "Successor",
		comment: "The string for the word 'successor'."
	)
	/// The string for the word 'cast'.
	///
	/// - Tag: L10n-cast
	static let cast: String = String(
		localized: "Cast",
		comment: "The string for the word 'cast'."
	)
	/// The string for the word 'songs'.
	///
	/// - Tag: L10n-songs
	static let songs: String = String(
		localized: "Songs",
		comment: "The string for the word 'songs'."
	)
	/// The string for the phrase 'More by'.
	///
	/// - Tag: L10n-moreBy
	static let moreBy: String = String(
		localized: "More by",
		comment: "The string for the word 'more by'."
	)
	/// The string for the phrase 'Related Shows'.
	///
	/// - Tag: L10n-relatedShows
	static let relatedShows: String = String(
		localized: "Related Shows",
		comment: "The string for the word 'related shows'."
	)
	/// The string for the phrase 'Related Literatures'.
	///
	/// - Tag: L10n-relatedLiteratures
	static let relatedLiteratures: String = String(
		localized: "Related Literatures",
		comment: "The string for the word 'related literatures'."
	)
	/// The string for the phrase 'Related Games'.
	///
	/// - Tag: L10n-relatedGames
	static let relatedGames: String = String(
		localized: "Related Games",
		comment: "The string for the word 'related games'."
	)
	/// The string for the word 'copyright'.
	///
	/// - Tag: L10n-copyright
	static let copyright: String = String(
		localized: "Copyright",
		comment: "The string for the word 'copyright'."
	)
	/// The string for the phrase 'Open Twitter'.
	///
	/// - Tag: L10n-openTwitter
	static let openTwitter: String = String(
		localized: "Open Twitter",
		comment: "The string for the word 'Open Twitter'."
	)
	/// The string for the word 'Redeem'.
	///
	/// - Tag: L10n-redeem
	static let redeem: String = String(
		localized: "Redeem",
		comment: "The string for the word 'Redeem'."
	)
	/// The string for the phrase 'View Subscription'.
	///
	/// - Tag: L10n-viewSubscription
	static let viewSubscription: String = String(
		localized: "View Subscription",
		comment: "The string for the word 'View Subscription'."
	)
	/// The string for the phrase 'Become a Subscriber'.
	///
	/// - Tag: L10n-becomeASubscriber
	static let becomeASubscriber: String = String(
		localized: "Become a Subscriber",
		comment: "The string for the word 'Become a Subscriber'."
	)
	/// The string for the word 'Continue'.
	///
	/// - Tag: L10n-continue
	static let `continue`: String = String(
		localized: "Continue",
		comment: "The string for the word 'Continue'."
	)
	/// The string for the phrase 'What’s New'.
	///
	/// - Tag: L10n-whatsNew
	static let whatsNew: String = String(
		localized: "What’s New in Kurozora",
		comment: "The string for the word 'What’s New'."
	)
	/// The string for the word 'Favorites'.
	///
	/// - Tag: L10n-favorites
	static let favorites: String = String(
		localized: "Favorites",
		comment: "The string for the word 'Favorites'"
	)
	/// The string for the phrase 'My Favorites'.
	///
	/// - Tag: L10n-myFavorites
	static let myFavorites: String = String(
		localized: "My Favorites",
		comment: "The string for the word 'My Favorites'"
	)
	/// The string for the word 'Reminders'.
	///
	/// - Tag: L10n-reminders
	static let reminders: String = String(
		localized: "Reminders",
		comment: "The string for the word 'Reminders'"
	)
	/// The string for the phrase 'Remind Me'.
	///
	/// - Tag: L10n-remindMe
	static let remindMe: String = String(
		localized: "Remind Me",
		comment: "The string for the word 'Remind Me'"
	)
	/// The string for the phrase 'My Reminders'.
	///
	/// - Tag: L10n-myReminders
	static let myReminders: String = String(
		localized: "My Reminders",
		comment: "The string for the word 'My Reminders'"
	)

	// MARK: - ReCap
	/// The string for the word 'Re:Cap'.
	///
	/// - Tag: L10n-reCAP
	static let reCAP: String = String(
		localized: "Re:CAP",
		comment: "The string for the word 'Re:CAP'."
	)
	/// The string for the word 'Milestones'.
	///
	/// - Tag: L10n-milestones
	static let milestones: String = String(
		localized: "Milestones",
		comment: "The string for the word 'Milestones'."
	)
	/// The string for the phrase 'Top %@'.
	///
	/// - Tag: L10n-topX
	static func top(_ string: String) -> String {
		return String(
			localized: "Top \(string)",
			comment: "The string for the word 'Top %@'."
		)
	}

	/// The string for the phrase '%@ total series'.
	///
	/// - Tag: L10n-totalSeries
	static func totalSeries(_ string: String) -> String {
		return String(
			localized: "\(string) total series",
			comment: "The string for the word '%@ total series'."
		)
	}
}
