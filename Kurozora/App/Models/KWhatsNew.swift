//
//  KWhatsNew.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import WhatsNew

class KWhatsNew {
	/// Features of the current version of the app. Don't forget to change
	static var current: [WhatsNewItem] {
		return v1_12_0
	}

	/// Features of version 1.12.0 of the app.
	static var v1_12_0: [WhatsNewItem] = [
        .image(title: "7 Years of Kurozora", subtitle: "Celebrate this special occasion with all new, and old, app icons!", image: .Icons.kuroChan),
        .image(title: "Episodes, Enhanced.", subtitle: "Revamped episode details, added suggestions, proper season names, and correct navigation titles.", image: .Icons.tvSparkles),
        .image(title: "Rate All the Things", subtitle: "You can now rate and review characters and people. Let your voice be heard across the cast!", image: .Icons.rate),
        .image(title: "See All Reviews", subtitle: "Tap into a dedicated list to read all reviews for a title.", image: .Icons.rating),
        .image(title: "Pinned Posts", subtitle: "You can now pin your favorite feed messages to your profile. Show off your best takes!", image: .Icons.messagePin),
        .image(title: "Feed Fixes", subtitle: "No more repeating posts, crashes on delete, or stale content after posting—your feed just works.", image: .Icons.message),
        .image(title: "Smoother Searches", subtitle: "Fixed crashes on pagination and made the search bar prominent, so it’s no longer hiding from you.", image: .Icons.search),
        .image(title: "Library, Leveled Up", subtitle: "New library settings, default sorting options, proper button states, and UI fixes for better tracking.", image: .Icons.libraryGear),
        .image(title: "Design Polish", subtitle: "From better button spacing to consistent title bars—your Kurozora experience just got a visual glow-up.", image: .Icons.clearCache),
        .image(title: "Settings & Navigation", subtitle: "Motion preferences, Image Playground support, smoother request handling, accurate back button titles, and more.", image: .Icons.wrenchAndScrewdriverFill),
        .image(title: "Bug Fixes", subtitle: "Crashes caused by silly bugs have been fixed. Bad Kirito has been bonked accordingly.", image: .Icons.ladybug)
	]

	/// Features of version 1.11.0 of the app.
	static var v1_11_0: [WhatsNewItem] = [
        .image(title: "Cozy Cocoa", subtitle: "Bring festive cheer to your home screen with the Christmas『Kuro-chan』app icon, and『Can D. Cane』premium theme.", image: .Icons.gift),
        .image(title: "Sticker Wonderland", subtitle: "Added 6 new Kuro-chan stickers for a total of 24. Spread joy while messaging!", image: .Icons.kuroChanStickerSignal),
        .image(title: "New Re:CAP Design", subtitle: "A refreshed look to better reflect your year-end memories.", image: .Icons.session),
        .image(title: "Your Schedule Awaits", subtitle: "Introducing the new Schedule view for quick access to daily episodes and releases.", image: .Icons.calendar),
        .image(title: "Fresh Feed", subtitle: "A revamped feed design to keep your updates looking polished and sleek.", image: .Icons.personCropCircle),
        .image(title: "Profile Makeover", subtitle: "Edit your username, bio, banner, and more with the redesigned Profile Edit page.", image: .Icons.personCropCircleGear),
        .image(title: "Quick Access", subtitle: "Tapping the Date widget now takes you straight to the title’s details page.", image: .Icons.widget),
        .image(title: "Seamless Sign-Ins", subtitle: "Actions requiring login are now performed automatically after you sign in.", image: .Icons.faceid),
        .image(title: "Bug Fixes", subtitle: "Poured a cup of hot cocoa on those pesky bugs, resolving issues like deep links opening without a close button, the 'Go to Last Watched' episode feature misbehaving, separator theming in badge sections, and more. Your experience should now be smoother than ever!", image: .Icons.ladybug)
	]

