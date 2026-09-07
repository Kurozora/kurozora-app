//
//  L10n.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// Namespace for all localized user-facing strings in the Watch app.
/// 
/// Strings are organized across five domains, each backed by its own
/// `.xcstrings` catalog for independent translation workflows:
///
/// - ``Common`` domain → `Localizable.xcstrings`  *(default, unscoped strings)*
///
/// - Tag: L10n
struct L10n {
	// MARK: - Destinations
	/// The app name, shown as the root navigation title.
	static var kurozora: String {
		String(localized: "Kurozora", comment: "The app name shown as the root navigation title.")
	}

	/// The title of the home destination.
	static var home: String {
		String(localized: "Home", comment: "The title of the home destination.")
	}

	/// The title of the library destination.
	static var library: String {
		String(localized: "Library", comment: "The title of the library destination.")
	}

	/// The title of the search destination.
	static var search: String {
		String(localized: "Search", comment: "The title of the search destination.")
	}

	/// The title of the profile destination.
	static var profile: String {
		String(localized: "Profile", comment: "The title of the profile destination.")
	}

	// MARK: - Search
	/// The placeholder in the search field.
	static var searchPlaceholder: String {
		String(localized: "Search…", comment: "The placeholder in the search field.")
	}

	/// The section listing suggested searches.
	static var discover: String {
		String(localized: "Discover", comment: "The section listing suggested searches.")
	}

	/// The section listing the catalog categories to browse.
	static var browse: String {
		String(localized: "Browse", comment: "The section listing the catalog categories to browse.")
	}

	/// The search tab listing anime results.
	static var anime: String {
		String(localized: "Anime", comment: "The search tab listing anime results.")
	}

	/// The search tab listing manga results.
	static var manga: String {
		String(localized: "Manga", comment: "The search tab listing manga results.")
	}

	/// The search tab listing game results.
	static var games: String {
		String(localized: "Games", comment: "The search tab listing game results.")
	}

	/// The search tab listing song results.
	static var songs: String {
		String(localized: "Songs", comment: "The search tab listing song results.")
	}

	/// The search tab listing episode results.
	static var episodes: String {
		String(localized: "Episodes", comment: "The search tab listing episode results.")
	}

	/// The search tab listing character results.
	static var characters: String {
		String(localized: "Characters", comment: "The search tab listing character results.")
	}

	/// The search tab listing person results.
	static var people: String {
		String(localized: "People", comment: "The search tab listing person results.")
	}

	/// The search tab listing studio results.
	static var studios: String {
		String(localized: "Studios", comment: "The search tab listing studio results.")
	}

	/// The search tab listing user results.
	static var users: String {
		String(localized: "Users", comment: "The search tab listing user results.")
	}

	// MARK: - Filters
	/// The title of the search filter screen.
	static var filters: String {
		String(localized: "Filters", comment: "The title of the search filter screen.")
	}

	/// The button that opens the search filters.
	static var filter: String {
		String(localized: "Filter", comment: "The button that opens the search filters.")
	}

	/// The button that applies the chosen search filters.
	static var apply: String {
		String(localized: "Apply", comment: "The button that applies the chosen search filters.")
	}

	/// The button that clears the chosen search filters.
	static var reset: String {
		String(localized: "Reset", comment: "The button that clears the chosen search filters.")
	}

	/// The filter option that puts no constraint on the results.
	static var any: String {
		String(localized: "Any", comment: "The filter option that puts no constraint on the results.")
	}

	// MARK: - Filter Attributes
	/// The filter choosing which kind of item to look for.
	static var type: String {
		String(localized: "Type", comment: "The search filter choosing which kind of item to look for.")
	}

	/// The filter choosing a media type.
	static var mediaType: String {
		String(localized: "Media Type", comment: "The search filter choosing a media type.")
	}

	/// The filter choosing an airing or publication status.
	static var status: String {
		String(localized: "Status", comment: "The search filter choosing an airing or publication status.")
	}

	/// The filter choosing an age rating.
	static var tvRating: String {
		String(localized: "TV Rating", comment: "The search filter choosing an age rating.")
	}

	/// The filter choosing the material a title was adapted from.
	static var source: String {
		String(localized: "Source", comment: "The search filter choosing the material a title was adapted from.")
	}

