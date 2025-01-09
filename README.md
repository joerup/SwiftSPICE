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

Calculate the distance from **Jupiter** to the **Sun** on `2025-01-01`:

```
let date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))
let (stateVector, _) = try SPICE.getState(target: "Jupiter", reference: "Sun", time: date)
let distance = stateVector.distance
```

Find the speed of the **Moon** relative to **Earth** on `2024-04-08`:

```
let date = Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 8))
let (stateVector, _) = try SPICE.getState(target: "Moon", reference: "Earth", time: date)
let speed = stateVector.speed
```

Get the current state of **Venus** relative to **Mercury** in the **ecliptic frame**:

```
let (stateVector, _) = try SPICE.getState(target: 2, reference: 1, frame: .eclipticJ2000) 
```

Get the current state of **Saturn** relative to the **Sun** with **light time correction**:
```
let (stateVector, lightTime) = try SPICE.getState(target: "Saturn", reference: "Sun", abcorr: .lightTime)
```

When you're done, unload the kernels to free up memory:

```
try SPICE.clearKernels()
```


