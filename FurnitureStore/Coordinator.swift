//
//  Coordinator.swift
//  FurnitureStore
//
//  Created by Atharv Patil on 8/1/22.
//

import Foundation
import RealityKit
import ARKit

class Coordinator {
    
    var arView: ARView?
    var mainScene: Experience.MainScene
    var vm: FurnitureViewModel
    
    init(vm: FurnitureViewModel) {
        self.vm = vm
        self.mainScene = try! Experience.loadMainScene()
    }
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        
        guard let arView = arView else {
            return
        }
        
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let arAnchor = ARAnchor(name: "Furniture Anchor", transform: result.worldTransform)
            
            let anchor = AnchorEntity(anchor: arAnchor)
            guard let entity = mainScene.findEntity(named: vm.selectedFurniture) else {
                return
            }
            entity.generateCollisionShapes(recursive: true)
            
            entity.position = SIMD3(0,0,0)
            
            anchor.addChild(entity)
            arView.session.add(anchor: arAnchor)
            arView.scene.addAnchor(anchor)
            arView.installGestures(.all ,for: entity as! HasCollision)
            
        }
        
    }
    
    func clearWorldMap() {
        
        guard let arView = arView else {
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "worldMap")
        userDefaults.synchronize()
        
        vm.isSaved = false
        
    }
    
    func loadWorldMap() {
        
        guard let arView = arView else {
            return
        }
        
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "worldMap") {
            
            print(data)
            
            guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                return
            }
            
            for anchor in worldMap.anchors {
                let anchorEntity = AnchorEntity(anchor: anchor)
                guard let entity = mainScene.findEntity(named: vm.selectedFurniture) else {
                    return
                }
                anchorEntity.addChild(entity)
                arView.scene.addAnchor(anchorEntity)
            }
            
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.initialWorldMap = worldMap
            configuration.planeDetection = .horizontal
            
            arView.session.run(configuration)
            
        }
        
    }
    
    func saveWorldMap() {
        
        guard let arView = arView else {
            return
        }
        
        arView.session.getCurrentWorldMap { [weak self] worldMap, error in
           
            if let error = error {
                print(error)
                return
            }
            
            if let worldMap = worldMap {
                
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true) else {
                    return
                }
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "worldMap")
                userDefaults.synchronize() // leave out synchronize, it will be saved on its own
                
                self?.vm.isSaved = true
                
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        switch frame.worldMappingStatus {
            case .notAvailable:
                vm.worldMapStatus = .notAvailable
            case .limited:
                vm.worldMapStatus = .limited
            case .extending:
                vm.worldMapStatus = .extending
            case .mapped:
                vm.worldMapStatus = .mapped
            @unknown default:
                fatalError()
        }
    }
}