	/// The filter choosing the weekday a series airs on.
	static var airDay: String {
		String(localized: "Air Day", comment: "The search filter choosing the weekday a series airs on.")
	}

	/// The filter choosing the season a series airs in.
	static var airSeason: String {
		String(localized: "Air Season", comment: "The search filter choosing the season a series airs in.")
	}

	/// The filter choosing the weekday a series publishes on.
	static var publicationDay: String {
		String(localized: "Publication Day", comment: "The search filter choosing the weekday a series publishes on.")
	}

	/// The filter choosing the season a series publishes in.
	static var publicationSeason: String {
		String(localized: "Publication Season", comment: "The search filter choosing the season a series publishes in.")
	}

	/// The filter choosing whether filler episodes appear.
	static var fillers: String {
		String(localized: "Fillers", comment: "The search filter choosing whether filler episodes appear.")
	}

	/// The filter choosing whether premiere episodes appear.
	static var premieres: String {
		String(localized: "Premieres", comment: "The search filter choosing whether premiere episodes appear.")
	}

	/// The filter choosing whether finale episodes appear.
	static var finales: String {
		String(localized: "Finales", comment: "The search filter choosing whether finale episodes appear.")
	}

	/// The filter choosing whether special episodes appear.
	static var specials: String {
		String(localized: "Specials", comment: "The search filter choosing whether special episodes appear.")
	}

	/// The filter choosing a character's or person's astrological sign.
	static var astrologicalSign: String {
		String(localized: "Astrological Sign", comment: "The search filter choosing a character's or person's astrological sign.")
	}

	// MARK: - Media Types
	/// The media type for a televised series.
	static var tv: String {
		String(localized: "TV", comment: "The media type for a televised series.")
	}

	/// The media type for an original video animation.
	static var ova: String {
		String(localized: "OVA", comment: "The media type for an original video animation. A fandom term, so it stays verbatim in most languages.")
	}

	/// The media type for an original net animation.
	static var ona: String {
		String(localized: "ONA", comment: "The media type for an original net animation. A fandom term, so it stays verbatim in most languages.")
	}

	/// The media type for a special episode.
	static var special: String {
		String(localized: "Special", comment: "The media type for a special episode.")
	}

	/// The media type for a feature film.
	static var movie: String {
		String(localized: "Movie", comment: "The media type for a feature film.")
	}

	/// The media type for a light novel.
	static var lightNovel: String {
		String(localized: "Light Novel", comment: "The media type for a light novel. A fandom term, so it stays verbatim in most languages.")
	}

	/// The media type for a one-shot manga.
	static var oneShot: String {
		String(localized: "One Shot", comment: "The media type for a manga published as a single installment.")
	}

	/// The media type for a visual novel.
	static var visualNovel: String {
		String(localized: "Visual Novel", comment: "The media type for a visual novel. A fandom term, so it stays verbatim in most languages.")
	}

	/// The media type for a novel.
	static var novel: String {
		String(localized: "Novel", comment: "The media type for a novel.")
	}

	/// The media type for a game.
	static var game: String {
		String(localized: "Game", comment: "The media type for a game.")
	}

	/// The media type for a console game.
	static var console: String {
		String(localized: "Console", comment: "The media type for a game released on a console.")
	}

	/// The media type for a computer game.
	static var pc: String {
		String(localized: "PC", comment: "The media type for a game released on computer.")
	}

	/// The media type for a mobile game.
	static var mobile: String {
		String(localized: "Mobile", comment: "The media type for a game released on mobile.")
	}

	/// The source stating a title is an original work.
	static var original: String {
		String(localized: "Original", comment: "The source stating a title is an original work rather than an adaptation.")
	}

	/// The source stating a title came from material not otherwise listed.
	static var other: String {
		String(localized: "Other", comment: "The source stating a title came from material not otherwise listed.")
	}

	// MARK: - Statuses
	/// The status for a series that is airing.
	static var currentlyAiring: String {
		String(localized: "Currently Airing", comment: "The status for a series that is currently airing.")
	}

	/// The status for a series that finished airing.
	static var finishedAiring: String {
		String(localized: "Finished Airing", comment: "The status for a series that has finished airing.")
	}

