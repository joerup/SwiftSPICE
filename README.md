# SwiftSPICE

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjoerup%2FSwiftSPICE%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/joerup/SwiftSPICE)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjoerup%2FSwiftSPICE%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/joerup/SwiftSPICE)

**SwiftSPICE** is a Swift package that provides a Swift-native interface for NASA's [SPICE Toolkit](https://naif.jpl.nasa.gov/naif/toolkit.html).

The SPICE Toolkit, developed by NASA's Navigation and Ancillary Information Facility (NAIF), is widely used in space science and engineering applications. SwiftSPICE makes it easy to integrate these powerful capabilities directly into Swift-based apps and simulations.

To use **SwiftSPICE**, you'll need to load SPK (Spacecraft and Planet Kernel) files, which contain ephemeris data for celestial bodies.

---

# Setup

Add **SwiftSPICE** to your Swift project:

In your `Package.swift` file, add the following dependency:

```
dependencies: [
    .package(url: "https://github.com/joerup/SwiftSPICE.git", from: "2.0.0")
]
```

Or, add the package directly in Xcode:

- **File > Add Package Dependencies**
- Enter the URL of the **SwiftSPICE** repository: `https://github.com/joerup/SwiftSPICE.git`
- Choose the latest version and add it to your project.

---

# Usage

Import `SwiftSPICE` into a Swift file:

```
import SwiftSPICE
```

Before performing any calculations, load the necessary SPICE kernels. Load from an SPK file (e.g., `de432s.bsp`) and a leapsecond file (e.g., `naif0012.tls`):

```
if let kernelURL = Bundle.main.url(forResource: "de432s", withExtension: "bsp") {
    try SPICE.loadKernel(kernelURL.path)
}
if let leapsecondKernelURL = Bundle.main.url(forResource: "naif0012", withExtension: "tls") {
    try SPICE.loadKernel(leapsecondKernelURL.path)
}
```

Once the kernels are loaded, you can directly access SPICE functions. For example, to get the state vector (position and velocity), and the light time, of the **Earth Barycenter** (ID 3) relative to the **Solar System Barycenter** (ID 0):

```
let (stateVector, lightTime) = try SPICE.getState(target: 3, reference: 0)
// or, using names:
let (stateVector, lightTime) = try SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")
```

When you're done, unload the kernels to free up memory and avoid conflicts:

```
try SPICE.clearKernels()
```

---

# Other Examples

Calculate the distance from **Jupiter Barycenter** (ID 5) to the **Sun** (ID 10) on `2025-01-01`:

```
let date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
let (stateVector, _) = try SPICE.getState(target: 5, reference: 10, time: date)
print(stateVector.distance)
```

Find the speed of the **Moon** relative to **Earth** on `2024-04-08` at `2:30:00 PM EDT`:

```
let date = Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "EDT"), year: 2024, month: 4, day: 8, hour: 14, minute: 30, second: 0))!
let (stateVector, _) = try SPICE.getState(target: "Moon", reference: "Earth", time: date)
print(stateVector.speed)
```

Get the current XYZ position and velocity of **Venus** (ID 2) relative to **Mercury** (ID 1) in the **ecliptic frame**:

```
let (stateVector, _) = try SPICE.getState(target: 2, reference: 1, frame: .eclipticJ2000) 
print("\(stateVector.x) \(stateVector.y) \(stateVector.z)")
print("\(stateVector.vx) \(stateVector.vy) \(stateVector.vz)")
```

Get the current state and light time of the **Saturn Barycenter** relative to the **Sun** with **light time correction**:

```
let (stateVector, lightTime) = try SPICE.getState(target: "Saturn Barycenter", reference: "Sun", abcorr: .lightTime)
print("\(stateVector) \(lightTime)")
```

---

# Planetaria

SwiftSPICE was created for [Planetaria](https://planetaria.app/), an immersive Solar System simulator app that I developed. SwiftSPICE powers Planetaria’s ephemeris calculations by integrating NASA’s SPICE Toolkit into a Swift-native environment, and allows you to see planetary orbits both in real-time and in the past or future.

![Header Image](https://www.joerup.com/images/planetaria/preview1.png)


