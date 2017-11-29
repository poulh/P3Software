//
//  WindowController.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/14/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet weak var searchField: NSSearchField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = self.window
        {
            // http://robin.github.io/cocoa/mac/2016/03/28/title-bar-and-toolbar-showcase/
            window.titleVisibility = .hidden
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    var viewController: ViewController? {
        get {
            if let win = self.window
            {
                if let vc = win.contentViewController as? ViewController
                {
                    return vc
                }
            }
            return nil
        }
    }

    @IBAction func searchButtonEnter(_ sender: NSSearchField) {
        if let vc = self.viewController
        {
            vc.searchButtonEnter(sender)
        }
    }
}
