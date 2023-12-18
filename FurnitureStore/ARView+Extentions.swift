//
//  ARView+Extentions.swift
//  FurnitureStore
//
//  Created by Atharv Patil on 8/1/22.
//

import Foundation
import RealityKit
import ARKit

extension ARView {
    
    func addCoachingOverlay() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        
        self.addSubview(coachingOverlay)
        
    }
    
}
