//
//  SeismoDataView.swift
//  rumble
//
//  Created by Andrew Folta on 10/18/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let SEISMO_COLOR_DATA = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)


class SeismoDataView: UIView {
    var data: SeismoDisplayData!

    override func drawRect(rect: CGRect) {
        if data.yScale == 0.0 {
            // we've been called a little too early to do anything meaningful.
            return
        }

        var x: CGFloat, y: CGFloat
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        CGContextBeginPath(context)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_DATA.CGColor)
        x = bounds.origin.x
        y = bounds.origin.y + data.yOrigin
        CGContextMoveToPoint(context, x, y)
        for v in 0..<data.values.count {
            var value = CGFloat(data.values[v])
            x += data.xPixelsPerDatum
            y = bounds.origin.y + data.yOrigin + value * data.yPixelsPerMagnitude
            CGContextAddLineToPoint(context, x, y)
        }
        CGContextStrokePath(context)
    }

}

