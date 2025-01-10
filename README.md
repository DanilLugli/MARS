# MARS

MARS (Mapping and AR Spatial) è una libreria sviluppata in **Swift** che consente di calcolare la posizione del dispositivo all'interno di ambienti 3D. Questi ambienti sono generati con l'app **ARL Creator**, sfruttando le capacità di ARKit e tecnologie avanzate per la visualizzazione e il posizionamento.

## Caratteristiche

- Calcolo accurato della posizione del dispositivo in ambienti 3D.
- Integrazione diretta con ambienti creati con **ARL Creator**.
- Compatibilità con iOS 13 e versioni successive.
- Utilizzo delle librerie **Numerics** per elaborazioni matematiche avanzate.

## Requisiti

- **Swift 6.0** o successivo.
- iOS 13.0 o versioni successive.
- Dipendenze:
  - [swift-numerics](https://github.com/apple/swift-numerics)

## Installazione

Per aggiungere MARS al tuo progetto, utilizza **Swift Package Manager (SPM)**. Aggiungi questa dipendenza al file `Package.swift` del tuo progetto:

```swift
dependencies: [
    .package(url: "https://github.com/DanilLugli/MARS.git", .upToNextMajor(from: "1.0.0"))
]