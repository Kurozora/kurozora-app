//
//  LinkScrapper.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 18/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Bolts

public class LinkData {
//
//    public var url: String?
//    public var type: String?
//    public var title: String?
//    public var description: String?
//    public var imageUrls: [String] = []
//    public var updatedTime: String?
//    public var siteName: String?
//
//    class func mapDataWithDictionary(dictionary: [String: AnyObject]) -> LinkData {
//        let linkData = LinkData()
//
//        if let url = dictionary["url"] as? String {
//            linkData.url = url
//        }
//        if let type = dictionary["type"] as? String {
//            linkData.type = type
//        }
//        if let url = dictionary["title"] as? String {
//            linkData.title = url
//        }
//        if let description = dictionary["description"] as? String {
//            linkData.description = description
//        }
//        if let imageUrls = dictionary["images"] as? [String] {
//            linkData.imageUrls = imageUrls
//        }
//        if let updatedTime = dictionary["updatedTime"] as? String {
//            linkData.updatedTime = updatedTime
//        }
//        if let siteName = dictionary["siteName"] as? String {
//            linkData.siteName = siteName
//        }
//        return linkData
//    }
//
//    public func toDictionary() -> [String: Any] {
//        return [
//            "url": url ?? "",
//            "type": type ?? "",
//            "title": title ?? "",
//            "description": description ?? "",
//            "images": imageUrls,
//            "updatedTime": updatedTime ?? "",
//            "siteName": siteName ?? ""
//        ]
//    }
//}
//
//public class LinkScrapper {
//
//    var viewController: UIViewController
//
//    public init(viewController: UIViewController) {
//        self.viewController = viewController
//    }
//
//    public func findInformationForLink(url: NSURL) -> BFTask {
//
//        let completion = BFTaskCompletionSource()
//
//        viewController.webScraper.scrape(url.absoluteString) { (hpple) -> Void in
//            if hpple == nil {
//                print("hpple is nil")
//                completion.setError(NSError(domain: "kurozora.findInformationForLink", code: 0, userInfo: nil))
//                return
//            }
//
//            let results = hpple.searchWithXPathQuery("//meta") as! [TFHppleElement]
//            let data = LinkData()
//
//            for result in results {
//                print(result.raw)
//                if let name = result.objectForKey("name") {
//                    switch name {
//                    case "title":
//                        data.title = result.objectForKey("content")
//                    case "description":
//                        data.description = result.objectForKey("content")
//                    default:
//                        continue
//                    }
//                }
//
//                guard let property = result.objectForKey("property") else {
//                    continue
//                }
//
//                switch property {
//                case "og:title":
//                    data.title = result.objectForKey("content")
//                case "og:url":
//                    data.url = result.objectForKey("content")
//                case "og:description":
//                    data.description = result.objectForKey("content")
//                case "og:image":
//                    data.imageUrls.append(result.objectForKey("content"))
//                case "og:site_name":
//                    data.siteName = result.objectForKey("content")
//                case "og:updated_time":
//                    data.updatedTime = result.objectForKey("content")
//                case "og:type":
//                    data.type = result.objectForKey("content")
//                default:
//                    continue
//                }
//            }
//
//            if data.title == nil {
//                let results = hpple.searchWithXPathQuery("//title") as! [TFHppleElement]
//
//                for result in results {
//                    if let title = result.nthChild(0)?.content {
//                        data.title = title
//                    }
//                }
//            }
//
//            if data.url == nil {
//                data.url = url.absoluteString
//            }
//
//            if data.imageUrls.count == 0 {
//                let results = hpple.searchWithXPathQuery("//img") as! [TFHppleElement]
//
//                for result in results {
//                    if let widthString = result.objectForKey("width"),
//                        let widthInt = Int(widthString),
//                        var imageUrl = result.objectForKey("src"), widthInt >= 200 {
//                        if imageUrl.hasPrefix("//") {
//                            imageUrl = "http:" + imageUrl
//                        }
//                        if imageUrl.hasPrefix("/") {
//                            imageUrl = url.host! + imageUrl
//                        }
//
//                        if let theURL = NSURL(string: imageUrl) {
//                            data.imageUrls.append(theURL.absoluteString)
//                        }
//                    }
//                }
//            }
//
//            completion.setResult(data)
//        }
//
//        return completion.task
//    }
}
