import Testing
import Foundation
@testable import SwiftSPICE

@Suite(.serialized) struct SerializedSuite {}

extension SerializedSuite {
    @Suite struct BasicTests {
        
        // Basic test
        @Test("Basic test")
        func basicTest() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
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
            #expect(state1.distance > 1e+8)
            #expect(state1.distance < 2e+8)
            #expect(state1.speed > 28)
            #expect(state1.speed < 31)
            
            guard let (state2, _) = try? SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter") else {
                #expect(Bool(false), "state is nil")
                return
            }
            #expect(state2.distance > 1e+8)
            #expect(state2.distance < 2e+8)
            #expect(state2.speed > 28)
            #expect(state2.speed < 31)
            
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
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
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
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
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
            
            #expect(state.distance > 1e+8 && state.distance < 2e+8, "Position magnitude out of expected range")
            #expect(lightTime > 400, "Unexpected light time")
            
            try SPICE.clearKernels()
        }
        
        // Test kernel clearing
        @Test("Clear kernels")
        func testClearKernels() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.clearKernels()
            
            #expect(SPICE.getLoadedObjectIDs().isEmpty, "Kernels not cleared properly")
        }
        
        // Test examples from the readme
        @Test("Readme test")
        func readMeTest() async throws {
            if let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") {
                try SPICE.loadKernel(kernelURL.path)
            }
            if let leapsecondKernelURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") {
                try SPICE.loadKernel(leapsecondKernelURL.path)
            }

            var (stateVector, _) = try SPICE.getState(target: 3, reference: 0)
            (stateVector, _) = try SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")

            var date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
            (stateVector, _) = try SPICE.getState(target: 5, reference: 10, time: date)
            let _ = stateVector.distance
            
            date = Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "EDT"), year: 2024, month: 4, day: 8, hour: 14, minute: 30, second: 0))!
            (stateVector, _) = try SPICE.getState(target: "Moon", reference: "Earth", time: date)
            let _ = stateVector.speed
            
            (stateVector, _) = try SPICE.getState(target: 2, reference: 1, frame: .eclipticJ2000)
            
            (stateVector, _) = try SPICE.getState(target: "Saturn Barycenter", reference: "Sun", abcorr: .lightTime)

            try SPICE.clearKernels()

        }
    }
}

