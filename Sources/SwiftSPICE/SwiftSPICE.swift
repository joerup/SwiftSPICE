//
//  SPICE.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import CSPICE
import CSPICEExtensions
import Foundation

/// A wrapper for interacting with CSPICE functions in Swift.
public struct SPICE {
    
    // MARK: - Static Properties
    
    /// A set containing the paths of currently loaded SPICE kernels.
    private static var kernels: Set<String> = []
    
    /// A mapping from object IDs to their corresponding SPICE kernel file paths.
    private static var kernelMap: [Int: String] = [:]
    
    /// Static initializer to set prevent console logging of errors within CSPICE.
    private static let initialize: Void = {
        let operation = "SET"
        let action = "RETURN"
        let report = "NONE"

        operation.withCString { opCStr in
            action.withCString { actCStr in
                erract_c(opCStr, SpiceInt(action.count + 1), UnsafeMutablePointer(mutating: actCStr))
            }
            report.withCString { repCStr in
                errprt_c(opCStr, SpiceInt(report.count + 1), UnsafeMutablePointer(mutating: repCStr))
            }
        }
    }()
    
    // MARK: - Enums
    
    public enum ReferenceFrame: String {
        case j2000 = "J2000"
        case eclipticJ2000 = "ECLIPJ2000"
        case iauEarth = "IAU_EARTH"
        case iauMars = "IAU_MARS"
    }
    
    public enum AberrationCorrection: String {
        case none = "NONE"
        case lightTime = "LT"
        case lightTimeStellar = "LT+S"
    }
    
    // MARK: - Public Methods
    
    /// Loads a SPICE kernel into the system.
    /// - Parameter filePath: The full path to the kernel file.
    /// - Throws:
    ///   - `SPICEError.invalidPath` if the file path is invalid.
    ///   - `SPICEError.kernelLoadFailed` if loading fails.
    public static func loadKernel(_ filePath: String) throws {
        _ = SPICE.initialize
        
        guard !kernels.contains(filePath), let path = filePath.cString(using: .utf8) else {
            throw SPICEError.kernelLoadFailed(filePath)
        }
        
        // Load the kernel
        furnsh_c(path)
        
        // Check for SPICE errors
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.kernelLoadFailed(filePath)
        }
        
