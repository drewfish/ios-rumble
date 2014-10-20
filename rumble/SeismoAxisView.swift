//
//  SeismoAxisView.swift
//  rumble
//
//  Created by Andrew Folta on 10/18/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let SEISMO_AXIS_INSET = CGFloat(0.5)
let SEISMO_AXIS_GRID = 1.0          // how often to draw the grid lines


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

        x0 = SEISMO_AXIS_INSET
        x1 = x0 + bounds.size.width

        // draw grid
        if data.yScale >= SEISMO_AXIS_GRID {
            CGContextBeginPath(context)
            CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_MAJOR.CGColor)
            var value = SEISMO_AXIS_GRID
            while value <= data.yScale {
                y0 = data.yOrigin + (CGFloat(value) * data.yPixelsPerMagnitude)
                CGContextMoveToPoint(context, x0, y0)
                CGContextAddLineToPoint(context, x1, y0)
                y1 = data.yOrigin + (CGFloat(-value) * data.yPixelsPerMagnitude)
                CGContextMoveToPoint(context, x0, y1)
                CGContextAddLineToPoint(context, x1, y1)
                value += SEISMO_AXIS_GRID
            }
            CGContextStrokePath(context)
        }

        // draw axis
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_MAJOR.CGColor)
        y0 = data.yOrigin
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x1, y0)
        y0 = 0.0
        y1 = y0 + bounds.size.height
        CGContextMoveToPoint(context, x0, y0)
        CGContextAddLineToPoint(context, x0, y1)
        CGContextStrokePath(context)
    }

}

