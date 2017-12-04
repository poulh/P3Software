//
//  Preferences.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 11/27/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

let MEDIA_DISPLAY_DIRECTORY = "Media Display Directory"
let MEDIA_ACTUAL_DIRECTORY = "Media Actual Directory"
let TVDB_SERIES = "TVDB Series"
let VIDEO_EXTENSIONS = "Video Extensions"
let SUBTITLE_EXTENSIONS = "Subtitle Extensions"
let FILENAME_REGEX = "Filename Regex"
let MEDIA_DIRECTORY_NAME = "Media Directory Name"
let TRANSMISSION_HOST = "Transmission Host"
let TRANSMISSION_PORT = "Transmission Port"
let TRANSMISSION_PATH = "Transmission Path"

extension Transmission
{
    convenience init?( defaults: UserDefaults )
    {
        guard let host = defaults.string( forKey: TRANSMISSION_HOST ),
            let path = defaults.string( forKey: TRANSMISSION_PATH )
            else {
                return nil
        }
        let port = defaults.integer(forKey: TRANSMISSION_PORT )
        
        self.init(host: host, port: port, path: path )
    }
}
