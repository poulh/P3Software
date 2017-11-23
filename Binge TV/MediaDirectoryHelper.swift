//
//  MediaDirectoryHelper.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/16/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class MediaDirectoryHelper : NSObject
{
    func getActualURL( fromDisplayURL: URL ) -> URL?
    {
        if( self.directoryExists(url: fromDisplayURL ) )
        {
            //most of the time this will be the case
            return fromDisplayURL
        }
        
        if( self.isDirectoryOnMountedVolume( url: fromDisplayURL ) )
        {
            if let volumeBaseURL = self.volumeBaseURL( url: fromDisplayURL )
            {
                let volumeDisplayName = volumeBaseURL.lastPathComponent
                let keys = [URLResourceKey.volumeNameKey, URLResourceKey.volumeIsRemovableKey, URLResourceKey.volumeIsEjectableKey]
                if let mountedVolumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: FileManager.VolumeEnumerationOptions.produceFileReferenceURLs)
                {
                    for mountedVolumeURL in mountedVolumeURLs
                    {
                        let mountedVolumeDisplayName = fileManager.displayName( atPath: mountedVolumeURL.relativePath )
                        if( mountedVolumeDisplayName == volumeDisplayName )
                        {
                            let components = fromDisplayURL.pathComponents
                            var volumeURL = mountedVolumeURL
                            let volumeBaseComponents = volumeBaseURL.pathComponents
                            for i in volumeBaseComponents.count ..< components.count
                            {
                                volumeURL = volumeURL.appendingPathComponent(components[i])
                            }
                            return volumeURL
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func getDisplayURL( url: URL ) -> URL
    {
        if( !self.isDirectoryOnMountedVolume( url: url ) )
        {
            print("not on mounted volume")
            return url
        }
        
        if let volumeBaseURL = self.volumeBaseURL( url: url )
        {
            print( "volume base url \(volumeBaseURL)" )
            let volumeDisplayName = self.fileManager.displayName(atPath: volumeBaseURL.relativePath)
            print( "vol display name \(volumeDisplayName)")
            var components = url.pathComponents
            let volumeBaseComponents = volumeBaseURL.pathComponents
            print( components)
            
            components[ volumeBaseComponents.count - 1 ] = volumeDisplayName
            
            var rval = URL( fileURLWithPath: components[0] )
            print( rval)
            for i in 1 ..< components.count
            {
                rval = rval.appendingPathComponent(components[i])
                print( rval )
            }
            return rval
        }
        
        return url
    }
    
    private func directoryExists( url: URL ) -> Bool
    {
        var isDir : ObjCBool = false
        if( fileManager.fileExists(atPath: url.relativePath, isDirectory: &isDir) )
        {
            if( isDir.boolValue )
            {
                return true
            }
            else
            {
                print("problem: there is a file in the spot where the dir should be")
            }
        }
        return false
    }
    
    
    
    private func isDirectoryOnMountedVolume( url: URL ) -> Bool
    {
        if( url.relativePath.range(of:"/Volumes") != nil )
        {
            return url.pathComponents.count >= 3
        }
        return false
    }
    
    private func volumeBaseURL( url: URL ) -> URL?
    {
        print( "passed in: \(url)")
        if( !isDirectoryOnMountedVolume( url: url ) )
        {
            return nil
        }
        
        var components = url.pathComponents
        print( components)
        if( components.count < 3 )
        {
            //not enough info in path
            return nil
        }
        print( "returning" )
        print(URL(fileURLWithPath: components[0]).appendingPathComponent(components[1]).appendingPathComponent(components[2]))
        var u = URL(fileURLWithPath: components[0])
        u = u.appendingPathComponent(components[1]).appendingPathComponent(components[2])
        print(u )
        return u
    }

    private let fileManager = FileManager()

}