	/// The status for a series that has not started airing.
	static var notYetAired: String {
		String(localized: "Not Yet Aired", comment: "The status for a series that has not started airing.")
	}

	/// The status for a series that is publishing.
	static var currentlyPublishing: String {
		String(localized: "Currently Publishing", comment: "The status for a series that is currently publishing.")
	}

	/// The status for a series that finished publishing.
	static var finishedPublishing: String {
		String(localized: "Finished Publishing", comment: "The status for a series that has finished publishing.")
	}

	/// The status for a series that has not started publishing.
	static var notYetPublished: String {
		String(localized: "Not Yet Published", comment: "The status for a series that has not started publishing.")
	}

	/// The character status for someone alive.
	static var alive: String {
		String(localized: "Alive", comment: "The character status for someone who is alive.")
	}

	/// The character status for someone deceased.
	static var deceased: String {
		String(localized: "Deceased", comment: "The character status for someone who has died.")
	}

	/// The character status for someone missing.
	static var missing: String {
		String(localized: "Missing", comment: "The character status for someone whose whereabouts are unknown.")
	}

	/// The character status for someone whose state is unknown.
	static var unknown: String {
		String(localized: "Unknown", comment: "The character status for someone whose state is unknown.")
	}

	/// The filter option that includes the matching episodes.
	static var shown: String {
		String(localized: "Shown", comment: "The filter option that includes the matching episodes.")
	}

	/// The filter option that excludes the matching episodes.
	static var hidden: String {
		String(localized: "Hidden", comment: "The filter option that excludes the matching episodes.")
	}

	// MARK: - Age Ratings
	/// The age rating for all audiences.
	static var ratingG: String {
		String(localized: "G", comment: "The age rating for all audiences.")
	}

	/// The age rating suggesting parental guidance.
	static var ratingPG: String {
		String(localized: "PG", comment: "The age rating suggesting parental guidance.")
	}

	/// The age rating for viewers over thirteen.
	static var ratingPG13: String {
		String(localized: "PG-13", comment: "The age rating for viewers over thirteen.")
	}

	/// The age rating for viewers over seventeen.
	static var ratingR17: String {
		String(localized: "R - 17+", comment: "The age rating for viewers over seventeen.")
	}

	/// The age rating for mature audiences.
	static var ratingRPlus: String {
		String(localized: "R+", comment: "The age rating for mature audiences.")
	}

	// MARK: - Studio Types
	/// The studio type for an animation studio.
	static var animeStudio: String {
		String(localized: "Anime Studio", comment: "The studio type for an animation studio.")
	}

	/// The studio type for a sound studio.
	static var soundStudio: String {
		String(localized: "Sound Studio", comment: "The studio type for a sound production studio.")
	}

	/// The studio type for a broadcast network.
	static var network: String {
		String(localized: "Network", comment: "The studio type for a broadcast network.")
	}

	// MARK: - Seasons
	/// The season Winter.
	static var winter: String {
		String(localized: "Winter", comment: "The season Winter, used as an airing or publication season.")
	}

	/// The season Spring.
	static var spring: String {
		String(localized: "Spring", comment: "The season Spring, used as an airing or publication season.")
	}

	/// The season Summer.
	static var summer: String {
		String(localized: "Summer", comment: "The season Summer, used as an airing or publication season.")
	}

	/// The season Fall.
	static var fall: String {
		String(localized: "Fall", comment: "The season Fall, used as an airing or publication season.")
	}

	// MARK: - Astrological Signs
	/// The astrological sign Aries.
	static var aries: String {
		String(localized: "Aries ♈", comment: "The astrological sign Aries, followed by its symbol.")
	}

	/// The astrological sign Taurus.
	static var taurus: String {
		String(localized: "Taurus ♉", comment: "The astrological sign Taurus, followed by its symbol.")
	}

	/// The astrological sign Gemini.
	static var gemini: String {
		String(localized: "Gemini ♊", comment: "The astrological sign Gemini, followed by its symbol.")
	}

	/// The astrological sign Cancer.
	static var cancer: String {
		String(localized: "Cancer ♋", comment: "The astrological sign Cancer, followed by its symbol.")
	}

