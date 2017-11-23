//
//  AppDelegate.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/2/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa
//import NetworkExtension
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
//        let filemanager = FileManager()
//
//        let dialog = NSOpenPanel(
//        
//        dialog.title                   = "Choose a .txt file";
//        dialog.showsResizeIndicator    = true;
//        dialog.showsHiddenFiles        = false;
//        dialog.canChooseDirectories    = true;
//        dialog.canCreateDirectories    = true;
//        dialog.allowsMultipleSelection = false;
//        //dialog.allowedFileTypes        = ["txt"];
//        
//        if (dialog.runModal() == NSModalResponseOK) {
//            if let result = dialog.url
//            {
//                print( result.relativePath)
//                print(filemanager.displayName(atPath: result.relativePath))
//            }
//        } else {
//            // User clicked on "Cancel"
//            return
//        }
//        
//        
//        let ws = NSWorkspace.shared()
//        ws.notificationCenter.addObserver(forName: NSNotification.Name.NSWorkspaceDidMount, object: nil, queue: nil) { (notification:Notification) in
//            print("mount")
//            
//            if let ui = notification.userInfo
//            {
//              //  print(ui.description)
//                print(ui["NSWorkspaceVolumeLocalizedNameKey"])
//                print( ui["NSDevicePath"])
//            }
//            
//        }
//        
//        
//     //   workspace.notificationCenter.addObserver(self, selector: #selector(didMount(_:)), name: NSWorkspace.didMountNotification, object: nil)
//
//      //  for runningApplication in ws.runningApplications
//      //  {
//      //      print( runningApplication.executableURL)
//      //  }
//        let url = URL(fileURLWithPath: "/Volumes/Multimedia/Lets Watch TV")
//        print(filemanager.displayName(atPath: url.relativePath))
//       // print("eoutnhent")
//       // let att = try? filemanager.attributesOfItem(atPath: url.relativePath)
//       // print( att )
//       // print( "-----")
//       // let attributes = try? filemanager.attributesOfFileSystem(forPath: url.relativePath)
//       // print( attributes )
//        print( url.relativeString)
//        print( url.relativePath)
//        let exists = filemanager.fileExists(atPath: url.relativePath)
//       // filemanager.unmountVolume(at: url, options: FileManager.UnmountOptions.allPartitionsAndEjectDisk) { (error:Error?) in
//       //     if let e = error
//       //     {
//        //        print( e )
//        //    }
//      //  else
//      //  {
//        //    print("unmounted")
//      //  }
//       // }
//        print( "exists \(exists)")
//        
//        let keys = [URLResourceKey.volumeNameKey, URLResourceKey.volumeIsRemovableKey, URLResourceKey.volumeIsEjectableKey]
//
//
//        if let urls = filemanager.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: FileManager.VolumeEnumerationOptions.produceFileReferenceURLs)
//        {
//            for url in urls {
//                print(url)
//                print(filemanager.displayName(atPath: url.relativePath))
//
//                
//            }
//        }
//        
        
//        let dict = UserDefaults.standard.dictionaryRepresentation()
//        for (key,value) in dict        {
//            print("\(key) --> \(value)")
//        }
        
        //this link may tell me if i'm connected via vpn: https://stackoverflow.com/questions/19438480/programmatically-detect-type-of-connection-to-mounted-volume
        
        // Insert code here to initialize your application
        //let m = NEVPNManager()
//        let tunnelProvider = NETunnelProviderManager()
//       // tunnelProvider.
//         //NEVPNProtocolIPSec()
//        var targetManager = NEVPNManager.shared()
//       // let p = NEVPNProtocolIPSec()
//        let p = NEVPNProtocolIKEv2
//        
//        p.username = "ospencer"
//        p.account
//        p.passwordReference = getPassc
//        p.passwordReference = getPasscodeNSData("vpnPassword")
//        p.serverAddress = "vconnect.uk.capgemini.com"
//        p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
//        p.sharedSecretReference = getPasscodeNSData("vpnSharedSecret")
//        p.useExtendedAuthentication = true
//        p.disconnectOnSleep = false
        
       // targetManager.proto
      //  print( targetManager.localizedDescription )
       // let c = NEVPNConnection()
       // c.
       // print(c.manager.isEnabled )
//        m.loadFromPreferences { (error:Error?) in
//            if let e = error
//            {
//                print( e )
//            }
//            else
//            {
//                print( "no error")
//            }
//        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

