# SwiftSPICE

SwiftSPICE is a Swift package to interact with the SPICE Toolkit.

https://naif.jpl.nasa.gov/naif/toolkit.html

---

## Installation

### Swift Package Manager

You can add **SwiftSPICE** to your project using Swift Package Manager.

1. Open your project in Xcode.
2. Navigate to **File > Add Packages**.
3. Enter the package repository URL:
https://github.com/joerup/SwiftSPICE.git

Alternatively, you can add the following line to your `Package.swift` file:

```
dependencies: [
 .package(url: "https://github.com/joerup/SwiftSPICE.git", from: "1.0.0")
]
```

Then, add `SwiftSPICE` to your target's dependencies:

```
.target(
    name: "YourTarget",
    dependencies: ["SwiftSPICE"])
)
```

---

## Usage

Import **SwiftSPICE** into your Swift file:

```
import SwiftSPICE
```

Load a kernel from the SPK file `de432s.bsp`:

```
if let kernelURL = Bundle.main.url(forResource: "de432s", withExtension: "bsp") {
    try SPICE.loadKernel(kernelURL.path)
}
```

Get the current state of the **Earth Barycenter** relative to the **Solar System Barycenter**:

```
let state = SPICE.getState(target: 3, reference: 0)
let state = SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")
```

Notes:
- `state` is a `StateVector` which contains **position** and **velocity** components (access via `state.x`, `state.y`, `state.z`, `state.vx`, `state.vy`, `state.vz`).
- You can also pass a `date` parameter of type `Date` to specify a timestamp. The default is the current time.
- The `target` and `reference` objects must have ephemerides in one of the loaded SPK files at the specified time.

When you're done, unload the kernels:

```
try SPICE.clearKernels()
```


