//
//  TVDB.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/3/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Foundation

func diagnose<T>(file: String = #file, line: Int = #line) -> T? {
    print("Testing \(file):\(line)")
    return nil
}

class TVDB : NSObject
{
    @objc(_TtCC8Binge_TV4TVDB7Episode)class Episode : NSObject, NSCoding
    {
        init?( json: [String:Any] )
        {
            guard let season_number = json["airedSeason"] as? Int,
                let episode_number = json["airedEpisodeNumber"] as? Int,
                let name = json["episodeName"] as? String,
                let first_aired = json["firstAired"] as? String,
                let overview = json["overview"] as? String
                
                else {
                    print( "Episode: couldn't parse json \(json)" )
                    return nil
            }
            
            self.season_number = season_number
            self.episode_number = episode_number
            self.name = name
            self.first_aired = first_aired
            self.overview = overview
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            let season_number = aDecoder.decodeInteger(forKey: "season_number")
            let episode_number = aDecoder.decodeInteger(forKey: "episode_number")
            guard let name = aDecoder.decodeObject(forKey: "name") as? String,
                let first_aired = aDecoder.decodeObject(forKey: "first_aired") as? String,
                let overview = aDecoder.decodeObject(forKey: "overview") as? String
                
                else {
                      print( "Episode: couldn't decode" )
                    return nil
            }
            self.episode_number = episode_number
            self.season_number = season_number
            self.name = name
            self.first_aired = first_aired
            self.overview = overview
        }
        
        func encode(with aCoder: NSCoder)
        {
            aCoder.encode(self.episode_number, forKey: "episode_number")
            aCoder.encode(self.season_number, forKey: "season_number")
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.first_aired, forKey: "first_aired")
            aCoder.encode(self.overview, forKey: "overview")
        }
        
