//
//  SeismoViewController.swift
//  rumble
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta.
//  See the "License" section of README.md for terms of use.
//

import UIKit


let SEISMO_DATA_COUNT       = 100
let SEISMO_AXIS_SPACING     = 0.2               // how often (in magnitude) to draw a grid line
let SEISMO_CANVAS_INSET     = CGSize(width: 20.0, height: 8.0)
let SEISMO_NEEDLE_OFFSET    = CGFloat(-12.5)    // where the point is located within the needle image
let SEISMO_COLOR_FILL       = UIColor(red: 252/255, green: 248/255, blue: 244/255, alpha: 1.0)
let SEISMO_COLOR_MINOR      = UIColor(red: 246/255, green: 234/255, blue: 225/255, alpha: 1.0)
let SEISMO_COLOR_MAJOR      = UIColor(red: 236/255, green: 219/255, blue: 201/255, alpha: 1.0)


// Many of these are just cached values so we don't have to recompute a lot.
@objc class SeismoDisplayData {
    var values              = RingBuffer(count: SEISMO_DATA_COUNT, repeatedValue: 0.0)
    var xPixelsPerDatum     = CGFloat()     // number of x pixels per reading
    var yPixelsPerMagnitude = CGFloat()     // number of y pixels per unit of magnitude
    var yScale              = SEISMO_AXIS_SPACING   // greatest magnitude (positive or negative) to show on the canvas
    var yOrigin             = CGFloat()     // origin (zero point) of magnitude (i.e., half of canvas height)
}


class SeismoViewController: UIViewController, SeismoModelDelegate {
    @IBOutlet weak var backgroundView: SeismoBackgroundView!
    @IBOutlet weak var axisView: SeismoAxisView!
    @IBOutlet weak var dataView: SeismoDataView!
    @IBOutlet weak var needleView: UIImageView!

    var seismoModel: SeismoModel?
    var data = SeismoDisplayData()
    var lastValue = 0.0     // GLUE for old SeisoModel implementation

    func sizeUpdated() {
        var canvas = view.bounds
        canvas.origin.x     += SEISMO_CANVAS_INSET.width
        canvas.origin.y     += SEISMO_CANVAS_INSET.height
        canvas.size.width   -= SEISMO_CANVAS_INSET.width
        canvas.size.height  -= 2.0 * SEISMO_CANVAS_INSET.height
        backgroundView.frame = canvas
        axisView.frame = canvas
        dataView.frame = canvas

        data.xPixelsPerDatum        = canvas.size.width / CGFloat(SEISMO_DATA_COUNT)
        data.yPixelsPerMagnitude    = canvas.size.height / CGFloat(2.0 * data.yScale)
        data.yOrigin                = canvas.size.height / CGFloat(2.0)

        backgroundView.sizeUpdated()
        axisView.setNeedsDisplay()
        dataView.setNeedsDisplay()
        setNeedle()
    }

    func scaleUpdated() {
        var canvas = backgroundView.frame
        data.yPixelsPerMagnitude = canvas.size.height / CGFloat(2.0 * data.yScale)

        backgroundView.scaleUpdated()
        axisView.setNeedsDisplay()
        dataView.setNeedsDisplay()
        setNeedle()
    }

    func valuesUpdated() {
        // update scale (if needed)
        // (There are some clever things we can do by inspecting the newest value and the recently dropped value, but given the very spiky nature of our data we end up calculating the max most of the time anyway, so we'll just do that always.)
        var m = self.data.values.reduce(0.0) { max($0, fabs($1)) }
        var newScale = ceil(m / SEISMO_AXIS_SPACING) * SEISMO_AXIS_SPACING
        if self.data.yScale != newScale {
            self.data.yScale = newScale
            self.scaleUpdated()
        }

        backgroundView.valuesUpdated()
        dataView.setNeedsDisplay()
        setNeedle()
    }

    func setNeedle() {
        var needleY = SEISMO_CANVAS_INSET.height + data.yOrigin + (CGFloat(data.values.newest) * data.yPixelsPerMagnitude)
        needleView.frame.origin.y = needleY + SEISMO_NEEDLE_OFFSET
    }

    // GLUE for old SeisoModel implementation
    func reportRichter(#x: Double, y: Double, z: Double) {
        var raw = sqrt(x * x + y * y + z * z)
        var magnitude = raw - lastValue
        lastValue = raw
        dispatch_async(dispatch_get_main_queue(), {
            self.data.values.add(magnitude)
            self.valuesUpdated()
        })
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        sizeUpdated()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        seismoModel = SeismoModel()
        seismoModel?.delegate = self

        // setup child views
        backgroundView.data = data
        axisView.data = data
        dataView.data = data

        // Oddly, we're in the wrong thread to do things like update the frames of child views.
        dispatch_async(dispatch_get_main_queue(), {
            self.sizeUpdated()
        })
    }

    override func viewDidAppear(animated: Bool) {
        seismoModel?.start()
    }

    override func viewWillDisappear(animated: Bool) {
        seismoModel?.stop()
    }
}

