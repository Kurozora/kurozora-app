////
////  AnimeRelation.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
//
//public class AnimeRelation {
//    public class func parseClassName() -> String {
//        return "AnimeRelation"
//    }
//    
//    @NSManaged public var alternativeVersions: [[String:AnyObject]]
//    @NSManaged public var mangaAdaptations: [[String:AnyObject]]
//    @NSManaged public var prequels: [[String:AnyObject]]
//    @NSManaged public var sequels: [[String:AnyObject]]
//    @NSManaged public var sideStories: [[String:AnyObject]]
//    @NSManaged public var spinOffs: [[String:AnyObject]]
//    
////    public var totalRelations: Int {
////        get {
////            return dataAvailable ? allRelationsCount() : 0
////        }
////    }
//    
//    public enum RelationType: String {
//        case AlternativeVersion = "Alternative Version"
//        case Prequel = "Prequel"
//        case Sequel = "Sequel"
//        case SideStory = "SideStory"
//        case SpinOff = "SpinOff"
//    }
//    
//    public struct Relation {
//        public var animeID: Int
//        public var title: String
//        public var url: String
//        public var relationType: RelationType
//        
//        static func relationWithData(data: [String:AnyObject], relationType: RelationType) -> Relation{
//            // All this mess of types is because of Atarashii api fault..
//            var animeIdentifier: Int?
//            if let animeID = (data["anime_id"] ?? data["manga_id"]) as? Int {
//                animeIdentifier = animeID
//            }
//            if let animeID = (data["anime_id"] ?? data["manga_id"]) as? String, let animeID2 = Int(animeID) {
//                animeIdentifier = animeID2
//            }
//            return Relation(
//                animeID: animeIdentifier!,
//                title: data["title"] as! String,
//                url: data["url"] as! String,
//                relationType:relationType)
//        }
//    }
//    
//    // TODO: Improve this to don't iterate through all relations..
//    
//    func allRelationsCount() -> Int {
//        var count = 0
//        let allRelations = alternativeVersions + prequels + sequels + sideStories + spinOffs
//        for relation in allRelations {
//            if let url = relation["url"] as? String, let _ = url.range(of: "anime") {
//                count += 1
//            }
//        }
//        return count
//    }
//    
//    public func relationAtIndex(index: Int) -> Relation {
//        var allRelations: [Relation] = []
//        
//        for relation in alternativeVersions {
//            allRelations += appendRelation(relation: relation, withType: .AlternativeVersion)
//        }
//        
//        for relation in prequels {
//            allRelations += appendRelation(relation: relation, withType: .Prequel)
//        }
//        
//        for relation in sequels {
//            allRelations += appendRelation(relation: relation, withType: .Sequel)
//        }
//        
//        for relation in sideStories {
//            allRelations += appendRelation(relation: relation, withType: .SideStory)
//        }
//        
//        for relation in spinOffs {
//            allRelations += appendRelation(relation: relation, withType: .SpinOff)
//        }
//        
//        return allRelations[index]
//    }
//    
//    func appendRelation(relation: [String:AnyObject], withType relationType: RelationType) -> [Relation] {
//        var relations: [Relation] = []
//        if let url = relation["url"] as? String, let _ = url.range(of: "anime") {
//            let newRelation = Relation.relationWithData(data: relation, relationType: relationType)
//            relations.append(newRelation)
//        }
//        return relations
//    }
//}
