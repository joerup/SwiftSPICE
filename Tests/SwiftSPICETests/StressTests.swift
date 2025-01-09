import Testing
import Foundation
@testable import SwiftSPICE

extension SerializedSuite {
    @Suite struct StressTests {
        
        // Test full lifecycle
        @Test("Full lifecycle")
        func fullLifecycle() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
                return
            }
            guard let leapsecondURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }
            
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondURL.path)
            
            let objectIDs = SPICE.getLoadedObjectIDs()
            
            // Get the state of each object with respect to all the other objects
            let currentTime: Date = .now
            let numIterations = 100
            for _ in 0..<numIterations {
                for objectID in objectIDs {
                    for referenceID in objectIDs {
                        let _ = try SPICE.getState(target: objectID, reference: referenceID, time: currentTime)
                    }
                }
            }
            
            // Get the state of each object at a distant (out of range) timestamp
            let futureTime: Date = .distantFuture
            for objectID in objectIDs {
                for referenceID in objectIDs {
                    guard objectID != referenceID else { continue }
                    do {
                        let _ = try SPICE.getState(target: objectID, reference: referenceID, time: futureTime)
                        #expect(Bool(false), "Expected SPICEError.stateUnavailable but no error was thrown")
                    } catch SPICEError.stateUnavailable(let target, let reference, _) {
                        #expect(target == objectID, "Incorrect target object in error message")
                        #expect(reference == referenceID, "Incorrect reference object in error message")
                    } catch {
                        #expect(Bool(false), "Unexpected error type")
                    }
                }
            }
            
            try SPICE.clearKernels()
        }
        
        // Test high-frequency state retrievals and long duration queries
        @Test("High-Frequency State Retrievals Over Long Durations")
        func highFrequencyAndLongDuration() async throws {
            guard let kernelURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") else {
                return
            }
            guard let leapsecondURL = Bundle.module.url(forResource: "naif0012", withExtension: "tls") else {
                return
            }

            try SPICE.loadKernel(kernelURL.path)
            try SPICE.loadKernel(leapsecondURL.path)

            let objectIDs = SPICE.getLoadedObjectIDs()
            let startTime: Date = .now

            // Stress test: Simulate long duration
            let numDays = 365
            for i in 0..<numDays {
                let time = startTime.advanced(by: Double(i * 24 * 60 * 60)) // Advance by one day
                for objectID in objectIDs {
                    for referenceID in objectIDs where objectID != referenceID {
                        let _ = try SPICE.getState(target: objectID, reference: referenceID, time: time)
                    }
                }
            }

            // Stress test: High-frequency queries (every second for 1 hour)
            let numSeconds = 3600
            for i in 0..<numSeconds {
                let time = startTime.advanced(by: Double(i))
                for objectID in objectIDs {
                    for referenceID in objectIDs where objectID != referenceID {
                        let _ = try SPICE.getState(target: objectID, reference: referenceID, time: time)
                    }
                }
            }

            // Random kernel unload/load during execution
            try SPICE.unloadKernel(kernelURL.path)
            try SPICE.loadKernel(kernelURL.path)
            try SPICE.unloadKernel(leapsecondURL.path)
            try SPICE.loadKernel(leapsecondURL.path)

            // Final verification after stress
            let finalTime = startTime.advanced(by: Double(numDays * 24 * 60 * 60))
            for objectID in objectIDs {
                for referenceID in objectIDs where objectID != referenceID {
                    let _ = try SPICE.getState(target: objectID, reference: referenceID, time: finalTime)
                }
            }

            try SPICE.clearKernels()
        }
    }
}
