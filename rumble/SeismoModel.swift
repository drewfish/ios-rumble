//
//  SeismoModel.swift
//  rumble
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit
import CoreMotion


let SEISMO_UPDATE_INTERVAL = 1.0 / 20.0
let SEISMO_BUFFER_SIZE = 10


@objc protocol SeismoModelDelegate {
    func reportRichter(#x: Double, y: Double, z: Double) -> Void
}


// http://earthquake.usgs.gov/learn/topics/measure.php
// surface wave magnitude assuming we're at the epicenter
func richter(val: Double) -> Double {
    return log10(fabs(val)) + 3.3
}


@objc class SeismoModel {
    var delegate: SeismoModelDelegate?

    init() {}

    func onAcceleration(data: CMAcceleration) {
        axisX.update(data.x)
        axisY.update(data.y)
        axisZ.update(data.z)
        var x = axisX.read()
        var y = axisY.read()
        var z = axisZ.read()
        delegate?.reportRichter(x: x, y: y, z: z)
    }

    // start listening for seismic activity
    func start() {
        var first = true
        if motionManager == nil {
            motionManager = CMMotionManager()
        }
        if !motionManager!.accelerometerAvailable {
            // FUTURE -- handle no accelerometer
//            println("NOTE: no accellerometer available")
            return
        }
        motionManager!.accelerometerUpdateInterval = SEISMO_UPDATE_INTERVAL
        motionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {
            (data: CMAccelerometerData?, error: NSError?) -> Void in
            if error != nil {
                // FUTURE -- handle error
                self.motionManager!.stopAccelerometerUpdates()
            }
            if data != nil {
                if first {
                    self.axisX.setup(data!.acceleration.x)
                    self.axisY.setup(data!.acceleration.y)
                    self.axisZ.setup(data!.acceleration.z)
                    first = false
                    return
                }
                self.onAcceleration(data!.acceleration)
            }
        })
    }

    // stop listening for seismic activity
    func stop() {
        motionManager?.stopAccelerometerUpdates()
    }

    // We auto-zero the values based on a rolling 1-second window.
    @objc class Axis {
        var ring: [Double] = []
        var ringIndex = 0
        var midValue = 0.0
        init() {}
        func setup(value: Double) {
            ring = Array<Double>(count: SEISMO_BUFFER_SIZE, repeatedValue: value)
        }
        func update(newValue: Double) {
            ringIndex = (ringIndex + 1) % SEISMO_BUFFER_SIZE
            ring[ringIndex] = newValue
            var minValue = ring[0]
            var maxValue = ring[0]
            for r in ring {
                minValue = min(minValue, r)
                maxValue = max(maxValue, r)
            }
            midValue = minValue + ((maxValue - minValue) / 2.0)
        }
        func read() -> Double {
            return ring[ringIndex] - midValue
        }
    }

    private var motionManager: CMMotionManager?
    private var axisX = Axis()
    private var axisY = Axis()
    private var axisZ = Axis()
}