	/// Features of version 1.10.0 of the app.
	static var v1_10_0: [WhatsNewItem] = [
        .image(title: "Boo!", subtitle: "Celebrate Halloween with the『Kur O' Zora』and『John』app icons.", image: .Icons.gift),
        .image(title: "Kuro-chan Stickers", subtitle: "Use them in Messages, FaceTime, and any app that supports attachments via the emoji keyboard. They’re also available on Telegram, Signal, and WhatsApp!", image: .Icons.kuroChanStickerSignal),
        .image(title: "Widgets", subtitle: "Added support for Control Center and Lock Screen widgets on iOS 18.", image: .Icons.widget),
        .image(title: "Chime", subtitle: "『Return by Death』,『Pine!』,『Youkoso!』and more chimes added to the collection!", image: .Icons.sound),
        .image(title: "Family Sharing", subtitle: "Share your 6-month or 12-month Kurozora+ subscription with up to 5 family members for free!", image: .Icons.familySharing),
        .image(title: "Studio Details", subtitle: "Now includes popularity ranking, defunct date, parent company, social links, successor, and predecessor studios. You can also rate and review studios now!", image: .Icons.studio),
        .image(title: "Country of Origin", subtitle: "Anime, manga, and games now have a country of origin detail.", image: .Icons.globe),
        .image(title: "Season Ratings", subtitle: "Season ratings reflect the average rating of all the episodes in a season to help you decide what to watch next. Don't forget to rate your favorite episodes!", image: .Icons.rating),
        .image(title: "Library Count", subtitle: "Easily view total counts from the navigation bar.", image: .Icons.libraryCount),
        .image(title: "Delete Library", subtitle: "A new big red button to empty your library with a single tap... kind of... provide the secret code just to be safe :D", image: .Icons.libraryTrash),
        .image(title: "In-app Purchase", subtitle: "Updated In-App Purchase process ensures smoother server verification and fewer errors.", image: .Icons.kurozoraPlus),
        .image(title: "Cache", subtitle: "Cache size now includes rich link data, with a detailed description explaining discrepancies between Kurozora and the Settings app.", image: .Icons.clearCache),
        .image(title: "Bug Fixes", subtitle: "Emptied two cans of premium bug spray to fix minor issues such as default themes not loading when not connected to the internet, pull-to-refresh not completing the refresh action correctly, and Re:CAP showing multiple months worth of statistics.", image: .Icons.ladybug)
	]

	/// Features of version 1.9.0 of the app.
	static var v1_9_0: [WhatsNewItem] = [
        .image(title: "Natsu Matsuri", subtitle: "Celebrate and make fond memories this summer with the new『Hanabi』,『Pink Lemonade』and『Shio Suika』app icons.", image: .Icons.gift),
        .image(title: "Lyrics", subtitle: "Want to sing along with your favorite anime songs? You can now with the lyrics on the details page of a song!", image: .Icons.music),
        .image(title: "Browse More", subtitle: "Is the Explore page and search bar not enough? It wasn’t for me either. Now you can browse everything Kurozora has to offer through the new \"Browse\" section on the Search page.", image: .Icons.browser),
        .image(title: "Date Widget", subtitle: "Personalize your home screen with the new Kurozora Date widget, cycling through episode, anime, manga, and game images. Customize options by tapping on the widget while in wiggle mode.", image: .Icons.widget),
        .image(title: "Quick Remind", subtitle: "Quickly add titles to your planning list and get reminded when they’re available by simply pressing on the \"Remind Me\" button :D", image: .Icons.reminder),
        .image(title: "Deeplinks", subtitle: "URLs redirecting to the app are now more reliable. You'll always land on the page you intended from now on!", image: .Icons.link),
        .image(title: "Spotlight Shortcuts", subtitle: "With Spotlight shortcuts, you can quickly visit the page you want in Kurozora right from your Home Screen!", image: .Icons.square2Layers3DTopFilled),
        .image(title: "Spotlight Search", subtitle: "Frequently visited titles will now appear directly in Spotlight, allowing you to find information quicker. Click on the result to be directed to the details page in Kurozora!", image: .Icons.search),
        .image(title: "Chimes", subtitle: "Discover new chimes from past and current anime seasons in the \"Sounds & Haptics\" settings! 🦌", image: .Icons.sound),
        .image(title: "Direct Engagement", subtitle: "Engage directly with other users by mentioning them in messages composed on their profile pages.", image: .Icons.messagePerson2),
        .image(title: "Updated Feature Lists", subtitle: "Stay informed about the latest features with updated feature lists for Pro and Kurozora+ members.", image: .Icons.unlock),
        .image(title: "Bug Fixes", subtitle: "More pesky bugs have been swatted, sprayed, and squashed. For example, the music play button will now correctly show the status of the played song.", image: .Icons.ladybug)
	]

