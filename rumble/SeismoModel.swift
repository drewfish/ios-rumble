//
//  SeismoModel.swift
//  rumble
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit
import CoreMotion


let SEISMO_UPDATE_INTERVAL = 1.0 / 10.0
let SEISMO_BUFFER_SIZE = 10


@objc protocol SeismoModelDelegate {
    func reportRichter(#x: Double, y: Double, z: Double) -> Void
}


// http://earthquake.usgs.gov/learn/topics/measure.php
// surface wave magnitude assuming we're at the epicenter
func richter(val: Double) -> Double {
    var v = log10(fabs(val)) + 3.3
    if val < 0.0 {
        return -v
    }
    return v
}


@objc class SeismoModel {
    var delegate: SeismoModelDelegate?

    init() {}

    func onAcceleration(data: CMAcceleration) {
        ringX.update(data.x)
        ringY.update(data.y)
        ringZ.update(data.z)
        var x = ringX.avg
        var y = ringY.avg
        var z = ringZ.avg
        x = richter(x)
        y = richter(y)
        z = richter(z)
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
            println("NOTE: no accellerometer available")
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
                    self.ringX.setup(data!.acceleration.x)
                    self.ringY.setup(data!.acceleration.y)
                    self.ringZ.setup(data!.acceleration.z)
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

    // uses a ring buffer to keep an average over a moving window
    @objc class RingAverage {
        var ring: [Double] = []
        var i = 0
        var avg = 0.0
        init() {}
        func setup(value: Double) {
            ring = Array<Double>(count: SEISMO_BUFFER_SIZE, repeatedValue: value)
        }
        func update(newValue: Double) {
            i = (i + 1) % SEISMO_BUFFER_SIZE
            ring[i] = newValue
            var sum = ring.reduce(0.0) { $0 + $1 }
            avg = sum / Double(SEISMO_BUFFER_SIZE)
        }
    }

    private var motionManager: CMMotionManager?
    private var ringX = RingAverage()
    private var ringY = RingAverage()
    private var ringZ = RingAverage()
}

