import Testing
import Foundation
@testable import SwiftSPICE

extension SerializedSuite {
    @Suite struct ErrorTests {
        
        // Test loading a kernel with an invalid path
        @Test("Load kernel with invalid path")
        func testLoadKernelInvalidPath() async throws {
            let invalidPath = "/invalid/path/to/kernel.bsp"
            
            do {
                try SPICE.loadKernel(invalidPath)
                #expect(Bool(false), "Expected SPICEError.invalidPath but no error was thrown")
            } catch SPICEError.kernelLoadFailed(let path) {
                #expect(path == invalidPath, "Incorrect path in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test retrieving state without loading leapseconds
        @Test("Get state without loading leapseconds")
        func testGetStateNoLeapseconds() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            
            let date = Date.now
            
            do {
                _ = try SPICE.getState(target: 3, reference: 0, time: date)
                #expect(Bool(false), "Expected SPICEError.invalidTime but no error was thrown")
            } catch SPICEError.invalidTime(let date) {
                #expect(date == date, "Incorrect date in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test retrieving object ID with an invalid name
        @Test("Get object ID with invalid name")
        func testGetObjectIDInvalidName() async throws {
            let invalidName = "NonexistentObject"
            
            do {
                _ = try SPICE.getObjectID(for: invalidName)
                #expect(Bool(false), "Expected SPICEError.invalidObjectName but no error was thrown")
            } catch SPICEError.invalidObjectName(let name) {
                #expect(name == invalidName, "Incorrect object name in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
        }
        
        // Test retrieving object name with an invalid ID
        @Test("Get object name with invalid ID")
        func testGetObjectNameInvalidID() async throws {
            let invalidID = 101
            
            do {
                _ = try SPICE.getObjectName(for: invalidID)
                #expect(Bool(false), "Expected SPICEError.invalidObjectID but no error was thrown")
            } catch SPICEError.invalidObjectID(let id) {
                #expect(id == invalidID, "Incorrect object ID in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
        }
        
        // Test clearing kernels when no kernels are loaded
        @Test("Clear kernels with no kernels loaded")
        func testClearKernelsNoKernels() async throws {
            do {
                try SPICE.clearKernels()
                #expect(SPICE.getLoadedObjectIDs().isEmpty, "No kernels should be loaded")
            } catch {
                #expect(Bool(false), "Unexpected error when clearing kernels")
            }
        }
        
        // Test unloading a kernel that is not loaded
        @Test("Unload kernel that is not loaded")
        func testUnloadKernelNotLoaded() async throws {
            let kernelPath = "/path/to/nonexistent/kernel.bsp"
            
            do {
                try SPICE.unloadKernel(kernelPath)
                #expect(Bool(false), "Expected SPICEError.kernelUnloadFailed but no error was thrown")
            } catch SPICEError.kernelUnloadFailed(let path) {
                #expect(path == kernelPath, "Incorrect kernel path in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
        }
        
        // Test retrieving state when no kernel is loaded
        @Test("Get state with no kernel loaded")
        func testGetStateNoKernelLoaded() async throws {
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(leapsecondsURL.path)
            
            do {
                _ = try SPICE.getState(target: 3, reference: 0)
                #expect(Bool(false), "Expected SPICEError.stateUnavailable but no error was thrown")
            } catch SPICEError.stateUnavailable(let target, let reference, _) {
                #expect(target == 3, "Incorrect target ID in error message")
                #expect(reference == 0, "Incorrect reference ID in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test retrieving state with a valid kernel but missing data for the target
        @Test("Get state with missing target data")
        func testGetStateMissingTargetData() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            let invalidTargetID = 101
            
            do {
                _ = try SPICE.getState(target: invalidTargetID, reference: 0)
                #expect(Bool(false), "Expected SPICEError.stateUnavailable but no error was thrown")
            } catch SPICEError.stateUnavailable(let target, let reference, _) {
                #expect(target == invalidTargetID, "Incorrect target ID in error message")
                #expect(reference == 0, "Incorrect reference ID in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test retrieving state with a valid kernel but missing data for the reference
        @Test("Get state with missing reference data")
        func testGetStateMissingReferenceData() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            let invalidReferenceID = 101
            
            do {
                _ = try SPICE.getState(target: 3, reference: invalidReferenceID)
                #expect(Bool(false), "Expected SPICEError.stateUnavailable but no error was thrown")
            } catch SPICEError.stateUnavailable(let target, let reference, _) {
                #expect(target == 3, "Incorrect target ID in error message")
                #expect(reference == invalidReferenceID, "Incorrect reference ID in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test retrieving state at an unsupported epoch
        @Test("Get state at unsupported epoch")
        func testGetStateUnsupportedEpoch() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            let unsupportedDate = Date(timeIntervalSince1970: 1e10)
            
            do {
                _ = try SPICE.getState(target: 3, reference: 0, time: unsupportedDate)
                #expect(Bool(false), "Expected SPICEError.stateUnavailable but no error was thrown")
            } catch SPICEError.stateUnavailable(let target, let reference, _) {
                #expect(target == 3, "Incorrect target ID in error message")
                #expect(reference == 0, "Incorrect reference ID in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            try SPICE.clearKernels()
        }
        
        // Test loading the same kernel twice
        @Test("Load the same kernel twice")
        func testLoadSameKernelTwice() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            
            do {
                try SPICE.loadKernel(kernelURL.path) // Load the same kernel again
                #expect(Bool(false), "Expected SPICEError.kernelLoadFailed but no error was thrown")
            } catch SPICEError.kernelLoadFailed(let path) {
                #expect(path == kernelURL.path, "Incorrect kernel path in error message")
            } catch {
                #expect(Bool(false), "Unexpected error type")
            }
            
            #expect(SPICE.getLoadedObjectIDs().count > 0, "No objects loaded after loading the kernel twice")
            
            try SPICE.clearKernels()
            #expect(SPICE.getLoadedObjectIDs().isEmpty, "Kernels were not cleared properly")
        }
        
    }
}