        // Store the kernel path
        kernels.insert(filePath)
        
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        if fileExtension == "bsp" {
            
            // Fetch object IDs
            var ids = [SpiceInt](repeating: 0, count: 500)
            var count: SpiceInt = 0
            getSPKObjectIDs(path, &ids, &count)
            
            // Populate the kernelMap dictionary
            for i in 0..<Int(count) {
                let objectID = Int(ids[i])
                kernelMap[objectID] = filePath
            }
        }
    }
    
    /// Unloads a specific SPICE kernel from the system.
    /// - Parameter filePath: The full path to the kernel file.
    /// - Throws:
    ///   - `SPICEError.invalidPath` if the file path is invalid.
    ///   - `SPICEError.kernelUnloadFailed` if unloading fails.
    public static func unloadKernel(_ filePath: String) throws {
        _ = SPICE.initialize
        
        guard kernels.contains(filePath), let path = filePath.cString(using: .utf8) else {
            throw SPICEError.kernelUnloadFailed(filePath)
        }
        
        // Unload the kernel
        unload_c(path)
        
        // Check for SPICE errors
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.kernelUnloadFailed(filePath)
        }
        
        // Remove the kernel path from the set
        kernels.remove(filePath)
        
        // Remove associated object IDs from the kernelMap
        kernelMap = kernelMap.filter { $0.value != filePath }
    }
    
    /// Clears all loaded SPICE kernels from the system.
    /// - Throws:
    ///   - `SPICEError.kernelClearFailed` if unloading fails.
    public static func clearKernels() throws {
        _ = SPICE.initialize
        
        // Clear all loaded kernels
        kclear_c()
        
        // Check for SPICE errors
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.kernelClearFailed
        }
        
        // Remove all stored kernel paths and clear the kernelMap
        kernels.removeAll()
        kernelMap.removeAll()
    }
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific time,
    /// along with the one-way light time.
    ///
    /// - Parameters:
    ///   - target: The integer ID of the target object (e.g., a planet or moon).
    ///   - reference: The integer ID of the reference object (e.g., the Sun or Earth).
    ///   - time: The time for which the state vector is to be retrieved. Defaults to the current time if not provided.
    ///   - frame: The reference frame in which the state vector should be computed. Defaults to `.j2000`.
    ///   - abcorr: The aberration correction to apply. Defaults to `.none`.
    ///
    /// - Returns: A tuple containing:
    ///   - `StateVector`: A `StateVector` struct with the position (x, y, z) in km and velocity (vx, vy, vz) in km/s of the target relative to the reference.
    ///   - `Double`: The one-way light time in seconds.
    ///
    /// - Throws:
    ///   - `SPICEError.invalidTime` if the time cannot be parsed correctly.
    ///   - `SPICEError.stateUnavailable` if no data is available for the state at the given epoch.
    public static func getState(target: Int, reference: Int, time: Date = Date(), frame: ReferenceFrame = .j2000, abcorr: AberrationCorrection = .none) throws -> (StateVector, Double) {
        _ = SPICE.initialize
        
        // Convert Date to Ephemeris Time (ET)
        let epoch = try convertToEphemerisTime(time)
        
        // Allocate memory safely using Swift arrays and pointers
        var stateArray = [SpiceDouble](repeating: 0.0, count: 6)
        var ltTime: SpiceDouble = 0.0
        
        // Call SPICE's spkez_c function within safe memory boundaries
        stateArray.withUnsafeMutableBufferPointer { statePtr in
            withUnsafeMutablePointer(to: &ltTime) { ltPtr in
                spkez_c(
                    SpiceInt(target),
                    epoch,
                    frame.rawValue,
                    abcorr.rawValue,
                    SpiceInt(reference),
                    statePtr.baseAddress,
                    ltPtr
                )
            }
        }
        
        // Check for SPICE errors
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.stateUnavailable(target: target, reference: reference, epoch: epoch)
        }
        
        // Construct the StateVector from the retrieved data
        let state = StateVector(
            x: stateArray[0],
            y: stateArray[1],
            z: stateArray[2],
            vx: stateArray[3],
            vy: stateArray[4],
            vz: stateArray[5]
        )
        
        // Convert light time to Double
        let lightTime = Double(ltTime)
        
        return (state, lightTime)
    }
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific time,
    /// along with the one-way light time.
    ///
    /// - Parameters:
    ///   - target: The name of the target object (e.g., "Earth", "Mars").
    ///   - reference: The name of the reference object (e.g., "Sun", "Moon").
    ///   - time: The time for which the state vector is to be retrieved. Defaults to the current time if not provided.
    ///   - frame: The reference frame in which the state vector should be computed. Defaults to `.j2000`.
    ///   - abcorr: The aberration correction to apply. Defaults to `.none`.
    ///
    /// - Returns: A tuple containing:
    ///   - `StateVector`: A `StateVector` struct with the position (x, y, z) in km and velocity (vx, vy, vz) in km/s of the target relative to the reference.
    ///   - `Double`: The one-way light time in seconds.
    ///
    /// - Throws:
    ///   - `SPICEError.invalidObjectName` if either of the provided object names does not correspond to a valid object.
    ///   - `SPICEError.invalidTime` if the time cannot be parsed correctly.
    ///   - `SPICEError.stateUnavailable` if no data is available for the state at the given epoch.
    public static func getState(target: String, reference: String, time: Date = Date(), frame: ReferenceFrame = .j2000, abcorr: AberrationCorrection = .none) throws -> (StateVector, Double) {
        // Resolve object IDs from names
        let targetID = try getObjectID(for: target)
        let referenceID = try getObjectID(for: reference)
        
        // Delegate to the integer-based getState method
        return try getState(target: targetID, reference: referenceID, time: time, frame: frame, abcorr: abcorr)
    }
    
    /// Converts a SPICE integer ID to its corresponding celestial object name.
    /// - Parameter id: The integer ID of the celestial object (e.g., 399 for Earth).
    /// - Returns: The name of the object.
    /// - Throws: `SPICEError.invalidObjectID` if the ID cannot be converted.
    public static func getObjectName(for id: Int) throws -> String {
        var name = [CChar](repeating: 0, count: 36)
        var found: SpiceBoolean = SPICEFALSE

        bodc2n_c(SpiceInt(id), 36, &name, &found)
        
        guard found == SPICETRUE else {
            throw SPICEError.invalidObjectID(id)
        }
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.invalidObjectID(id)
        }

        return String(cString: name)
    }
    
    /// Converts a celestial object name to its corresponding SPICE integer ID.
    /// - Parameter name: The name of the celestial object (e.g., "Earth", "Mars").
    /// - Returns: The integer ID of the object.
    /// - Throws: `SPICEError.invalidObjectName` if the name cannot be converted.
    public static func getObjectID(for name: String) throws -> Int {
        var id: SpiceInt = 0
        var found: SpiceBoolean = SPICEFALSE

        let nameCStr = name.cString(using: .utf8)!
        bodn2c_c(nameCStr, &id, &found)

        guard found == SPICETRUE else {
            throw SPICEError.invalidObjectName(name)
        }
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.invalidObjectName(name)
        }

        return Int(id)
    }
    
    /// Retrieves the IDs of all objects currently loaded in kernels.
    /// - Returns: A list of integer IDs of all currently loaded objects.
    public static func getLoadedObjectIDs() -> [Int] {
        return Array(kernelMap.keys)
    }
    
    // MARK: - Private Helper Methods
    
    /// Converts a `Date` object to SPICE Ephemeris Time (ET).
    ///
    /// - Parameter date: The date to convert.
    /// - Returns: The corresponding ephemeris time as `SpiceDouble`.
    /// - Throws: `SPICEError.invalidTime` if conversion fails or if the leapseconds kernel is not loaded.
    private static func convertToEphemerisTime(_ date: Date) throws -> SpiceDouble {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMM-dd HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timeString = formatter.string(from: date)
        
        guard let timeCStr = timeString.cString(using: .utf8) else {
            throw SPICEError.invalidTime(date)
        }
        
        var et: SpiceDouble = 0.0
        str2et_c(timeCStr, &et)
        
        // Check for SPICE errors
        do {
            try checkSPICEError()
        } catch {
            throw SPICEError.invalidTime(date)
        }
        
        return et
    }
    
    /// Checks for any SPICE errors and throws a `CSPICEError.error` with the error message if any.
    ///
    /// - Throws: `CSPICEError.error` containing the SPICE error message.
    private static func checkSPICEError() throws {
        if failed_c() == SPICETRUE {
            var errorMessage = [CChar](repeating: 0, count: 256)
            
            // Retrieve the SPICE error message (SHORT)
            getmsg_c("SHORT", 255, &errorMessage)
            
            // Clear the SPICE error state
            reset_c()
            
            // Convert the CChar array to a Swift String
            let errorString = String(cString: errorMessage)
            
            throw CSPICEError.error(errorString)
        }
    }
}

