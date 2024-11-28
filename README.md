# SwiftSPICE

SwiftSPICE is a Swift package to interact with the SPICE Toolkit.

https://naif.jpl.nasa.gov/naif/toolkit.html

---

## Example Usage

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
```
or
```
let state = SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")
```

Notes:
- You can specify `target` and `reference` by **name** or **id**.
- `state` is a `StateVector` which contains **position** and **velocity** components (accessed via `state.x`, `state.y`, `state.z`, `state.vx`, `state.vy`, `state.vz`).
- You can also pass a `time` parameter of type `Date` to specify a timestamp. The default is the current time.
- The `target` and `reference` objects must have ephemerides in one of the loaded SPK files at the specified time, otherwise it will return `nil`.

When you're done, unload the kernels:

```
try SPICE.clearKernels()
```


