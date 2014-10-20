//
//  SeismoBackgroundView.swift
//  rumble
//
//  Created by Andrew Folta on 10/19/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class SeismoBackgroundView: UIView {
    var data: SeismoDisplayData!
    var bg: UIImage!

    func redrawBackground() {
        var origin = CGPoint(x: 0.0, y: 0.0)
        var size = CGSize(
            // as wide as one second
            width:  20.0 * data.xPixelsPerDatum,
            // as high as 0.1 magnitude
            height: 0.1 * data.yPixelsPerMagnitude
        )
        var rect = CGRect(origin: origin, size: size)

        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        CGContextSetFillColorWithColor(context, SEISMO_COLOR_FILL.CGColor)
        CGContextFillRect(context, rect)
        CGContextSetStrokeColorWithColor(context, SEISMO_COLOR_MINOR.CGColor)
        CGContextStrokeRect(context, rect)

        bg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        backgroundColor = UIColor(patternImage: bg)
    }

    func sizeUpdated() {
        redrawBackground()
    }

    func scaleUpdated() {
        // If there was a way to scale the background image, we could do that here and not have to redraw.
        redrawBackground()
    }

    func valuesUpdated() {
        // This is what makes the background move.
        bounds.origin.x = CGFloat(-data.values.index) * data.xPixelsPerDatum
    }

}

