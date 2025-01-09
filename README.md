# SwiftSPICE

SwiftSPICE is a Swift package to interact with the SPICE Toolkit.

https://naif.jpl.nasa.gov/naif/toolkit.html

---

## Example Usage

Import **SwiftSPICE** into your Swift file:

```
import SwiftSPICE
```

Load a kernel from the SPK file `de432s.bsp` and the leapsecond file `naif0012.tls`:

```
if let kernelURL = Bundle.main.url(forResource: "de432s", withExtension: "bsp") {
    try SPICE.loadKernel(kernelURL.path)
}
if let leapsecondURL = Bundle.main.url(forResource: "naif0012", withExtension: "tls") {
    try SPICE.loadKernel(leapsecondURL.path)
}
```

Get the current state (position and velocity vectors), and the one-way light time, of the **Earth Barycenter** relative to the **Solar System Barycenter**:

```
let (stateVector, lightTime) = try SPICE.getState(target: 3, reference: 0)
```
or
```
let (stateVector, lightTime) = try SPICE.getState(target: "Earth Barycenter", reference: "Solar System Barycenter")
```

When you're done, unload the kernels:

```
try SPICE.clearKernels()
```


