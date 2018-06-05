//
//  KCommonKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

public class KCommonKit {
    public class func bundle() -> Bundle {
        return Bundle(for: self)
    }
    
    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Action", bundle: bundle())
    }
    
    public class func actionListViewController() -> ActionListViewController {
        let controller = defaultStoryboard().instantiateViewController(withIdentifier: "ActionList") as! ActionListViewController
        return controller
    }

    public class func dropDownListViewController() -> DropDownListViewController {
        let controller = defaultStoryboard().instantiateViewController(withIdentifier: "DropDownList") as! DropDownListViewController
        return controller
    }
}

public struct GlobalVariables{
    public init() {
        // This initializer intentionally left empty
    }
    
    public let BaseURLString = "https://kurozora.app/api/v1/"
    
    public let KDefaults = UserDefaults.standard
    
}

public enum FontAwesome: String {
    case AngleDown = ""
    case TimesCircle = ""
    case Ranking = ""
    case Members = ""
    case Watched = ""
    case Favorite = ""
    case Rated = ""
}

public enum AnimeType: String {
    case TV = "TV"
    case Movie = "Movie"
    case Special = "Special"
    case OVA = "OVA"
    case ONA = "ONA"
    case Music = "Music"
    
    static public func count() -> Int {
        return 6
    }
    
    static public func allRawValues() -> [String] {
        return [AnimeType.TV.rawValue, AnimeType.Movie.rawValue, AnimeType.Special.rawValue, AnimeType.OVA.rawValue, AnimeType.ONA.rawValue, AnimeType.Music.rawValue]
    }
}

public enum AnimeClassification: String {
    case G = "G - All Ages"
    case PG = "PG - Children"
    case PG13 = "PG-13 - Teens 13 or older"
    case R17 = "R - 17+ (violence & profanity)"
    case RPlus = "R+ - Mild Nudity"
    
    static public func count() -> Int {
        return 5
    }
    
    static public func allRawValues() -> [String] {
        return [AnimeClassification.G.rawValue, AnimeClassification.PG.rawValue, AnimeClassification.PG13.rawValue, AnimeClassification.R17.rawValue, AnimeClassification.RPlus.rawValue]
    }
}

public enum AnimeStatus: String {
    case FinishedAiring = "finished airing"
    case CurrentlyAiring = "currently airing"
    case NotYetAired = "not yet aired"
    
    static public func count() -> Int {
        return 3
    }
    
    static public func allRawValues() -> [String] {
        return [AnimeStatus.FinishedAiring.rawValue, AnimeStatus.CurrentlyAiring.rawValue, AnimeStatus.NotYetAired.rawValue]
    }
}

public enum AnimeGenre: String {
    case Action = "Action"
    case Adventure = "Adventure"
    case Cars = "Cars"
    case Comedy = "Comedy"
    case Dementia = "Dementia"
    case Demons = "Demons"
    case Drama = "Drama"
    case Ecchi = "Ecchi"
    case Fantasy = "Fantasy"
    case Game = "Game"
    case Harem = "Harem"
    case Historical = "Historical"
    case Horror = "Horror"
    case Josei = "Josei"
    case Kids = "Kids"
    case Magic = "Magic"
    case MartialArts = "Martial Arts"
    case Mecha = "Mecha"
    case Military = "Military"
    case Music = "Music"
    case Mystery = "Mystery"
    case Parody = "Parody"
    case Police = "Police"
    case Psychological = "Psychological"
    case Romance = "Romance"
    case Samurai = "Samurai"
    case School = "School"
    case SciFi = "Sci-Fi"
    case Seinen = "Seinen"
    case Shoujo = "Shoujo"
    case ShoujoAi = "Shoujo Ai"
    case Shounen = "Shounen"
    case ShounenAi = "Shounen Ai"
    case SliceOfLife = "Slice of Life"
    case Space = "Space"
    case Sports = "Sports"
    case SuperPower = "Super Power"
    case Supernatural = "Supernatural"
    case Thriller = "Thriller"
    case Vampire = "Vampire"
    case Yaoi = "Yaoi"
    case Yuri = "Yuri"
    
    static public func count() -> Int {
        return 43
    }
    
    static public func allRawValues() -> [String] {
        return [AnimeGenre.Action.rawValue, AnimeGenre.Adventure.rawValue, AnimeGenre.Cars.rawValue, AnimeGenre.Comedy.rawValue, AnimeGenre.Dementia.rawValue, AnimeGenre.Demons.rawValue, AnimeGenre.Drama.rawValue, AnimeGenre.Ecchi.rawValue, AnimeGenre.Fantasy.rawValue, AnimeGenre.Game.rawValue, AnimeGenre.Harem.rawValue, AnimeGenre.Historical.rawValue, AnimeGenre.Horror.rawValue, AnimeGenre.Josei.rawValue, AnimeGenre.Kids.rawValue, AnimeGenre.Magic.rawValue, AnimeGenre.MartialArts.rawValue, AnimeGenre.Mecha.rawValue, AnimeGenre.Military.rawValue, AnimeGenre.Music.rawValue, AnimeGenre.Mystery.rawValue, AnimeGenre.Parody.rawValue, AnimeGenre.Police.rawValue, AnimeGenre.Psychological.rawValue, AnimeGenre.Romance.rawValue, AnimeGenre.Samurai.rawValue, AnimeGenre.School.rawValue, AnimeGenre.SciFi.rawValue, AnimeGenre.Seinen.rawValue, AnimeGenre.Shoujo.rawValue, AnimeGenre.ShoujoAi.rawValue, AnimeGenre.Shounen.rawValue, AnimeGenre.ShounenAi.rawValue, AnimeGenre.SliceOfLife.rawValue, AnimeGenre.Space.rawValue, AnimeGenre.Sports.rawValue, AnimeGenre.SuperPower.rawValue, AnimeGenre.Supernatural.rawValue, AnimeGenre.Thriller.rawValue, AnimeGenre.Vampire.rawValue, AnimeGenre.Yaoi.rawValue, AnimeGenre.Yuri.rawValue]
    }
}

public enum AnimeSort: String {
    case AZ = "A-Z"
    case Popular = "Most Popular"
    case Rating = "Highest Rated"
}
