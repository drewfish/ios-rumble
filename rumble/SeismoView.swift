//
//  SeismoView.swift
//  rumble
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let SEISMO_GRID_SPACING = 0.2


class SeismoView: UIView, SeismoModelDelegate {
    // we'll only display one line
    var values: [Double] = []
    var scale = SEISMO_GRID_SPACING

    override init(frame: CGRect) {
        super.init(frame: frame)
        moreInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        moreInit()
    }

    func moreInit() {
        contentMode = .Redraw
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange", name:UIDeviceOrientationDidChangeNotification, object: nil)
    }

    func reportRichter(#x: Double, y: Double, z: Double) {
        var val = 0.0
        // use whichever has the biggest magnitude
        if fabs(x) > fabs(y) {
            val = x
        }
        else {
            if fabs(y) > fabs(z) {
                val = y
            }
            else {
                val = z
            }
        }
        values.append(val)
        var f = fabs(val)
        while f > scale {
            scale += SEISMO_GRID_SPACING
        }
        // The CoreMotion updates happen in a different thread?
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            self.setNeedsDisplay()
        })
    }

    func onOrientationChange() {
        // I'm surprised that this doesn't happen automatically.
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)

        var x0: CGFloat, x1: CGFloat
        var y0: CGFloat, y1: CGFloat

        var canvas = bounds
        canvas.origin.x += 20.0
        canvas.origin.y += 8.0
        canvas.size.width -= 20.0
        canvas.size.height -= 16.0

        var yRange = 2 * scale
        var yPixelsPerRichter = canvas.height / CGFloat(yRange)

        // draw grid
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
        var numGrid = Int(yRange / SEISMO_GRID_SPACING)
        x0 = canvas.origin.x
        x1 = x0 + canvas.size.width
        y0 = canvas.origin.y
        for g in 0...numGrid {
            CGContextMoveToPoint(context, x0, y0)
            CGContextAddLineToPoint(context, x1, y0)
            y0 += CGFloat(SEISMO_GRID_SPACING) * yPixelsPerRichter
        }
        CGContextStrokePath(context)

        // draw axes
        CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)
        y0 = canvas.origin.y + (canvas.size.height / 2.0)
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x1, y0)
        y0 = canvas.origin.y
        y1 = y0 + canvas.size.height
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x0, y1)
        CGContextStrokePath(context)
        // TODO -- draw text label for each grid line

        // draw data
        var xPixelsPerValue = canvas.size.width / CGFloat(values.count)
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        x0 = canvas.origin.x
        y0 = canvas.origin.y + (canvas.size.height / 2.0)
        CGContextMoveToPoint(context, x0, y0)
        x1 = x0
        for v in 0..<values.count {
            // draw newer values left-most
            var value = values[values.count - v - 1]
            x1 += xPixelsPerValue
            y1 = canvas.origin.y + CGFloat(scale - value) * yPixelsPerRichter
            CGContextAddLineToPoint(context, x1, y1)
        }
        CGContextStrokePath(context)
    }
}

