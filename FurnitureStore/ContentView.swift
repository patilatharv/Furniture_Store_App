//
//  ContentView.swift
//  FurnitureStore
//
//  Created by Mohammad Azam on 6/7/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    
    @StateObject private var vm = FurnitureViewModel()
    let furnitures = ["sofa", "chair", "table", "armoire"]
    
    var body: some View {
        VStack {
            HStack {
                Text(vm.worldMapStatus.rawValue)
                    .font(.largeTitle)
            }.frame(maxWidth: .infinity, maxHeight: 40)
                .background(.blue)
            
            ARViewContainer(vm: vm).edgesIgnoringSafeArea(.all)
            HStack {
                Button("SAVE") {
                    vm.onSave()
                }.buttonStyle(.borderedProminent)
                
                Button("CLEAR") {
                    vm.onClear()
                }.buttonStyle(.bordered)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(furnitures, id: \.self) { name in
                        Image(name)
                            .resizable()
                            .frame(width: 75, height: 75)
                            .border(.white, width: vm.selectedFurniture == name ? 1.0: 0.0)
                            .onTapGesture {
                                vm.selectedFurniture = name
                            }
                    }
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let vm: FurnitureViewModel
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        session.run(config)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped)))
        context.coordinator.arView = arView
        arView.addCoachingOverlay()
        
        vm.onSave = {
            context.coordinator.saveWorldMap()
        }
        
        vm.onClear = {
            context.coordinator.clearWorldMap()
        }
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm: vm)
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
