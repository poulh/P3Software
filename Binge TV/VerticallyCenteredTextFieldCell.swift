//
//  VerticallyCenteredTextFieldCell.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 11/19/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa

class VerticallyCenteredTextFieldCell: NSTextFieldCell {

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView)
    {
        // https://stackoverflow.com/questions/11775128/set-text-vertical-center-in-nstextfield
        let stringHeight : CGFloat = self.attributedStringValue.size().height
        var titleRect : NSRect = super.titleRect(forBounds: cellFrame)
        let oldOriginY: CGFloat = cellFrame.origin.y
        titleRect.origin.y = cellFrame.origin.y + (cellFrame.size.height - stringHeight) / 2.0
        titleRect.size.height = titleRect.size.height - (titleRect.origin.y - oldOriginY)
        
        super.drawInterior(withFrame: titleRect, in: controlView)
    }
}