        var episode_number : Int = -1
        var season_number : Int = -1
        var name : String = ""
        var first_aired : String = ""
        var overview : String = ""
    }
    
    @objc(_TtCC8Binge_TV4TVDB6Result)class Result : NSObject, NSCoding
    {
        init?( json: [String:Any])
        {
            guard let id = json["id"] as? Int,
                let name = json["seriesName"] as? String,
                let overview = json["overview"] as? String,
                let first_aired = json["firstAired"] as? String,
                let network = json["network"] as? String,
                let banner = json["banner"] as? String,
                let banner_url = URL( string: "https://www.thetvdb.com/banners/" + banner ),
                let status = json["status"] as? String
                else
            {
                print("result: couldn't parse json")
                return nil
            }
            
            self.id = id
            self.name = name
            self.overview = overview
            self.first_aired = first_aired
            self.network = network
            self.bannerURL = banner_url
            self.status = status
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            let id = aDecoder.decodeInteger( forKey: "id" )
            guard let name = aDecoder.decodeObject( forKey: "name" ) as? String ?? diagnose(),
                let overview = aDecoder.decodeObject( forKey: "overview" ) as? String ?? diagnose(),
                let first_aired = aDecoder.decodeObject( forKey: "first_aired" ) as? String ?? diagnose(),
                let network = aDecoder.decodeObject( forKey: "network" ) as? String ?? diagnose(),
                let banner_url = aDecoder.decodeObject( forKey: "banner_url" ) as? URL ?? diagnose(),
                let status = aDecoder.decodeObject( forKey: "status" ) as? String ?? diagnose()
                else {
                    print( "result: couldn't decode")
                    return nil
            }
            
            self.id = id
            self.name = name
            self.overview = overview
            self.first_aired = first_aired
            self.network = network
            self.bannerURL = banner_url
            self.status = status
        }
        
        func encode(with aCoder: NSCoder)
        {
            aCoder.encode(self.id, forKey: "id")
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.overview, forKey: "overview")
            aCoder.encode(self.first_aired, forKey: "first_aired")
            aCoder.encode(self.network, forKey: "network")
            aCoder.encode(self.bannerURL, forKey: "banner_url")
            aCoder.encode(self.status, forKey: "status")
        }
        
        var id : Int = -1
        var name : String = ""
        var overview : String = ""
        var first_aired : String = ""
        var network : String = ""
        var bannerURL : URL = URL(fileURLWithPath: "")
        var status : String = ""
        
        private static let THE : String = "The "
        private static let THE_LEN : Int = Result.THE.count
        
        var sortName : String {
            get {
                if( self.name.hasPrefix( Result.THE ) )
                {
                    let end = self.name.index( self.name.startIndex, offsetBy: Result.THE_LEN )
                    return self.name.replacingCharacters(in: ( self.name.startIndex ..< end ), with: "" )
                }
                return self.name
            }
        }
    }
    
    @objc(_TtCC8Binge_TV4TVDB7Series)class Series : Result
    {
        override init?( json: [String:Any])
        {
            super.init( json: json )
          
            guard let genres = json["genre"] as? [String],
                let rating = json["rating"] as? String,
                let runtimeStr = json["runtime"] as? String,
                let runtime = Int( runtimeStr ),
                let air_time = json["airsTime"] as? String,
                let imdb_id = json["imdbId"] as? String
                else {
                    print( "Series: couldn't parse json for \(json)" )
                    return nil
            }
                        
            self.genres = genres
            self.rating = rating
            self.runtime = runtime
            self.air_time = air_time
            self.imdb_id = imdb_id
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init( coder: aDecoder )
            let runtime = aDecoder.decodeInteger(forKey: "runtime" )

            guard let genres = aDecoder.decodeObject(forKey: "genres" ) as? [String] ?? diagnose(),
                let rating = aDecoder.decodeObject(forKey: "rating" ) as? String ?? diagnose(),
                let air_time = aDecoder.decodeObject(forKey: "air_time" ) as? String ?? diagnose(),
                let imdb_id = aDecoder.decodeObject(forKey: "imdb_id" ) as? String ?? diagnose(),
                let episodes = aDecoder.decodeObject( forKey: "episodes" ) as? [ TVDB.Episode]  ?? diagnose()
                else {
                       print( "Series: couldn't decode" )
                    return
            }

            self.genres = genres
            self.rating = rating
            self.runtime = runtime
            self.air_time = air_time
            self.imdb_id = imdb_id
            self.episodes = episodes
        }
        
        override func encode(with aCoder: NSCoder)
        {
            super.encode(with: aCoder )

            aCoder.encode(self.genres, forKey: "genres")
            aCoder.encode(self.rating, forKey: "rating")
            aCoder.encode(self.runtime, forKey: "runtime")
            aCoder.encode(self.air_time, forKey: "air_time")
            aCoder.encode(self.imdb_id, forKey: "imdb_id")
            aCoder.encode(self.episodes, forKey: "episodes")
        }
        
        func addEpisode( episode: TVDB.Episode )
        {
            if( episode.season_number == 0 )
            {
                return
            }
            self.episodes.append( episode )
            
            self.episodes.sort( by:{ (lhs:TVDB.Episode, rhs:TVDB.Episode) -> Bool in
                if( lhs.season_number == rhs.season_number )
                {
                    return lhs.episode_number < rhs.episode_number
                }
                return lhs.season_number < rhs.season_number
            })
        }
        
        var genres : [String] = []
        var rating : String = ""
        var runtime : Int = -1
        var air_time : String = ""
        var imdb_id : String = ""
        var episodes : [TVDB.Episode] = []
    }
    
    var apiKey: String = ""
    var userKey: String = ""
    var userName: String = ""
    var jvm:String?
    
    
    let APIScheme = "https"
    let APIHost = "api.thetvdb.com"
    let BannerHost = "www.thetvdb.com"
    
    init?( apiKey: String, userKey: String, userName: String )
    {
        self.apiKey = apiKey
        self.userKey = userKey
        self.userName = userName
    }
    
    private func buildURL( path: String, queryItems : [URLQueryItem]? = nil ) -> URL?
    {
        var c = URLComponents()
        c.scheme = self.APIScheme
        c.host = self.APIHost
        c.path = "/" + path
        c.queryItems = queryItems
        
        return c.url
    }
    
    func authenticate(callback: @escaping (Bool)-> ())
    {
        guard let url: URL = self.buildURL(path: "login")
            else {
                callback( false )
                return
        }
        
        let postString = "{\"apikey\":\"\(apiKey)\",\"username\":\"\(userName)\",\"userkey\":\"\(userKey)\"}"
        var request = URLRequest.init(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task1 = URLSession.shared.dataTask( with: request ) { ( data, response, error ) in
            if let _ = error
            {
                callback( false )
                return
            }
            guard let usableData = data
                else {
                    callback( false )
                    return
            }
            
            do {
                guard let obj = try JSONSerialization.jsonObject(with: usableData) as? [String: Any],
                    let jvm = obj["token"] as? String
                    else {
                        callback( false )
                        return
                }
                
                self.jvm = jvm
                
            } catch {
                callback( false )
                return
            }
            callback( true )
            return
        }
        task1.resume()
    }

    private func fetchData( url: URL, callback: @escaping (Data)-> () ) {
        var request = URLRequest.init( url: url )
        guard let jvm = self.jvm
            else {
                return
        }
        
        // this header mangling comes from the spec: https://api.thetvdb.com/swagger
        request.setValue( "Bearer \(jvm)", forHTTPHeaderField: "Authorization" )
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
            if error != nil {
                print(error!)
            } else {
                if let binary = data {
                    callback( binary )
                    return
                }
            }
        }
        task.resume()
    }

    private func fetchJSON( url: URL, callback: @escaping ([String:Any])-> () ) {
        self.fetchData( url: url, callback: { ( data: Data ) -> () in
            do
            {
                let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                callback( obj )
                return
            }
            catch
            {
                print("caught")
            }
        })
    }

    func search( series: String, callback: @escaping (TVDB.Result)->() )
    {
        if let url: URL = self.buildURL(path: "search/series", queryItems: [ URLQueryItem( name: "name", value: series ) ] )
        {
            self.fetchJSON( url: url, callback: { ( obj: [String:Any] ) ->() in
                if let result_array = obj["data"] as? [[String:Any]]
                {
                    for result in result_array
                    {
                        if let r = TVDB.Result( json: result )
                        {
                              callback( r )
                        }
                    }
                }
                else
                {
                    //    print( "Search: could not parse: \(obj)")
                }
            })
        }
        else
        {
        }
    }
    
    
    func series( result:TVDB.Result, callback: @escaping ( TVDB.Series )->() )
    {
        if let url:URL = self.buildURL(path: "series/\(result.id)" )
        {
            self.fetchJSON( url: url, callback: { ( obj: [String:Any] ) ->() in
                if let s = obj["data"] as? [String:Any]
                {
                    if let series = Series(json: s )
                    {
                        series.bannerURL = result.bannerURL
                        
                        if let episodesURL : URL = self.buildURL(path: "series/\(result.id)/episodes" )
                        {
                            self.fetchJSON( url: episodesURL, callback: { ( obj: [String:Any] ) ->() in
                                if let ep_array = obj["data"] as? [[String:Any]]
                                {
                                    for ep in ep_array
                                    {
                                        if let e = Episode( json: ep )
                                        {
                                            series.addEpisode(episode: e )
                                        }
                                    }
                                    callback( series )
                                }
                                else
                                {
                                    //     print("couldn't parse Episode json: \(obj)")
                                }
                            })
                        }
                    }
                }
                else
                {
                    //    print("couldn't parse  Series json: \(obj)")
                }
            })
        }
    }
}
