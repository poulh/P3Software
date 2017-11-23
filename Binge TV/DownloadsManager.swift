//
//  DownloadsManager.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/7/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class DownloadsManager: NSObject {
    
    enum EpisodeStatus
    {
        case upcoming,missing, downloading, downloaded, catalogued, error
    }
    
    class EpisodeFile : NSObject
    {
        static var regexes : [String] = []
        static var downloadComplete : Float = 1.0
        static var downloadNotStarted : Float = 0.0
        static var videoExtensions : Set<String> = []
        static var subtitleExtensions : Set<String> = []
       // static var fileExtensions : Set<String> = []
        
        init?( url:URL, withPercent: Float )
        {
           // print("EpisodeFile: \(url)")
            if( withPercent < EpisodeFile.downloadNotStarted || withPercent > EpisodeFile.downloadComplete )
            {
              //  print("bad percent")
                return nil
            }
            
            if( EpisodeFile.videoExtensions.contains( url.pathExtension ) == false && EpisodeFile.subtitleExtensions.contains( url.pathExtension ) == false )
            {
               // print( "bad extension \(url.pathExtension)")
                return nil
            }
            
            guard let path = url.pathComponents.last
                else {
                 //   print("no path")
                    return nil
            }
            
           // print("path: \(path)")
            for pattern in EpisodeFile.regexes
            {
               // print("pattern: \(pattern)")
                guard let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    else {
                      //  print("couldn't make regex")
                        return nil
                }
                
                let matches = regex.matches(in: path, options: [], range: NSRange(location: 0, length: path.count) )
        
                for m in matches
                {
                    let match = m.range(at: 0)
                    let titleRange = path.startIndex ..< path.index(path.startIndex, offsetBy: match.location)
                    let title = path[ titleRange ].replacingOccurrences(of: ".", with: " ").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines ).capitalized
                    
                    let seasonMatch = m.range(at: 1)
                    let seasonStart = path.index(path.startIndex, offsetBy: seasonMatch.location )
                    let seasonRange = seasonStart ..< path.index(seasonStart, offsetBy: seasonMatch.length)
                    
                    guard let season_number = Int( path[ seasonRange ] )
                        else {
                         //   print("bad season")
                            return nil
                    }
                    
                    let episodeMatch = m.range(at: 2)
                    let episodeStart = path.index(path.startIndex, offsetBy: episodeMatch.location )
                    let episodeRange = episodeStart ..< path.index( episodeStart, offsetBy: episodeMatch.length )
                    guard let episode_number = Int( path[ episodeRange ] )
                        else {
                     //       print( "bad episode")
                            return nil
                    }
                    
                    self.seasonNumber = season_number
                    self.episodeNumber = episode_number
                    self.series = title
                    self.url = url
                    self.percentDone = withPercent

                    return
                }
            }

            return nil
        }

        func matches( series: TVDB.Series, episode: TVDB.Episode ) -> Bool
        {
            if( self.series == series.name.capitalized &&
                self.seasonNumber == episode.season_number &&
                self.episodeNumber == episode.episode_number )
            {
                return true
            }
            return false
        }
        
        let series : String
        let seasonNumber : Int
        let episodeNumber : Int
        let percentDone : Float
        let url : URL
        
        var path : String {
            get {
                return self.url.relativePath
            }
        }
        var ext : String {
            get {
                return self.url.pathExtension
            }
        }
        
        func seriesDirectoryURL( inDir: URL ) -> URL
        {
            return inDir.appendingPathComponent( self.series )
        }
        
        func seasonDirectoryURL( inDir: URL ) -> URL
        {
            let series = self.seriesDirectoryURL( inDir: inDir )
            return series.appendingPathComponent( String( format: "Season %02d", seasonNumber ) )
        }
        
        var prettyFileName : String {
            return String(format: "\(self.series) S%02dE%02d.\(self.ext)", seasonNumber, episodeNumber)
        }
        
        func episodeURL( inDir: URL ) -> URL
        {
            let season = self.seasonDirectoryURL( inDir: inDir )
            return season.appendingPathComponent( self.prettyFileName )
        }
    }
    
    func getEpisodeIcon( status: EpisodeStatus ) -> String
    {
        switch( status )
        {
        case EpisodeStatus.error:
           return NSImage.Name.statusUnavailable.rawValue
        case EpisodeStatus.missing:
           return NSImage.Name.statusUnavailable.rawValue
        case EpisodeStatus.downloading:
            return NSImage.Name.statusPartiallyAvailable.rawValue
        case EpisodeStatus.downloaded:
            return NSImage.Name.statusPartiallyAvailable.rawValue
        case EpisodeStatus.catalogued:
            return NSImage.Name.statusAvailable.rawValue
        case EpisodeStatus.upcoming:
            return NSImage.Name.statusNone.rawValue
        }
    }
    
    func seriesDirectoryURL( series: TVDB.Series ) -> URL
    {
        return self.mediaDirectoryURL.appendingPathComponent(series.name)
    }
    
    func episodeDirectoryURL( series: TVDB.Series, episode: TVDB.Episode ) -> URL
    {
        return self.seriesDirectoryURL(series: series).appendingPathComponent(String(format: "Season %02d", episode.season_number))
    }
    
    func episodeFileName( series: TVDB.Series, episode: TVDB.Episode, ext: String ) -> String
    {
        return String(format: "\(series.name) S%02dE%02d.\(ext)", episode.season_number, episode.episode_number)
    }
    
    func directoryExists( url: URL ) -> Bool
    {
        var isDir : ObjCBool = false
        self.fileManager.fileExists(atPath: url.relativePath, isDirectory: &isDir )
        return isDir.boolValue
    }
    
    func addSeries( series: TVDB.Series ) -> Bool
    {
        let url = seriesDirectoryURL(series: series )
        if( self.directoryExists(url: url ) )
        {
            // do nothing. we're done
        }
        else
        {
            do
            {
                try self.fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            }
            catch
            {
                return false
            }
        }
        return true
    }
    
    func getEpisodeFileIfCatalogued( series: TVDB.Series, episode: TVDB.Episode, ext: String? = nil ) -> EpisodeFile?
    {
        let episodeDirectoryURL = self.episodeDirectoryURL(series: series, episode: episode)
        let enumerator = fileManager.enumerator(at: episodeDirectoryURL , includingPropertiesForKeys: nil)
        
        while let url = enumerator?.nextObject() as? URL
        {
            if let episodeFile = EpisodeFile(url: url, withPercent: 1.0 )
            {
                if( episodeFile.matches(series: series, episode: episode ) )
                {
                    return episodeFile
                }
            }
        }
        return nil
    }
    
    func getEpisodeFileIfDownloaded( series: TVDB.Series, episode: TVDB.Episode ) -> EpisodeFile?
    {
        for episodeFile in self.downloadedEpisodeFiles
        {
            if( episodeFile.matches( series: series, episode: episode ) )
            {
                return episodeFile
            }
        }
        return nil
    }
    
    func episodeStatus( series: TVDB.Series, episode: TVDB.Episode ) -> ( EpisodeStatus, Float )
    {
        
        if let _ = self.getEpisodeFileIfCatalogued( series: series, episode: episode )
        {
            return ( EpisodeStatus.catalogued, 1.0 )
        }

        if let _ = self.getEpisodeFileIfDownloaded( series: series, episode: episode )
        {
            return ( EpisodeStatus.downloaded, 1.0 )
        }
    
        for downloadingEpisodeFile in self.downloadingEpisodeFiles
        {
            if( downloadingEpisodeFile.matches( series: series, episode: episode ) )
            {
                return ( EpisodeStatus.downloading, downloadingEpisodeFile.percentDone )
            }
        }
        
        return ( EpisodeStatus.missing, 0.0 )
    }
    
    func updateDownloadDirectory()
    {
        guard let downloadDirectoryURL = self.downloadDirectoryURL
            else {
                print( "no download directory")
                return
        }
        
        self.downloadedEpisodeFiles = []
        let enumerator  = fileManager.enumerator(at: downloadDirectoryURL , includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL
        {
            if let episodeFile = EpisodeFile( url: url, withPercent: EpisodeFile.downloadComplete )
            {
                self.downloadedEpisodeFiles.append( episodeFile )
            }
        }
    }
    
    func updateTorrents( removeCompleted: Bool, callback: @escaping ( Bool, Int)-> () )
    {
        guard let transmission = self.transmission
            else {
                callback( false, 0 )
                return
        }
        
        transmission.getTorrents(callback:{ ( torrents: [Transmission.Torrent] ) -> () in
            var ids :Set<Int> = []
            var toRemoveEpisodeFiles : [ EpisodeFile ] = []
            self.downloadingEpisodeFiles = []

            for torrent in torrents
            {
                for torrentFile in torrent.torrentFiles
                {
                    if let episodeFile = EpisodeFile( url: URL(fileURLWithPath: torrentFile.name ), withPercent: torrent.percentDone)
                    {
                        if( torrentFile.name.components(separatedBy: "/").count <= 2 )
                        {
                            if( torrent.done && removeCompleted )
                            {
                                ids.insert(torrent.id)
                                toRemoveEpisodeFiles.append( episodeFile )
                            }
                            else
                            {
                                self.downloadingEpisodeFiles.append( episodeFile )
                            }
                        }
                    }
                }
            }
            
            if( ids.isEmpty || !removeCompleted )
            {
                callback( true, 0 )
                return
            }

            transmission.removeTorrents(ids: ids.map({ (value:Int) -> Int in
                return value
            }), callback: { ( success: Bool) in
                if( success )
                {
                    // we're done
                    callback( success, ids.count )
                }
                else
                {
                    // shouldn't get here but assume the removal didn't work
                    self.downloadingEpisodeFiles += toRemoveEpisodeFiles
                    callback( success, 0 )
                }
            })
        })
    }
    
    func catalogDownloads( series: [TVDB.Series] )
    {
        //todo: this function needs some work... very inefficient
        self.updateDownloadDirectory()
        for episodeFile in self.downloadedEpisodeFiles
        {
            for s in series
            {
                for e in s.episodes
                {
                    if( episodeFile.matches( series: s, episode: e ) )
                    {
                        do
                        {
                            try self.fileManager.createDirectory(at: episodeFile.seasonDirectoryURL(inDir: self.mediaDirectoryURL ), withIntermediateDirectories: true )
                            try self.fileManager.moveItem( at: episodeFile.url, to: episodeFile.episodeURL(inDir: self.mediaDirectoryURL) )
                        }
                        catch
                        {
                            print("could not create directory or move file when cataloguing")
                        }
                    }
                }
            }
        }
        self.updateDownloadDirectory()
    }
    
    init?( mediaDirectoryURL: URL, downloadRegexes: Array<String>, videoExtensions: Array<String>, subtitleExtensions: Array<String> )
    {
        self.mediaDirectoryURL = mediaDirectoryURL
        do
        {
            try fileManager.createDirectory(at: self.mediaDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            return nil
        }
        
        for ext in videoExtensions
        {
            EpisodeFile.videoExtensions.insert( ext )
        }
        
        for ext in subtitleExtensions
        {
            EpisodeFile.subtitleExtensions.insert( ext )
        }
        
        EpisodeFile.regexes = downloadRegexes
        
        if( !self.fileManager.fileExists(atPath: self.mediaDirectoryURL.relativePath ) )
        {
            do
            {
                try self.fileManager.createDirectory(at: self.mediaDirectoryURL, withIntermediateDirectories: true )
            }
            catch
            {
                return nil
            }
        }
    }
    
    func setTransmission( transmission: Transmission )
    {
        self.transmission = transmission
    }
    
    func scheduleTransmissionTimer( callback: @escaping (Int)-> ())
    {
        if let transmissionTimer = self.transmissionTimer
        {
            transmissionTimer.invalidate()
        }
        
        self.transmissionTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer:Timer) in

            self.updateTorrents( removeCompleted: true ) { (success:Bool, numRemoved:Int) in
                if( success )
                {
                    DispatchQueue.main.async() {
                        callback(numRemoved)
                    }
                }
            }
        }
    }
    
    func getDownloads() -> [ EpisodeFile ]
    {
        return self.downloadingEpisodeFiles + self.downloadedEpisodeFiles
    }
    
    func setDownloadsDirectory( path: String )
    {
        self.downloadDirectoryURL = URL(fileURLWithPath: path )
    }
    
    let fileManager = FileManager.default
    
    var transmission : Transmission?
    var downloadingEpisodeFiles : [ EpisodeFile ] = []
    var transmissionTimer :Timer?
    
    var downloadDirectoryURL : URL?
    var downloadedEpisodeFiles : [ EpisodeFile ] = []
    
    let mediaDirectoryURL : URL
    
    
}
