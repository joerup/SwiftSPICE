//
//  SPICE.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import CSPICE
import Foundation

public struct SPICE {
    
    /// Loads a SPICE kernel into the system.
    /// - Parameter filePath: The full path to the kernel file.
    /// - Throws: An error if the kernel cannot be loaded.
    public static func loadKernel(_ filePath: String) throws {
        let filePathCString = filePath.cString(using: .utf8)
        
        // Ensure the file path is valid
        guard let path = filePathCString else {
            throw SPICEError.invalidPath(filePath)
        }
        
        // Load the kernel
        furnsh_c(path)
        
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
        
        // Unload the kernel
        unload_c(path)
        
        // Check for SPICE errors
        try checkSPICEError()
    }
    
    /// Clears all loaded SPICE kernels from the system.
    /// - Throws: An error if the operation fails.
    public static func clearKernels() throws {
        
        // Clear all loaded kernels
        kclear_c()
        
        // Check for SPICE errors
        try checkSPICEError()
    }
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific date.
    ///
    /// - Parameters:
    ///   - target: The integer ID of the target object (e.g., a planet or moon).
    ///   - reference: The integer ID of the reference object (e.g., the Sun or Earth).
    ///   - date: The date for which the state vector is to be retrieved. Defaults to the current date if not provided.
    ///
    /// - Returns: A `StateVector` struct containing the position (x, y, z) and velocity (vx, vy, vz) of the target relative to the reference.
    ///
    /// - Throws: Throws an error if the SPICE kernel cannot provide the state vector for the specified objects or time.
    ///
    public static func getState(target: Int, reference: Int, date: Date = Date()) -> StateVector? {
        
        let epoch = date.timeIntervalSince(.j2000)
        
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
    
    /// Retrieves the state vector (position and velocity) of a target object relative to a reference object at a specific date.
    ///
    /// - Parameters:
    ///   - target: The name of the target object (e.g., "Earth", "Mars").
    ///   - reference: The name of the reference object (e.g., "Sun", "Moon").
    ///   - date: The date for which the state vector is to be retrieved. Defaults to the current date if not provided.
    ///
    /// - Returns: A `StateVector` struct containing the position (x, y, z) and velocity (vx, vy, vz) of the target relative to the reference.
    ///
    /// - Throws: Throws an error if the SPICE kernel cannot provide the state vector for the specified objects or time.
    ///
    public static func getState(target: String, reference: String, date: Date = Date()) -> StateVector? {
        
        let epoch = date.timeIntervalSince(.j2000)
        
        let ptrToState = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 6)
        let ptrToLtTime = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 1)
        
        defer {
            ptrToState.deinitialize(count: 6)
            ptrToState.deallocate()
            
            ptrToLtTime.deinitialize(count: 1)
            ptrToLtTime.deallocate()
        }
        
        spkezr_c(target, epoch, "J2000", "NONE", reference, ptrToState, ptrToLtTime)
        
        let state = StateVector(x: ptrToState[0], y: ptrToState[1], z: ptrToState[2], vx: ptrToState[3], vy: ptrToState[4], vz: ptrToState[5])
        
        return state
    }
    
    /// Converts a celestial object name to its corresponding SPICE integer ID.
    /// - Parameter name: The name of the celestial object (e.g., "Earth", "Mars").
    /// - Returns: The integer ID of the object, or `nil` if the name cannot be converted.
    /// - Throws: An error if the conversion fails.
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
    /// - Throws: An error if the conversion fails.
    public static func objectName(for id: Int) -> String? {
        var name = [CChar](repeating: 0, count: 36)
        var found: SpiceBoolean = SPICEFALSE

        bodc2n_c(SpiceInt(id), 36, &name, &found)
        
        guard found == SPICETRUE else {
            return nil
        }

        return String(cString: name)
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
