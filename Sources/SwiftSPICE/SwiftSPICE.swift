import CSPICE
import Foundation

public func spice() {
    let epochTDBjd: SpiceDouble = 2460639.0
    let epochJ2000: SpiceDouble = 2451545.0
    let msPerDay: SpiceDouble = 86400000.0
    
    let msSinceJ2K = ((epochTDBjd - epochJ2000) * msPerDay).rounded()
    let secSinceJ2K = msSinceJ2K * 0.001

    let ptrToState = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 48)
    let ptrToLtTime = UnsafeMutablePointer<SpiceDouble>.allocate(capacity: 8)

    defer {
        ptrToState.deinitialize(count: 6)
        ptrToState.deallocate()

        ptrToLtTime.deinitialize(count: 1)
        ptrToLtTime.deallocate()
    }
    
    if let fileURL = Bundle.module.url(forResource: "de432s", withExtension: "bsp") {
        furnsh_c(fileURL.path)
    } else {
        print("File not found")
    }

    // Call the CSPICE function to get the state vector and light time
    spkezr_c("Moon", secSinceJ2K, "J2000", "None", "Earth", ptrToState, ptrToLtTime)

    print("Position: \(ptrToState[0]), \(ptrToState[1]), \(ptrToState[2])")
    print("Velocity: \(ptrToState[3]), \(ptrToState[4]), \(ptrToState[5])")
}
