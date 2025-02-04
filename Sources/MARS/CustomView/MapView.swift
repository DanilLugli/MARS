import SwiftUI
import ARKit
import AlertToast

@available(iOS 16.0, *)
public struct MapView: View {
    
    @StateObject private var locationProvider: PositionProvider
    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                if locationProvider.markerFounded == false{
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                }
                
                
                switch debug {
                    
                case true:
                    VStack {
                        
                        CardView(
                            buildingMap: locationProvider.building.name,
                            floorMap: locationProvider.activeFloor.name,
                            
                            roomMap: locationProvider.activeRoom.name,
                            matrixMap: locationProvider.roomMatrixActive,
                            actualPosition: locationProvider.lastFloorPosition,
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

                            VStack{
                                Image(systemName: "camera.viewfinder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .scaleEffect(scale)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true),
                                        value: scale
                                    )
                                    .onAppear {
                                        scale = 1.2
                                    }
                                
                                Text("Searching Marker...")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.top, 22)
                            }
                            
                        }
                        else{
                            
                            Spacer()
                            
                            VStack {
                                HStack {
                                    locationProvider.scnFloorView
                                        .frame(width: 380, height: 200)
                                        .cornerRadius(20)
                                        .padding(.bottom, 20)
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
            }.toast(isPresenting: $locationProvider.showMarkerFoundedToast, duration: 7.0) {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("location.fill", .green),
                    title: "Marker Found",
                    subTitle: "You have been located in \(locationProvider.activeRoom.name)"
                )
            }
        } else {
            //
        }
    }
}
