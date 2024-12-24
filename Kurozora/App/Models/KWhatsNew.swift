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
		return v111
	}

	/// Features of version 1.11.0 of the app.
	static var v111: [WhatsNewItem] = [
		.image(title: "Cozy Cocoa", subtitle: "Bring festive cheer to your home screen with the Christmas『Kuro-chan』app icon, and『Can D. Cane』premium theme.", image: R.image.icons.gift()!),
		.image(title: "Sticker Wonderland", subtitle: "Added 6 new Kuro-chan stickers for a total of 24. Spread joy while messaging!", image: R.image.icons.kuroChanStickerSignal()!),
		.image(title: "New Re:CAP Design", subtitle: "A refreshed look to better reflect your year-end memories.", image: R.image.icons.session()!),
		.image(title: "Your Schedule Awaits", subtitle: "Introducing the new Schedule view for quick access to daily episodes and releases.", image: R.image.icons.calendar()!),
		.image(title: "Fresh Feed", subtitle: "A revamped feed design to keep your updates looking polished and sleek.", image: R.image.icons.personCropCircle()!),
		.image(title: "Profile Makeover", subtitle: "Edit your username, bio, banner, and more with the redesigned Profile Edit page.", image: R.image.icons.personCropCircleGear()!),
		.image(title: "Quick Access", subtitle: "Tapping the Date widget now takes you straight to the title’s details page.", image: R.image.icons.widget()!),
		.image(title: "Seamless Sign-Ins", subtitle: "Actions requiring login are now performed automatically after you sign in.", image: R.image.icons.faceid()!),
		.image(title: "Bug Fixes", subtitle: "Poured a cup of hot cocoa on those pesky bugs, resolving issues like deep links opening without a close button, the 'Go to Last Watched' episode feature misbehaving, separator theming in badge sections, and more. Your experience should now be smoother than ever!", image: R.image.icons.bug()!)
	]

	/// Features of version 1.10.0 of the app.
	static var v110: [WhatsNewItem] = [
		.image(title: "Boo!", subtitle: "Celebrate Halloween with the『Kur O' Zora』and『John』app icons.", image: R.image.icons.gift()!),
		.image(title: "Kuro-chan Stickers", subtitle: "Use them in Messages, FaceTime, and any app that supports attachments via the emoji keyboard. They’re also available on Telegram, Signal, and WhatsApp!", image: R.image.icons.kuroChanStickerSignal()!),
		.image(title: "Widgets", subtitle: "Added support for Control Center and Lock Screen widgets on iOS 18.", image: R.image.icons.widget()!),
		.image(title: "Chime", subtitle: "『Return by Death』,『Pine!』,『Youkoso!』and more chimes added to the collection!", image: R.image.icons.sound()!),
		.image(title: "Family Sharing", subtitle: "Share your 6-month or 12-month Kurozora+ subscription with up to 5 family members for free!", image: R.image.icons.familySharing()!),
		.image(title: "Studio Details", subtitle: "Now includes popularity ranking, defunct date, parent company, social links, successor, and predecessor studios. You can also rate and review studios now!", image: R.image.icons.studio()!),
		.image(title: "Country of Origin", subtitle: "Anime, manga, and games now have a country of origin detail.", image: R.image.icons.globe()!),
		.image(title: "Season Ratings", subtitle: "Season ratings reflect the average rating of all the episodes in a season to help you decide what to watch next. Don't forget to rate your favorite episodes!", image: R.image.icons.rating()!),
		.image(title: "Library Count", subtitle: "Easily view total counts from the navigation bar.", image: R.image.icons.libraryCount()!),
		.image(title: "Delete Library", subtitle: "A new big red button to empty your library with a single tap... kind of... provide the secret code just to be safe :D", image: R.image.icons.libraryTrash()!),
		.image(title: "In-app Purchase", subtitle: "Updated In-App Purchase process ensures smoother server verification and fewer errors.", image: R.image.icons.kurozoraPlus()!),
		.image(title: "Cache", subtitle: "Cache size now includes rich link data, with a detailed description explaining discrepancies between Kurozora and the Settings app.", image: R.image.icons.clearCache()!),
		.image(title: "Bug Fixes", subtitle: "Emptied two cans of premium bug spray to fix minor issues such as default themes not loading when not connected to the internet, pull-to-refresh not completing the refresh action correctly, and Re:CAP showing multiple months worth of statistics.", image: R.image.icons.bug()!)
	]

	/// Features of version 1.9.0 of the app.
	static var v19: [WhatsNewItem] = [
		.image(title: "Natsu Matsuri", subtitle: "Celebrate and make fond memories this summer with the new『Hanabi』,『Pink Lemonade』and『Shio Suika』app icons.", image: R.image.icons.gift()!),
		.image(title: "Lyrics", subtitle: "Want to sing along with your favorite anime songs? You can now with the lyrics on the details page of a song!", image: R.image.icons.music()!),
		.image(title: "Browse More", subtitle: "Is the Explore page and search bar not enough? It wasn’t for me either. Now you can browse everything Kurozora has to offer through the new \"Browse\" section on the Search page.", image: R.image.icons.browser()!),
		.image(title: "Date Widget", subtitle: "Personalize your home screen with the new Kurozora Date widget, cycling through episode, anime, manga, and game images. Customize options by tapping on the widget while in wiggle mode.", image: R.image.icons.widget()!),
		.image(title: "Quick Remind", subtitle: "Quickly add titles to your planning list and get reminded when they’re available by simply pressing on the \"Remind Me\" button :D", image: R.image.icons.reminder()!),
		.image(title: "Deeplinks", subtitle: "URLs redirecting to the app are now more reliable. You'll always land on the page you intended from now on!", image: R.image.icons.link()!),
		.image(title: "Spotlight Shortcuts", subtitle: "With Spotlight shortcuts, you can quickly visit the page you want in Kurozora right from your Home Screen!", image: R.image.icons.shortcuts()!),
		.image(title: "Spotlight Search", subtitle: "Frequently visited titles will now appear directly in Spotlight, allowing you to find information quicker. Click on the result to be directed to the details page in Kurozora!", image: R.image.icons.search()!),
		.image(title: "Chimes", subtitle: "Discover new chimes from past and current anime seasons in the \"Sounds & Haptics\" settings! 🦌", image: R.image.icons.sound()!),
		.image(title: "Direct Engagement", subtitle: "Engage directly with other users by mentioning them in messages composed on their profile pages.", image: R.image.icons.messagePerson2()!),
		.image(title: "Updated Feature Lists", subtitle: "Stay informed about the latest features with updated feature lists for Pro and Kurozora+ members.", image: R.image.icons.unlock()!),
		.image(title: "Bug Fixes", subtitle: "More pesky bugs have been swatted, sprayed, and squashed. For example, the music play button will now correctly show the status of the played song.", image: R.image.icons.bug()!)
	]

	/// Features of version 1.8.0 of the app.
	static var v18: [WhatsNewItem] = [
		.image(title: "6 Years of Kurozora", subtitle: "Celebrate this special occasion with the new『Kuro-chan』app icon, available for all users.", image: R.image.icons.kuroChan()!),
		.image(title: "Date Widget", subtitle: "Personalize your home screen with the new Kurozora Date widget, cycling through episode, anime, manga, and game images. Customize options by tapping on the widget while in wiggle mode.", image: R.image.icons.widget()!),
		.image(title: "Search from Anywhere", subtitle: "Expand your search capabilities with the new『Find on Kurozora』Shortcuts app action, enabling convenient access to Kurozora from anywhere you want.", image: R.image.icons.shortcuts()!),
		.image(title: "Quick Access", subtitle: "Quickly access any tab you want with the app shortcuts feature. Simply long-press the app on your home screen to access them, allowing you to navigate through Kurozora's tabs without even opening the app!", image: R.image.icons.bunny()!),
		.image(title: "User Libraries", subtitle: "Explore other users' libraries directly from their profile pages.", image: R.image.icons.libraryPerson3()!),
		.image(title: "Hidden Entries", subtitle: "Mark library entries as hidden to keep them private from your public-facing library and favorites list.", image: R.image.icons.libraryEyeSquareSlash()!),
		.image(title: "Revamped Library", subtitle: "Enjoy an improved library experience with a reorganized navigation bar for increased clarity.", image: R.image.icons.librarySparkles()!),
		.image(title: "Library Sharing", subtitle: "Share your library easily with others through a new menu option in your library.", image: R.image.icons.libraryShare()!),
		.image(title: "Sort by Popularity", subtitle: "Sort your library by trending titles to help you decide what to watch next.", image: R.image.icons.flame()!),
		.image(title: "Reminder Management", subtitle: "Stay organized by conveniently managing your reminders through a new menu option on your profile page and library.", image: R.image.icons.reminder()!),
		.image(title: "Message Limit", subtitle: "Express yourself freely with an expanded feed message limit—now increased from 240 to 280 characters for all users, 500 characters for Pro members and a whopping 1000 characters for Kurozora+ members.", image: R.image.icons.message()!),
		.image(title: "Direct Engagement", subtitle: "Engage directly with other users by mentioning them in messages composed on their profile pages.", image: R.image.icons.messagePerson2()!),
		.image(title: "Updated Feature Lists", subtitle: "Stay informed about the latest features with updated feature lists for Pro and Kurozora+ members.", image: R.image.icons.unlock()!),
		.image(title: "Bug Fixes", subtitle: "Experience smoother navigation with fixes to theme store button roundness and crashes when switching accounts using the Account Switcher feature (long hold tab bar for quick access).", image: R.image.icons.bug()!)
	]

	/// Features of version 1.7.0 of the app.
	static var v17: [WhatsNewItem] = [
		.image(title: "Egg Hunt", subtitle: "Embark on an Easter egg hunt with the new『Eggstein』app icon and『Pastel Paradise』theme.", image: R.image.icons.gift()!),
		.image(title: "Review List", subtitle: "Like reading reviews? Easily view your own and others' reviews directly from the profile page.", image: R.image.icons.rating()!),
		.image(title: "TV Rating", subtitle: "Enjoy more control over your content with the ability to change TV ratings", image: R.image.icons.tvRating()!),
		.image(title: "Timezone", subtitle: "View schedules, broadcasts and in your timezone.", image: R.image.icons.globe()!),
		.image(title: "Localization", subtitle: "Tailor your experience by selecting your preferred localization. English will be used as fallback where this feature isn't available yet.", image: R.image.icons.language()!),
		.image(title: "Tip Jar", subtitle: "Now you can view a list of unlockable features when you tip in the Tip Jar.", image: R.image.icons.tipJar()!),
		.image(title: "Kurozora+", subtitle: "A revamped Kurozora+ page, with new features listed for your convenience.", image: R.image.icons.unlock()!),
		.image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: R.image.icons.sound()!)
	]

	/// Features of version 1.6.0 of the app.
	static var v16: [WhatsNewItem] = [
		.image(title: "Heart-Thief", subtitle: "Prepare to have your heart stolen by the『White of Crime』app icon and the mysterious『Blue Sapphire』theme.", image: R.image.icons.gift()!),
		.image(title: "Rich Links", subtitle: "Share gifs, images, videos, and music directly in the feed with enhanced rich link previews, providing more context and information.", image: R.image.icons.link()!),
		.image(title: "OpticID", subtitle: "Unlock the app effortlessly using OpticID on Apple Vision Pro, providing a seamless and secure way to access your favorite content.", image: R.image.icons.opticID()!),
		.image(title: "TV Rating", subtitle: "Enjoy more control over your content with the ability to change TV ratings", image: R.image.icons.tvRating()!),
		.image(title: "Timezone", subtitle: "View schedules, broadcasts and in your timezone.", image: R.image.icons.globe()!),
		.image(title: "Localization", subtitle: "Tailor your experience by selecting your preferred localization. English will be used as fallback where this feature isn't available yet.", image: R.image.icons.language()!),
		.image(title: "Tip Jar", subtitle: "Now you can view a list of unlockable features when you tip in the Tip Jar.", image: R.image.icons.tipJar()!),
		.image(title: "Kurozora+", subtitle: "A revamped Kurozora+ page, with new features listed for your convenience.", image: R.image.icons.unlock()!),
		.image(title: "Re:CAP", subtitle: "Your personalized year-end review is now available in the app! Reflect on your top series of the year, along with the milestones you've achieved!", image: R.image.icons.session()!),
		.image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: R.image.icons.sound()!),
		.image(title: "Gem Icons", subtitle: "Created under immense pressure and extreme temperatures, the gem icon set shines with elegance and sophistication. Discover the allure of『Amethyst』,『Onyx』,『Ruby』, and『Sapphire』.", image: R.image.icons.ruby()!)
	]

	/// Features of version 1.5.0 of the app.
	static var v15: [WhatsNewItem] = [
		.image(title: "Love-Struck", subtitle: "Experience romance with the new charming『Touching Clouds』app icon and the romantic『Love Bug』theme.", image: R.image.icons.gift()!),
		.image(title: "Re:CAP", subtitle: "Your personalized year-end review is now available in the app! Reflect on your top series of the year, along with the milestones you've achieved!", image: R.image.icons.session()!),
		.image(title: "Splash Screen", subtitle: "The Kurozora logo now dynamically adapts to match your selected theme, creating a cohesive and personalized experience from the moment you open the app.", image: R.image.icons.theme()!),
		.image(title: "Sounds & Haptics", subtitle: "A harmonious blend of serene chimes and iconic anime sounds. Whether you seek tranquility or a touch of nostalgia, find the perfect ambiance to accompany your journey.", image: R.image.icons.sound()!),
		.image(title: "Gem Icons", subtitle: "Created under immense pressure and extreme temperatures, the gem icon set shines with elegance and sophistication. Discover the allure of『Amethyst』,『Onyx』,『Ruby』, and『Sapphire』.", image: R.image.icons.ruby()!)
	]

	/// Features of version 1.4.0 of the app.
	static var v14: [WhatsNewItem] = [
		.image(title: "Fireside Update", subtitle: "This update brings a cozy touch to Kurozora, warming up your experience with a blaze of exciting new features and enhancements. Get ready to ignite your journey with the Meri-Chri app icon and Cozy Cabin theme.", image: R.image.icons.gift()!),
		.image(title: "Kurozora+ Badges", subtitle: "Unlock the brilliance of the Kurozora+ badges, exclusive to the most dedicated members. Watch as these badges evolve as you continue supporting Kurozora.", image: R.image.icons.kurozoraPlus()!),
		.image(title: "Revamped Search", subtitle: "Experience the all-new Search tab – a sleek and efficient way to discover your favorites.", image: R.image.icons.search()!),
		.image(title: "Search Filters", subtitle: "Explore enhanced search functionality with new filters to refine your results, making it easier to find your content preferences.", image: R.image.icons.filter()!),
		.image(title: "Top Rankings", subtitle: "Discover a new dimension of content assessment with rankings for anime, manga, and games, providing valuable insights into what's trending.", image: R.image.icons.ranking()!),
		.image(title: "Enhanced Ratings and Reviews", subtitle: "Ratings now help streamline decision-making with charts and an overall sentiment score. Plus you can now share your thoughts with the new reviews feature.", image: R.image.icons.rating()!),
		.image(title: "Favorites Library", subtitle: "Your Favorites library now encompasses manga and games, making it even simpler to keep track of your preferred content.", image: R.image.icons.favorite()!),
		.image(title: "Episodes Revamp", subtitle: "Get a deeper insight into episodes with the revamped Episode lockups, offering more information and enhancing your viewing experience.", image: R.image.icons.tvSparkles()!),
		.image(title: "Season-Wide Watching", subtitle: "Effortlessly mark entire seasons as watched through Force Touch, or the convenient new button in the season details navigation bar.", image: R.image.icons.eyeCircle()!),
		.image(title: "Badges", subtitle: "Adding a touch of distinction to your profile. Show off your fandom and let others know what makes you a true Kurozora fan.", image: R.image.icons.shieldCheckered()!),
		.image(title: "Music Streaming Links", subtitle: "Enjoy a wider selection of music streaming options with added links to various platforms, ensuring you never miss a beat.", image: R.image.icons.music()!),
		.image(title: "Ignored List", subtitle: "Your personalized sanctuary for titles you want to exclude from your experience. Take control of your library like never before.", image: R.image.icons.library()!),
		.image(title: "Track your manga journey", subtitle: "Explore a vast universe of manga, light novels and other literature titles! Keep track of your reading progress and history while never missing a single chapter!", image: R.image.icons.manga()!),
		.image(title: "Game On!", subtitle: "Stay Ahead of the Game! Game tracking on Kurozora is now a breeze. Explore a wide variety of anime-related games, keep track of your favorites, and never miss a beat on the latest anime-inspired titles. Expand your universe beyond TV and books!", image: R.image.icons.game()!),
		.image(title: "UAL", subtitle: "With PRO and Kurozora+ you can now use the new Unified Anime Linking feature. It supports up to 12 services!", image: R.image.icons.mention()!),
		.image(title: "Jump-start", subtitle: "Now you can easily import your anime and manga list from other services directly into Kurozora, streamlining your tracking experience with just a few *taps*!", image: R.image.icons.brands.myAnimeList()!)
	]
}
