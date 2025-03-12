import SwiftUI
import ARKit
import AlertToast

@available(iOS 16.0, *)
public struct MapView: View {
    
    @StateObject private var locationProvider: PositionProvider
    @ObservedObject private var fileHandler = FileHandler.shared 
    
    @State private var hasStarted: Bool = false
    @State private var debug: Bool = true
    
    @State private var scale: CGFloat = 1.0
    
    @State private var roomMap: SCNViewContainer = SCNViewContainer()
    
    public init(locationProvider: PositionProvider) {
        _locationProvider = StateObject(wrappedValue: locationProvider)
    }
    
    @available(iOS 16.0, *)
    public var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
            
                locationProvider.arSCNView
                
                VStack{
                    if !locationProvider.markerFounded{
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .bold()
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            
                            Text("Scan the Marker")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(Color.blue.opacity(0.6))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.top, 110)
                        .frame(maxWidth: .infinity)
                    }
                    if locationProvider.firstLocalization{
                        HStack {
                            Image(systemName: "figure.walk")
                                .bold()
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            
                            Text("Re-Localization")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(Color.red.opacity(0.6))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.top, 110)
                        .frame(maxWidth: .infinity)
                        
                        }
                    Spacer()
                }
                
                switch debug {
                    
                case true:
                    VStack {
                        
                        CardView(
                            buildingMap: locationProvider.building.name,
                            floorMap: locationProvider.activeFloor.name,
                    
                            roomMap: locationProvider.activeRoom.name,
                            matrixMap: locationProvider.roomMatrixActive,
                            actualPosition: locationProvider.currentFloorPosition,
                            trackingState: locationProvider.trackingState,
                            nodeContainedIn: locationProvider.nodeContainedIn,
                            switchingRoom: locationProvider.switchingRoom
                        )
                        .padding(.top, 60)
                        
                        Spacer()
                        
                        VStack {
                            
                            
                            HStack {
                                VStack {
                                    HStack(spacing: 0) {
                                        Text("Floor: ")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                        Text(locationProvider.activeFloor.name)
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                            .italic()
                                    }
                                    
                                    locationProvider.scnFloorView
                                        .frame(width: 185, height: 200)
                                        .cornerRadius(20)
                                        .padding(.bottom, 20)
                                }
                                
                                VStack {
                                    HStack(spacing: 0) {
                                        Text("Room: ")
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                        Text(locationProvider.activeRoom.name)
                                            .foregroundColor(.white)
                                            .bold()
                                            .font(.title2)
                                            .italic()
                                    }
                                    
                                    locationProvider.scnRoomView
                                        .frame(width: 185, height: 200)
                                        .cornerRadius(20)
                                        .padding(.bottom, 20)
                                }
                            }
                            
                            HStack {
                                Text("Debug Mode")
                                    .font(.system(size: 18))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 16)
                                Toggle("", isOn: $debug)
                                    .toggleStyle(SwitchToggleStyle())
                                    .padding([.leading, .trailing], 16)
                            }
                            .frame(width: 300, height: 60)
                            .background(Color.blue.opacity(0.4))
                            .cornerRadius(20)
                            
                        }
                        .padding(.bottom, 40)
                    }
                    
                case false:
                    VStack {
                        if locationProvider.markerFounded == false{
                            //
                        }
                        else{
                            
                            Spacer()
                            
                            VStack {
                                HStack {
                                    if !locationProvider.firstLocalization{
                                        
                                        locationProvider.scnFloorView
                                            .frame(width: 380, height: 200)
                                            .cornerRadius(20)
                                            .padding(.bottom, 10)
                                    }
                                    
                                }
                                
                                HStack {
                                    Text("Debug Mode")
                                        .font(.system(size: 18))
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding([.leading, .trailing], 16)
                                    Toggle("", isOn: $debug)
                                        .toggleStyle(SwitchToggleStyle())
                                        .padding([.leading, .trailing], 16)
                                }
                                .frame(width: 300, height: 60)
                                .background(Color.blue.opacity(0.4))
                                .cornerRadius(20)
                                
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .onAppear {
                if !hasStarted {
                    locationProvider.start()
                    hasStarted = true
                }
            }
            .onChange(of: locationProvider.activeRoom.name) {
                if let planimetry = locationProvider.activeRoom.planimetry {
                    roomMap.loadPlanimetry(scene: locationProvider.activeRoom, roomsNode: nil, borders: true, nameCaller: "")
                }
            }.toast(isPresenting: $locationProvider.showMarkerFoundedToast, duration: 5.0) {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("photo.badge.checkmark", .green),
                    title: "Marker Found",
                    subTitle: "You have been located in \(locationProvider.activeRoom.name)"
                )
            }
            .toast(isPresenting: $locationProvider.showChangeFloorToast, duration: 5.0) {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("arrow.up.arrow.down", .blue),
                    title: "Changed Floor",
                    subTitle: "You have changed floor"
                )
            }
            .toast(isPresenting: $fileHandler.isErrorMatrix, duration: 5.0) {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("exclamationmark.triangle", .red),
                    title: "Error Room Position",
                    subTitle: "There's issue with room position."
                )
            }
        } else {
            //
        }
    }
}
