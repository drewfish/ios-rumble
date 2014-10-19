//
//  SeismoAxisView.swift
//  rumble
//
//  Created by Andrew Folta on 10/18/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let SEISMO_COLOR_GRID = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
let SEISMO_COLOR_AXIS = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
let SEISMO_AXIS_INSET = CGFloat(0.5)


class SeismoAxisView: UIView {
    var data: SeismoDisplayData!

    override func drawRect(rect: CGRect) {
        if data.yScale == 0.0 {
            // we've been called a little too early to do anything meaningful.
            return
        }

        var x0: CGFloat, x1: CGFloat
        var y0: CGFloat, y1: CGFloat
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)

        // draw grid
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_GRID.CGColor)
        var numGrid = Int((2.0 * data.yScale) / SEISMO_AXIS_SPACING)
        x0 = bounds.origin.x
        x1 = x0 + bounds.size.width
        y0 = bounds.origin.y
        for g in 0...numGrid {
            var inset = CGFloat(0.0)
            if g == 0 {
                inset = +SEISMO_AXIS_INSET
            }
            if g == numGrid {
                inset = -SEISMO_AXIS_INSET
            }
            CGContextMoveToPoint(context, x0, y0 + inset)
            CGContextAddLineToPoint(context, x1, y0 + inset)
            y0 += CGFloat(SEISMO_AXIS_SPACING) * data.yPixelsPerMagnitude
        }
        CGContextStrokePath(context)

        // draw axis
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_AXIS.CGColor)
        x0 += SEISMO_AXIS_INSET
        y0 = bounds.origin.y + data.yOrigin
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x1, y0)
        y0 = bounds.origin.y
        y1 = y0 + bounds.size.height
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x0, y1)
        CGContextStrokePath(context)
    }

}

