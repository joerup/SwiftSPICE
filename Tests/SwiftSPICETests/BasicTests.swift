import Testing
import Foundation
@testable import SwiftSPICE

@Suite(.serialized) struct SerializedSuite {}

extension SerializedSuite {
    @Suite struct BasicTests {
        
        // Basic test
        @Test("Basic test")
        func basicTest() async throws {
            
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            guard let (state1, _) = try? SPICE.getState(target: 3, reference: 0) else {
                #expect(Bool(false), "state is nil")
                return
            }
            #expect(state1.positionMagnitude > 1e+8)
            #expect(state1.positionMagnitude < 2e+8)
            #expect(state1.velocityMagnitude > 28)
            #expect(state1.velocityMagnitude < 31)
            
            guard let (state2, _) = try? SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter") else {
                #expect(Bool(false), "state is nil")
                return
            }
            #expect(state2.positionMagnitude > 1e+8)
            #expect(state2.positionMagnitude < 2e+8)
            #expect(state2.velocityMagnitude > 28)
            #expect(state2.velocityMagnitude < 31)
            
            let id1 = try SPICE.getObjectID(for: "Earth Barycenter")
            let id2 = try SPICE.getObjectID(for: "Solar System Barycenter")
            #expect(id1 == 3)
            #expect(id2 == 0)
            
            let name1 = try SPICE.getObjectName(for: 3)
            let name2 = try SPICE.getObjectName(for: 0)
            #expect(name1 == "EARTH BARYCENTER")
            #expect(name2 == "SOLAR SYSTEM BARYCENTER")
            
            try SPICE.clearKernels()
        }
        
        // Test loading and unloading kernels
        @Test("Load and unload kernel")
        func testLoadAndUnloadKernel() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            #expect(SPICE.getLoadedObjectIDs().count > 0, "No objects loaded")
            
            try SPICE.unloadKernel(kernelURL.path)
            #expect(SPICE.getLoadedObjectIDs().isEmpty, "Objects were not unloaded")
        }
        
        // Test conversion of object name to ID and back
        @Test("Object ID and name conversion")
        func testObjectIDAndNameConversion() async throws {
            let objectName = "Earth Barycenter"
            let objectID = try SPICE.getObjectID(for: objectName)
            let retrievedName = try SPICE.getObjectName(for: objectID)
            
            #expect(objectID == 3, "Incorrect object ID")
            #expect(retrievedName == objectName.uppercased(), "Incorrect object name")
        }
        
        // Test retrieving state vector using names
        @Test("Get state using names")
        func testGetStateUsingNames() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            guard let (state, lightTime) = try? SPICE.getState(target: "Earth", reference: "Sun") else {
                #expect(Bool(false), "Failed to retrieve state")
                return
            }
            
            #expect(state.positionMagnitude > 1e+8 && state.positionMagnitude < 2e+8, "Position magnitude out of expected range")
            #expect(lightTime > 400, "Unexpected light time")
            
            try SPICE.clearKernels()
        }
        
        // Test kernel clearing
        @Test("Clear kernels")
        func testClearKernels() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.clearKernels()
            
            #expect(SPICE.getLoadedObjectIDs().isEmpty, "Kernels not cleared properly")
        }
    }
}

