//
//  Transmission.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/10/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class Transmission: NSObject {
    
    // https://trac.transmissionbt.com/browser/branches/1.7x/doc/rpc-spec.txt
    class Session: NSObject
    {
        init?( json: [String:Any] )
        {
            guard let alt_speed_down = json["alt-speed-down"] as? Int ?? diagnose(),
                let alt_speed_enabled = json["alt-speed-enabled"] as? Bool ?? diagnose(),
                let alt_speed_time_begin = json["alt-speed-time-begin"] as? Int  ?? diagnose(),
                let alt_speed_time_enabled = json["alt-speed-time-enabled"] as? Bool  ?? diagnose(),
                let alt_speed_time_end = json["alt-speed-time-end"] as? Int  ?? diagnose(),
                let alt_speed_time_day = json["alt-speed-time-day"] as? Int  ?? diagnose(),
                let alt_speed_up = json["alt-speed-up"] as? Int  ?? diagnose(),
                let blocklist_enabled = json["blocklist-enabled"] as? Bool  ?? diagnose(),
                let blocklist_size = json["blocklist-size"] as? Int  ?? diagnose(),
                let blocklist_url = json["blocklist-url"] as? String ?? diagnose(),
                let config_dir = json["config-dir"] as? String ?? diagnose(),
                let download_dir = json["download-dir"] as? String ?? diagnose(),
                let download_dir_free_space = json["download-dir-free-space"] as? Int ?? diagnose(),
                let download_queue_enabled = json["download-queue-enabled"] as? Bool ?? diagnose(),
                let download_queue_size = json["download-queue-size"] as? Int ?? diagnose(),
                let dht_enabled = json["dht-enabled"] as? Bool  ?? diagnose(),
                let encryption = json["encryption"] as? String  ?? diagnose(), //  "required", "preferred", "tolerated"
                let idle_seeding_limit = json["idle-seeding-limit"] as? Int ?? diagnose(),
                let idle_seeding_limit_enabled = json["idle-seeding-limit-enabled"] as? Bool ?? diagnose(),
                let incomplete_dir = json["incomplete-dir"] as? String ?? diagnose(),
                let incomplete_dir_enabled = json["incomplete-dir-enabled"] as? Bool ?? diagnose(),
                let lpd_enabled = json["lpd-enabled"] as? Bool ?? diagnose(),
                let peer_limit_global = json["peer-limit-global"] as? Int  ?? diagnose(),
                let peer_limit_per_torrent = json["peer-limit-per-torrent"] as? Int  ?? diagnose(),
                let pex_enabled = json["pex-enabled"] as? Bool  ?? diagnose(),
                let peer_port = json["peer-port"] as? Int  ?? diagnose(),
                let peer_port_random_on_start = json["peer-port-random-on-start"] as? Bool  ?? diagnose(),
                let port_forwarding_enabled = json["port-forwarding-enabled"] as? Bool ?? diagnose(),
                let queue_stalled_enabled = json["queue-stalled-enabled"] as? Bool ?? diagnose(),
                let queue_stalled_minutes = json["queue-stalled-minutes"] as? Int ?? diagnose(),
                let rename_partial_files = json["rename-partial-files"] as? Bool ?? diagnose(),
                let rpc_version = json["rpc-version"] as? Int  ?? diagnose(),
                let rpc_version_minimum = json["rpc-version-minimum"] as? Int  ?? diagnose(),
                let script_torrent_done_enabled = json["script-torrent-done-enabled"] as? Bool ?? diagnose(),
                let script_torrent_done_filename = json["script-torrent-done-filename"] as? String ?? diagnose(),
                let seed_queue_enabled = json["seed-queue-enabled"] as? Bool ?? diagnose(),
                let seed_queue_size = json["seed-queue-size"] as? Int ?? diagnose(),
                let seed_ratio_limit = json["seedRatioLimit"] as? Double  ?? diagnose(),
                let seed_ratio_limited = json["seedRatioLimited"] as? Bool  ?? diagnose(),
                let start_added_torrents = json["start-added-torrents"] as? Bool ?? diagnose(),
                let speed_limit_down = json["speed-limit-down"] as? Int  ?? diagnose(),
                let speed_limit_down_enabled = json["speed-limit-down-enabled"] as? Bool  ?? diagnose(),
                let speed_limit_up = json["speed-limit-up"] as? Int  ?? diagnose(),
                let speed_limit_up_enabled = json["speed-limit-up-enabled"] as? Bool  ?? diagnose(),
                let trash_original_torrent_files = json["trash-original-torrent-files"] as? Bool ?? diagnose(),
                let version = json["version"] as? String  ?? diagnose()
                else {
                    print( "Session: couldn't parse json \(json)" )
                    return nil
            }
            
            self.alt_speed_down = alt_speed_down
            self.alt_speed_enabled = alt_speed_enabled
            self.alt_speed_time_begin = alt_speed_time_begin
            self.alt_speed_time_enabled = alt_speed_time_enabled
            self.alt_speed_time_end = alt_speed_time_end
            self.alt_speed_time_day = alt_speed_time_day
            self.alt_speed_up = alt_speed_up
            self.blocklist_enabled = blocklist_enabled
            self.blocklist_size = blocklist_size
            self.blocklist_url = blocklist_url
            self.config_dir = config_dir
            self.download_dir = download_dir
            self.download_dir_free_space = download_dir_free_space
            self.download_queue_enabled = download_queue_enabled
            self.download_queue_size = download_queue_size
            self.dht_enabled = dht_enabled
            self.encryption = encryption
            self.idle_seeding_limit = idle_seeding_limit
            self.idle_seeding_limit_enabled = idle_seeding_limit_enabled
            self.incomplete_dir = incomplete_dir
            self.incomplete_dir_enabled = incomplete_dir_enabled
            self.lpd_enabled = lpd_enabled
            self.peer_limit_global = peer_limit_global
            self.peer_limit_per_torrent = peer_limit_per_torrent
            self.pex_enabled = pex_enabled
            self.peer_port = peer_port
            self.peer_port_random_on_start = peer_port_random_on_start
            self.port_forwarding_enabled = port_forwarding_enabled
            self.queue_stalled_enabled = queue_stalled_enabled
            self.queue_stalled_minutes = queue_stalled_minutes
            self.rename_partial_files = rename_partial_files
            self.rpc_version = rpc_version
            self.rpc_version_minimum = rpc_version_minimum
            self.script_torrent_done_enabled = script_torrent_done_enabled
            self.script_torrent_done_filename = script_torrent_done_filename
            self.seed_queue_enabled = seed_queue_enabled
            self.seed_queue_size = seed_queue_size
            self.seed_ratio_limit = seed_ratio_limit
            self.seed_ratio_limited = seed_ratio_limited
            self.speed_limit_down = speed_limit_down
            self.speed_limit_down_enabled = speed_limit_down_enabled
            self.speed_limit_up = speed_limit_up
            self.speed_limit_up_enabled = speed_limit_up_enabled
            self.start_added_torrents  = start_added_torrents
            self.trash_original_torrent_files = trash_original_torrent_files
            self.version = version
        }
        
        var alt_speed_down = 0
        var alt_speed_enabled = false
        var alt_speed_time_begin = 0
        var alt_speed_time_enabled = false
        var alt_speed_time_end = 0
        var alt_speed_time_day = 0
        var alt_speed_up = 0
        var blocklist_enabled = false
        var blocklist_size = 0
        var blocklist_url = ""
        var config_dir = ""
        var download_dir = ""
        var download_dir_free_space = 0
        var download_queue_enabled = false
        var download_queue_size = 0
        var dht_enabled = false
        var encryption = ""
        var idle_seeding_limit = 0
        var idle_seeding_limit_enabled = false
        var incomplete_dir = ""
        var incomplete_dir_enabled = false
        var lpd_enabled = false
        var peer_limit_global = 0
        var peer_limit_per_torrent = 0
        var pex_enabled = false
        var peer_port = 0
        var peer_port_random_on_start = false
        var port_forwarding_enabled = false
        var queue_stalled_enabled = false
        var queue_stalled_minutes = 0
        var rename_partial_files = false
        var rpc_version = 0
        var rpc_version_minimum = 0
        var script_torrent_done_enabled = false
        var script_torrent_done_filename = ""
        var seed_queue_enabled = false
        var seed_queue_size = 0
        var seed_ratio_limit = 0.0
        var seed_ratio_limited = false
        var speed_limit_down = 0
        var speed_limit_down_enabled = false
        var speed_limit_up = 0
        var speed_limit_up_enabled = false
        var start_added_torrents = false
        var trash_original_torrent_files = false
        var version = ""
    }
    
    class Torrent: NSObject
    {
        class File : NSObject
        {
            init?( json: [String:Any] )
            {
                guard let bytesCompleted = json["bytesCompleted"] as? Int ?? diagnose(),
                let totalBytes = json["length"] as? Int ?? diagnose(),
                let name = json["name"] as? String  ?? diagnose()
                    else {
                        return nil
                }
                
                self.bytesCompleted = bytesCompleted
                self.totalBytes = totalBytes
                self.name = name
            }
            
            var bytesCompleted : Int
            var totalBytes : Int
            var name : String
        }
        
        init?( json: [String:Any] )
        {
            guard let addedDate = json["addedDate"] as? Int ?? diagnose(),
                let comment = json["comment"] as? String ?? diagnose(),
                let doneDate = json["doneDate"] as? Int  ?? diagnose(),
                let downloadDir = json["downloadDir"] as? String  ?? diagnose(),
                let eta = json["eta"] as? Int  ?? diagnose(),
                let hashString = json["hashString"] as? String  ?? diagnose(),
                let id = json["id"] as? Int  ?? diagnose(),
                let isFinished = json["isFinished"] as? Bool  ?? diagnose(),
                let leftUntilDone = json["leftUntilDone"] as? Int  ?? diagnose(),
                let name = json["name"] as? String  ?? diagnose(),
                let percentDone = json["percentDone"] as? Float  ?? diagnose(),
                let rateDownload = json["rateDownload"] as? Int  ?? diagnose(),
                let rateUpload = json["rateUpload"] as? Int  ?? diagnose(),
                let seedRatioLimit = json["seedRatioLimit"] as? Int  ?? diagnose(),
                let sizeWhenDone = json["sizeWhenDone"] as? Int  ?? diagnose(),
                let status = json["status"] as? Int  ?? diagnose(),
                let torrentFile = json["torrentFile"] as? String  ?? diagnose(),
                let totalSize = json["totalSize"] as? Int  ?? diagnose(),
                let uploadLimit = json["uploadLimit"] as? Int  ?? diagnose(),
                let uploadLimited = json["uploadLimited"] as? Bool  ?? diagnose(),
                let uploadRatio = json["uploadRatio"] as? Float  ?? diagnose(),
                let files = json["files"] as? [ [String:Any] ] ?? diagnose()
                else {
                  print( "Torrent: couldn't parse json \(json)" )
                return nil
            }
            
            for fileJson in files
            {
                if let torrentFile = Transmission.Torrent.File( json:fileJson )
                {
                    self.torrentFiles.append( torrentFile )
                }
            }
            
            self.addedDate = addedDate
            self.comment = comment
            self.doneDate = doneDate
            self.downloadDir = downloadDir
            self.eta = eta
            self.hashString = hashString
            self.id = id
            self.isFinished = isFinished
            self.leftUntilDone = leftUntilDone
            self.name = name
            self.percentDone = percentDone
            self.rateDownload = rateDownload
            self.rateUpload = rateUpload
            self.seedRatioLimit = seedRatioLimit
            self.sizeWhenDone = sizeWhenDone
            self.status = status
            self.torrentFile = torrentFile
            self.totalSize = totalSize
            self.uploadLimit = uploadLimit
            self.uploadLimited = uploadLimited
            self.uploadRatio = uploadRatio
        }
      
       

        var addedDate : Int = 0
        var comment : String = ""
        var doneDate : Int = 0
        var downloadDir: String = ""
        var eta: Int = -1
        var hashString: String = ""
        var id: Int = 0
        var isFinished: Bool = false
        var leftUntilDone: Int = 0
        var name: String = ""
        var percentDone: Float = 0.0
        var rateDownload: Int = 0
        var rateUpload: Int = 0
        var seedRatioLimit: Int = 0
        var sizeWhenDone: Int = 0
        var status: Int = 0
        var torrentFile: String = ""
        var totalSize: Int = 0
        var uploadLimit: Int = 0
        var uploadLimited: Bool = false
        var uploadRatio: Float = 0
        var torrentFiles : [ Transmission.Torrent.File ] = []
        
        var done: Bool {
            get {
                return self.percentDone == 1.0
            }
        }
    }
    
    var urlComponents = URLComponents()
    var sessionID : String?
    
    let HEADER_KEY = "X-Transmission-Session-Id"
    let AUTH_STATUS_CODE = 409
    
    static let TORRENT_FIELDS = [
        "id",
        "name",
        "totalSize",
        "addedDate",
        "isFinished",
        "rateDownload",
        "rateUpload",
        "percentDone",
        "files",
        "comment",
        "description",
        "downloadDir",
        "doneDate",
        "eta",
        "hashString",
        "leechers",
        "leftUntilDone",
        "name",
        "rateDownload",
        "seeders",
        "seedRatioLimit",
        "sizeWhenDone",
        "status",
        "torrentFile",
        //"trackers",
        "uploadLimit",
        "uploadLimited",
        "uploadRatio"
    ]
    
    init?( host:String, port:Int, path:String = "transmission/rpc" )
    {
        self.urlComponents.scheme = "http"
        self.urlComponents.host = host
        self.urlComponents.port = port
        self.urlComponents.path = "/" + path
    }
    
    func authenticate(callback: @escaping (Bool)-> ())
    {
        if let url = self.urlComponents.url
        {
            var request = URLRequest.init( url: url )
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
                if error != nil {
                    print( "error: \(error!)")
                } else {
                    if let response = response as? HTTPURLResponse
                    {
                        if( response.statusCode == self.AUTH_STATUS_CODE )
                        {
                            if let id = response.allHeaderFields[ self.HEADER_KEY ] as? String
                            {
                                self.sessionID = id
                                callback( true )
                                return
                            }
                        }
                    }
                }
                callback( false )
                return
            }
            task.resume()
        }
    }
    
    func removeTorrent(  id:Int, callback: @escaping (Bool)-> () )
    {
        removeTorrents( ids:[id], callback:callback )
    }
    
    func removeTorrents(  ids:[Int], callback: @escaping (Bool)-> () )
    {
        if( ids.isEmpty )
        {
            callback( true ) // nothing to remove so what you asked to be removed did succeed
            return
        }
        var arguments: [String:Any] = [:]
        arguments["ids"] = ids
        
        self.executeMethod(method: "torrent-remove", arguments: arguments, callback: { ( obj:[String : Any] ) -> () in
            print( "done remove ")
            print( obj )
            callback( true )
            return
        })

    }
    
    func getTorrents( ids:[String]? = nil, callback: @escaping ([Transmission.Torrent])-> () )
    {
        var arguments: [String:Any] = [:]
        if let ids = ids
        {
            arguments["ids"] = ids
        }
        
        self.executeMethod(method: "torrent-get", arguments: arguments, callback: { ( obj:[String : Any] ) -> () in
            guard let arguments = obj["arguments"] as? [String:Any],
            let torrents = arguments["torrents"] as? [ [String:Any] ]
                else {
                    return
            }
            
            var rval: [ Transmission.Torrent ] = []
            for t in torrents
            {
                if let torrent = Transmission.Torrent( json: t )
                {
                    rval.append( torrent )
                }
            }
            callback( rval )
        })
    }
    
    func addTorrent( url: URL )
    {
        let arguments: [String:Any] = ["filename":url.absoluteString,
                                       "paused":true]
        
        self.executeMethod(method: "torrent-add", arguments: arguments, callback: { ( obj:[String : Any] ) -> () in
            
            print( obj )
        })
    }
    
    func addTorrent( magnetLink: URL )
    {
        addTorrent( url:magnetLink )
    }
    
    func getSession( callback: @escaping (Transmission.Session)-> () )
    {
        self.executeMethod(method: "session-get", arguments: [:], callback: { ( obj:[String : Any] ) -> () in
            guard let arguments = obj["arguments"] as? [String:Any]
                else {
                    return
            }
            
            if let session = Transmission.Session( json:arguments )
            {
                callback( session )
            }
        })
    }
    
    private func postData( arguments: [String:Any] = [:], callback: @escaping (Data)-> () ) {
        
        guard let url = self.urlComponents.url,
            let sessionId = self.sessionID
            else
        {
            return
        }

        var request = URLRequest.init( url: url )
        request.httpMethod = "POST"
        request.setValue( sessionId, forHTTPHeaderField: self.HEADER_KEY )
        
        do
        {
            let json = try JSONSerialization.data(withJSONObject: arguments )
            request.httpBody = json
        }
        catch
        {
            
        }
        
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
            if error != nil {
                print( "error: \(error!)")
            } else {
                if let binary = data
                {
                   // let s = String( data: binary, encoding: String.Encoding.utf8)
                   // print( s )
                    callback( binary )
                }
            }
        }
        task.resume()
    }
    
    private func executeMethod( method: String, arguments: [String:Any], fields:[String] = Transmission.TORRENT_FIELDS, callback: @escaping ([String:Any])-> () ) {
        
        var args : [String : Any] = ["method" : method, "arguments" : arguments ]
        if var a = args["arguments"] as? [String:Any]
        {
            a["fields"] = fields
            args["arguments"] = a
        }
        
        print( args )
        self.postData( arguments: args, callback: { ( data: Data ) -> () in
            do
            {
                let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                callback( obj )
            }
            catch
            {
                
            }
        })
    }
}
