# MARS (Multiple Augmented Reality System)

MARS is a **Swift** library designed to calculate the device's position within 3D environments using ARWorldTrackingConfiguration configuration of ARKit. These environments are generated using the **ARL Creator** app.

Leveraging the data created with ARL Creator, MARS uses ARWorldMap from **ARKit** to calculate the position within the 3D environment and SCNScene from **SceneKit** to display the position on the environment map. This integration provides a seamless way to visualize and interact with augmented reality spaces.

**Link to ARL Creator Repo:** [ARL Creator GitHub Repository](https://github.com/DanilLugli/ARL_Creator)
## Features

- Calculation of device position in ARL Creator data.
- Direct integration with environments created using **ARL Creator**.
- Compatibility with iOS 13 and later versions.
- Utilization of the **Numerics** library for advanced mathematical computations.

## Requirements

- Swift 6.0 or later.
- iOS 13.0 or later.
- Dependencies:
  - [swift-numerics](https://github.com/apple/swift-numerics)

## Installation

To add **MARS** to your project, use **Swift Package Manager (SPM)**. Add the following dependency to your project's `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DanilLugli/MARS.git", .upToNextMajor(from: "1.0.0"))
]
```

## How to Use
### Data Setup for MARS

1. **Copy ARL Creator Data**  
   Manually copy the folder generated by the **ARL Creator** app from the iPhone’s file system and paste it into your project’s data folder on the target iPhone.

2. **⚠️ Single-Building Limitation**  
   Ensure you copy only the folder for the specific building where you want to localize. MARS does not yet support multi-building setups.
### MARS Setup in your project
Follow these steps:

1. **Import MARS and Required Libraries**  
Add the following imports to your SwiftUI view:

   ```swift
   import SwiftUI
   import MARS
   import ARKit
   ```
2.	**How to use MARS in your App**  
Here’s a simplified example of how to use MARS to calculate and display the device’s position in a 3D environment:

- Load the data created with **ARL Creator** directly from its directory.  
- Create an instance of `PositionProvider`, passing your `ARSCNView` and the data from **ARL Creator**.

    ```swift
    struct ContentView: View {

        @State private var locationProvider: PositionProvider? = nil
        @State private var arView = ARSCNView()

        var body: some View {
            VStack {
                if let provider = locationProvider {

                    provider.showMap()
                       
                } else {
                    Button("Start Positioning") {
                        let fileManager = FileManager.default
                        
                        let arlCreator_Data = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ARLCreator_DATA")

                        locationProvider = PositionProvider(data: arlCreator_Data, arSCNView: arView)
                    }
                }
            }
        }
    }
    ```

3.	**Run App**
MARS will manage both the positioning and visualization of the device using the data provided in `arlCreator_Data`.


## Example output