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
	static var takePhoto: String {
		L10n.resolve {
			String(
				localized: "Take Photo 📷",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action sheet button for capturing a new photo from the camera."
			)
		}
	}
	/// The action sheet button for picking an existing photo from the library.
	///
	/// - Tag: L10n-photoLibrary
	static var photoLibrary: String {
		L10n.resolve {
			String(
				localized: "Photo Library 🏛",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action sheet button for picking an existing photo from the library."
			)
		}
	}
	/// The action sheet button for generating a new image with Image Playground.
	///
	/// - Tag: L10n-imagePlayground
	static var imagePlayground: String {
		L10n.resolve {
			String(
				localized: "Image Playground ✨",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action sheet button for generating a new image with Image Playground."
			)
		}
	}

	// MARK: - Sign Out Confirmation
	/// The destructive confirmation button for the sign-out alert.
	///
	/// - Tag: L10n-signOutConfirm
	static var signOutConfirm: String {
		L10n.resolve {
			String(
				localized: "Yes, sign me out 🤨",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The destructive confirmation button for the sign-out alert."
			)
		}
	}
	/// The body string for the sign-out confirmation alert.
	///
	/// - Tag: L10n-signOutConfirmMessage
	static var signOutConfirmMessage: String {
		L10n.resolve {
			String(
				localized: "Are you sure you want to sign out?",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The body string for the sign-out confirmation alert."
			)
		}
	}
	/// The cancel button for the sign-out confirmation alert.
	///
	/// - Tag: L10n-signOutCancel
	static var signOutCancel: String {
		L10n.resolve {
			String(
				localized: "No, keep me signed in 😅",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The cancel button for the sign-out confirmation alert."
			)
		}
	}

	// MARK: - Library
	/// The string for the phrase 'View Options', used as a submenu title in the library table layout.
	///
	/// - Tag: L10n-viewOptions
	static var viewOptions: String {
		L10n.resolve {
			String(
				localized: "View Options",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The submenu title for toggling view options in the library table layout."
			)
		}
	}
	/// The string for the phrase 'Show Poster', used as a view option in the library table layout.
	///
	/// - Tag: L10n-showPoster
	static var showPoster: String {
		L10n.resolve {
			String(
				localized: "Show Poster",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The view option that toggles whether the title cell shows a poster."
			)
		}
	}
	/// The string for the phrase 'Always Show Title', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleAlways
	static var compactTitleAlways: String {
		L10n.resolve {
			String(
				localized: "Always Show Title",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The view option that always shows the series title beneath the poster in the library compact layout."
			)
		}
	}
	/// The string for the phrase 'Hide Title', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleNever
	static var compactTitleNever: String {
		L10n.resolve {
			String(
				localized: "Hide Title",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The view option that hides the series title in the library compact layout."
			)
		}
	}
	/// The string for the word 'Smart', used as a view option in the library compact layout.
	///
	/// - Tag: L10n-compactTitleSmart
	static var compactTitleSmart: String {
		L10n.resolve {
			String(
				localized: "Smart",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The view option that hides the series title when real poster art is available in the library compact layout."
			)
		}
	}
	/// The string for the subtitle accompanying the 'Smart' compact title-visibility option.
	///
	/// - Tag: L10n-compactTitleSmartSubtitle
	static var compactTitleSmartSubtitle: String {
		L10n.resolve {
			String(
				localized: "Shows title only when poster art isn't available",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtitle explaining the 'Smart' compact title-visibility option."
			)
		}
	}
	/// The string for the phrase 'Reset to Default', used inside the library table's View Options menu.
	///
	/// - Tag: L10n-resetToDefault
	static var resetToDefault: String {
		L10n.resolve {
			String(
				localized: "Reset to Default",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The destructive action that restores the default set of library table view options."
			)
		}
	}
	/// The string for the word 'Title', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnTitle
	static var columnTitle: String {
		L10n.resolve {
			String(
				localized: "Title",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's title in the library table layout."
			)
		}
	}
	/// The string for the word 'Type', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnType
	static var columnType: String {
		L10n.resolve {
			String(
				localized: "Type",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's media type in the library table layout."
			)
		}
	}
	/// The string for the word 'Status', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnStatus
	static var columnStatus: String {
		L10n.resolve {
			String(
				localized: "Status",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's airing or publishing status in the library table layout."
			)
		}
	}
	/// The string for the word 'Genres', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnGenres
	static var columnGenres: String {
		L10n.resolve {
			String(
				localized: "Genres",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's genres in the library table layout."
			)
		}
	}
	/// The string for the word 'Year', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnYear
	static var columnYear: String {
		L10n.resolve {
			String(
				localized: "Year",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's release year in the library table layout."
			)
		}
	}
	/// The string for the phrase 'Date Added', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnDateAdded
	static var columnDateAdded: String {
		L10n.resolve {
			String(
				localized: "Date Added",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the date the item was added to the library."
			)
		}
	}
	/// The string for the word 'Progress', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnProgress
	static var columnProgress: String {
		L10n.resolve {
			String(
				localized: "Progress",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the item's progress indicator in the library table layout."
			)
		}
	}
	/// The string for the word 'Chapters', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnChapters
	static var columnChapters: String {
		L10n.resolve {
			String(
				localized: "Chapters",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the literature item's chapter count in the library table layout."
			)
		}
	}
	/// The string for the word 'Volumes', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnVolumes
	static var columnVolumes: String {
		L10n.resolve {
			String(
				localized: "Volumes",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the literature item's volume count in the library table layout."
			)
		}
	}
	/// The string for the word 'Editions', used as a column header in the library table layout.
	///
	/// - Tag: L10n-columnEditions
	static var columnEditions: String {
		L10n.resolve {
			String(
				localized: "Editions",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The column header for the game item's edition count in the library table layout."
			)
		}
	}

	// MARK: - Library Table Accessibility
	/// The string for the word 'Favorite', used as an accessibility label for the library table's favorite control.
	///
	/// - Tag: L10n-favorite
	static var favorite: String {
		L10n.resolve {
			String(
				localized: "Favorite",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the favorite column or control in the library table layout."
			)
		}
	}
	/// The string for the word 'Reminder', used as an accessibility label for the library table's reminder control.
	///
	/// - Tag: L10n-reminder
	static var reminder: String {
		L10n.resolve {
			String(
				localized: "Reminder",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the reminder column or control in the library table layout."
			)
		}
	}
	/// The string for the phrase 'Remove from favorites', used as an accessibility label when a library item is favorited.
	///
	/// - Tag: L10n-removeFromFavorites
	static var removeFromFavorites: String {
		L10n.resolve {
			String(
				localized: "Remove from favorites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the favorite button when the item is already favorited."
			)
		}
	}
	/// The string for the phrase 'Add to favorites', used as an accessibility label when a library item is not favorited.
	///
	/// - Tag: L10n-addToFavorites
	static var addToFavorites: String {
		L10n.resolve {
			String(
				localized: "Add to favorites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the favorite button when the item is not favorited."
			)
		}
	}
	/// The string for the phrase 'Remove reminder', used as an accessibility label when a library item has a reminder set.
	///
	/// - Tag: L10n-removeReminder
	static var removeReminder: String {
		L10n.resolve {
			String(
				localized: "Remove reminder",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the reminder button when a reminder is set."
			)
		}
	}
	/// The string for the phrase 'Add reminder', used as an accessibility label when a library item has no reminder.
	///
	/// - Tag: L10n-addReminder
	static var addReminder: String {
		L10n.resolve {
			String(
				localized: "Add reminder",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the reminder button when no reminder is set."
			)
		}
	}
	/// The string for the word 'Visibility', used as an accessibility label for the library table's public-visibility control.
	///
	/// - Tag: L10n-visibility
	static var visibility: String {
		L10n.resolve {
			String(
				localized: "Visibility",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the visibility column or control in the library table layout."
			)
		}
	}

	// MARK: - Misc
	/// The string for the word 'Error'.
	///
	/// - Tag: L10n-error
	static var error: String {
		L10n.resolve {
			String(
				localized: "Error",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Error'."
			)
		}
	}
	/// The string for the word 'Default'.
	///
	/// - Tag: L10n-default
	static let `default`: String = String(
		localized: "Default",
		bundle: LanguageManager.shared.bundle,
		locale: LanguageManager.shared.locale,
		comment: "The string for the word 'Default'."
	)
	/// The string for the word 'Premium'.
	///
	/// - Tag: L10n-premium
	static var premium: String {
		L10n.resolve {
			String(
				localized: "Premium",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Premium'."
			)
		}
	}
	/// The string for the word 'today'.
	///
	/// - Tag: L10n-today
	static var today: String {
		L10n.resolve {
			String(
				localized: "Today",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'today'."
			)
		}
	}
	/// The string for the word 'now'.
	///
	/// - Tag: L10n-now
	static var now: String {
		L10n.resolve {
			String(
				localized: "Now",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'now'."
			)
		}
	}
	/// The string for the word 'submitted'.
	///
	/// - Tag: L10n-submitted
	static var submitted: String {
		L10n.resolve {
			String(
				localized: "Submitted",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'submitted'."
			)
		}
	}
	/// The string for the word 'rated'.
	///
	/// - Tag: L10n-rated
	static var rated: String {
		L10n.resolve {
			String(
				localized: "Rated",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'rated'."
			)
		}
	}
	/// The section-header button that opens the full list.
	///
	/// - Tag: L10n-seeAll
	static var seeAll: String {
		L10n.resolve {
			String(
				localized: "See All",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The section-header button that opens the full list."
			)
		}
	}
	/// The spelled-out word for a count of one.
	///
	/// - Tag: L10n-one
	static var one: String {
		L10n.resolve {
			String(
				localized: "one",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The spelled-out word for a count of one, as in 'Across one season.'."
			)
		}
	}
	/// The string for the word 'add'.
	///
	/// - Tag: L10n-add
	static var add: String {
		L10n.resolve {
			String(
				localized: "Add",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'add'."
			)
		}
	}
	/// The string for the word 'all'.
	///
	/// - Tag: L10n-all
	static var all: String {
		L10n.resolve {
			String(
				localized: "All",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'all'."
			)
		}
	}
	/// The string for the word 'apply'.
	///
	/// - Tag: L10n-apply
	static var apply: String {
		L10n.resolve {
			String(
				localized: "Apply",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'apply'."
			)
		}
	}
	/// The string for the word 'reset'.
	///
	/// - Tag: L10n-reset
	static var reset: String {
		L10n.resolve {
			String(
				localized: "Reset",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'reset'."
			)
		}
	}
	/// The string for the word 'discover'.
	///
	/// - Tag: L10n-discover
	static var discover: String {
		L10n.resolve {
			String(
				localized: "Discover",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'discover'."
			)
		}
	}
	/// The string for the word 'browse'.
	///
	/// - Tag: L10n-browse
	static var browse: String {
		L10n.resolve {
			String(
				localized: "Browse",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'browse'."
			)
		}
	}
	/// The string for the word 'browse genres'.
	///
	/// - Tag: L10n-browseGenres
	static var browseGenres: String {
		L10n.resolve {
			String(
				localized: "Browse Genres",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'browse genres'."
			)
		}
	}
	/// The string for the word 'browse themes'.
	///
	/// - Tag: L10n-browseThemes
	static var browseThemes: String {
		L10n.resolve {
			String(
				localized: "Browse Themes",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'browse themes'."
			)
		}
	}
	/// The string for the word 'header'.
	///
	/// - Tag: L10n-header
	static var header: String {
		L10n.resolve {
			String(
				localized: "Header",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'header'."
			)
		}
	}
	/// The string for the word 'about'.
	///
	/// - Tag: L10n-about
	static var about: String {
		L10n.resolve {
			String(
				localized: "About",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'about'."
			)
		}
	}
	/// The string for the word 'information'.
	///
	/// - Tag: L10n-information
	static var information: String {
		L10n.resolve {
			String(
				localized: "Information",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'information'."
			)
		}
	}
	/// The string for the word 'number'.
	///
	/// - Tag: L10n-number
	static var number: String {
		L10n.resolve {
			String(
				localized: "Number",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'number'."
			)
		}
	}
	/// The string for the word 'duration'.
	///
	/// - Tag: L10n-duration
	static var duration: String {
		L10n.resolve {
			String(
				localized: "Duration",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'duration'."
			)
		}
	}
	/// The string for the word 'aired'.
	///
	/// - Tag: L10n-aired
	static var aired: String {
		L10n.resolve {
			String(
				localized: "Aired",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'aired'."
			)
		}
	}
	/// The string for the word 'tba'.
	///
	/// - Tag: L10n-tba
	static var tba: String {
		L10n.resolve {
			String(
				localized: "TBA",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'tba'."
			)
		}
	}
	/// The string for the word 'shows'.
	///
	/// - Tag: L10n-shows
	static var shows: String {
		L10n.resolve {
			String(
				localized: "Shows",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'shows'."
			)
		}
	}
	/// The string for the word 'characters'.
	///
	/// The string for the word 'story'.
	static var story: String {
		L10n.resolve {
			String(
				localized: "Story",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'story'."
			)
		}
	}
	/// The star rating a score translates to.
	static func outOfFiveStars(_ stars: String) -> String {
		L10n.resolve {
			String(
				localized: "outOfFiveStars",
				defaultValue: "\(stars) out of 5 stars",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The star rating a score translates to."
			)
		}
	}
	/// - Tag: L10n-characters
	static var characters: String {
		L10n.resolve {
			String(
				localized: "Characters",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'characters'."
			)
		}
	}
	/// The string for the word 'episodes'.
	///
	/// - Tag: L10n-episodes
	static var episodes: String {
		L10n.resolve {
			String(
				localized: "Episodes",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'episodes'."
			)
		}
	}
	/// The string for the word 'people'.
	///
	/// - Tag: L10n-people
	static var people: String {
		L10n.resolve {
			String(
				localized: "People",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'people'."
			)
		}
	}
	/// The string for the word 'genres'.
	///
	/// - Tag: L10n-genres
	static var genres: String {
		L10n.resolve {
			String(
				localized: "Genres",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'genres'."
			)
		}
	}
	/// The string for the word 'themes'.
	///
	/// - Tag: L10n-themes
	static var themes: String {
		L10n.resolve {
			String(
				localized: "Themes",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'themes'."
			)
		}
	}
	/// The string for the word 'leaderboard'.
	///
	/// - Tag: L10n-leaderboard
	static var leaderboard: String {
		L10n.resolve {
			String(
				localized: "Leaderboard",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'leaderboard'."
			)
		}
	}
	/// The string for the phrase 'profile details'.
	///
	/// - Tag: L10n-profileDetails
	static var profileDetails: String {
		L10n.resolve {
			String(
				localized: "Profile Details",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'profile details'."
			)
		}
	}
	/// The string for the phrase 'message details'.
	///
	/// - Tag: L10n-messageDetails
	static var messageDetails: String {
		L10n.resolve {
			String(
				localized: "Message Details",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'message details'."
			)
		}
	}
	/// The string for the phrase 'message replies'.
	///
	/// - Tag: L10n-messageReplies
	static var messageReplies: String {
		L10n.resolve {
			String(
				localized: "Message Replies",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'message replies'."
			)
		}
	}
	/// The string for the phrase 'explore feed'.
	///
	/// - Tag: L10n-exploreFeed
	static var exploreFeed: String {
		L10n.resolve {
			String(
				localized: "Explore Feed",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'explore feed'."
			)
		}
	}
	/// The string for the phrase 'parental guide entries'.
	///
	/// - Tag: L10n-parentalGuideEntries
	static var parentalGuideEntries: String {
		L10n.resolve {
			String(
				localized: "Parental Guide Entries",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'parental guide entries'."
			)
		}
	}
	/// The string for the word 'sessions'.
	///
	/// - Tag: L10n-sessions
	static var sessions: String {
		L10n.resolve {
			String(
				localized: "Sessions",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'sessions'."
			)
		}
	}
	/// The string for the word 'more'.
	///
	/// - Tag: L10n-more
	static var more: String {
		L10n.resolve {
			String(
				localized: "More",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The overflow ('More') menu button."
			)
		}
	}
	/// The string for the phrase 'Show more'.
	///
	/// - Tag: L10n-showMore
	static var showMore: String {
		L10n.resolve {
			String(
				localized: "Show more",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The inline affordance appended after a truncated feed message body that expands the rest of the post when tapped."
			)
		}
	}
	/// The string for the word 'debut'.
	///
	/// - Tag: L10n-debut
	static var debut: String {
		L10n.resolve {
			String(
				localized: "Debut",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'debut'."
			)
		}
	}
	/// The string for the word 'age'.
	///
	/// - Tag: L10n-age
	static var age: String {
		L10n.resolve {
			String(
				localized: "Age",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'age'."
			)
		}
	}
	/// The string for the word 'measurements'.
	///
	/// - Tag: L10n-measurements
	static var measurements: String {
		L10n.resolve {
			String(
				localized: "Measurements",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'measurements'."
			)
		}
	}
	/// The string for the word 'characteristics'.
	///
	/// - Tag: L10n-characteristics
	static var characteristics: String {
		L10n.resolve {
			String(
				localized: "Characteristics",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'characteristics'."
			)
		}
	}
	/// The string for the word 'aliases'.
	///
	/// - Tag: L10n-aliases
	static var aliases: String {
		L10n.resolve {
			String(
				localized: "Aliases",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'aliases'."
			)
		}
	}
	/// The string for the word 'socials'.
	///
	/// - Tag: L10n-socials
	static var socials: String {
		L10n.resolve {
			String(
				localized: "Socials",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'socials'."
			)
		}
	}
	/// The string for the word 'websites'.
	///
	/// - Tag: L10n-websites
	static var websites: String {
		L10n.resolve {
			String(
				localized: "Websites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'websites'."
			)
		}
	}
	/// The string for the word 'new'.
	///
	/// - Tag: L10n-new
	static var new: String {
		L10n.resolve {
			String(
				localized: "New",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'new'."
			)
		}
	}
	/// The string for the word 'off'.
	///
	/// - Tag: L10n-off
	static var off: String {
		L10n.resolve {
			String(
				localized: "Off",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'off'."
			)
		}
	}
	/// The string for the word 'automatic'.
	///
	/// - Tag: L10n-automatic
	static var automatic: String {
		L10n.resolve {
			String(
				localized: "Automatic",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'automatic'."
			)
		}
	}
	/// The string for the word 'by type'.
	///
	/// - Tag: L10n-byType
	static var byType: String {
		L10n.resolve {
			String(
				localized: "By Type",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'by type'."
			)
		}
	}
	/// The string for the word 'other'.
	///
	/// - Tag: L10n-other
	static var other: String {
		L10n.resolve {
			String(
				localized: "Other",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Catch-all 'Other' option."
			)
		}
	}
	/// The string for the word 'follower'.
	///
	/// - Tag: L10n-follower
	static var follower: String {
		L10n.resolve {
			String(
				localized: "Follower",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'follower'."
			)
		}
	}
	/// The string for the word 'followers'.
	///
	/// - Tag: L10n-followers
	static var followers: String {
		L10n.resolve {
			String(
				localized: "Followers",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The plural string for the word 'followers'."
			)
		}
	}
	/// The string for the active follow state.
	///
	/// - Tag: L10n-followingState
	static var followingState: String {
		L10n.resolve {
			String(
				localized: "followingState",
				defaultValue: "Following",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. The follow button title when the user already follows this account."
			)
		}
	}
	/// The string for the following list.
	///
	/// - Tag: L10n-followingList
	static var followingList: String {
		L10n.resolve {
			String(
				localized: "followingList",
				defaultValue: "Following",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Noun. The accounts a user follows. Shown as a list title and a profile stat label."
			)
		}
	}
	/// The string for the word 'reputation'.
	///
	/// - Tag: L10n-reputation
	static var reputation: String {
		L10n.resolve {
			String(
				localized: "Reputation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Noun. A user's reputation score."
			)
		}
	}
	/// The string for the word 'follow'.
	///
	/// - Tag: L10n-follow
	static var follow: String {
		L10n.resolve {
			String(
				localized: "Follow",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'follow'."
			)
		}
	}
	/// The string for the word 'message'.
	///
	/// - Tag: L10n-message
	static var message: String {
		L10n.resolve {
			String(
				localized: "Message",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'message'."
			)
		}
	}
	/// The string for the word 'catalog'.
	///
	/// - Tag: L10n-catalog
	static var catalog: String {
		L10n.resolve {
			String(
				localized: "Catalog",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'catalog'."
			)
		}
	}
	/// The string for the word 'library'.
	///
	/// - Tag: L10n-library
	static var library: String {
		String(
			localized: "Library",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'library'."
		)
	}
	/// The string for the word 'Sorting'.
	///
	/// - Tag: L10n-sorting
	static var sorting: String {
		L10n.resolve {
			String(
				localized: "Sorting",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Sorting'."
			)
		}
	}
	/// The string for the word 'Library Type'.
	///
	/// - Tag: L10n-libraryType
	static var libraryType: String {
		L10n.resolve {
			String(
				localized: "Library Type",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Library Type'."
			)
		}
	}
	/// The string for the word 'your library'.
	///
	/// - Tag: L10n-yourLibrary
	static var yourLibrary: String {
		L10n.resolve {
			String(
				localized: "Your Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'your library'."
			)
		}
	}
	/// The string for the word 'add to library'.
	///
	/// - Tag: L10n-addToLibrary
	static var addToLibrary: String {
		L10n.resolve {
			String(
				localized: "Add to Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'add to library'."
			)
		}
	}
	/// The string for the word 'update library status'.
	///
	/// - Tag: L10n-updateLibraryStatus
	static var updateLibraryStatus: String {
		L10n.resolve {
			String(
				localized: "Update Library Status",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'update library status'."
			)
		}
	}
	/// The string for the word 'remove from library'.
	///
	/// - Tag: L10n-removeFromLibrary
	static var removeFromLibrary: String {
		L10n.resolve {
			String(
				localized: "Remove from Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'remove from library'."
			)
		}
	}
	/// The string for the sentence 'Can’t delete library 😔'.
	///
	/// - Tag: L10n-cantDeleteLibrary
	static var cantDeleteLibrary: String {
		L10n.resolve {
			String(
				localized: "Can’t delete library 😔",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the sentence 'Can’t delete library 😔'."
			)
		}
	}
	/// The string for the phrase 'Delete Permanently'.
	///
	/// - Tag: L10n-deletePermanently
	static var deletePermanently: String {
		L10n.resolve {
			String(
				localized: "Delete Permanently",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Delete Permanently'."
			)
		}
	}
	/// The string for the phrase 'hide from public'.
	///
	/// - Tag: L10n-hideFromPublic
	static var hideFromPublic: String {
		L10n.resolve {
			String(
				localized: "Hide from Public",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'hide from public'."
			)
		}
	}
	/// The string for the phrase 'show to public'.
	///
	/// - Tag: L10n-showToPublic
	static var showToPublic: String {
		L10n.resolve {
			String(
				localized: "Show to Public",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'show to public'."
			)
		}
	}
	/// The string for the word 'watched'.
	///
	/// - Tag: L10n-watched
	static var watched: String {
		L10n.resolve {
			String(
				localized: "Watched",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Library status for an item the user has watched."
			)
		}
	}
	/// The string for the phrase 'mark as watched'.
	///
	/// - Tag: L10n-markAsWatched
	static var markAsWatched: String {
		L10n.resolve {
			String(
				localized: "Mark as Watched",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'mark as watched'."
			)
		}
	}
	/// The string for the phrase 'mark as unwatched'.
	///
	/// - Tag: L10n-markAsUnwatched
	static var markAsUnwatched: String {
		L10n.resolve {
			String(
				localized: "Mark as Unwatched",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'mark as unwatched'."
			)
		}
	}
	/// The string for the phrase 'mark all watched'.
	///
	/// - Tag: L10n-markAllWatched
	static var markAllWatched: String {
		L10n.resolve {
			String(
				localized: "Mark All Watched",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'mark all watched'."
			)
		}
	}
	/// The string for the phrase 'mark all unwatched'.
	///
	/// - Tag: L10n-markAllUnwatched
	static var markAllUnwatched: String {
		L10n.resolve {
			String(
				localized: "Mark All Unwatched",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'mark all unwatched'."
			)
		}
	}
	/// The string for the phrase 'Mark all'.
	///
	/// - Tag: L10n-markAll
	static var markAll: String {
		L10n.resolve {
			String(
				localized: "Mark all",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Mark all'."
			)
		}
	}
	/// The string for the phrase 'Mark all as read'.
	///
	/// - Tag: L10n-markAllAsRead
	static var markAllAsRead: String {
		L10n.resolve {
			String(
				localized: "Mark all as read",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Mark all as read'."
			)
		}
	}
	/// The string for the phrase 'Mark all as unread'.
	///
	/// - Tag: L10n-markAllAsUnread
	static var markAllAsUnread: String {
		L10n.resolve {
			String(
				localized: "Mark all as unread",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Mark all as unread'."
			)
		}
	}
	/// The string for the phrase 'Mark as read'.
	///
	/// - Tag: L10n-markAsRead
	static var markAsRead: String {
		L10n.resolve {
			String(
				localized: "Mark as read",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Mark as read'."
			)
		}
	}
	/// The string for the phrase 'Mark as unread'.
	///
	/// - Tag: L10n-markAsUnread
	static var markAsUnread: String {
		L10n.resolve {
			String(
				localized: "Mark as unread",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Mark as unread'."
			)
		}
	}
	/// The string for the word 'next'.
	///
	/// - Tag: L10n-next
	static var next: String {
		L10n.resolve {
			String(
				localized: "Next",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'next'."
			)
		}
	}
	/// The string for the word 'previous'.
	///
	/// - Tag: L10n-previous
	static var previous: String {
		L10n.resolve {
			String(
				localized: "Previous",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'previous'."
			)
		}
	}
	/// The string for the word 'chart'.
	///
	/// - Tag: L10n-chart
	static var chart: String {
		L10n.resolve {
			String(
				localized: "Chart",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'chart'."
			)
		}
	}
	/// The string for the word 'anime'.
	///
	/// - Tag: L10n-anime
	static var anime: String {
		L10n.resolve {
			String(
				localized: "Anime",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'anime'."
			)
		}
	}
	/// The string for the word 'literatures'.
	///
	/// - Tag: L10n-literatures
	static var literatures: String {
		L10n.resolve {
			String(
				localized: "Literatures",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'literatures'."
			)
		}
	}
	/// The string for the word 'games'.
	///
	/// - Tag: L10n-games
	static var games: String {
		L10n.resolve {
			String(
				localized: "Games",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'games'."
			)
		}
	}
	/// The string for the word 'user'.
	///
	/// - Tag: L10n-user
	static var user: String {
		L10n.resolve {
			String(
				localized: "User",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'user'."
			)
		}
	}
	/// The string for the word 'users'.
	///
	/// - Tag: L10n-users
	static var users: String {
		L10n.resolve {
			String(
				localized: "Users",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'users'."
			)
		}
	}
	/// The string for the word 'account'.
	///
	/// - Tag: L10n-account
	static var account: String {
		L10n.resolve {
			String(
				localized: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'account'."
			)
		}
	}
	/// The string for the word 'debug'.
	///
	/// - Tag: L10n-debug
	static var debug: String {
		L10n.resolve {
			String(
				localized: "Debug",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'debug'."
			)
		}
	}
	/// The string for the word 'pro'.
	///
	/// - Tag: L10n-pro
	static var pro: String {
		L10n.resolve {
			String(
				localized: "Pro",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'pro'."
			)
		}
	}
	/// The string for the word 'alerts'.
	///
	/// - Tag: L10n-alerts
	static var alerts: String {
		L10n.resolve {
			String(
				localized: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'alerts'."
			)
		}
	}
	/// The string for the word 'general'.
	///
	/// - Tag: L10n-general
	static var general: String {
		L10n.resolve {
			String(
				localized: "General",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'general'."
			)
		}
	}
	/// The string for the word 'Guest'.
	///
	/// - Tag: L10n-guest
	static var guest: String {
		L10n.resolve {
			String(
				localized: "Guest",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Guest'."
			)
		}
	}
	/// The string for the word 'notifications'.
	///
	/// - Tag: L10n-notifications
	static var notifications: String {
		String(
			localized: "Notifications",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'notifications'."
		)
	}
	/// The string for the word 'profile'.
	///
	/// - Tag: L10n-profile
	static var profile: String {
		L10n.resolve {
			String(
				localized: "Profile",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'profile'."
			)
		}
	}
	/// The string for the word 'stickers'.
	///
	/// - Tag: L10n-stickers
	static var stickers: String {
		L10n.resolve {
			String(
				localized: "Stickers",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'stickers'."
			)
		}
	}
	/// The string for the word 'security'.
	///
	/// - Tag: L10n-security
	static var security: String {
		L10n.resolve {
			String(
				localized: "Security",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'security'."
			)
		}
	}
	/// The string for the word 'support us'.
	///
	/// - Tag: L10n-supportUs
	static var supportUs: String {
		L10n.resolve {
			String(
				localized: "Support Us",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'support us'."
			)
		}
	}
	/// The string for the word 'social'.
	///
	/// - Tag: L10n-social
	static var social: String {
		L10n.resolve {
			String(
				localized: "Social",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'social'."
			)
		}
	}
	/// The string for the word 'theme'.
	///
	/// - Tag: L10n-theme
	static var theme: String {
		L10n.resolve {
			String(
				localized: "Theme",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'theme'."
			)
		}
	}
	/// The string for the word 'icon'.
	///
	/// - Tag: L10n-icon
	static var icon: String {
		L10n.resolve {
			String(
				localized: "Icon",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'icon'."
			)
		}
	}
	/// The string for the word 'motion'.
	///
	/// - Tag: L10n-motion
	static var motion: String {
		L10n.resolve {
			String(
				localized: "Motion",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'motion'."
			)
		}
	}
	/// The string for the word 'browser'.
	///
	/// - Tag: L10n-browser
	static var browser: String {
		L10n.resolve {
			String(
				localized: "Browser",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'browser'."
			)
		}
	}
	/// The string for the word 'passcode'.
	///
	/// - Tag: L10n-passcode
	static var passcode: String {
		L10n.resolve {
			String(
				localized: "Passcode",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'passcode'."
			)
		}
	}
	/// The string for the word 'cache'.
	///
	/// - Tag: L10n-cache
	static var cache: String {
		L10n.resolve {
			String(
				localized: "Cache",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'cache'."
			)
		}
	}
	/// The string for the word 'images'.
	///
	/// - Tag: L10n-images
	static var images: String {
		L10n.resolve {
			String(
				localized: "Images",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'images'."
			)
		}
	}
	/// The string for the phrase 'rich links'.
	///
	/// - Tag: L10n-richLinks
	static var richLinks: String {
		L10n.resolve {
			String(
				localized: "Rich Links",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'rich links'."
			)
		}
	}
	/// The string for the word 'privacy'.
	///
	/// - Tag: L10n-privacy
	static var privacy: String {
		L10n.resolve {
			String(
				localized: "Privacy",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'privacy'."
			)
		}
	}
	/// The string for the word 'founded'.
	///
	/// - Tag: L10n-founded
	static var founded: String {
		L10n.resolve {
			String(
				localized: "Founded",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'founded'."
			)
		}
	}
	/// The string for the word 'defunct'.
	///
	/// - Tag: L10n-defunct
	static var defunct: String {
		L10n.resolve {
			String(
				localized: "Defunct",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'defunct'."
			)
		}
	}
	/// The string for the word 'headquarters'.
	///
	/// - Tag: L10n-headquarters
	static var headquarters: String {
		L10n.resolve {
			String(
				localized: "Headquarters",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'headquarters'."
			)
		}
	}
	/// The string for the word 'synopsis'.
	///
	/// - Tag: L10n-synopsis
	static var synopsis: String {
		L10n.resolve {
			String(
				localized: "Synopsis",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'synopsis'."
			)
		}
	}
	/// The string for the word 'explore'.
	///
	/// - Tag: L10n-explore
	static var explore: String {
		String(
			localized: "Explore",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'explore'."
		)
	}
	/// The string for the word 'schedule'.
	///
	/// - Tag: L10n-schedule
	static var schedule: String {
		String(
			localized: "Schedule",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'schedule'."
		)
	}
	/// The string for the word 'museum'.
	///
	/// - Tag: L10n-museum
	static var museum: String {
		String(
			localized: "Museum",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'museum'."
		)
	}
	/// The string for the phrase 'Adapted to Anime'.
	///
	/// - Tag: L10n-adaptedToAnime
	static var adaptedToAnime: String {
		String(
			localized: "Adapted to Anime",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the phrase 'Adapted to Anime'."
		)
	}
	/// The string for the phrase 'Airing Now'.
	///
	/// - Tag: L10n-airingNow
	static var airingNow: String {
		String(
			localized: "Airing Now",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the phrase 'Airing Now'."
		)
	}
	/// The string for the phrase 'Upcoming Anime'.
	///
	/// - Tag: L10n-upcomingAnime
	static var upcomingAnime: String {
		String(
			localized: "Upcoming Anime",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the phrase 'Upcoming Anime'."
		)
	}
	/// The string for the word 'feed'.
	///
	/// - Tag: L10n-feed
	static var feed: String {
		String(
			localized: "Feed",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'feed'."
		)
	}
	/// The string for the word 'reviews'.
	///
	/// - Tag: L10n-reviews
	static var reviews: String {
		L10n.resolve {
			String(
				localized: "Reviews",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'reviews'."
			)
		}
	}
	/// The string for the word 'posts'.
	///
	/// - Tag: L10n-posts
	static var posts: String {
		L10n.resolve {
			String(
				localized: "Posts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'posts'."
			)
		}
	}
	/// The string for the word 'replies'.
	///
	/// - Tag: L10n-replies
	static var replies: String {
		L10n.resolve {
			String(
				localized: "Replies",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'replies'."
			)
		}
	}
	/// The string for the word 'unknown'.
	///
	/// - Tag: L10n-unknown
	static var unknown: String {
		L10n.resolve {
			String(
				localized: "Unknown",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'unknown'."
			)
		}
	}
	/// The string for the word 'name'.
	///
	/// - Tag: L10n-name
	static var name: String {
		L10n.resolve {
			String(
				localized: "Name",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'name'."
			)
		}
	}
	/// The string for the word 'dismiss'.
	///
	/// - Tag: L10n-dismiss
	static var dismiss: String {
		L10n.resolve {
			String(
				localized: "Dismiss",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'dismiss'."
			)
		}
	}
	/// The string for the word 'search'.
	///
	/// - Tag: L10n-search
	static var search: String {
		String(
			localized: "Search",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'search'."
		)
	}
	/// The string for the phrase 'Search Library'.
	///
	/// - Tag: L10n-searchLibrary
	static var searchLibrary: String {
		L10n.resolve {
			String(
				localized: "Search Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title and placeholder for the library search screen."
			)
		}
	}
	/// The string for the word 'suggestions'.
	///
	/// - Tag: L10n-suggestions
	static var suggestions: String {
		L10n.resolve {
			String(
				localized: "Suggestions",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'suggestions'."
			)
		}
	}
	/// The string for the word 'sort'.
	///
	/// - Tag: L10n-sort
	static var sort: String {
		L10n.resolve {
			String(
				localized: "Sort",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'sort'."
			)
		}
	}
	/// The string for the word 'filter'.
	///
	/// - Tag: L10n-filter
	static var filter: String {
		L10n.resolve {
			String(
				localized: "Filter",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'filter'."
			)
		}
	}
	/// The string for the word 'filters'.
	///
	/// - Tag: L10n-filters
	static var filters: String {
		L10n.resolve {
			String(
				localized: "Filters",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'filters'."
			)
		}
	}
	/// The string for the word 'settings'.
	///
	/// - Tag: L10n-settings
	static var settings: String {
		String(
			localized: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'settings'."
		)
	}
	/// The string for the word 'subscribe'.
	///
	/// - Tag: L10n-subscribe
	static var subscribe: String {
		L10n.resolve {
			String(
				localized: "Subscribe",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'subscribe'."
			)
		}
	}
	/// The string for the word 'send'.
	///
	/// - Tag: L10n-send
	static var send: String {
		L10n.resolve {
			String(
				localized: "Send",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'send'."
			)
		}
	}
	/// The string for the phrase 'save draft'.
	///
	/// - Tag: L10n-saveDraft
	static var saveDraft: String {
		L10n.resolve {
			String(
				localized: "Save Draft",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'save draft'."
			)
		}
	}
	/// The string for the word 'drafts'.
	///
	/// - Tag: L10n-drafts
	static var drafts: String {
		L10n.resolve {
			String(
				localized: "Drafts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'drafts'."
			)
		}
	}
	/// The string for the 'no drafts' empty state title.
	///
	/// - Tag: L10n-noDraftsTitle
	static var noDraftsTitle: String {
		L10n.resolve {
			String(
				localized: "No Drafts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'no drafts' empty state title."
			)
		}
	}
	/// The string for the 'no drafts' empty state detail.
	///
	/// - Tag: L10n-noDraftsDetail
	static var noDraftsDetail: String {
		L10n.resolve {
			String(
				localized: "Your saved drafts will appear here.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'no drafts' empty state detail."
			)
		}
	}
	/// The string for the 'empty draft' placeholder.
	///
	/// - Tag: L10n-emptyDraft
	static var emptyDraft: String {
		L10n.resolve {
			String(
				localized: "Empty draft",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'empty draft' placeholder."
			)
		}
	}
	/// The string for the word 'discard'.
	///
	/// - Tag: L10n-discard
	static var discard: String {
		L10n.resolve {
			String(
				localized: "Discard",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'discard'."
			)
		}
	}
	/// The string for the word 'done'.
	///
	/// - Tag: L10n-done
	static var done: String {
		L10n.resolve {
			String(
				localized: "Done",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'done'."
			)
		}
	}
	/// The string for the word 'cancel'.
	///
	/// - Tag: L10n-cancel
	static var cancel: String {
		L10n.resolve {
			String(
				localized: "Cancel",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'cancel'."
			)
		}
	}
	/// The string for the word 'remove'.
	///
	/// - Tag: L10n-remove
	static var remove: String {
		L10n.resolve {
			String(
				localized: "Remove",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'remove'."
			)
		}
	}
	/// The string for the word 'skip'.
	static var skip: String {
		L10n.resolve {
			String(
				localized: "Skip",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. The action advancing to the next song."
			)
		}
	}

	/// The string for the word 'share'.
	///
	/// - Tag: L10n-share
	static var share: String {
		L10n.resolve {
			String(
				localized: "Share",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. The share action."
			)
		}
	}
	/// The string for the word 'copy'.
	///
	/// - Tag: L10n-copy
	static var copy: String {
		L10n.resolve {
			String(
				localized: "Copy",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'copy'."
			)
		}
	}
	/// The string for the word 'Copy Review'.
	///
	/// - Tag: L10n-copyReview
	static var copyReview: String {
		L10n.resolve {
			String(
				localized: "Copy Review",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Copy Review'."
			)
		}
	}
	/// The string for the word 'Copy Title'.
	///
	/// - Tag: L10n-copyTitle
	static var copyTitle: String {
		L10n.resolve {
			String(
				localized: "Copy Title",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Copy Title'."
			)
		}
	}
	/// The string for the word 'Copy Link'.
	///
	/// - Tag: L10n-copyLink
	static var copyLink: String {
		L10n.resolve {
			String(
				localized: "Copy Link",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Copy Link'."
			)
		}
	}
	/// The string for the word 'update'.
	///
	/// - Tag: L10n-update
	static var update: String {
		L10n.resolve {
			String(
				localized: "Update!",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'update'."
			)
		}
	}
	/// The string for the word 'reconnect'.
	///
	/// - Tag: L10n-reconnect
	static var reconnect: String {
		L10n.resolve {
			String(
				localized: "Reconnect!",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'reconnect'."
			)
		}
	}
	/// The string for the word 'Lyrics'.
	///
	/// - Tag: L10n-lyrics
	static var lyrics: String {
		L10n.resolve {
			String(
				localized: "Lyrics",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Lyrics'."
			)
		}
	}
	/// The title shown when a song has no synced lyrics.
	///
	/// - Tag: L10n-lyricsUnavailableTitle
	static var lyricsUnavailableTitle: String {
		L10n.resolve {
			String(
				localized: "No Lyrics",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when a song has no synced lyrics."
			)
		}
	}
	/// The detail shown when a song has no synced lyrics.
	///
	/// - Tag: L10n-lyricsUnavailableDetail
	static var lyricsUnavailableDetail: String {
		L10n.resolve {
			String(
				localized: "Lyrics aren't available for this song yet.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The detail shown when a song has no synced lyrics."
			)
		}
	}
	/// The string for the phrase 'Play a song to see lyrics here.'.
	///
	/// - Tag: L10n-playASongToSeeLyrics
	static var playASongToSeeLyrics: String {
		L10n.resolve {
			String(
				localized: "Play a song to see lyrics here.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The stand-in shown in the player's lyrics pane while nothing is playing."
			)
		}
	}
	/// The string for the phrase 'Hide Lyrics'.
	///
	/// - Tag: L10n-hideLyrics
	static var hideLyrics: String {
		L10n.resolve {
			String(
				localized: "Hide Lyrics",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the player menu action that dismisses the lyrics pane."
			)
		}
	}
	/// The string for the phrase 'Show Large Artwork'.
	///
	/// - Tag: L10n-showLargeArtwork
	static var showLargeArtwork: String {
		L10n.resolve {
			String(
				localized: "Show Large Artwork",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the player menu action that grows the window into the artwork card."
			)
		}
	}
	/// The string for the phrase 'Hide Large Artwork'.
	///
	/// - Tag: L10n-hideLargeArtwork
	static var hideLargeArtwork: String {
		L10n.resolve {
			String(
				localized: "Hide Large Artwork",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the player menu action that shrinks the window to the compact bar."
			)
		}
	}
	/// The string for the phrase 'Show Pronunciation'.
	///
	/// - Tag: L10n-showPronunciation
	static var showPronunciation: String {
		L10n.resolve {
			String(
				localized: "Show Pronunciation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the lyrics menu action that reveals the romanized pronunciation of each word."
			)
		}
	}
	/// The string for the phrase 'Hide Pronunciation'.
	///
	/// - Tag: L10n-hidePronunciation
	static var hidePronunciation: String {
		L10n.resolve {
			String(
				localized: "Hide Pronunciation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the lyrics menu action that hides the romanized pronunciation of each word."
			)
		}
	}
	/// The string for the phrase 'Show Original'.
	///
	/// - Tag: L10n-showOriginal
	static var showOriginal: String {
		L10n.resolve {
			String(
				localized: "Show Original",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the lyrics menu action that reveals the original lyrics alongside the pronunciation."
			)
		}
	}
	/// The string for the phrase 'Hide Original'.
	///
	/// - Tag: L10n-hideOriginal
	static var hideOriginal: String {
		L10n.resolve {
			String(
				localized: "Hide Original",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the lyrics menu action that hides the original lyrics, leaving only the pronunciation."
			)
		}
	}
	/// The string for the word 'Translation'.
	///
	/// - Tag: L10n-translation
	static var translation: String {
		L10n.resolve {
			String(
				localized: "Translation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the lyrics menu for choosing the translation language shown beneath each line."
			)
		}
	}
	/// The string for the phrase 'As Heard On'.
	///
	/// - Tag: L10n-asHeardOn
	static var asHeardOn: String {
		L10n.resolve {
			String(
				localized: "As Heard On",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'As Heard On'."
			)
		}
	}
	/// The string for the phrase 'View on Amazon Music'.
	///
	/// - Tag: L10n-viewOnAmazonMusic
	static var viewOnAmazonMusic: String {
		L10n.resolve {
			String(
				localized: "View on Amazon Music",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View on Amazon Music'."
			)
		}
	}
	/// The string for the phrase 'View on Apple Music'.
	///
	/// - Tag: L10n-viewOnAppleMusic
	static var viewOnAppleMusic: String {
		L10n.resolve {
			String(
				localized: "View on Apple Music",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View on Apple Music'."
			)
		}
	}
	/// The string for the phrase 'View on Deezer'.
	///
	/// - Tag: L10n-viewOnDeezer
	static var viewOnDeezer: String {
		L10n.resolve {
			String(
				localized: "View on Deezer",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View on Deezer'."
			)
		}
	}
	/// The string for the phrase 'View on Spotify'.
	///
	/// - Tag: L10n-viewOnSpotify
	static var viewOnSpotify: String {
		L10n.resolve {
			String(
				localized: "View on Spotify",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View on Spotify'."
			)
		}
	}
	/// The string for the phrase 'View on YouTube'.
	///
	/// - Tag: L10n-viewOnYouTube
	static var viewOnYouTube: String {
		L10n.resolve {
			String(
				localized: "View on YouTube",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View on YouTube'."
			)
		}
	}
	/// The string for the 'View on' context menu that groups external music services.
	///
	/// - Tag: L10n-viewOn
	static var viewOn: String {
		L10n.resolve {
			String(
				localized: "View on",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'View on' submenu grouping external music services."
			)
		}
	}
	/// The string for the 'Go to Song' context menu option.
	///
	/// - Tag: L10n-goToSong
	static var goToSong: String {
		L10n.resolve {
			String(
				localized: "Go to Song",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Go to Song' context menu option."
			)
		}
	}
	/// The string for the word 'preview'.
	///
	/// - Tag: L10n-preview
	static var preview: String {
		L10n.resolve {
			String(
				localized: "Preview",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'preview'."
			)
		}
	}
	/// The string for the word 'Play'.
	///
	/// - Tag: L10n-play
	static var play: String {
		L10n.resolve {
			String(
				localized: "Play",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. Media playback control. Paired with Pause."
			)
		}
	}
	/// The string for the phrase 'Play Trailer'.
	///
	/// - Tag: L10n-playTrailer
	static var playTrailer: String {
		L10n.resolve {
			String(
				localized: "Play Trailer",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Play Trailer'."
			)
		}
	}
	/// The string for the word 'pause'.
	///
	/// - Tag: L10n-pause
	static var pause: String {
		L10n.resolve {
			String(
				localized: "Pause",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Pause'."
			)
		}
	}
	/// The string for the word 'stop'.
	///
	/// - Tag: L10n-stop
	static var stop: String {
		L10n.resolve {
			String(
				localized: "Stop",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'stop'."
			)
		}
	}

	// MARK: - Low Data Mode
	/// The settings entry grouping options that reduce data usage.
	///
	/// - Tag: L10n-lowDataMode
	static var lowDataMode: String {
		L10n.resolve {
			String(
				localized: "Low Data Mode",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The settings entry grouping options that reduce data usage."
			)
		}
	}
	/// The description shown in the Low Data Mode settings header.
	///
	/// - Tag: L10n-lowDataModeHeaderDescription
	static var lowDataModeHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Reduce the data used by trailers and other media.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown in the Low Data Mode settings header."
			)
		}
	}

	// MARK: - Video Autoplay
	/// The settings entry that controls when trailers play automatically.
	///
	/// - Tag: L10n-autoplay
	static var autoplay: String {
		L10n.resolve {
			String(
				localized: "Autoplay",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The settings entry that controls when trailers play automatically."
			)
		}
	}
	/// The autoplay option that plays trailers automatically on any connection.
	///
	/// - Tag: L10n-autoplayAlways
	static var autoplayAlways: String {
		L10n.resolve {
			String(
				localized: "Always",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The autoplay option that plays trailers automatically on any connection."
			)
		}
	}
	/// The autoplay option that plays trailers automatically only on Wi-Fi.
	///
	/// - Tag: L10n-autoplayWiFiOnly
	static var autoplayWiFiOnly: String {
		L10n.resolve {
			String(
				localized: "Wi-Fi Only",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The autoplay option that plays trailers automatically only on Wi-Fi."
			)
		}
	}
	/// The autoplay option that never plays trailers automatically.
	///
	/// - Tag: L10n-autoplayNever
	static var autoplayNever: String {
		L10n.resolve {
			String(
				localized: "Never",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The autoplay option that never plays trailers automatically."
			)
		}
	}
	/// The footer explaining the trailer autoplay options.
	///
	/// - Tag: L10n-autoplayFooter
	static var autoplayFooter: String {
		L10n.resolve {
			String(
				localized: "Choose when trailers play automatically. Playing on cellular uses more data.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer explaining the trailer autoplay options."
			)
		}
	}
	/// The string for the word 'password'.
	///
	/// - Tag: L10n-password
	static var password: String {
		L10n.resolve {
			String(
				localized: "Password",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'password'."
			)
		}
	}
	/// The email address field placeholder.
	static var emailAddress: String {
		L10n.resolve {
			String(
				localized: "Email Address",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The email address field placeholder."
			)
		}
	}
	/// The username field placeholder.
	static var username: String {
		L10n.resolve {
			String(
				localized: "Username",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The username field placeholder."
			)
		}
	}
	/// A one-based position within a total count.
	static func indexOfTotal(_ current: Int, _ total: Int) -> String {
		L10n.resolve {
			String(
				localized: "\(current) of \(total)",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A one-based position within a total count, where the placeholders are the current index and the total."
			)
		}
	}
	/// The string for the word 'download'.
	///
	/// - Tag: L10n-download
	static var download: String {
		L10n.resolve {
			String(
				localized: "Download",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'download'."
			)
		}
	}
	/// The string for the phrase 'coming soon'.
	///
	/// - Tag: L10n-comingSoon
	static var comingSoon: String {
		L10n.resolve {
			String(
				localized: "Coming Soon",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'coming soon'."
			)
		}
	}
	/// The string for the word 'expected'.
	///
	/// - Tag: L10n-expected
	static var expected: String {
		L10n.resolve {
			String(
				localized: "Expected",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'expected'."
			)
		}
	}
	/// The string for the word 'achievements'.
	///
	/// - Tag: L10n-achievements
	static var achievements: String {
		L10n.resolve {
			String(
				localized: "Achievements",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'achievements'."
			)
		}
	}
	/// The string for the word 'badges'.
	///
	/// - Tag: L10n-badges
	static var badges: String {
		L10n.resolve {
			String(
				localized: "Badges",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'badges'."
			)
		}
	}
	/// The string for the word 'rank'.
	///
	/// - Tag: L10n-rank
	static var rank: String {
		L10n.resolve {
			String(
				localized: "Rank",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'rank'."
			)
		}
	}
	/// The string for the word 'languages'.
	///
	/// - Tag: L10n-language
	static var language: String {
		L10n.resolve {
			String(
				localized: "Languages",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'language'."
			)
		}
	}
	/// The explanatory description shown above the language picker clarifying that it changes content language, not the app's interface language.
	///
	/// - Tag: L10n-languagePickerDescription
	static var languagePickerDescription: String {
		L10n.resolve {
			String(
				localized: "languagePicker.description",
				defaultValue: "Your preferred language is used for the information shown throughout Kurozora, such as titles, descriptions, and metadata. It does not change the language of the app's interface.\n\nThese changes take effect anywhere you are signed in with your Kurozora Account.\n\nIf information cannot be shown in your preferred language, English will be used instead.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Explanatory text shown above the language picker to clarify that the setting changes content language, not the app's interface language."
			)
		}
	}
	/// The explanatory description shown above the TV rating picker clarifying that TV ratings are tiered.
	///
	/// - Tag: L10n-tvRatingPickerDescription
	static var tvRatingPickerDescription: String {
		L10n.resolve {
			String(
				localized: "tvRatingPicker.description",
				defaultValue: "TV ratings are tiered. Depending on the chosen TV rating some shows might be hidden.\n\nFor example, selecting R15+ will show you all anime up to a TV rating of R15+.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Explanatory text shown above the TV rating picker to clarify how tiered TV ratings affect visible content."
			)
		}
	}
	/// The explanatory description shown above the timezone picker clarifying what the timezone setting affects.
	///
	/// - Tag: L10n-timezonePickerDescription
	static var timezonePickerDescription: String {
		L10n.resolve {
			String(
				localized: "timezonePicker.description",
				defaultValue: "The selected timezone will be used to display all dates and times, including premiere dates, broadcasts, and schedules.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Explanatory text shown above the timezone picker to clarify what the setting affects."
			)
		}
	}
	/// The string for the word 'country'.
	///
	/// - Tag: L10n-country
	static var country: String {
		L10n.resolve {
			String(
				localized: "Country",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'country'."
			)
		}
	}
	/// The string for the phrase 'TV Rating'.
	///
	/// - Tag: L10n-tvRating
	static var tvRating: String {
		L10n.resolve {
			String(
				localized: "TV Rating",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'TV rating'."
			)
		}
	}
	/// The string for the phrase 'Time Zone'.
	///
	/// - Tag: L10n-timeZone
	static var timeZone: String {
		L10n.resolve {
			String(
				localized: "Time Zone",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Time Zone'."
			)
		}
	}
	/// The string for the word 'seasons'.
	///
	/// - Tag: L10n-seasons
	static var seasons: String {
		L10n.resolve {
			String(
				localized: "Seasons",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'seasons'."
			)
		}
	}
	/// The string for the word 'winter'.
	///
	/// - Tag: L10n-winter
	static var winter: String {
		L10n.resolve {
			String(
				localized: "Winter",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'winter'."
			)
		}
	}
	/// The string for the word 'spring'.
	///
	/// - Tag: L10n-spring
	static var spring: String {
		L10n.resolve {
			String(
				localized: "Spring",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'spring'."
			)
		}
	}
	/// The string for the word 'summer'.
	///
	/// - Tag: L10n-summer
	static var summer: String {
		L10n.resolve {
			String(
				localized: "Summer",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'summer'."
			)
		}
	}
	/// The string for the word 'fall'.
	///
	/// - Tag: L10n-fall
	static var fall: String {
		L10n.resolve {
			String(
				localized: "Fall",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'fall'."
			)
		}
	}
	/// The string for the accessibility label of the season picker.
	///
	/// - Tag: L10n-seasonPicker
	static var seasonPicker: String {
		L10n.resolve {
			String(
				localized: "Season picker",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label for the seasonal browse picker."
			)
		}
	}
	/// The string for the phrase 'Current Season'.
	///
	/// - Tag: L10n-currentSeason
	static var currentSeason: String {
		L10n.resolve {
			String(
				localized: "Current Season",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Current Season'."
			)
		}
	}
	/// The string for the word 'season'.
	///
	/// - Tag: L10n-season
	static var season: String {
		L10n.resolve {
			String(
				localized: "Season",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Noun. A show's season or installment, not the airing quarter."
			)
		}
	}
	/// The string for the word 'studios'.
	///
	/// - Tag: L10n-studios
	static var studios: String {
		L10n.resolve {
			String(
				localized: "Studios",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'studios'."
			)
		}
	}
	/// The string for the word 'studio'.
	///
	/// - Tag: L10n-studio
	static var studio: String {
		L10n.resolve {
			String(
				localized: "Studio",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'studio'."
			)
		}
	}
	/// The string for the phrase 'Founded on [date]'.
	///
	/// - Tag: L10n-foundedOn
	static func foundedOn(date: String) -> String {
		String(
			localized: "Founded on \(date)",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'Founded on [date]'."
		)
	}

	/// The string for the word 'cast'.
	///
	/// - Tag: L10n-cast
	static var cast: String {
		L10n.resolve {
			String(
				localized: "Cast",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'cast'."
			)
		}
	}
	/// The string for the word 'songs'.
	///
	/// - Tag: L10n-songs
	static var songs: String {
		L10n.resolve {
			String(
				localized: "Songs",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'songs'."
			)
		}
	}
	/// The string for the phrase 'More by'.
	///
	/// - Tag: L10n-moreBy
	static var moreBy: String {
		L10n.resolve {
			String(
				localized: "More by",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'more by'."
			)
		}
	}
	/// The string for the phrase 'Related Shows'.
	///
	/// - Tag: L10n-relatedShows
	static var relatedShows: String {
		L10n.resolve {
			String(
				localized: "Related Shows",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'related shows'."
			)
		}
	}
	/// The string for the phrase 'Related Literatures'.
	///
	/// - Tag: L10n-relatedLiteratures
	static var relatedLiteratures: String {
		L10n.resolve {
			String(
				localized: "Related Literatures",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'related literatures'."
			)
		}
	}
	/// The string for the phrase 'Related Games'.
	///
	/// - Tag: L10n-relatedGames
	static var relatedGames: String {
		L10n.resolve {
			String(
				localized: "Related Games",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'related games'."
			)
		}
	}
	/// The string for the word 'copyright'.
	///
	/// - Tag: L10n-copyright
	static var copyright: String {
		L10n.resolve {
			String(
				localized: "Copyright",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'copyright'."
			)
		}
	}
	/// The string for the phrase 'Open Twitter'.
	///
	/// - Tag: L10n-openTwitter
	static var openTwitter: String {
		L10n.resolve {
			String(
				localized: "Open Twitter",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Open Twitter'."
			)
		}
	}
	/// The string for the word 'Redeem'.
	///
	/// - Tag: L10n-redeem
	static var redeem: String {
		L10n.resolve {
			String(
				localized: "Redeem",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Redeem'."
			)
		}
	}
	/// The string for the phrase 'View Subscription'.
	///
	/// - Tag: L10n-viewSubscription
	static var viewSubscription: String {
		L10n.resolve {
			String(
				localized: "View Subscription",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'View Subscription'."
			)
		}
	}
	/// The string for the phrase 'Become a Subscriber'.
	///
	/// - Tag: L10n-becomeASubscriber
	static var becomeASubscriber: String {
		L10n.resolve {
			String(
				localized: "Become a Subscriber",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Become a Subscriber'."
			)
		}
	}
	/// The string for the word 'Continue'.
	///
	/// - Tag: L10n-continue
	static var `continue`: String {
		L10n.resolve {
			String(
				localized: "Continue",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Continue'."
			)
		}
	}
	/// The string for the phrase 'What’s New'.
	///
	/// - Tag: L10n-whatsNew
	static var whatsNew: String {
		L10n.resolve {
			String(
				localized: "What’s New in Kurozora",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'What’s New'."
			)
		}
	}
	/// The string for the word 'Favorites'.
	///
	/// - Tag: L10n-favorites
	static var favorites: String {
		L10n.resolve {
			String(
				localized: "Favorites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Favorites'"
			)
		}
	}
	/// The string for the phrase 'My Favorites'.
	///
	/// - Tag: L10n-myFavorites
	static var myFavorites: String {
		L10n.resolve {
			String(
				localized: "My Favorites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'My Favorites'"
			)
		}
	}
	/// The string for the word 'Reminders'.
	///
	/// - Tag: L10n-reminders
	static var reminders: String {
		L10n.resolve {
			String(
				localized: "Reminders",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Reminders'"
			)
		}
	}
	/// The string for the phrase 'Remind Me'.
	///
	/// - Tag: L10n-remindMe
	static var remindMe: String {
		L10n.resolve {
			String(
				localized: "Remind Me",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Remind Me'"
			)
		}
	}
	/// The string for the phrase 'My Reminders'.
	///
	/// - Tag: L10n-myReminders
	static var myReminders: String {
		L10n.resolve {
			String(
				localized: "My Reminders",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'My Reminders'"
			)
		}
	}

	// MARK: - ReCap
	/// The string for the word 'Re:Cap'.
	///
	/// - Tag: L10n-reCAP
	static var reCAP: String {
		L10n.resolve {
			String(
				localized: "Re:CAP",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Re:CAP'."
			)
		}
	}
	/// The string for the word 'Milestones'.
	///
	/// - Tag: L10n-milestones
	static var milestones: String {
		L10n.resolve {
			String(
				localized: "Milestones",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Milestones'."
			)
		}
	}
	/// The string for the phrase 'Top %@'.
	///
	/// - Tag: L10n-topX
	static func top(_ string: String) -> String {
		return String(
			localized: "Top \(string)",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the word 'Top %@'."
		)
	}

	/// The string for the word 'trailers'.
	///
	/// - Tag: L10n-trailers
	static var trailers: String {
		L10n.resolve {
			String(
				localized: "Trailers",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'trailers'."
			)
		}
	}

	/// The string for the phrase 'Top Charts'.
	///
	/// - Tag: L10n-topCharts
	static var topCharts: String {
		L10n.resolve {
			String(
				localized: "Top Charts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Top Charts'."
			)
		}
	}
	/// The string for the phrase '%@ Top Charts'.
	///
	/// - Parameter kind: The localized noun naming the charted resource.
	///
	/// - Tag: L10n-xTopCharts
	static func xTopCharts(_ kind: String) -> String {
		return String(
			localized: "\(kind) Top Charts",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The title of a single top chart, naming the charted resource."
		)
	}

	/// The string for the phrase '%@ total series'.
	///
	/// - Tag: L10n-totalSeries
	static func totalSeries(_ count: Int) -> String {
		return String(
			localized: "\(count) total series",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The total series count shown on the ReCap year card."
		)
	}

	/// The string for the phrase '%@ · %@ titles'.
	///
	/// - Tag: L10n-yearTitlesCount
	static func yearTitlesCount(_ year: Int, _ count: Int) -> String {
		return String(
			localized: "\(String(year)) · \(count) titles",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The year and titles count shown in the Museum timeline chip."
		)
	}

	/// The string for the phrase '%@ works · %@–%@'.
	///
	/// - Tag: L10n-worksCountRange
	static func worksCountRange(_ count: String, _ startYear: Int, _ endYear: Int) -> String {
		return String(
			localized: "\(count) works · \(String(startYear))–\(String(endYear))",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The collection scale shown beneath the Museum title while idle."
		)
	}

	/// The string for the phrase '%@ works · %@'.
	///
	/// - Tag: L10n-worksCountYear
	static func worksCountYear(_ count: String, _ year: Int) -> String {
		return String(
			localized: "\(count) works · \(String(year))",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The active year's scale shown beneath the Museum title while scrolling."
		)
	}

	/// The string for the phrase 'Dim Library'.
	///
	/// - Tag: L10n-dimLibrary
	static var dimLibrary: String {
		L10n.resolve {
			String(
				localized: "Dim Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label of the Museum button that dims entries already in the user's library."
			)
		}
	}

	// MARK: - Library Batch Edit
	/// The string for the word 'Hide'.
	static var hide: String {
		L10n.resolve {
			String(
				localized: "Hide",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. Hides a library title. Paired with Reveal."
			)
		}
	}
	/// The string for the reveal action.
	///
	/// - Tag: L10n-reveal
	static var reveal: String {
		L10n.resolve {
			String(
				localized: "reveal",
				defaultValue: "Show",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Verb. Reveals a hidden library title. The opposite of Hide."
			)
		}
	}
	/// The string for the word 'Mute'.
	static var mute: String {
		L10n.resolve {
			String(
				localized: "Mute",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Mute'."
			)
		}
	}
	/// The string for the word 'Unmute'.
	static var unmute: String {
		L10n.resolve {
			String(
				localized: "Unmute",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Unmute'."
			)
		}
	}
	/// The string for the word 'Unfavorite'.
	static var unfavorite: String {
		L10n.resolve {
			String(
				localized: "Unfavorite",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'Unfavorite'."
			)
		}
	}
	/// The string for the phrase 'Stop Reminding'.
	static var stopReminding: String {
		L10n.resolve {
			String(
				localized: "Stop Reminding",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Stop Reminding'."
			)
		}
	}
	/// The string for the phrase 'Could Not Update Reminders'.
	static var couldNotUpdateReminders: String {
		L10n.resolve {
			String(
				localized: "Could Not Update Reminders",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error alert title when a reminders batch update fails."
			)
		}
	}
	/// The string for the phrase 'Move to'.
	static var moveTo: String {
		L10n.resolve {
			String(
				localized: "Move to",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the menu title that lets the user pick a target library status."
			)
		}
	}
	/// The string for the phrase 'Select All'.
	static var selectAll: String {
		L10n.resolve {
			String(
				localized: "Select All",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The leading nav-bar action that selects every loaded library item in batch-edit mode."
			)
		}
	}
	/// The string for the phrase 'Deselect All'.
	static var deselectAll: String {
		L10n.resolve {
			String(
				localized: "Deselect All",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The leading nav-bar action that deselects every selected library item in batch-edit mode."
			)
		}
	}
	/// The string for the phrase 'Select Items'.
	static var selectItems: String {
		L10n.resolve {
			String(
				localized: "Select Items",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label shown in the bottom batch-edit toolbar when no items are selected."
			)
		}
	}
	/// The string for the phrase 'Could Not Update Library'.
	static var couldNotUpdateLibrary: String {
		L10n.resolve {
			String(
				localized: "Could Not Update Library",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error alert title when a library batch update fails."
			)
		}
	}
	/// The string for the phrase 'Could Not Update Favorites'.
	static var couldNotUpdateFavorites: String {
		L10n.resolve {
			String(
				localized: "Could Not Update Favorites",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error alert title when a favorites batch update fails."
			)
		}
	}
	/// The confirmation alert message shown when removing items from the library.
	///
	/// - Parameter count: The number of items being removed.
	///
	/// - Tag: L10n-deleteItemsConfirmation
	static func deleteItemsConfirmation(_ count: Int) -> String {
		return String(
			localized: "library.deleteItemsConfirmation",
			defaultValue: "\(count) items will be deleted from your library.",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The confirmation alert message shown when removing items from the library."
		)
	}
	/// The string for the phrase '%d Selected'.
	static func itemsSelected(_ count: Int) -> String {
		return String(
			localized: "\(count) Selected",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label showing how many items are selected in batch-edit mode."
		)
	}
	/// The destructive button shown in the delete confirmation alert when multiple items are selected.
	static func deleteItems(_ count: Int) -> String {
		return String(
			localized: "Delete \(count) Items",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The destructive button shown in the delete confirmation alert when multiple items are selected."
		)
	}

	/// The string for the word 'Select'.
	static var select: String {
		L10n.resolve {
			String(
				localized: "Select",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The leading nav-bar action that enters batch-edit mode in lists such as notifications."
			)
		}
	}
	/// The string for the phrase 'Select Notifications'.
	static var selectNotifications: String {
		L10n.resolve {
			String(
				localized: "Select Notifications",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label shown in the bottom batch-edit toolbar when no notifications are selected."
			)
		}
	}
	/// The destructive button shown when removing notifications.
	static func deleteNotifications(_ count: Int) -> String {
		return String(
			localized: "Delete \(count) Notifications",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The destructive button shown when removing multiple notifications."
		)
	}
	/// The confirmation alert message shown when removing notifications.
	///
	/// - Parameter count: The number of notifications being removed.
	///
	/// - Tag: L10n-deleteNotificationsConfirmation
	static func deleteNotificationsConfirmation(_ count: Int) -> String {
		return String(
			localized: "notifications.deleteNotificationsConfirmation",
			defaultValue: "\(count) notifications will be removed.",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The confirmation alert message shown when removing notifications."
		)
	}
	/// The string for the phrase 'Could Not Update Notifications'.
	static var couldNotUpdateNotifications: String {
		L10n.resolve {
			String(
				localized: "Could Not Update Notifications",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error alert title shown when a notifications batch update fails."
			)
		}
	}
	/// The string for the phrase 'Could Not Remove Notifications'.
	static var couldNotRemoveNotifications: String {
		L10n.resolve {
			String(
				localized: "Could Not Remove Notifications",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error alert title shown when a notifications batch remove fails."
			)
		}
	}

	// MARK: - Menu Commands
	/// The menu command and title for the Home screen.
	///
	/// - Tag: L10n-home
	static var home: String {
		L10n.resolve {
			String(
				localized: "Home",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command and title for the Home screen."
			)
		}
	}
	/// The discoverability title for the Home menu command.
	///
	/// - Tag: L10n-toggleHome
	static var toggleHome: String {
		L10n.resolve {
			String(
				localized: "Toggle Home",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The discoverability title for the Home menu command."
			)
		}
	}
	/// The menu title for the command that returns to the previous screen.
	///
	/// - Tag: L10n-back
	static var back: String {
		L10n.resolve {
			String(
				localized: "Back",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu title for the command that returns to the previous screen."
			)
		}
	}
	/// The menu title for the command that reopens the screen the user navigated away from.
	///
	/// - Tag: L10n-forward
	static var forward: String {
		L10n.resolve {
			String(
				localized: "Forward",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu title for the command that reopens the screen the user navigated away from."
			)
		}
	}
	/// The menu title for the refresh command.
	///
	/// - Tag: L10n-refresh
	static var refresh: String {
		L10n.resolve {
			String(
				localized: "Refresh",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu title for the refresh command."
			)
		}
	}
	/// The menu command that refreshes the current page.
	///
	/// - Tag: L10n-refreshPage
	static var refreshPage: String {
		L10n.resolve {
			String(
				localized: "Refresh Page",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that refreshes the current page."
			)
		}
	}
	/// The menu command that opens settings.
	///
	/// - Tag: L10n-settingsCommand
	static var settingsCommand: String {
		L10n.resolve {
			String(
				localized: "Settings…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that opens settings."
			)
		}
	}
	/// The menu command that opens the user's account settings.
	///
	/// - Tag: L10n-accountSettingsCommand
	static var accountSettingsCommand: String {
		L10n.resolve {
			String(
				localized: "Account Settings…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that opens the user's account settings."
			)
		}
	}
	/// The menu command that opens the user's profile.
	///
	/// - Tag: L10n-viewMyProfileCommand
	static var viewMyProfileCommand: String {
		L10n.resolve {
			String(
				localized: "View My Profile…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that opens the user's profile."
			)
		}
	}
	/// The menu command that subscribes to reminders.
	///
	/// - Tag: L10n-subscribeToRemindersCommand
	static var subscribeToRemindersCommand: String {
		L10n.resolve {
			String(
				localized: "Subscribe to Reminders…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that subscribes to reminders."
			)
		}
	}
	/// The menu command that opens the Kurozora+ upgrade flow.
	///
	/// - Tag: L10n-upgradeToKurozoraPlus
	static var upgradeToKurozoraPlus: String {
		L10n.resolve {
			String(
				localized: "Upgrade to Kurozora+…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that opens the Kurozora+ upgrade flow."
			)
		}
	}
	/// The menu command that opens the redeem flow.
	///
	/// - Tag: L10n-redeemCommand
	static var redeemCommand: String {
		L10n.resolve {
			String(
				localized: "Redeem…",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command that opens the redeem flow."
			)
		}
	}
	/// The menu command and window title for the MiniPlayer.
	///
	/// - Tag: L10n-miniPlayer
	static var miniPlayer: String {
		L10n.resolve {
			String(
				localized: "MiniPlayer",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu command and window title for the MiniPlayer."
			)
		}
	}
	/// The discoverability title for the MiniPlayer menu command.
	///
	/// - Tag: L10n-toggleMiniPlayer
	static var toggleMiniPlayer: String {
		L10n.resolve {
			String(
				localized: "Toggle MiniPlayer",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The discoverability title for the MiniPlayer menu command."
			)
		}
	}

	// MARK: - Media Viewer
	/// The action that opens the media in a browser.
	///
	/// - Tag: L10n-openInBrowser
	static var openInBrowser: String {
		L10n.resolve {
			String(
				localized: "Open in Browser",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action that opens the media in a browser."
			)
		}
	}
	/// The toast shown after an image is saved to the photo library.
	///
	/// - Tag: L10n-imageSavedToLibrary
	static var imageSavedToLibrary: String {
		L10n.resolve {
			String(
				localized: "Image saved to your library!",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The toast shown after an image is saved to the photo library."
			)
		}
	}
	/// The default toast shown when an image could not be saved.
	///
	/// - Tag: L10n-imageSaveFailed
	static var imageSaveFailed: String {
		L10n.resolve {
			String(
				localized: "Image could not be saved.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The default toast shown when an image could not be saved."
			)
		}
	}
	/// The toast shown when photo library access is denied while saving.
	///
	/// - Tag: L10n-photoLibraryAccessDenied
	static var photoLibraryAccessDenied: String {
		L10n.resolve {
			String(
				localized: "Access to photo library denied.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The toast shown when photo library access is denied while saving."
			)
		}
	}
	/// The toast shown when an image fails to download.
	///
	/// - Tag: L10n-imageDownloadFailed
	static var imageDownloadFailed: String {
		L10n.resolve {
			String(
				localized: "Failed to download image.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The toast shown when an image fails to download."
			)
		}
	}
	/// The toast shown when an image fails to save.
	///
	/// - Tag: L10n-imageSaveFailedRetry
	static var imageSaveFailedRetry: String {
		L10n.resolve {
			String(
				localized: "Failed to save image.",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The toast shown when an image fails to save."
			)
		}
	}
	/// The button that rotates the media viewer.
	///
	/// - Tag: L10n-tapToRotate
	static var tapToRotate: String {
		L10n.resolve {
			String(
				localized: "Tap to Rotate",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button that rotates the media viewer."
			)
		}
	}

	// MARK: - Text Editor
	/// The button title for opening the content labels picker.
	///
	/// - Tag: L10n-labels
	static var labels: String {
		L10n.resolve {
			String(
				localized: "Labels",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button title for opening the content labels picker."
			)
		}
	}
	/// The button title shown when content labels have been added.
	///
	/// - Tag: L10n-labelsAdded
	static var labelsAdded: String {
		L10n.resolve {
			String(
				localized: "Labels Added",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button title shown when content labels have been added."
			)
		}
	}

	// MARK: - Search
	/// The placeholder shown in the main search bar.
	///
	/// - Tag: L10n-searchPlaceholder
	static var searchPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Anime, Manga, Games and More",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder shown in the main search bar."
			)
		}
	}

	// MARK: - Quick Links
	/// The Home quick link to the in-app purchases article.
	///
	/// - Tag: L10n-quickLinkIAP
	static var quickLinkIAP: String {
		L10n.resolve {
			String(
				localized: "About In-App Purchases",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The Home quick link to the in-app purchases article."
			)
		}
	}
	/// The Home quick link to the personalization article.
	///
	/// - Tag: L10n-quickLinkPersonalization
	static var quickLinkPersonalization: String {
		L10n.resolve {
			String(
				localized: "About Personalization",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The Home quick link to the personalization article."
			)
		}
	}
	/// The Home quick link to the welcome page.
	///
	/// - Tag: L10n-quickLinkWelcome
	static var quickLinkWelcome: String {
		L10n.resolve {
			String(
				localized: "Welcome to Kurozora",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The Home quick link to the welcome page."
			)
		}
	}

	// MARK: - Misc
	/// The string for the word 'options'.
	///
	/// - Tag: L10n-options
	static var options: String {
		L10n.resolve {
			String(
				localized: "Options",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'options'."
			)
		}
	}
}
