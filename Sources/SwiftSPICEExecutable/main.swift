//
//  main.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import SwiftSPICE
import Foundation

let kernelName = "de432s"

guard CommandLine.argc >= 3 && CommandLine.argc <= 4 else {
    print("Usage: <targetID> <referenceID> [time]")
    exit(1)
}
guard let target = Int(CommandLine.arguments[1]), let reference = Int(CommandLine.arguments[2]) else {
    print("Invalid arguments. Both targetID and referenceID should be integers.")
    exit(1)
}
let timeString = CommandLine.argc == 4 ? CommandLine.arguments[3] : nil

guard let kernelURL = Bundle.module.url(forResource: kernelName, withExtension: "bsp") else {
    print("Kernel \(kernelName).bsp not found.")
    exit(1)
}
guard let leapsecondURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
    print("Kernel naif0012.tls not found.")
    exit(1)
}

do {
    try SPICE.loadKernel(kernelURL.path)
    try SPICE.loadKernel(leapsecondURL.path)
    
    // Convert the time string to a Date object, or use the current date if time is not provided
    let time: Date
    if let timeString {
        let formatter = ISO8601DateFormatter()
        guard let parsedDate = formatter.date(from: timeString) else {
            print("Invalid time format. Please use ISO 8601 format (e.g., 2000-01-01T12:00:00Z).")
            exit(1)
        }
        time = parsedDate
    } else {
        time = Date()
    }
    
    let targetName = try SPICE.getObjectName(for: target)
    let referenceName = try SPICE.getObjectName(for: reference)
    
    if let timeString = timeString {
        print("State for \(targetName) (\(target)) relative to \(referenceName) (\(reference)) at time \(timeString):")
    } else {
        print("State for \(targetName) (\(target)) relative to \(referenceName) (\(reference)):")
    }
    
    let (state, lighttime) = try SPICE.getState(target: target, reference: reference, time: time, frame: .eclipticJ2000)
    print("Position: \(state.x), \(state.y), \(state.z)")
    print("Velocity: \(state.vx), \(state.vy), \(state.vz)")
    print("One-Way Light Time: \(lighttime)")
    
    try SPICE.clearKernels()
    
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
