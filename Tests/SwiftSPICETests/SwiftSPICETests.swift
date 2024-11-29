import Testing
import Foundation
@testable import SwiftSPICE

@Test("Get state from SPICE")
func getStateFromSPICE() async throws {
    
    guard let kernelURL = Bundle.module.url(forResource: "sample", withExtension: "bsp") else {
        return
    }

    try SPICE.loadKernel(kernelURL.path)
    
    guard let state1 = SPICE.getState(target: 3, reference: 0) else {
        #expect(Bool(false), "state is nil")
        return
    }
    #expect(state1.positionMagnitude > 1e+8)
    #expect(state1.positionMagnitude < 2e+8)
    #expect(state1.velocityMagnitude > 28)
    #expect(state1.velocityMagnitude < 31)
    
    guard let state2 = SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter") else {
        #expect(Bool(false), "state is nil")
        return
    }
    #expect(state2.positionMagnitude > 1e+8)
    #expect(state2.positionMagnitude < 2e+8)
    #expect(state2.velocityMagnitude > 28)
    #expect(state2.velocityMagnitude < 31)
    
    let id1 = SPICE.objectID(for: "Earth Barycenter")
    let id2 = SPICE.objectID(for: "Solar System Barycenter")
    #expect(id1 == 3)
    #expect(id2 == 0)
    
    let name1 = SPICE.objectName(for: 3)
    let name2 = SPICE.objectName(for: 0)
    #expect(name1 == "EARTH BARYCENTER")
    #expect(name2 == "SOLAR SYSTEM BARYCENTER")
    
    try SPICE.clearKernels()
}


