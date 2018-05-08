//
//  AnimeController.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

public class AiringController {
    
    public typealias AiringStatusType = (string: String, status: AiringStatus)
    
    public enum AiringStatus {
        case Behind
        case Future
    }
    
    public class func airingStatusForFirstAired(firstAired: Date, currentEpisode: Int, totalEpisodes: Int, airingStatus: AnimeStatus) -> AiringStatusType {
        
        // TODO: Clean this mess
        let nextEpisodeToWatchDate = firstAired.dateByAddingWeeks(weeks: currentEpisode)
        let (nextAirEpisodeDate, _) = AiringController.nextEpisodeToAirForStartDate(startDate: firstAired)
        
        if airingStatus != AnimeStatus.FinishedAiring && nextEpisodeToWatchDate.compare(Date()) == .orderedDescending {
            // Future episode
            print("Future Episode")
            
            let etaString = nextAirEpisodeDate.etaStringForDate(short: true)
            return (etaString, .Future)
        } else {
            
            print("Past Episode")
            var episodesBehind = 0
            var newDate = nextEpisodeToWatchDate
            
            var lastAiredEpisode: Date
            
            if airingStatus == AnimeStatus.FinishedAiring {
                lastAiredEpisode = firstAired.dateByAddingWeeks(weeks: totalEpisodes - 1)
            } else {
                lastAiredEpisode = nextAirEpisodeDate
            }
            
            while newDate.compare(lastAiredEpisode) == .orderedAscending {
                episodesBehind += 1
                newDate = nextEpisodeToWatchDate.dateByAddingWeeks(weeks: episodesBehind)
            }
            
            return ("\(episodesBehind + 1) behind", .Behind)
        }
    }
    
    public class func nextEpisodeToAirForStartDate(startDate: Date) -> (nextDate: Date, nextEpisode: Int) {
        
        let now = Date()
        
        if startDate.compare(now as Date) == ComparisonResult.orderedDescending {
            return (startDate, 1)
        }
        
        let cal = Calendar.current
        let unit = Set<Calendar.Component>([.weekOfYear])
        var components = cal.dateComponents(unit, from: startDate, to: now)
        components.weekOfYear = components.weekOfYear!+1
        
        let nextEpisodeDate: Date = cal.date(byAdding: components, to: startDate)!
        
        return (nextEpisodeDate, components.weekOfYear!+1)
    }
}

extension Date {
    func dateByAddingWeeks(weeks: Int) -> Date {
        return addingTimeInterval(Double(weeks * 7 * 24 * 60 * 60))
    }
}
