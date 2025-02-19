import SwiftUI
import ARKit
import AlertToast

@available(iOS 16.0, *)
public struct MapView: View {
    
    @StateObject private var locationProvider: PositionProvider
    @ObservedObject private var fileHandler = FileHandler.shared 
    
    @State private var hasStarted: Bool = false
    @State private var debug: Bool = false
    
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
                
                VStack{
                    if !locationProvider.markerFounded{
                        HStack {
                            Image(systemName: "photo")
                                .bold()
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Text("Scan the Marker")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity)


                    }
                    if locationProvider.firstLocalization{
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .bold()
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Text("Re-Localization")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.top, 80)
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
                            actualPosition: locationProvider.position,
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
                    type: .systemImage("location.fill", .green),
                    title: "Marker Found",
                    subTitle: "You have been located in \(locationProvider.activeRoom.name)"
                )
            }
//            .toast(isPresenting: $fileHandler.isLoadingComplete, duration: 5.0) {
//                AlertToast(
//                    displayMode: .hud,
//                    type: .systemImage("exclamationmark.triangle", .red),
//                    title: "Error Connection",
//                    subTitle: "You have 2/more Floor but no connections."
//                )
//            }
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
