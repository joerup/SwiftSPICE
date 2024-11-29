//
//  SPICE.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import CSPICE
import CSPICEExtensions
import Foundation

public struct SPICE {
    
    private static var kernels: Set<String> = []
    private static var kernelMap: [Int: String] = [0 : "default"]
    
    /// Loads a SPICE kernel into the system.
    /// - Parameter filePath: The full path to the kernel file.
    /// - Throws: An error if the kernel cannot be loaded.
    public static func loadKernel(_ filePath: String) throws {
        let filePathCString = filePath.cString(using: .utf8)
        
        // Ensure the file path is valid
        guard let path = filePathCString else {
            throw SPICEError.invalidPath(filePath)
        }
        
        // Store the kernel path
        kernels.insert(filePath)
        
        // Load the kernel
        furnsh_c(path)
        
        // Fetch object IDs from the kernel
        var ids = [Int32](repeating: 0, count: 100)
        var count: Int32 = 0
        
        // Call the C helper function
        GetSPKObjectIDs(path, &ids, &count)
        
        // Populate the dictionary
        for i in 0..<Int(count) {
            let objectID = Int(ids[i])
            kernelMap[objectID] = filePath
        }
        
        // Check for SPICE errors
        try checkSPICEError()
        
    }
    
    /// Unloads a specific SPICE kernel from the system.
    /// - Parameter filePath: The full path to the kernel file.
    /// - Throws: An error if the kernel cannot be unloaded.
    public static func unloadKernel(_ filePath: String) throws {
        let filePathCString = filePath.cString(using: .utf8)
        
        // Ensure the file path is valid
        guard let path = filePathCString else {
            throw SPICEError.invalidPath(filePath)
        }
        
        // Remove the kernel path
        kernels.remove(filePath)
        
        // Unload the kernel
        unload_c(path)
        
        // Check for SPICE errors
        try checkSPICEError()
    }
    
