//
//  StateVector.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import Foundation

public struct StateVector: Equatable {
    public var x: Double
    public var y: Double
    public var z: Double
    public var vx: Double
    public var vy: Double
    public var vz: Double
    
    public init(x: Double, y: Double, z: Double, vx: Double, vy: Double, vz: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.vx = vx
        self.vy = vy
        self.vz = vz
    }
    
    public static let zero = Self(x: 0, y: 0, z: 0, vx: 0, vy: 0, vz: 0)
    
    public var distance: Double {
        return sqrt(x * x + y * y + z * z)
    }
    public var speed: Double {
        return sqrt(vx * vx + vy * vy + vz * vz)
    }
}