	/// Features of version 1.8.0 of the app.
	static var v1_8_0: [WhatsNewItem] = [
        .image(title: "6 Years of Kurozora", subtitle: "Celebrate this special occasion with the new『Kuro-chan』app icon, available for all users.", image: .Icons.kuroChan),
        .image(title: "Date Widget", subtitle: "Personalize your home screen with the new Kurozora Date widget, cycling through episode, anime, manga, and game images. Customize options by tapping on the widget while in wiggle mode.", image: .Icons.widget),
        .image(title: "Search from Anywhere", subtitle: "Expand your search capabilities with the new『Find on Kurozora』Shortcuts app action, enabling convenient access to Kurozora from anywhere you want.", image: .Icons.square2Layers3DTopFilled),
        .image(title: "Quick Access", subtitle: "Quickly access any tab you want with the app shortcuts feature. Simply long-press the app on your home screen to access them, allowing you to navigate through Kurozora's tabs without even opening the app!", image: .Icons.bunny),
        .image(title: "User Libraries", subtitle: "Explore other users' libraries directly from their profile pages.", image: .Icons.libraryPerson3),
        .image(title: "Hidden Entries", subtitle: "Mark library entries as hidden to keep them private from your public-facing library and favorites list.", image: .Icons.libraryEyeSquareSlash),
        .image(title: "Revamped Library", subtitle: "Enjoy an improved library experience with a reorganized navigation bar for increased clarity.", image: .Icons.librarySparkles),
        .image(title: "Library Sharing", subtitle: "Share your library easily with others through a new menu option in your library.", image: .Icons.libraryShare),
        .image(title: "Sort by Popularity", subtitle: "Sort your library by trending titles to help you decide what to watch next.", image: .Icons.flame),
        .image(title: "Reminder Management", subtitle: "Stay organized by conveniently managing your reminders through a new menu option on your profile page and library.", image: .Icons.reminder),
        .image(title: "Message Limit", subtitle: "Express yourself freely with an expanded feed message limit—now increased from 240 to 280 characters for all users, 500 characters for Pro members and a whopping 1000 characters for Kurozora+ members.", image: .Icons.message),
        .image(title: "Direct Engagement", subtitle: "Engage directly with other users by mentioning them in messages composed on their profile pages.", image: .Icons.messagePerson2),
        .image(title: "Updated Feature Lists", subtitle: "Stay informed about the latest features with updated feature lists for Pro and Kurozora+ members.", image: .Icons.unlock),
        .image(title: "Bug Fixes", subtitle: "Experience smoother navigation with fixes to theme store button roundness and crashes when switching accounts using the Account Switcher feature (long hold tab bar for quick access).", image: .Icons.ladybug)
	]

