//
//  EpisodeTableCellView.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/8/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class EpisodeTableCellView: NSTableCellView {

    @IBOutlet weak var titleTextfield: NSTextField!
    @IBOutlet weak var episodeTextField: NSTextField!
    @IBOutlet weak var overviewTextField: NSTextField!
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var statusImageView: NSImageView!

    @IBOutlet weak var percentDoneTextField: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
}
