//
//  RingBuffer.swift
//  rumble
//
//  Created by Andrew Folta on 10/18/14.
//  Copyright (c) 2014 Andrew Folta.
//  See the "License" section of README.md for terms of use.
//

import Foundation


// A fixed sized array that discards old values as new values are added.
class RingBuffer {
    var values: [Double]
    var index: Int      // points to the newest value

    init(count: Int, repeatedValue: Double) {
        values = Array<Double>(count: count, repeatedValue: repeatedValue)
        index = 0
    }

    var count: Int {
        return values.count
    }

    // zero is newest value, incrementally moving back in time
    subscript(i: Int) -> Double {
        return values[(index - (i % values.count) + values.count) % values.count]
    }

    func add(newValue: Double) {
        index = (index + 1) % values.count
        values[index] = newValue
    }

    var oldest: Double {
        return values[(index + 1) % values.count]
    }

    var newest: Double {
        return values[index]
    }

    // This makes no guarantees about the order the values are iterated.
    func reduce(initial: Double, combine: (accumulator: Double, newValue: Double) -> Double) -> Double {
        return values.reduce(initial, combine)
    }
}