	/// Features of version 1.7.0 of the app.
	static var v1_7_0: [WhatsNewItem] = [
        .image(title: "Egg Hunt", subtitle: "Embark on an Easter egg hunt with the new『Eggstein』app icon and『Pastel Paradise』theme.", image: .Icons.gift),
        .image(title: "Review List", subtitle: "Like reading reviews? Easily view your own and others' reviews directly from the profile page.", image: .Icons.rating),
        .image(title: "TV Rating", subtitle: "Enjoy more control over your content with the ability to change TV ratings", image: .Icons.tvRating),
        .image(title: "Timezone", subtitle: "View schedules, broadcasts and in your timezone.", image: .Icons.globe),
        .image(title: "Localization", subtitle: "Tailor your experience by selecting your preferred localization. English will be used as fallback where this feature isn't available yet.", image: .Icons.language),
        .image(title: "Tip Jar", subtitle: "Now you can view a list of unlockable features when you tip in the Tip Jar.", image: .Icons.tipJar),
        .image(title: "Kurozora+", subtitle: "A revamped Kurozora+ page, with new features listed for your convenience.", image: .Icons.unlock),
        .image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: .Icons.sound)
	]

	/// Features of version 1.6.0 of the app.
	static var v1_6_0: [WhatsNewItem] = [
        .image(title: "Heart-Thief", subtitle: "Prepare to have your heart stolen by the『White of Crime』app icon and the mysterious『Blue Sapphire』theme.", image: .Icons.gift),
        .image(title: "Rich Links", subtitle: "Share gifs, images, videos, and music directly in the feed with enhanced rich link previews, providing more context and information.", image: .Icons.link),
        .image(title: "OpticID", subtitle: "Unlock the app effortlessly using OpticID on Apple Vision Pro, providing a seamless and secure way to access your favorite content.", image: .Icons.opticID),
        .image(title: "TV Rating", subtitle: "Enjoy more control over your content with the ability to change TV ratings", image: .Icons.tvRating),
        .image(title: "Timezone", subtitle: "View schedules, broadcasts and in your timezone.", image: .Icons.globe),
        .image(title: "Localization", subtitle: "Tailor your experience by selecting your preferred localization. English will be used as fallback where this feature isn't available yet.", image: .Icons.language),
        .image(title: "Tip Jar", subtitle: "Now you can view a list of unlockable features when you tip in the Tip Jar.", image: .Icons.tipJar),
        .image(title: "Kurozora+", subtitle: "A revamped Kurozora+ page, with new features listed for your convenience.", image: .Icons.unlock),
        .image(title: "Re:CAP", subtitle: "Your personalized year-end review is now available in the app! Reflect on your top series of the year, along with the milestones you've achieved!", image: .Icons.session),
        .image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: .Icons.sound),
        .image(title: "Gem Icons", subtitle: "Created under immense pressure and extreme temperatures, the gem icon set shines with elegance and sophistication. Discover the allure of『Amethyst』,『Onyx』,『Ruby』, and『Sapphire』.", image: .Icons.ruby)
	]

	/// Features of version 1.5.0 of the app.
	static var v1_5_0: [WhatsNewItem] = [
        .image(title: "Love-Struck", subtitle: "Experience romance with the new charming『Touching Clouds』app icon and the romantic『Love Bug』theme.", image: .Icons.gift),
        .image(title: "Re:CAP", subtitle: "Your personalized year-end review is now available in the app! Reflect on your top series of the year, along with the milestones you've achieved!", image: .Icons.session),
        .image(title: "Splash Screen", subtitle: "The Kurozora logo now dynamically adapts to match your selected theme, creating a cohesive and personalized experience from the moment you open the app.", image: .Icons.theme),
        .image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: .Icons.sound),
        .image(title: "Gem Icons", subtitle: "Created under immense pressure and extreme temperatures, the gem icon set shines with elegance and sophistication. Discover the allure of『Amethyst』,『Onyx』,『Ruby』, and『Sapphire』.", image: .Icons.ruby)
	]

	/// Features of version 1.4.0 of the app.
	static var v1_4_0: [WhatsNewItem] = [
        .image(title: "Fireside Update", subtitle: "This update brings a cozy touch to Kurozora, warming up your experience with a blaze of exciting new features and enhancements. Get ready to ignite your journey with the Meri-Chri app icon and Cozy Cabin theme.", image: .Icons.gift),
        .image(title: "Kurozora+ Badges", subtitle: "Unlock the brilliance of the Kurozora+ badges, exclusive to the most dedicated members. Watch as these badges evolve as you continue supporting Kurozora.", image: .Icons.kurozoraPlus),
        .image(title: "Revamped Search", subtitle: "Experience the all-new Search tab – a sleek and efficient way to discover your favorites.", image: .Icons.search),
        .image(title: "Search Filters", subtitle: "Explore enhanced search functionality with new filters to refine your results, making it easier to find your content preferences.", image: .Icons.filter),
        .image(title: "Top Rankings", subtitle: "Discover a new dimension of content assessment with rankings for anime, manga, and games, providing valuable insights into what's trending.", image: .Icons.ranking),
        .image(title: "Enhanced Ratings and Reviews", subtitle: "Ratings now help streamline decision-making with charts and an overall sentiment score. Plus you can now share your thoughts with the new reviews feature.", image: .Icons.rating),
        .image(title: "Favorites Library", subtitle: "Your Favorites library now encompasses manga and games, making it even simpler to keep track of your preferred content.", image: .Icons.heartCircle),
        .image(title: "Episodes Revamp", subtitle: "Get a deeper insight into episodes with the revamped Episode lockups, offering more information and enhancing your viewing experience.", image: .Icons.tvSparkles),
        .image(title: "Season-Wide Watching", subtitle: "Effortlessly mark entire seasons as watched through Force Touch, or the convenient new button in the season details navigation bar.", image: .Icons.eyeCircle),
        .image(title: "Badges", subtitle: "Adding a touch of distinction to your profile. Show off your fandom and let others know what makes you a true Kurozora fan.", image: .Icons.shieldCheckered),
        .image(title: "Music Streaming Links", subtitle: "Enjoy a wider selection of music streaming options with added links to various platforms, ensuring you never miss a beat.", image: .Icons.music),
        .image(title: "Ignored List", subtitle: "Your personalized sanctuary for titles you want to exclude from your experience. Take control of your library like never before.", image: .Icons.library),
        .image(title: "Track your manga journey", subtitle: "Explore a vast universe of manga, light novels and other literature titles! Keep track of your reading progress and history while never missing a single chapter!", image: .Icons.manga),
        .image(title: "Game On!", subtitle: "Stay Ahead of the Game! Game tracking on Kurozora is now a breeze. Explore a wide variety of anime-related games, keep track of your favorites, and never miss a beat on the latest anime-inspired titles. Expand your universe beyond TV and books!", image: .Icons.joystick),
        .image(title: "UAL", subtitle: "With PRO and Kurozora+ you can now use the new Unified Anime Linking feature. It supports up to 12 services!", image: .Icons.at),
        .image(title: "Jump-start", subtitle: "Now you can easily import your anime and manga list from other services directly into Kurozora, streamlining your tracking experience with just a few *taps*!", image: .Icons.Brands.myAnimeList)
	]
}
