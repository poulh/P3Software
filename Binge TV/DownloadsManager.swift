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
            get {
                return String(format: "\(self.series) S%02dE%02d.\(self.ext)", seasonNumber, episodeNumber)
            }
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
    
    private func seriesDirectoryURL( series: TVDB.Series ) -> URL
    {
        return self.mediaDirectoryURL.appendingPathComponent(series.name)
    }
    
    private func episodeDirectoryURL( series: TVDB.Series, episode: TVDB.Episode ) -> URL
    {
        return self.seriesDirectoryURL(series: series).appendingPathComponent(String(format: "Season %02d", episode.season_number))
    }
    
    private func episodeFileName( series: TVDB.Series, episode: TVDB.Episode, ext: String ) -> String
    {
        return String(format: "\(series.name) S%02dE%02d.\(ext)", episode.season_number, episode.episode_number)
    }
    
    private func directoryExists( url: URL ) -> Bool
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
        //only once we create the dir do we add it to the member variable
        self.tvdbSeries.append( series )
        
        self.sortSeries()
        self.saveTVDBSeriesData()
        self.resetSearchIndexes()
        self.catalogDownloads()

        return true
    }
    
    func removeSeries( at: Int )
    {
        if( at < self.tvdbSeries.count )
        {
            self.tvdbSeries.remove(at: at )
            self.saveTVDBSeriesData()
            self.resetSearchIndexes()
        }
    }
    
    private func saveTVDBSeriesData()
    {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.tvdbSeries )
        self.defaults.set( data, forKey: TVDB_SERIES )
    }
    
    private func getEpisodeFileIfCatalogued( series: TVDB.Series, episode: TVDB.Episode, ext: String? = nil ) -> EpisodeFile?
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
    
    private func getEpisodeFileIfDownloaded( series: TVDB.Series, episode: TVDB.Episode ) -> EpisodeFile?
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
    
    private func updateDownloadDirectory()
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
    
    func catalogDownloads()
    {
        //todo: this function needs some work... very inefficient
        self.updateDownloadDirectory()
        for episodeFile in self.downloadedEpisodeFiles
        {
            for s in self.tvdbSeries
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
    
    init?( defaults: UserDefaults)
    {
        guard let actualMediaDirectory = defaults.url(forKey: MEDIA_ACTUAL_DIRECTORY )
            else {
                return nil
        }
        self.mediaDirectoryURL = actualMediaDirectory
 
        do
        {
            try fileManager.createDirectory(at: self.mediaDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            return nil
        }
        
        guard let video_extensions = defaults.array(forKey: VIDEO_EXTENSIONS ) as? [String],
            let subtitle_extensions = defaults.array( forKey: SUBTITLE_EXTENSIONS ) as? [String],
            let filename_regex = defaults.array(forKey: FILENAME_REGEX ) as? [String]
            else {
                return nil
        }
        
        self.defaults = defaults
        
        if let seriesData = UserDefaults.standard.object(forKey: TVDB_SERIES) as? Data,
            let series = NSKeyedUnarchiver.unarchiveObject(with: seriesData) as? [TVDB.Series]
        {
            self.tvdbSeries = series
        }
        
        for ext in video_extensions
        {
            EpisodeFile.videoExtensions.insert( ext )
        }
        
        for ext in subtitle_extensions
        {
            EpisodeFile.subtitleExtensions.insert( ext )
        }
        
        EpisodeFile.regexes = filename_regex
        
        do
        {
            try self.fileManager.createDirectory(at: self.mediaDirectoryURL, withIntermediateDirectories: true )
        }
        catch
        {
            print("already created")
            return nil
        }
        
       
        
        self.transmission = Transmission( defaults: defaults )
    }
    
    deinit
    {
        self.stopDownloadStatusTimer()
        self.stopSearchForMissingEpisodesTimer()
    }
    
    private func sortSeries()
    {
        self.tvdbSeries.sort( by:{ (lhs:TVDB.Series, rhs:TVDB.Series) -> Bool in
            return lhs.sortName < rhs.sortName
        })
    }
    
    func initDownloader( callback: @escaping (Bool) -> () )
    {
        guard let transmission = self.transmission
            else {
                return
        }

        transmission.authenticate( callback: { (authenticated: Bool ) -> () in
            if( authenticated )
            {
                print( "transmission authenticated")
                if let transmission = self.transmission
                {
                    transmission.getSession( callback: { (session: Transmission.Session ) -> () in
                        print( "got transmission session")
                        self.setDownloadsDirectory(path: session.download_dir)
                    })
                }
            }
            else
            {
                print( "couldn't auth transmission")
            }
            callback( authenticated )
        })
    }

    func stopDownloadStatusTimer()
    {
        if let transmissionTimer = self.transmissionTimer
        {
            print("invalidate timer")
            transmissionTimer.invalidate()
        }
    }
    
    private func resetSearchIndexes()
    {
        let seriesCount = self.tvdbSeries.count
        if( seriesCount == 0 )
        {
            self.downloadSeriesIndex = 0
            self.downloadEpisodeIndex = 0
            return
        }
        
        self.downloadSeriesIndex = min( self.downloadSeriesIndex, self.tvdbSeries.count - 1 )
        
        let series = self.tvdbSeries[ self.downloadSeriesIndex ]
        self.downloadEpisodeIndex = max( 0, min( self.downloadEpisodeIndex, series.episodes.count - 1 ) )
    }
    
    func searchForMissingEpisodes()
    {
        guard let transmission = self.transmission
            else {
                return
        }
        
        if( self.tvdbSeries.count == 0 )
        {
            return
        }
        
        let series = self.tvdbSeries[ self.downloadSeriesIndex ]
        
        
        let episode = series.episodes[ self.downloadEpisodeIndex ]
        
        self.downloadEpisodeIndex += 1
        if( self.downloadEpisodeIndex >= series.episodes.count )
        {
            self.downloadSeriesIndex = ( self.downloadSeriesIndex + 1 ) % self.tvdbSeries.count
            self.downloadEpisodeIndex = 0
        }
        
        let (status, _ ) = self.episodeStatus(series: series, episode: episode)
        
        if( status == DownloadsManager.EpisodeStatus.missing )
        {
            self.eztv.search(series: series.name,
                             seasonNumber: episode.season_number,
                             episodeNumber: episode.episode_number,
                             resolution: EZTV.RESOLUTION_720P,
                             callback: { ( result:EZTV.Result? ) in
                                if let result = result
                                {
                                    print( "----------" )
                                    print( result.title )
                                    print( result.downloadURL )
                                   // print( result.magnetURL )
                                    transmission.addTorrent( url: result.downloadURL )
                                    
                                }
            })
        }

    }
    
    func startSearchForMissingEpisodesTimer()
    {
        if( self.transmission == nil )
        {
            return
        }
        
        self.downloadMissingTimer = Timer(timeInterval: 1, repeats: true) { (timer:Timer) in
            self.searchForMissingEpisodes()
        }
        
        if let timer = self.downloadMissingTimer
        {
            RunLoop.main.add( timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    func stopSearchForMissingEpisodesTimer()
    {
        if let timer = self.downloadMissingTimer
        {
            print("invalidate search for missing timer")
            timer.invalidate()
        }
    }
    
    func startDownloadStatusTimer( callback: @escaping (Int)-> ())
    {
        if( self.transmission == nil )
        {
            return
        }

        self.stopDownloadStatusTimer()
        
        self.transmissionTimer = Timer(timeInterval: 5, repeats: true) { (timer:Timer) in
            print( Date() )
            self.updateTorrents( removeCompleted: true ) { (success:Bool, numRemoved:Int) in
                if( success )
                {
                    if( numRemoved > 0 )
                    {
                        self.catalogDownloads()
                    }
                    callback( numRemoved )
                }
            }
        }

        if let timer = self.transmissionTimer
        {
            timer.fire()
            RunLoop.main.add( timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    var episodeFileDownloads : [ EpisodeFile ]
    {
        get {
            return self.downloadingEpisodeFiles + self.downloadedEpisodeFiles
        }
    }
    
    private func setDownloadsDirectory( path: String )
    {
        self.downloadDirectoryURL = URL(fileURLWithPath: path )
    }
    
    var series : [ TVDB.Series ] {
        get {
            return self.tvdbSeries
        }
    }
    
    private let fileManager = FileManager.default
    
    private var transmission : Transmission?
    private var eztv : EZTV = EZTV()
    private var tvdbSeries : [TVDB.Series] = []
    private var downloadSeriesIndex = 0
    private var downloadEpisodeIndex = 0
    private var downloadingEpisodeFiles : [ EpisodeFile ] = []
    private var transmissionTimer : Timer?
    private var downloadMissingTimer : Timer?
    private let defaults : UserDefaults
    
    var downloadDirectoryURL : URL?
    private var downloadedEpisodeFiles : [ EpisodeFile ] = []
    
    let mediaDirectoryURL : URL
}
