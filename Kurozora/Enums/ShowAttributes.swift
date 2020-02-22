//
//  ShowAttributes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

class ShowAttributes {
	/**
		List of anime seasons

		```
		case winter = "Winter"
		case spring = "Spring"
		case summer = "Summer"
		case fall = "Fall"
		```
	*/
	public enum Season: String {
		case winter = "Winter"
		case spring = "Spring"
		case summer = "Summer"
		case fall = "Fall"

		static public let allRawValues: [String] = [Season.winter.rawValue, Season.spring.rawValue, Season.summer.rawValue, Season.fall.rawValue]
		static public let count: Int = allRawValues.count
	}

	/**
		List of anime types

		```
		case tv = "TV"
		case movie = "Movie"
		case special = "Special"
		case ova = "OVA"
		case ona = "ONA"
		case music = "Music"
		```
	*/
	public enum `Type`: String {
		case tv = "TV"
		case movie = "Movie"
		case special = "Special"
		case ova = "OVA"
		case ona = "ONA"
		case music = "Music"

		static public let allRawValues: [String] = [Type.tv.rawValue, Type.movie.rawValue, Type.special.rawValue, Type.ova.rawValue, Type.ona.rawValue, Type.music.rawValue]
		static public let count: Int = allRawValues.count
	}

	/**
		List of anime classifications

		```
		case gAllAges = "G - All Ages"
		case pgChildren = "PG - Children"
		case pg13 = "PG-13 - Teens 13 or older"
		case r17 = "R - 17+ (violence & profanity)"
		case rPlus = "R+ - Mild Nudity"
		```
	*/
	public enum Classification: String {
		case gAllAges = "G - All Ages"
		case pgChildren = "PG - Children"
		case pg13 = "PG-13 - Teens 13 or older"
		case r17 = "R - 17+ (violence & profanity)"
		case rPlus = "R+ - Mild Nudity"

		static public let allRawValues: [String] = [Classification.gAllAges.rawValue, Classification.pgChildren.rawValue, Classification.pg13.rawValue, Classification.r17.rawValue, Classification.rPlus.rawValue]
		static public let count: Int = allRawValues.count
	}

	/**
		List of anime status

		```
		case finishedAiring = "Finished Airing"
		case currentlyAiring = "Currently Airing"
		case notYetAired = "Not Yet Aired"
		case cancelled = "Cancelled"
		```
	*/
	public enum Status: String {
		case finishedAiring = "Finished Airing"
		case currentlyAiring = "Currently Airing"
		case notYetAired = "Not Yet Aired"
		case cancelled = "Cancelled"

		static public let allRawValues: [String] = [Status.finishedAiring.rawValue, Status.currentlyAiring.rawValue, Status.notYetAired.rawValue, Status.cancelled.rawValue]
		static public let count: Int = allRawValues.count
	}

	/**
		List of anime genres

		```
		case action = "Action"
		case adventure = "Adventure"
		case cars = "Cars"
		case comedy = "Comedy"
		case dementia = "Dementia"
		etc.
		```
	*/
	public enum Genre: String {
		case action = "Action"
		case adventure = "Adventure"
		case cars = "Cars"
		case comedy = "Comedy"
		case dementia = "Dementia"
		case demons = "Demons"
		case drama = "Drama"
		case ecchi = "Ecchi"
		case fantasy = "Fantasy"
		case game = "Game"
		case harem = "Harem"
		case historical = "Historical"
		case horror = "Horror"
		case josei = "Josei"
		case kids = "Kids"
		case magic = "Magic"
		case martialArts = "Martial Arts"
		case mecha = "Mecha"
		case military = "Military"
		case music = "Music"
		case mystery = "Mystery"
		case parody = "Parody"
		case police = "Police"
		case psychological = "Psychological"
		case romance = "Romance"
		case samurai = "Samurai"
		case school = "School"
		case sciFi = "Sci-Fi"
		case seinen = "Seinen"
		case shoujo = "Shoujo"
		case shoujoAi = "Shoujo Ai"
		case shounen = "Shounen"
		case shounenAi = "Shounen Ai"
		case sliceOfLife = "Slice of Life"
		case space = "Space"
		case sports = "Sports"
		case superPower = "Super Power"
		case supernatural = "Supernatural"
		case thriller = "Thriller"
		case vampire = "Vampire"
		case yaoi = "Yaoi"
		case yuri = "Yuri"

		static public let allRawValues: [String] = [Genre.action.rawValue, Genre.adventure.rawValue, Genre.cars.rawValue, Genre.comedy.rawValue, Genre.dementia.rawValue, Genre.demons.rawValue, Genre.drama.rawValue, Genre.ecchi.rawValue, Genre.fantasy.rawValue, Genre.game.rawValue, Genre.harem.rawValue, Genre.historical.rawValue, Genre.horror.rawValue, Genre.josei.rawValue, Genre.kids.rawValue, Genre.magic.rawValue, Genre.martialArts.rawValue, Genre.mecha.rawValue, Genre.military.rawValue, Genre.music.rawValue, Genre.mystery.rawValue, Genre.parody.rawValue, Genre.police.rawValue, Genre.psychological.rawValue, Genre.romance.rawValue, Genre.samurai.rawValue, Genre.school.rawValue, Genre.sciFi.rawValue, Genre.seinen.rawValue, Genre.shoujo.rawValue, Genre.shoujoAi.rawValue, Genre.shounen.rawValue, Genre.shounenAi.rawValue, Genre.sliceOfLife.rawValue, Genre.space.rawValue, Genre.sports.rawValue, Genre.superPower.rawValue, Genre.supernatural.rawValue, Genre.thriller.rawValue, Genre.vampire.rawValue, Genre.yaoi.rawValue, Genre.yuri.rawValue]
		static public let count: Int = allRawValues.count
	}

	/**
		List of anime sorting

		```
		case alphabetic = "A-Z"
		case popular = "Most Popular"
		case rating = "Highest Rated"
		```
	*/
	public enum Sort: String {
		case alphabetic = "A-Z"
		case popular = "Most Popular"
		case rating = "Highest Rated"
	}
}