	/// The astrological sign Leo.
	static var leo: String {
		String(localized: "Leo ♌", comment: "The astrological sign Leo, followed by its symbol.")
	}

	/// The astrological sign Virgo.
	static var virgo: String {
		String(localized: "Virgo ♍", comment: "The astrological sign Virgo, followed by its symbol.")
	}

	/// The astrological sign Libra.
	static var libra: String {
		String(localized: "Libra ♎", comment: "The astrological sign Libra, followed by its symbol.")
	}

	/// The astrological sign Scorpio.
	static var scorpio: String {
		String(localized: "Scorpio ♏", comment: "The astrological sign Scorpio, followed by its symbol.")
	}

	/// The astrological sign Sagittarius.
	static var sagittarius: String {
		String(localized: "Sagittarius ♐", comment: "The astrological sign Sagittarius, followed by its symbol.")
	}

	/// The astrological sign Capricorn.
	static var capricorn: String {
		String(localized: "Capricorn ♑", comment: "The astrological sign Capricorn, followed by its symbol.")
	}

	/// The astrological sign Aquarius.
	static var aquarius: String {
		String(localized: "Aquarius ♒", comment: "The astrological sign Aquarius, followed by its symbol.")
	}

	/// The astrological sign Pisces.
	static var pisces: String {
		String(localized: "Pisces ♓", comment: "The astrological sign Pisces, followed by its symbol.")
	}

	// MARK: - Library
	/// The section header showing where a title sits in the user's library.
	static var libraryStatus: String {
		String(localized: "Library Status", comment: "The section header showing where a title sits in the user's library.")
	}

	/// The button that adds a title to the user's library.
	static var addToLibrary: String {
		String(localized: "Add to Library", comment: "The button that adds a title to the user's library.")
	}

	/// The button that removes a title from the user's library.
	static var removeFromLibrary: String {
		String(localized: "Remove from Library", comment: "The button that removes a title from the user's library.")
	}

	/// The message shown when a library status holds no shows.
	static var libraryStatusEmpty: String {
		String(localized: "Nothing here yet.", comment: "The message shown when a library status holds no shows.")
	}

	/// The accessibility label for the favorite indicator on a library row.
	static var favorite: String {
		String(localized: "Favorite", comment: "The accessibility label for the favorite indicator on a library row.")
	}

	/// The accessibility label for the reminder indicator on a library row.
	static var reminder: String {
		String(localized: "Reminder", comment: "The accessibility label for the reminder indicator on a library row.")
	}

	/// The library status for a title the user has not tracked.
	static var libraryNone: String {
		String(localized: "None", comment: "The library status for a show the user has not tracked.")
	}

	/// The library status for a title the user is watching.
	static var watching: String {
		String(localized: "Watching", comment: "The library status for a show the user is currently watching.")
	}

	/// The library status for a title the user plans to watch.
	static var planning: String {
		String(localized: "Planning", comment: "The library status for a show the user plans to watch.")
	}

	/// The library status for a title the user finished.
	static var completed: String {
		String(localized: "Completed", comment: "The library status for a show the user finished watching.")
	}

	/// The library status for a title the user paused.
	static var onHold: String {
		String(localized: "On-Hold", comment: "The library status for a show the user paused.")
	}

	/// The library status for a title the user abandoned.
	static var dropped: String {
		String(localized: "Dropped", comment: "The library status for a show the user abandoned.")
	}

	/// The library status for a title the user is interested in.
	static var interested: String {
		String(localized: "Interested", comment: "The library status for a show the user is interested in.")
	}

	/// The library status for a title the user chose to ignore.
	static var ignored: String {
		String(localized: "Ignored", comment: "The library status for a show the user chose to ignore.")
	}

	// MARK: - Episodes
	/// The episode count shown beneath a title.
	///
	/// - Parameter count: The number of episodes.
	///
	/// - Returns: The abbreviated episode count.
	static func episodeCount(_ count: Int) -> String {
		String(localized: "\(count) ep", comment: "The episode count shown beneath a title, abbreviated to fit the watch.")
	}

	/// The marker on an episode that is filler rather than canon.
	static var filler: String {
		String(localized: "Filler", comment: "The marker on an episode that is filler rather than canon.")
	}

