{\rtf1\ansi\ansicpg1252\cocoartf2818
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # MARS\
\
MARS (Mapping and AR Spatial) \'e8 una libreria sviluppata in **Swift** che consente di calcolare la posizione del dispositivo all'interno di ambienti 3D. Questi ambienti sono generati con l'app **ARL Creator**, sfruttando le capacit\'e0 di ARKit e tecnologie avanzate per la visualizzazione e il posizionamento.\
\
## Caratteristiche\
\
- Calcolo accurato della posizione del dispositivo in ambienti 3D.\
- Integrazione diretta con ambienti creati con **ARL Creator**.\
- Compatibilit\'e0 con iOS 13 e versioni successive.\
- Utilizzo delle librerie **Numerics** per elaborazioni matematiche avanzate.\
\
## Requisiti\
\
- **Swift 6.0** o successivo.\
- iOS 13.0 o versioni successive.\
- Dipendenze:\
  - [swift-numerics](https://github.com/apple/swift-numerics)\
\
## Installazione\
\
Per aggiungere MARS al tuo progetto, utilizza **Swift Package Manager (SPM)**. Aggiungi questa dipendenza al file `Package.swift` del tuo progetto:\
\
```swift\
dependencies: [\
    .package(url: "https://github.com/DanilLugli/MARS.git", .upToNextMajor(from: "1.0.0"))\
]}