//
//  EZTV.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 11/19/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa
import SwiftSoup

extension String {
    func removingCharacters(inCharacterSet forbiddenCharacters:CharacterSet) -> String
    {
        var filteredString = self
        while true {
            if let forbiddenCharRange = filteredString.rangeOfCharacter(from: forbiddenCharacters)  {
                filteredString.removeSubrange(forbiddenCharRange)
            }
            else {
                break
            }
        }
        
        return filteredString
    }
}

class EZTV: NSObject {
    
    static let RESOLUTION_480P = "480p"
    static let RESOLUTION_720P = "720p"
    static let RESOLUTION_1080P = "1080p"
    static let RESOLUTION_UNSPECIFIED = ""
    
    class Result : NSObject {
        
        init?( title:String,
               magnetLink:String,
               downloadLink:String,
               size:String,
               seeds:String)
        {
            guard let magnetURL = URL( string:magnetLink),
                let downloadURL = URL( string:downloadLink),
                let seeds = Int(seeds)
                else {
                    return nil
            }
            self.title = title
            self.magnetURL = magnetURL
            self.downloadURL = downloadURL
            self.size = size
            self.seeds = seeds
        }
        
        let title : String
        let magnetURL : URL
        let downloadURL : URL
        let size : String
        let seeds : Int
    }
    
    static let API_SCHEME = "https"
    static let HOST = "eztv.ag"
    
    var urlComponents : URLComponents
    
    init?( host: String = EZTV.HOST)
    {
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = EZTV.API_SCHEME
        self.urlComponents.host = EZTV.HOST
        self.urlComponents.path = "/search/"
    }
    
    private func fetchData( url: URL, callback: @escaping ( String? )-> () ) {
        var request = URLRequest.init( url: url )
       
        
        // this header mangling comes from the spec: https://api.thetvdb.com/swagger
        //request.setValue( "Bearer \(jvm)", forHTTPHeaderField: "Authorization" )
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
            if error != nil {
                callback( nil )
                return
            } else {
                guard let encoded = data
                    else {
                        callback( nil )
                        return
                }
                callback( String( data: encoded, encoding: String.Encoding.utf8 ) )
            }
        }
        task.resume()
    }
    
  // //*[@id="header_holder"]/table[5]/tbody/tr[3]
    
    func search( series: String,
                 seasonNumber: Int, episodeNumber: Int,
                 resolution: String = EZTV.RESOLUTION_UNSPECIFIED,
                 callback: @escaping ([EZTV.Result]?)->() )
    {
        let query = String( format: "\(series) S%02dE%02d \(resolution)", seasonNumber, episodeNumber )
        print( query )
        self.search( query:query, callback: callback)
    }
    
    func search( series: String,
                 resolution: String = EZTV.RESOLUTION_UNSPECIFIED,
                 callback: @escaping ([EZTV.Result]?)->() )
    {
        self.search( query:"\(series) \(resolution)", callback: callback)
    }
    
    private func search(  query:String, callback: @escaping ([EZTV.Result]?)->() )
    {
        guard var url = self.urlComponents.url
            else {
                callback( nil )
                return
        }
        
        let strippedQuery = query.removingCharacters(inCharacterSet: CharacterSet.alphanumerics.union(CharacterSet.whitespaces).inverted).trimmingCharacters(in: CharacterSet.whitespaces)
       
        url = url.appendingPathComponent( strippedQuery )
        print( url )

        self.fetchData(url: url) { ( html:String?) in
            guard let html = html,
                let doc = try? SwiftSoup.parse( html ),
                let shows = try? doc.select("#header_holder > table:nth-child(15) > tbody > tr")
                else {
                    callback(nil)
                    return
            }
            
            var rval : [EZTV.Result] = []
            for show in shows
            {
                guard let name = try? show.attr("name"),
                    let columnElements = try? show.select("td")
                    else {
                        continue
                }
                if( name == "hover" )
                {
                    let cols = columnElements.array()
                    if( cols.count == 7 )
                    {
                        guard let title = try? cols[1].text(),
                            let links = try? cols[2].select("a"),
                            let firstElem = links.first(),
                            let lastElem = links.last(),
                            let magnetLink = try? firstElem.attr("href"),
                            let downloadLink = try? lastElem.attr("href"),
                            let size = try? cols[3].text(),
                            let seeds = try? cols[5].text()
                            else {
                                continue
                        }
                        
                      
                        if let result = EZTV.Result(title: title, magnetLink: magnetLink, downloadLink: downloadLink, size: size, seeds: seeds)
                        {
                            rval.append(result)
                        }
                    }
                }
            }
            callback( rval )
        }
    }
}