	/// The button that marks an episode as watched.
	static var markAsWatched: String {
		String(localized: "Mark as Watched", comment: "The button that marks an episode as watched.")
	}

	/// The marker on an episode the user has already watched.
	static var watchedMarker: String {
		String(localized: "✓ Watched", comment: "The marker on an episode the user has already watched.")
	}

	// MARK: - Profile
	/// The profile stat counting the accounts that follow the user.
	static var followers: String {
		String(localized: "Followers", comment: "The profile stat counting the accounts that follow the user.")
	}

	/// The profile stat counting the accounts the user follows.
	static var following: String {
		String(localized: "Following", comment: "The profile stat counting the accounts the user follows.")
	}

	/// The button that signs the user out.
	static var signOut: String {
		String(localized: "Sign Out", comment: "The button that signs the user out.")
	}

	/// The message shown when no account is signed in.
	static var signInOnIPhone: String {
		String(localized: "Sign in on your iPhone to get started.", comment: "The message shown on the watch when no account is signed in.")
	}

	// MARK: - Notifications
	/// The notification grouping that lets the system decide.
	static var groupingAutomatic: String {
		String(localized: "Automatic", comment: "The notification grouping that lets the system decide.")
	}

	/// The notification grouping that groups by notification type.
	static var groupingByType: String {
		String(localized: "By Type", comment: "The notification grouping that groups by notification type.")
	}

	/// The notification grouping that shows one flat list.
	static var groupingOff: String {
		String(localized: "Off", comment: "The notification grouping that shows one flat list.")
	}

	// MARK: - Errors
	/// The button that retries a failed load.
	static var retry: String {
		String(localized: "Retry", comment: "The button that retries a failed load.")
	}

	/// The button that retries a failed request.
	static var tryAgain: String {
		String(localized: "Try Again", comment: "The button that retries a failed request.")
	}

	/// The message shown when the Up Next list fails to load.
	static var failedToLoadUpNext: String {
		String(localized: "Failed to load Up Next.", comment: "The message shown when the Up Next list fails to load.")
	}

	/// The message shown when the library fails to load.
	static var failedToLoadLibrary: String {
		String(localized: "Failed to load library.", comment: "The message shown when the library fails to load.")
	}

	/// The message shown when the search suggestions fail to load.
	static var failedToLoadSuggestions: String {
		String(localized: "Failed to load suggestions.", comment: "The message shown when the search suggestions fail to load.")
	}

	/// The message shown when the anime search results fail to load.
	static var failedToLoadShows: String {
		String(localized: "Failed to load shows.", comment: "The message shown when the anime search results fail to load.")
	}

	/// The message shown when the manga search results fail to load.
	static var failedToLoadManga: String {
		String(localized: "Failed to load manga.", comment: "The message shown when the manga search results fail to load.")
	}

	/// The message shown when the game search results fail to load.
	static var failedToLoadGames: String {
		String(localized: "Failed to load games.", comment: "The message shown when the game search results fail to load.")
	}

	/// The message shown when the episode search results fail to load.
	static var failedToLoadEpisodes: String {
		String(localized: "Failed to load episodes.", comment: "The message shown when the episode search results fail to load.")
	}

	/// The message shown when the character search results fail to load.
	static var failedToLoadCharacters: String {
		String(localized: "Failed to load characters.", comment: "The message shown when the character search results fail to load.")
	}

	/// The message shown when the person search results fail to load.
	static var failedToLoadPeople: String {
		String(localized: "Failed to load people.", comment: "The message shown when the person search results fail to load.")
	}

	/// The message shown when the song search results fail to load.
	static var failedToLoadSongs: String {
		String(localized: "Failed to load songs.", comment: "The message shown when the song search results fail to load.")
	}

	/// The message shown when the studio search results fail to load.
	static var failedToLoadStudios: String {
		String(localized: "Failed to load studios.", comment: "The message shown when the studio search results fail to load.")
	}

	/// The message shown when the user search results fail to load.
	static var failedToLoadUsers: String {
		String(localized: "Failed to load users.", comment: "The message shown when the user search results fail to load.")
	}
}
