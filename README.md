# SwiftSPICE

**Swift Package Manager Compatible**

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

Then, add "SwiftSPICE" to your target's dependencies:

```
.target(
    name: "YourTarget",
    dependencies: ["SwiftSPICE"]),
```

---

## Usage

### Importing the Package

First, import **SwiftSPICE** into your Swift file:

```
import SwiftSPICE
```

### Basic Usage

Load a kernel into the system:

```
try SPICE.loadKernel("de432s.bsp")
```

Get the current state of Earth relative to the Solar System Barycenter (SSB):

```
let state = SPICE.getState(target: 3, reference: 0)
let state = SPICE.getState(target: "Earth", reference: "SSB")
```

This returns a `StateVector` which contains **position** and **velocity** components.

When you're done, unload the kernel:

```
try SPICE.unloadKernel("de432s.bsp")
```

or clear all kernels:

```
try SPICE.clearKernels()
```


