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
            
            #expect(state.distance > 1e+8 && state.distance < 2e+8, "Position magnitude out of expected range")
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
        
        // Test examples from the readme
        @Test("Readme test")
        func readMeTest() async throws {
            if let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") {
                try SPICE.loadKernel(kernelURL.path)
            }
            if let leapsecondKernelURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") {
                try SPICE.loadKernel(leapsecondKernelURL.path)
            }
            
            var (stateVector, _) = try SPICE.getState(target: 3, reference: 0)
            (stateVector, _) = try SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")
            
            var date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
            (stateVector, _) = try SPICE.getState(target: 5, reference: 10, time: date)
            print(stateVector.distance)
            
            date = Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "EDT"), year: 2024, month: 4, day: 8, hour: 14, minute: 30, second: 0))!
            (stateVector, _) = try SPICE.getState(target: "Moon", reference: "Earth", time: date)
            print(stateVector.speed)
            
            (stateVector, _) = try SPICE.getState(target: 2, reference: 1, frame: .eclipticJ2000)
            print("\(stateVector.x) \(stateVector.y) \(stateVector.z)")
            print("\(stateVector.vx) \(stateVector.vy) \(stateVector.vz)")
            
            var lightTime: Double
            (stateVector, lightTime) = try SPICE.getState(target: "Saturn Barycenter", reference: "Sun", abcorr: .lightTime)
            print("\(stateVector) \(lightTime)")
            
            try SPICE.clearKernels()
            
        }
        
        // Test getState with epoch relative to J2000 TDB
        @Test("Get state using epoch relative to J2000 TDB")
        func testGetStateWithEpoch() async throws {
            // Define epoch relative to J2000 TDB (e.g., seconds since J2000)
            let epoch: Double = 790520686
            
            // Load necessary kernels
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp"),
                  let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Retrieve state using epoch
            guard let (state, _) = try? SPICE.getState(target: "Mars Barycenter", reference: "Solar System Barycenter", epoch: epoch) else {
                #expect(Bool(false), "Failed to retrieve state using epoch")
                return
            }
            
            // Validate state properties
            #expect(state.distance > 2e+8)
            #expect(state.distance < 3e+8)
            #expect(state.speed > 20)
            #expect(state.speed < 25)
            
            try SPICE.clearKernels()
        }
        
        // Test convertToEphemerisTime with a valid date
        @Test("Convert UTC Date to Ephemeris Time")
        func testConvertToEphemerisTime() async throws {
            // Define a valid date
            var dateComponents = DateComponents()
            dateComponents.year = 2025
            dateComponents.month = 6
            dateComponents.day = 15
            dateComponents.hour = 12
            dateComponents.minute = 0
            dateComponents.second = 0
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            guard let date = calendar.date(from: dateComponents) else {
                #expect(Bool(false), "Failed to create date")
                return
            }
            
            // Load necessary kernels
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert to ephemeris time
            let ephemerisTime: Double
            do {
                ephemerisTime = try SPICE.convertToEphemerisTime(date)
            } catch {
                #expect(Bool(false), "Conversion to ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            try SPICE.clearKernels()
            
            // Validate ephemeris time
            #expect(ephemerisTime > 86400 * (2460842 - 2451545) + 50, "Ephemeris time is too low")
            #expect(ephemerisTime < 86400 * (2460842 - 2451545) + 100, "Ephemeris time is too high")
        }
        
        // Test convertToEphemerisTime with a valid date
        @Test("Convert Eastern Date to Ephemeris Time")
        func testConvertEasternToEphemerisTime() async throws {
            // Define a valid date
            var dateComponents = DateComponents()
            dateComponents.year = 2025
            dateComponents.month = 6
            dateComponents.day = 15
            dateComponents.hour = 12
            dateComponents.minute = 0
            dateComponents.second = 0
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .init(abbreviation: "EST")!
            guard let date = calendar.date(from: dateComponents) else {
                #expect(Bool(false), "Failed to create date")
                return
            }
            
            // Load necessary kernels
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert to ephemeris time
            let ephemerisTime: Double
            do {
                ephemerisTime = try SPICE.convertToEphemerisTime(date)
            } catch {
                #expect(Bool(false), "Conversion to ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            try SPICE.clearKernels()
            
            // Validate ephemeris time
            #expect(ephemerisTime > 86400 * (2460842.1666667 - 2451545) + 50, "Ephemeris time is too low")
            #expect(ephemerisTime < 86400 * (2460842.1666667 - 2451545) + 100, "Ephemeris time is too high")
        }
        
        // Test convertFromEphemerisTime with a valid ephemeris time
        @Test("Convert Ephemeris Time to UTC Date")
        func testConvertFromEphemerisTime() async throws {
            let ephemerisTime: Double = 86400 * (2460842 - 2451545) + 70
            
            // Load necessary leapseconds kernel
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                #expect(Bool(false), "Failed to locate naif0012.tls")
                return
            }
            
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert ephemeris time to Date
            let date: Date
            do {
                date = try SPICE.convertFromEphemerisTime(ephemerisTime)
            } catch {
                #expect(Bool(false), "Conversion from ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            // Define the expected date for J2000 epoch
            var expectedDateComponents = DateComponents()
            expectedDateComponents.year = 2025
            expectedDateComponents.month = 6
            expectedDateComponents.day = 15
            expectedDateComponents.hour = 12
            expectedDateComponents.minute = 0
            expectedDateComponents.second = 0
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .init(secondsFromGMT: 0)!
            guard let expectedDate = calendar.date(from: expectedDateComponents) else {
                #expect(Bool(false), "Failed to create expected date")
                try SPICE.clearKernels()
                return
            }
            
            // Validate the converted date is equal to the expected date
            let timeDifference = abs(date.timeIntervalSince(expectedDate))
            #expect(timeDifference < 30.0, "Converted date \(date) does not match expected date \(expectedDate)")
            
            try SPICE.clearKernels()
        }
        
        // Test convertFromEphemerisTime with a valid ephemeris time
        @Test("Convert Ephemeris Time to Eastern Date")
        func testConvertEasternFromEphemerisTime() async throws {
            let ephemerisTime: Double = 86400 * (2460842.1666667 - 2451545) + 70
            
            // Load necessary leapseconds kernel
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                #expect(Bool(false), "Failed to locate naif0012.tls")
                return
            }
            
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert ephemeris time to Date
            let date: Date
            do {
                date = try SPICE.convertFromEphemerisTime(ephemerisTime)
            } catch {
                #expect(Bool(false), "Conversion from ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            // Define the expected date for J2000 epoch
            var expectedDateComponents = DateComponents()
            expectedDateComponents.year = 2025
            expectedDateComponents.month = 6
            expectedDateComponents.day = 15
            expectedDateComponents.hour = 12
            expectedDateComponents.minute = 0
            expectedDateComponents.second = 0
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .init(abbreviation: "EST")!
            guard let expectedDate = calendar.date(from: expectedDateComponents) else {
                #expect(Bool(false), "Failed to create expected date")
                try SPICE.clearKernels()
                return
            }
            
            // Validate the converted date is equal to the expected date
            let timeDifference = abs(date.timeIntervalSince(expectedDate))
            #expect(timeDifference < 30.0, "Converted date \(date) does not match expected date \(expectedDate)")
            
            try SPICE.clearKernels()
        }
        
        // Test round-trip conversion: Ephemeris Time -> Date -> Ephemeris Time
        @Test("Round-Trip Conversion between Ephemeris Time and Date")
        func testRoundTripConversion() async throws {
            // Define a valid ephemeris time
            let originalEphemerisTime: Double = 2451545.0
            
            // Load necessary leapseconds kernel
            guard let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                #expect(Bool(false), "Failed to locate naif0012.tls")
                return
            }
            
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert ephemeris time to Date
            let date: Date
            do {
                date = try SPICE.convertFromEphemerisTime(originalEphemerisTime)
            } catch {
                #expect(Bool(false), "Conversion from ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            // Convert Date back to ephemeris time
            let convertedEphemerisTime: Double
            do {
                convertedEphemerisTime = try SPICE.convertToEphemerisTime(date)
            } catch {
                #expect(Bool(false), "Conversion to ephemeris time failed with error: \(error)")
                try SPICE.clearKernels()
                return
            }
            
            // Validate the round-trip conversion
            let difference = abs(originalEphemerisTime - convertedEphemerisTime)
            #expect(difference < 1e-3, "Round-trip conversion mismatch: original ET \(originalEphemerisTime), converted ET \(convertedEphemerisTime)")
            
            try SPICE.clearKernels()
        }
        
        // Test consistency between getState using Date and getState using epoch
        @Test("Compare getState variants using Date and epoch")
        func testCompareGetStateVariants() async throws {
            // Define a specific date
            var dateComponents = DateComponents()
            dateComponents.year = 2025
            dateComponents.month = 7
            dateComponents.day = 4
            dateComponents.hour = 12
            dateComponents.minute = 0
            dateComponents.second = 0
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: dateComponents) else {
                #expect(Bool(false), "Failed to create date")
                return
            }
            
            // Load necessary kernels
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp"),
                  let leapsecondsURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondsURL.path)
            
            // Convert date to ephemeris time
            let epoch: Double
            do {
                epoch = try SPICE.convertToEphemerisTime(date)
            } catch {
                #expect(Bool(false), "Conversion to ephemeris time failed with error: \(error)")
                return
            }
            
            // Retrieve state using Date
            guard let (stateDate2, _) = try? SPICE.getState(target: 2, reference: 0, time: date) else {
                #expect(Bool(false), "Failed to retrieve state using Date")
                try SPICE.clearKernels()
                return
            }
            guard let (stateDate1, _) = try? SPICE.getState(target: "Venus Barycenter", reference: "Solar System Barycenter", time: date) else {
                #expect(Bool(false), "Failed to retrieve state using Date")
                try SPICE.clearKernels()
                return
            }
            
            // Retrieve state using epoch
            guard let (stateEpoch2, _) = try? SPICE.getState(target: 2, reference: 0, epoch: epoch) else {
                #expect(Bool(false), "Failed to retrieve state using epoch")
                try SPICE.clearKernels()
                return
            }
            guard let (stateEpoch1, _) = try? SPICE.getState(target: "Venus Barycenter", reference: "Solar System Barycenter", epoch: epoch) else {
                #expect(Bool(false), "Failed to retrieve state using epoch")
                try SPICE.clearKernels()
                return
            }
            
            // Compare the state vectors
            let distanceDifference = abs(stateDate1.distance - stateEpoch1.distance) + abs(stateDate2.distance - stateEpoch2.distance) + abs(stateDate1.distance - stateEpoch2.distance) + abs(stateDate2.distance - stateEpoch1.distance)
            let speedDifference = abs(stateDate1.speed - stateEpoch1.speed) + abs(stateDate2.speed - stateEpoch2.speed) + abs(stateDate1.speed - stateEpoch2.speed) + abs(stateDate2.speed - stateEpoch1.speed)
            
            try SPICE.clearKernels()
            
            #expect(distanceDifference < 1e-3, "Distance mismatch between variants: \(distanceDifference)")
            #expect(speedDifference < 1e-6, "Speed mismatch between variants: \(speedDifference)")
        }

        // Test getLoadedObjectIDs() returns the IDs of all loaded objects from all kernels
        @Test("Get loaded object IDs from all kernels")
        func testGetLoadedObjectIDs() async throws {
            // Ensure no kernels are loaded initially
            let initialLoadedIDs = SPICE.getLoadedObjectIDs()
            #expect(initialLoadedIDs.isEmpty, "Initially, loaded object IDs should be empty")
            
            // Load first kernel
            guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
                #expect(Bool(false), "Failed to locate sample.bsp")
                return
            }
            try SPICE.loadKernel(kernelURL.path)
            
            // Retrieve loaded object IDs
            let loadedIDs = SPICE.getLoadedObjectIDs()
            
            // Define expected IDs from both kernels
            // Replace these with actual expected IDs based on your kernel contents
            let expectedIDs: Set<Int> = [1, 2, 3, 301, 399, 4, 5, 6, 7, 8, 9, 10]
            
            // Convert loadedIDs to a Set for comparison
            let loadedIDSet = Set(loadedIDs)
            
            // Check that all expected IDs are present
            #expect(loadedIDSet.isSuperset(of: expectedIDs), "Loaded object IDs do not include all expected IDs from both kernels")
            
            // Optionally, ensure no extra IDs are loaded
            #expect(loadedIDSet == expectedIDs, "Loaded object IDs contain unexpected IDs")
            
            try SPICE.clearKernels()
        }

    }
}
