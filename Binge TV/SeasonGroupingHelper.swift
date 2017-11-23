//
//  SeriesGroupingHelper.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/9/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class SeasonGroupingHelper: NSObject {

    var seasonCount = -1
    var nextIndex = 0
    var episodes : [ TVDB.Episode? ] = []
    var groupingSeason : [ Int: Int ] = [0:0]
    
    
    func reset()
    {
        self.seasonCount = -1
        self.nextIndex = 0
        self.episodes = []
        self.groupingSeason = [:]
    }
    
    func getEpisode( series:TVDB.Series, row:Int ) -> TVDB.Episode?
    {
        while( row >= self.episodes.count )
        {
            if( nextIndex < series.episodes.count )
            {
                let episode = series.episodes[ nextIndex ]
                while( episode.season_number > self.seasonCount )
                {
                    let groupIndex = self.episodes.count // the index we are about to append to
                    self.episodes.append( nil )
                    self.seasonCount += 1
                    self.groupingSeason[ groupIndex ] = seasonCount
                }
                self.episodes.append( episode )
                nextIndex += 1
            }
            else
            {
                return nil
            }
        }
        
        return self.episodes[ row ]
    }
    
    func numRows( series:TVDB.Series ) -> Int
    {
        if let last_episode = series.episodes.last
        {
            return last_episode.season_number + series.episodes.count + 1
        }
        return 0
    }
}