    /// Clears all loaded SPICE kernels from the system.
    /// - Throws: An error if the operation fails.
    public static func clearKernels() throws {
        
        // Remove all stored kernel paths
        kernels.removeAll()
        
        // Clear all loaded kernels
        kclear_c()
        
        // Check for SPICE errors
        try checkSPICEError()
    }
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific time.
    ///
    /// - Parameters:
    ///   - target: The integer ID of the target object (e.g., a planet or moon).
    ///   - reference: The integer ID of the reference object (e.g., the Sun or Earth).
    ///   - time: The time for which the state vector is to be retrieved. Defaults to the current time if not provided.
    ///   - ref: The reference frame in which the state vector should be computed (e.g., "J2000", "ECLIPJ2000"). Defaults to "J2000".
    ///   - abcorr: The aberration correction to apply (e.g., "NONE", "LT", "LT+S"). Defaults to "NONE".
    ///
    /// - Returns: A `StateVector` struct containing the position (x, y, z) and velocity (vx, vy, vz) of the target relative to the reference,
    ///   or `nil` if the state cannot be computed.
    ///
    public static func getState(target: Int, reference: Int, time: Date = Date(), ref: String = "J2000", abcorr: String = "NONE") -> StateVector? {
        
        let epoch = time.timeIntervalSince(.j2000)
        
        guard let targetFile = kernelMap[target], isValid(targetFile, id: target, epoch: epoch) else { return nil }
        guard let referenceFile = kernelMap[reference], isValid(referenceFile, id: reference, epoch: epoch) else { return nil }
        
        let ptrToState = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 6)
        let ptrToLtTime = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 1)
        
        defer {
            ptrToState.deinitialize(count: 6)
            ptrToState.deallocate()
            
            ptrToLtTime.deinitialize(count: 1)
            ptrToLtTime.deallocate()
        }
        
        spkez_c(SpiceInt(target), epoch, "J2000", "None", SpiceInt(reference), ptrToState, ptrToLtTime)
        
        let state = StateVector(x: ptrToState[0], y: ptrToState[1], z: ptrToState[2], vx: ptrToState[3], vy: ptrToState[4], vz: ptrToState[5])
        
        return state
    }
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific time.
    ///
    /// - Parameters:
    ///   - target: The name of the target object (e.g., "Earth", "Mars").
    ///   - reference: The name of the reference object (e.g., "Sun", "Moon").
    ///   - time: The time for which the state vector is to be retrieved. Defaults to the current time if not provided.
    ///   - ref: The reference frame in which the state vector should be computed (e.g., "J2000", "ECLIPJ2000"). Defaults to "J2000".
    ///   - abcorr: The aberration correction to apply (e.g., "NONE", "LT", "LT+S"). Defaults to "NONE".
    ///
    /// - Returns: A `StateVector` struct containing the position (x, y, z) and velocity (vx, vy, vz) of the target relative to the reference,
    ///   or `nil` if the state cannot be computed.
    ///
    public static func getState(target: String, reference: String, time: Date = Date(), ref: String = "J2000", abcorr: String = "NONE") -> StateVector? {
        guard let targetID = objectID(for: target), let referenceID = objectID(for: reference) else { return nil }
        
        return getState(target: targetID, reference: referenceID, time: time, ref: ref, abcorr: abcorr)
    }
    
    /// Converts a celestial object name to its corresponding SPICE integer ID.
    /// - Parameter name: The name of the celestial object (e.g., "Earth", "Mars").
    /// - Returns: The integer ID of the object, or `nil` if the name cannot be converted.
    public static func objectID(for name: String) -> Int? {
        var id: SpiceInt = 0
        var found: SpiceBoolean = SPICEFALSE

        bodn2c_c(name, &id, &found)

        guard found == SPICETRUE else {
            return nil
        }

        return Int(id)
    }

    /// Converts a SPICE integer ID to its corresponding celestial object name.
    /// - Parameter id: The integer ID of the celestial object (e.g., 399 for Earth).
    /// - Returns: The name of the object, or `nil` if the ID cannot be converted.
    public static func objectName(for id: Int) -> String? {
        var name = [CChar](repeating: 0, count: 36)
        var found: SpiceBoolean = SPICEFALSE

        bodc2n_c(SpiceInt(id), 36, &name, &found)
        
        guard found == SPICETRUE else {
            return nil
        }

        return String(cString: name)
    }
    
    /// Retrieves all objects currently loaded in kernels.
    /// - Returns: A list of integer IDs of all currently loaded objects.
    public static func getLoadedObjects() -> [Int] {
        return Array(kernelMap.keys)
    }

    // Helper function to check if object id is present in filePath SDK for given epoch.
    private static func isValid(_ filePath: String, id: Int, epoch: Double) -> Bool {
        if id == 0 {
            return true
        }
        
        guard let cFilename = filePath.cString(using: .utf8) else {
            return false
        }
        
        return cFilename.withUnsafeBufferPointer { bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress else {
                return false
            }
            
            // Call the C function and return the result
            let result = BeEpochInSPK(baseAddress, SpiceInt(id), epoch)
            return result == SPICETRUE
        }
    }

    // Helper function to check for SPICE errors and throw appropriate Swift errors.
    private static func checkSPICEError() throws {
        if failed_c() == SPICETRUE {
            var errorMessage = [CChar](repeating: 0, count: 256)
            
            // Retrieve the SPICE error message (SHORT)
            getmsg_c("SHORT", 255, &errorMessage)
            
            // Clear the SPICE error state
            reset_c()
            
            // Convert the CChar array to UInt8 array, as String(decoding:) expects UInt8
            let byteArray = errorMessage.compactMap { UInt8($0) }
            
            // Convert the array of bytes to a Swift String
            let errorString = String(decoding: byteArray, as: UTF8.self)

            throw SPICEError.spiceError(errorString)
        }
    }
}

/// Errors specific to the KernelManager
public enum SPICEError: Error {
    case invalidPath(String)
    case spiceError(String)
}
