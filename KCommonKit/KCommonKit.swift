//
//  KCommonKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

public class KCommonKit {
    public class func bundle() -> Bundle {
        return Bundle(for: self)
    }

    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Action", bundle: bundle())
    }

    public class func actionListViewController() -> ActionListViewController {
        let actionListController = defaultStoryboard().instantiateViewController(withIdentifier: "ActionList") as! ActionListViewController
        return actionListController
    }

    public class func dropDownListViewController() -> DropDownListViewController {
        let dropDownListController = defaultStoryboard().instantiateViewController(withIdentifier: "DropDownList") as! DropDownListViewController
        return dropDownListController
    }

    public static var shared = KCommonKit()
    private init() {}
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
public enum AnimeType: String {
    case tv = "TV"
    case movie = "Movie"
    case special = "Special"
    case ova = "OVA"
    case ona = "ONA"
    case music = "Music"

	static public let allRawValues: [String] = [AnimeType.tv.rawValue, AnimeType.movie.rawValue, AnimeType.special.rawValue, AnimeType.ova.rawValue, AnimeType.ona.rawValue, AnimeType.music.rawValue]
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
public enum AnimeClassification: String {
    case gAllAges = "G - All Ages"
    case pgChildren = "PG - Children"
    case pg13 = "PG-13 - Teens 13 or older"
    case r17 = "R - 17+ (violence & profanity)"
    case rPlus = "R+ - Mild Nudity"

	static public let allRawValues: [String] = [AnimeClassification.gAllAges.rawValue, AnimeClassification.pgChildren.rawValue, AnimeClassification.pg13.rawValue, AnimeClassification.r17.rawValue, AnimeClassification.rPlus.rawValue]
	static public let count: Int = allRawValues.count
}

/**
	List of anime status

	```
	case finishedAiring = "finished airing"
	case currentlyAiring = "currently airing"
	case notYetAired = "not yet aired"
	```
*/
public enum AnimeStatus: String {
    case finishedAiring = "finished airing"
    case currentlyAiring = "currently airing"
    case notYetAired = "not yet aired"

	static public let allRawValues: [String] = [AnimeStatus.finishedAiring.rawValue, AnimeStatus.currentlyAiring.rawValue, AnimeStatus.notYetAired.rawValue]
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
public enum AnimeGenre: String {
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

	static public let allRawValues: [String] = [AnimeGenre.action.rawValue, AnimeGenre.adventure.rawValue, AnimeGenre.cars.rawValue, AnimeGenre.comedy.rawValue, AnimeGenre.dementia.rawValue, AnimeGenre.demons.rawValue, AnimeGenre.drama.rawValue, AnimeGenre.ecchi.rawValue, AnimeGenre.fantasy.rawValue, AnimeGenre.game.rawValue, AnimeGenre.harem.rawValue, AnimeGenre.historical.rawValue, AnimeGenre.horror.rawValue, AnimeGenre.josei.rawValue, AnimeGenre.kids.rawValue, AnimeGenre.magic.rawValue, AnimeGenre.martialArts.rawValue, AnimeGenre.mecha.rawValue, AnimeGenre.military.rawValue, AnimeGenre.music.rawValue, AnimeGenre.mystery.rawValue, AnimeGenre.parody.rawValue, AnimeGenre.police.rawValue, AnimeGenre.psychological.rawValue, AnimeGenre.romance.rawValue, AnimeGenre.samurai.rawValue, AnimeGenre.school.rawValue, AnimeGenre.sciFi.rawValue, AnimeGenre.seinen.rawValue, AnimeGenre.shoujo.rawValue, AnimeGenre.shoujoAi.rawValue, AnimeGenre.shounen.rawValue, AnimeGenre.shounenAi.rawValue, AnimeGenre.sliceOfLife.rawValue, AnimeGenre.space.rawValue, AnimeGenre.sports.rawValue, AnimeGenre.superPower.rawValue, AnimeGenre.supernatural.rawValue, AnimeGenre.thriller.rawValue, AnimeGenre.vampire.rawValue, AnimeGenre.yaoi.rawValue, AnimeGenre.yuri.rawValue]
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
public enum AnimeSort: String {
    case alphabetic = "A-Z"
    case popular = "Most Popular"
    case rating = "Highest Rated"
}
