# MARS (Multiple Augmented Reality System)

MARS is a **Swift** library designed to calculate the device's position within 3D environments. These environments are generated using the **ARL Creator** app. 

Leveraging the data created with ARL Creator, MARS uses ARWorldMap from **ARKit** to calculate the position within the 3D environment and SCNScene from  **SceneKit** to display the position on the environment map. This integration provides a seamless way to visualize and interact with augmented reality spaces.
## Features

- Accurate calculation of device position in 3D environments.
- Direct integration with environments created using **ARL Creator**.
- Compatibility with iOS 13 and later versions.
- Utilization of the **Numerics** library for advanced mathematical computations.

## Requirements

- **Swift 6.0** or later.
- iOS 13.0 or later.
- Dependencies:
  - [swift-numerics](https://github.com/apple/swift-numerics)

## Installation

To add **MARS** to your project, use **Swift Package Manager (SPM)**. Add the following dependency to your project's `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DanilLugli/MARS.git", .upToNextMajor(from: "1.0.0"))
]

## How to Use

Using MARS in your project is straightforward. Follow these steps:

1. **Import MARS and Required Libraries**  
   Add the following imports to your SwiftUI view:

   ```swift
   import SwiftUI
   import MARS
   import ARKit

2.	**Create a Basic View with MARS**
    Here’s a simplified example of how to use MARS to calculate and display the device’s position in a 3D environment:

    ```swift
    struct ContentView: View {
        @State private var locationProvider: PositionProvider? = nil
        @State private var arView = ARSCNView()

        var body: some View {
            VStack {
                if let provider = locationProvider {
                    provider.showMap()
                        .ignoresSafeArea()
                } else {
                    Button("Start Positioning") {
                        let fileManager = FileManager.default
                        let environmentDataPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("EnvironmentData")
                        locationProvider = PositionProvider(data: environmentDataPath, arSCNView: arView)
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
    }

	3.	**Run App**
     MARS will handle the positioning and visualization based on the provided environment data.