fileprivate enum CSPICEError: Error {
    case error(String)
}

/// Defines custom errors related to SPICE operations.
public enum SPICEError: Error, LocalizedError {
    case kernelLoadFailed(String)
    case kernelUnloadFailed(String)
    case kernelClearFailed
    case invalidObjectID(Int)
    case invalidObjectName(String)
    case invalidTime(Date)
    case stateUnavailable(target: Int, reference: Int, epoch: Double)
    
    public var errorDescription: String? {
        switch self {
        case .kernelLoadFailed(let kernel):
            return "Failed to load kernel: \(kernel)"
        case .kernelUnloadFailed(let kernel):
            return "Failed to unload kernel: \(kernel)"
        case .kernelClearFailed:
            return "Failed to clear kernels"
        case .invalidObjectID(let id):
            return "Invalid Object ID: \(id)"
        case .invalidObjectName(let name):
            return "Invalid Object Name: \(name)"
        case .invalidTime(let date):
            return "Invalid Time: \(date) (Note: make sure a leapseconds kernel has been loaded)"
        case .stateUnavailable(let target, let reference, let epoch):
            return "Failed to get state for object ID \(target) with respect to object ID \(reference) at epoch \(epoch) (Note: make sure the appropriate kernels have been loaded)"
        }
    }
}
