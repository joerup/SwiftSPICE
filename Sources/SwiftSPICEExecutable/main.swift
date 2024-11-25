//
//  main.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import SwiftSPICE
import Foundation

let kernelName = "de432s"

guard CommandLine.argc == 3 else {
    print("Usage: SwiftSPICE <targetID> <referenceID>")
    exit(1)
}
guard let target = Int(CommandLine.arguments[1]), let reference = Int(CommandLine.arguments[2]) else {
    print("Invalid arguments. Both targetID and referenceID should be integers.")
    exit(1)
}
guard let kernelURL = Bundle.module.url(forResource: kernelName, withExtension: "bsp") else {
    print("Kernel \(kernelName).bsp not found.")
    exit(1)
}
    
do {
    try SPICE.loadKernel(kernelURL.path)
    
    let state = try SPICE.getState(target: target, reference: reference)
    
    print("Position: \(state.x), \(state.y), \(state.z)")
    print("Velocity: \(state.vx), \(state.vy), \(state.vz)")
    
    try SPICE.clearKernels()
    
} catch {
    print("Error: \(error)")
    exit(1)
}
