//
//  SeriesTableCellView.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/15/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class SearchResultsTableCellView: NSTableCellView {

    
    @IBOutlet weak var nameTextfield: NSTextField!
    @IBOutlet weak var overviewTextfield: NSTextField!
    @IBOutlet weak var yearTextfield: NSTextField!
    @IBOutlet weak var networkTextfield: NSTextField!
    @IBOutlet weak var statusImageView: NSImageView!
    @IBOutlet weak var seriesButton: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

class SeriesTableCellView: SearchResultsTableCellView {
    
    
//    @IBOutlet weak var nameTextfield: NSTextField!
//    @IBOutlet weak var overviewTextfield: NSTextField!
//    @IBOutlet weak var yearTextfield: NSTextField!
//    @IBOutlet weak var networkTextfield: NSTextField!
//    @IBOutlet weak var statusImageView: NSImageView!
//    @IBOutlet weak var addSeriesButton: NSButton!
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//        
//        // Drawing code here.
//    }
}
