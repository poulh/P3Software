//
//  PreferencesViewController.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 11/27/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var changeMediaDirectoryButton: NSButton!
    
    @IBOutlet weak var mediaDirectoryPathTextField: NSTextField!
    
    let mediaDirectoryHelper = MediaDirectoryHelper()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.changeMediaDirectoryButton.toolTip = "Change Media Directory"
        
        let defaults = UserDefaults.standard
        guard let mediaDirectoryURL = defaults.url(forKey: MEDIA_DISPLAY_DIRECTORY)
            else {
                return
        }
        
        self.mediaDirectoryPathTextField.stringValue = mediaDirectoryURL.path
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window,
            let zoomButton = window.standardWindowButton(NSWindow.ButtonType.zoomButton)
        {
            zoomButton.isHidden = true
        }
    }
    
    @IBAction func changeMediaDirectory(_ sender: NSButton) {

        let defaults = UserDefaults.standard
        guard let mediaDirectoryInfo = self.mediaDirectoryHelper.getMediaDirectoryURL( displayDirectoryURL: nil, mediaDirectoryName: defaults.string(forKey: MEDIA_DIRECTORY_NAME )! )
            else {
                return
        }
        
        defaults.set( nil, forKey: MEDIA_ACTUAL_DIRECTORY )
        defaults.set( mediaDirectoryInfo.displayURL, forKey: MEDIA_DISPLAY_DIRECTORY )
        defaults.set( mediaDirectoryInfo.actualURL, forKey: MEDIA_ACTUAL_DIRECTORY )
        
        self.mediaDirectoryPathTextField.stringValue = mediaDirectoryInfo.displayURL.path
    }
}
