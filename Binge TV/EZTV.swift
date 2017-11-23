//
//  EZTV.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 11/19/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class EZTV: NSObject {
    
    class Result : NSObject {
        
    }
    
    static let API_SCHEME = "https"
    static let HOST = "eztv.ag"
    
    var urlComponents : URLComponents
    
    init?( host: String = EZTV.HOST)
    {
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = EZTV.API_SCHEME
        self.urlComponents.host = EZTV.HOST
        
    }
    
    private func fetchData( url: URL, callback: @escaping (Data)-> () ) {
        var request = URLRequest.init( url: url )
       
        
        // this header mangling comes from the spec: https://api.thetvdb.com/swagger
        //request.setValue( "Bearer \(jvm)", forHTTPHeaderField: "Authorization" )
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
            if error != nil {
                print(error!)
            } else {
                if let binary = data {
                    let s = String(data: binary, encoding: String.Encoding.utf8)
                    print( s )
                    callback( binary )
                    return
                }
            }
        }
        task.resume()
    }
    
  // //*[@id="header_holder"]/table[5]/tbody/tr[3]
    
    
    
    func search(  callback: @escaping (EZTV.Result)->() )
    {
        let u = URL(string: "https://www.1377x.to/srch?search=the+deuce+720p")!
        self.urlComponents.path = "/search/The Walking Dead"
        if let url = self.urlComponents.url
        {
            if let xmlParser = XMLParser(contentsOf: u)
            {
                xmlParser.delegate = self
                xmlParser.parse()
            }
        }
        else
        {
        }
    }

}

extension EZTV : XMLParserDelegate
{
    func parserDidStartDocument(_ parser: XMLParser) {
        print("begin")
     
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print( "error: " + parseError.localizedDescription)
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        print( "parse " + elementName)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print( "char " + string )
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print( "end " + elementName)
    }
    
    
}
